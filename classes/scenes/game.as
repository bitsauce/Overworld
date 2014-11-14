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
		for(int i = 0; i < furnitures.size; ++i)
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
		for(int i = 0; i < players.size; ++i)
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
	
	void setWorldDir(string worldDir)
	{
		// Set world directory
		this.worldDir = worldDir;
	}
	
	string getWorldDir() const
	{
		return worldDir;
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
		//Console.log("Creating terrain...");
		//@terrain = @Terrain();
		
		// Generate world
		//terrain.generate(250, 50);
		
		// Create player
		Console.log("Creating player...");
		
		Player player();
		
		player.body.setPosition(Vector2(0, Terrain.generator.getGroundHeight(0)*TILE_PX));
		
		// Give default loadout
		player.inventory.addItem(@Items[PICKAXE_IRON]);
		player.inventory.addItem(@Items[AXE_IRON]);
		
		addPlayer(@player);
	}
	
	void loadWorld(string worldDir)
	{
		// Set the world directory
		setWorldDir(worldDir);
		
		// Load terrain
		//@terrain = cast<Terrain@>(@Scripts.deserialize(worldDir + "/terrain.obj"));
		
		// Load time of day
		//@timeOfDay = cast<TimeOfDay@>(Scripts.deserialize(worldDir + "/timeOfDay.obj"));
		
		// Create global objects
		//@spawner = @Spawner();
		//@background = @Background();
		//@water = @Water();
		
		// Load all objects
		array<string> @objectFiles = @FileSystem.listFiles(worldDir + "/objects", "*.obj");
		for(int i = 0; i < objectFiles.size; ++i)
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
		//Scripts.serialize(@terrain, worldDir + "/terrain.obj");
		
		// Save time of day
		//Scripts.serialize(@timeOfDay, worldDir + "/timeOfDay.obj");
		
		// Save game objects
		FileSystem.remove(worldDir + "/objects");
		for(int i = 0; i < objects.size; ++i) {
			Scripts.serialize(cast<Serializable>(@objects[i]), worldDir + "/objects/" + i + ".obj");
		}
	}
	
	void show()
	{
		Console.log("Show game");
		
		resized(Window.getSize().x, Window.getSize().y);
		
		// Create layer batches
		for(int i = 0; i < batches.size; ++i) {
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
		//terrain.generateThread.stop();
	}
	
	void update()
	{
		// Step Box2D
		Box2D.step(Graphics.dt);
		
		Terrain.update();
		TimeOfDay.update();
		Background.update();
		Spawner.update();
		//Water.update();
		
		// Update all game objects
		for(int i = 0; i < objects.size; ++i) {
			objects[i].update();
		}
	}
	
	void draw()
	{
		// Clear batches
		for(int i = 0; i < batches.size; ++i) {
			batches[i].clear();
		}
	
		// Create translation matrix
		Matrix4 projmat = Camera.getProjectionMatrix();
		batches[SCENE].setProjectionMatrix(projmat);
		
		Background.draw(@batches[BACKGROUND]);
		//Water.draw();
		
		if(Input.getKeyState(KEY_Z)) {
			Debug.draw();
			if(Input.getKeyState(KEY_W))
				Graphics.enableWireframe();
			else
				Graphics.disableWireframe();
		}
		
		// Draw game object into batches
		for(int i = 0; i < objects.size; ++i) {
			objects[i].draw();
		}
		
		// Draw background batch
		batches[BACKGROUND].draw();
		
		// Draw terrain background
		Terrain.draw(TERRAIN_BACKGROUND, @batches[BACKGROUND]);
		
		Shadows.setProjectionMatrix(Camera.getProjectionMatrix());
		if(!(Input.getKeyState(KEY_Z) && Input.getKeyState(KEY_X)))
			Shadows.draw();
		Shadows.clear();
		
		// Draw scene content
		batches[SCENE].draw();
		// Draw terrain scene
		//terrain.draw(TERRAIN_SCENE, projmat);
		
		// Box2D debug draw
		if(Input.getKeyState(KEY_B)) {
			Box2D.draw(@batches[SCENE]);
		}
		
		// Draw terrain foreground
		//terrain.draw(TERRAIN_FOREGROUND, projmat);
		
		// Draw terrain shadows
		/*if(!Input.getKeyState(KEY_8))
		{
			Sprite @shadows = @Sprite(TextureRegion(@terrain.getShadowMap(), camera.position.x/(TILE_PX*terrain.getWidth()), (camera.position.y+Window.getSize().y)/(TILE_PX*terrain.getHeight()),
													(camera.position.x+Window.getSize().x)/(TILE_PX*terrain.getWidth()), camera.position.y/(TILE_PX*terrain.getHeight())));
			shadows.setSize(Vector2(Window.getSize()));
			shadows.draw(@batches[FOREGROUND]);
		}*/
		batches[FOREGROUND].draw();
		
		// Draw remaining batches
		for(int i = FOREGROUND + 1; i < batches.size; ++i) {
			batches[i].draw();
		}
		
		// Draw debug text to screen
		Debug.setVariable("FPS", ""+Graphics.FPS);
	}
	
	void resized(int width, int height)
	{
	}
}

bool loadGame(string worldDir)
{
	Console.log("Loading world: " + worldDir + "...");
	
	// Make sure required world files exist
	if(!FileSystem.fileExists(worldDir + "/world.ini")/* || !FileSystem.fileExists(worldPath + "/players.ini")*/)
	{
		Console.log("Loading failed (missing files)");
		return false;
	}
	
	// Load world
	scene::game.loadWorld(worldDir);
	Engine.pushScene(@scene::game);
	
	return true;
}