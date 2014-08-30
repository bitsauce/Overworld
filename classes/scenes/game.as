class GameScene : Scene
{
	private array<GameObject@> objects;
	private array<Furniture@> furnitures;
	private array<Player@> players;
	private array<Batch@> batches(LAYERS_MAX);
		
	// Game objects
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
	
	private Water @water;
	Water @getWater() const { return @water; }
	
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
		@water = @Water();
		
		// Create player
		Console.log("Creating player...");
		
		Player player();
		
		int x = 250/2;
		int y = terrain.generator.getGroundHeight(x);
		player.body.setPosition(Vector2(x*TILE_SIZE, y*TILE_SIZE));
		
		// Give default loadout
		player.inventory.addItem(@game::items[PICKAXE_IRON]);
		
		addPlayer(@player);
	}
	
	void loadWorld(string worldDir)
	{
		// Set the world directory
		setWorldDir(worldDir);
		
		// Load terrain
		@terrain = cast<Terrain@>(@Scripts.deserialize(worldDir + "/terrain.obj"));
		
		// Load time of day
		@timeOfDay = cast<TimeOfDay@>(Scripts.deserialize(worldDir + "/timeOfDay.obj"));
		
		// Create global objects
		@camera = @Camera();
		@debug = @DebugTextDrawer();
		@spawner = @Spawner();
		@background = @Background();
		@water = @Water();
		
		// Load all objects
		array<string> @objectFiles = @FileSystem.listFiles(worldDir + "/objects", "*.obj");
		for(int i = 0; i < objectFiles.size; i++)
		{
			GameObject @object = cast<GameObject>(@Scripts.deserialize(objectFiles[i]));
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
		
		// Save time of day
		Scripts.serialize(@timeOfDay, worldDir + "/timeOfDay.obj");
		
		// Save game objects
		FileSystem.remove(worldDir + "/objects");
		for(int i = 0; i < objects.size; i++) {
			Scripts.serialize(cast<Serializable>(@objects[i]), worldDir + "/objects/" + i + ".obj");
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
		
		timeOfDay.update();
		background.update();
		spawner.update();
		water.update();
		
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
		Matrix4 projmat = camera.getProjectionMatrix();
		batches[SCENE].setProjectionMatrix(projmat);
		
		background.draw();
		timeOfDay.draw();
		spawner.draw();
		water.draw();
		
		if(Input.getKeyState(KEY_Z)) {
			debug.draw();
		}
		
		// Draw game object into batches
		for(int i = 0; i < objects.size; i++) {
			objects[i].draw();
		}
		
		// Draw background batch
		batches[BACKGROUND].draw();
		
		// Draw terrain background
		terrain.draw(TERRAIN_BACKGROUND, projmat);
		
		// Draw scene content
		batches[SCENE].draw();
		
		// Draw terrain scene
		terrain.draw(TERRAIN_SCENE, projmat);
		
		// Box2D debug draw
		if(Input.getKeyState(KEY_B)) {
			Box2D.draw(@batches[SCENE]);
		}
		
		// Draw terrain foreground
		terrain.draw(TERRAIN_FOREGROUND, projmat);
		
		// Draw terrain shadows
		if(!Input.getKeyState(KEY_8))
		{
			Sprite @shadows = @Sprite(TextureRegion(@terrain.getShadowMap(), camera.position.x/(TILE_SIZE*terrain.getWidth()), (camera.position.y+Window.getSize().y)/(TILE_SIZE*terrain.getHeight()),
													(camera.position.x+Window.getSize().x)/(TILE_SIZE*terrain.getWidth()), camera.position.y/(TILE_SIZE*terrain.getHeight())));
			shadows.setSize(Vector2(Window.getSize()));
			shadows.draw(@batches[FOREGROUND]);
		}
		
		batches[FOREGROUND].draw();
		
		// Draw remaining batches
		for(int i = FOREGROUND + 1; i < batches.size; i++) {
			batches[i].draw();
		}
		
		// Draw debug text to screen
		debug.setVariable("FPS", ""+Graphics.FPS);
	}
	
	void resized(int width, int height)
	{
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