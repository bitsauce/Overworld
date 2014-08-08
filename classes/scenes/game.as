class GameScene : Scene
{
	IniFile @worldFile;
	
	void setWorldFile(IniFile @worldFile)
	{
		// Load config file
		@this.worldFile = @worldFile;
	}
	
	void loadWorldFile(IniFile @worldFile)
	{
		// Set the world file
		setWorldFile(@worldFile);
		
		// Load terrain
		Console.log("Loading terrain...");
		global::terrain.load(@worldFile);
		
		// Set time of day
		//global::timeOfDay.setTime(file.getValue("world", "time"));
	}
	
	void addPlayer(Player @player)
	{
		Console.log("Loading player '" + player.name + "'...");
		player.load(@worldFile);
	}
	
	void save()
	{
		for(int i = 0; i < global::gameObjects.size; i++)
		{
			Serializable @object = cast<Serializable@>(@global::gameObjects[i]);
			if(@object != null)
			{
				object.save(@worldFile);
			}
		}
	}
	
	void show()
	{
		Console.log("Show game");
		
		// Create background
		Background();
		
		// Create player
		Player player();
		addPlayer(player);
	}
	
	void hide()
	{
		// Do clean up here
		Console.log("Leaving game");
		save();
		global::gameObjects.clear();
		global::interactables.clear();
		global::players.clear();
	}
	
	void update()
	{
		// Step Box2D
		Box2D.step(Graphics.dt);
		
		// Update all game objects
		for(int i = 0; i < global::gameObjects.size; i++) {
			global::gameObjects[i].update();
		}
	}
	
	void draw()
	{
		// Clear batches
		for(int i = 0; i < global::batches.size; i++) {
			global::batches[i].clear();
		}
	
		// Create translation matrix
		global::batches[SCENE].setProjectionMatrix(global::camera.getProjectionMatrix());
		
		// Draw game object into batches
		for(int i = 0; i < global::gameObjects.size; i++) {
			global::gameObjects[i].draw();
		}
		
		// Render scene terrain-layer to texture
		global::terrain.terrainTexture.clear();
		global::terrain.draw(TERRAIN_BACKGROUND);
		
		Shape @screen = @Shape(Rect(Vector2(-global::terrain.padding/2.0f), Vector2(Window.getSize()) + Vector2(global::terrain.padding)));
		screen.setFillTexture(@global::terrain.terrainTexture);
		screen.draw(@global::batches[BACKGROUND]);
		
		global::batches[BACKGROUND].draw();
		
		// Box2D debug draw
		if(Input.getKeyState(KEY_B)) {
			Box2D.draw(@global::batches[SCENE]);
		}
		
		// Draw scene content
		global::batches[SCENE].draw();
		
		// Draw terrain scene and foreground layer to texture
		global::terrain.terrainTexture.clear();
		global::terrain.draw(TERRAIN_SCENE);
		global::terrain.draw(TERRAIN_FOREGROUND);
		
		screen.setFillTexture(@global::terrain.terrainTexture);
		screen.draw(@global::batches[FOREGROUND]);
		
		global::terrain.drawShadows();
		
		global::batches[FOREGROUND].draw();
		
		// Draw debug text to screen
		global::debug.addVariable("FPS", ""+Graphics.FPS);
		
		// Draw remaining batches
		for(int i = FOREGROUND + 1; i < global::batches.size; i++) {
			global::batches[i].draw();
		}
	}
}

bool loadGame(string worldPath)
{
	Console.log("Loading world: " + worldPath + "...");
	
	// Make sure required world files exist
	if(!FileSystem.fileExists(worldPath + "/world.ini")/* || !FileSystem.fileExists(worldPath + "/players.ini")*/) {
		Console.log("Loading failed (missing files)");
		return false;
	}
	
	// Load world
	global::gameScene.loadWorldFile(@IniFile(worldPath + "/world.ini"));
	Engine.pushScene(@global::gameScene);
	
	return true;
}