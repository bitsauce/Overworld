class GameScene : Scene
{
	// Game objects
	private array<GameObject@> objects;
	
	void addGameObject(GameObject @object)
	{
		objects.insertLast(@object);
	}
	
	void removeGameObject(GameObject @object)
	{
		int idx = objects.findByRef(@object);
		if(idx >= 0) {
			objects.removeAt(idx);
		}
	}
	
	// Furnitures
	private array<Furniture@> furnitures;
		
	void addFurniture(Furniture @furniture)
	{
		furnitures.insertLast(@furniture);
	}
	
	void removeFurniture(Furniture @furniture)
	{
		int idx = furnitures.findByRef(@furniture);
		if(idx >= 0) {
			furnitures.removeAt(idx);
		}
	}
	
	Furniture @getHoveredFurniture() const
	{
		for(int i = 0; i < furnitures.size; i++)
		{
			if(furnitures[i].isHovered())
				return @furnitures[i];
		}
		return null;
	}	
	
	// Players
	private array<Player@> players;
	
	void addPlayer(Player @player)
	{
		players.insertLast(@player);
	}
	
	void removePlayer(Player @player)
	{
		int idx = players.findByRef(@player);
		if(idx >= 0) {
			players.removeAt(idx);
		}
	}
	
	Player @getClosestPlayer(const Vector2 position, float &out distance = void) const
	{
		// Make sure we have players
		if(players.size == 0)
			return null;
		
		Player @player = null;
		float minDist = 0.0f;
		for(int i = 0; i < players.size; i++)
		{
			float tmpDist = (players[i].body.getCenter() - position).length();
			if(tmpDist < minDist || @player == null) {
				minDist = distance = tmpDist;
				@player = @players[i];
			}
		}
		return player;
	}
	
	// Batches
	private array<Batch@> batches(LAYERS_MAX);
	
	Batch @getBatch(const Layer layer) const
	{
		return @batches[layer];
	}
	
	// World directory
	private string worldDir;
	
	// Terrain FBO
	private Texture @terrainFbo;
	
	// Terrain
	private Terrain @terrain;
	Terrain @getTerrain() const { return @terrain; }	
	
	private TimeOfDay @timeOfDay;
	TimeOfDay @getTimeOfDay() const { return @timeOfDay; }
	
	private Camera @camera;
	Camera @getCamera() const { return @camera; }
	
	private DebugTextDrawer @debug;
	DebugTextDrawer @getDebug() const { return @debug; }
	
	private Spawner @spawner;
	Spawner @getSpawner() const { return @spawner; }
	
	private Background @background;
	Background @getBackground() const { return @background; }
	
	void setWorldDir(string worldDir)
	{
		// Set world directory
		this.worldDir = worldDir;
	}
	
	void createWorld(string worldName)
	{
		// Set the world directory
		setWorldDir("saves:/Overworld/" + worldName);
		
		// Create world file
		IniFile @worldFile = @IniFile(worldDir + "/world.ini");
		worldFile.setValue("world", "name", worldName);
		worldFile.save();
		
		// Create terrain
		Console.log("Creating terrain...");
		@terrain = @Terrain();
		
		// Generate world
		terrain.generate(250, 50);
		
		// Create global objects
		@timeOfDay = @TimeOfDay();
		@camera = @Camera();
		@debug = @DebugTextDrawer();
		@spawner = @Spawner();
		@background = @Background();
		
		// Create player
		Console.log("Creating player...");
		
		Player player();
		
		int x = 250/2;
		int y = terrain.generator.getGroundHeight(x);
		player.body.setPosition(Vector2(x*TILE_SIZE, y*TILE_SIZE));
		
		// Give default loadout
		player.inventory.addItem(@game::items[PICKAXE_IRON]);
		player.inventory.addItem(@game::items[STONE_BLOCK], 50);
		
		addPlayer(@player);
	}
	
	void loadWorld(string worldDir)
	{
		// Set the world directory
		setWorldDir(worldDir);
		
		// Load terrain
		Scripts.deserialize(@terrain, worldDir + "/terrain.obj");
		if(@terrain == null) Console.log("wat1");
		
		// Create global objects
		@timeOfDay = @TimeOfDay();
		@camera = @Camera();
		@debug = @DebugTextDrawer();
		@spawner = @Spawner();
		@background = @Background();
		
		// Load all objects
		array<string> @objectFiles = @FileSystem.listFiles(worldDir + "/objects", "*.obj");
		for(int i = 0; i < objectFiles.size; i++)
		{
			GameObject @object;
			Scripts.deserialize(@object, objectFiles[i]);
			objects.insertLast(@object);
			
			Furniture @furniture = cast<Furniture>(object);
			if(@furniture != null) addFurniture(@furniture);
				
			Player @player = cast<Player>(object);
			if(@player != null) addPlayer(@player);
		}
	}
	
	void save()
	{
		// Save terrain
		Scripts.serialize(@terrain, worldDir + "/terrain.obj");
		
		// Save game objects
		FileSystem.remove(worldDir + "/objects");
		for(int i = 0; i < objects.size; i++) {
			Scripts.serialize(@objects[i], worldDir + "/objects/" + i + ".obj");
		}
	}
	
	void show()
	{
		Console.log("Show game");
		
		resized(Window.getSize().x, Window.getSize().y);
		
		// Create layer batches
		for(int i = 0; i < batches.size; i++) {
			@batches[i] = @Batch();
		}
	}
	
	void hide()
	{
		// Do clean up here
		Console.log("Leaving game");
		save();
		objects.clear();
		furnitures.clear();
		players.clear();
	}
	
	void update()
	{
		// Step Box2D
		Box2D.step(Graphics.dt);
		
		background.update();
		
		// Update all game objects
		for(int i = 0; i < objects.size; i++) {
			objects[i].update();
		}
	}
	
	void draw()
	{
		// Clear batches
		for(int i = 0; i < batches.size; i++) {
			batches[i].clear();
		}
	
		// Create translation matrix
		batches[SCENE].setProjectionMatrix(camera.getProjectionMatrix());
		
		background.draw();
		
		// Draw game object into batches
		for(int i = 0; i < objects.size; i++) {
			objects[i].draw();
		}
		
		// Render scene terrain-layer to texture
		terrainFbo.clear();
		terrain.draw(TERRAIN_BACKGROUND, @terrainFbo);
		
		Shape @screen = @Shape(Rect(Vector2(-padding*0.5f), Vector2(Window.getSize()) + Vector2(padding)));
		screen.setFillTexture(@terrainFbo);
		screen.draw(@batches[BACKGROUND]);
		
		batches[BACKGROUND].draw();
		
		// Box2D debug draw
		if(Input.getKeyState(KEY_B)) {
			Box2D.draw(@batches[SCENE]);
		}
		
		// Draw scene content
		batches[SCENE].draw();
		
		// Draw terrain scene and foreground layer to texture
		terrainFbo.clear();
		terrain.draw(TERRAIN_SCENE, @terrainFbo);
		terrain.draw(TERRAIN_FOREGROUND, @terrainFbo);
		
		screen.setFillTexture(@terrainFbo);
		screen.draw(@batches[FOREGROUND]);
		
		shadowFbo.clear();
		shadowBatch.renderToTexture(@shadowFbo);
		screen.setFillTexture(@shadowFbo);
		screen.draw(@batches[FOREGROUND]);
		
		batches[FOREGROUND].draw();
		
		// Draw debug text to screen
		debug.setVariable("FPS", ""+Graphics.FPS);
		
		// Draw remaining batches
		for(int i = FOREGROUND + 1; i < batches.size; i++) {
			batches[i].draw();
		}
	}
	
	// Shadow shader
	Shader @shadowShader = @Shader(":/shaders/terrainshadows.vert", ":/shaders/terrainshadows.frag"); // Move to global scope
	
	// Shadow batch and texture (fbo)
	Batch @shadowBatch = @Batch(); // Move to global scope
	Texture @shadowFbo; // Move to global scope
	
	// Shadow shader uniforms
	float radius = 3.0f;
	float falloff = 3.0f;
	int shadowDownsampleLevel = 16; // must be power of two
	
	int get_padding() const
	{
		return radius*shadowDownsampleLevel*2;
	}
	
	void resized(int width, int height)
	{
		// Resize terrain FBO
		@terrainFbo = @Texture(width + padding, height + padding);
		terrainFbo.setFiltering(LINEAR);
		
		// Create downsampled shadow texture
		Vector2i resolution = Vector2i(width, height)/shadowDownsampleLevel;
		@shadowFbo = @Texture(resolution.x, resolution.y);
		shadowFbo.setFiltering(LINEAR);
		
		// Clear and update shadow batch
		shadowBatch.clear();
		shadowBatch.setShader(@shadowShader);
		Shape @downsampledRect = @Shape(Rect(0.0f, 0.0f, resolution.x, resolution.y));
		downsampledRect.draw(@shadowBatch);
		
		// Update shadow shader uniforms
		shadowShader.setUniform1f("radius", radius);
		shadowShader.setUniform1f("falloff", falloff);
		shadowShader.setUniform2f("resolution", resolution.x, resolution.y);
		shadowShader.setSampler2D("texture", @terrainFbo);
	}
}

bool loadGame(string worldDir)
{
	Console.log("Loading world: " + worldDir + "...");
	
	// Make sure required world files exist
	if(!FileSystem.fileExists(worldDir + "/world.ini")/* || !FileSystem.fileExists(worldPath + "/players.ini")*/) {
		Console.log("Loading failed (missing files)");
		return false;
	}
	
	// Load world
	scene::game.loadWorld(worldDir);
	Engine.pushScene(@scene::game);
	
	return true;
}