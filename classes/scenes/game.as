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
		game::terrain.load(@worldFile);
		
		// Set time of day
		//timeOfDay.setTime(file.getValue("world", "time"));
	}
	
	void addPlayer(Player @player)
	{
		Console.log("Loading player '" + player.name + "'...");
		player.load(@worldFile);
	}
	
	void save()
	{
		for(int i = 0; i < game::objects.size; i++)
		{
			Serializable @object = cast<Serializable@>(@game::objects[i]);
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
		game::objects.clear();
		game::furnitures.clear();
		game::players.clear();
	}
	
	void update()
	{
		// Step Box2D
		Box2D.step(Graphics.dt);
		
		// Update all game objects
		for(int i = 0; i < game::objects.size; i++) {
			game::objects[i].update();
		}
	}
	
	void draw()
	{
		// Clear batches
		for(int i = 0; i < game::batches.size; i++) {
			game::batches[i].clear();
		}
	
		// Create translation matrix
		game::batches[SCENE].setProjectionMatrix(game::camera.getProjectionMatrix());
		
		// Draw game object into batches
		for(int i = 0; i < game::objects.size; i++) {
			game::objects[i].draw();
		}
		
		// Render scene terrain-layer to texture
		game::terrain.terrainTexture.clear();
		game::terrain.draw(TERRAIN_BACKGROUND);
		
		Shape @screen = @Shape(Rect(Vector2(-game::terrain.padding/2.0f), Vector2(Window.getSize()) + Vector2(game::terrain.padding)));
		screen.setFillTexture(@game::terrain.terrainTexture);
		screen.draw(@game::batches[BACKGROUND]);
		
		game::batches[BACKGROUND].draw();
		
		// Box2D debug draw
		if(Input.getKeyState(KEY_B)) {
			Box2D.draw(@game::batches[SCENE]);
		}
		
		// Draw scene content
		game::batches[SCENE].draw();
		
		// Draw terrain scene and foreground layer to texture
		game::terrain.terrainTexture.clear();
		game::terrain.draw(TERRAIN_SCENE);
		game::terrain.draw(TERRAIN_FOREGROUND);
		
		screen.setFillTexture(@game::terrain.terrainTexture);
		screen.draw(@game::batches[FOREGROUND]);
		
		game::terrain.drawShadows();
		
		game::batches[FOREGROUND].draw();
		
		// Draw debug text to screen
		game::debug.addVariable("FPS", ""+Graphics.FPS);
		
		// Draw remaining batches
		for(int i = FOREGROUND + 1; i < game::batches.size; i++) {
			game::batches[i].draw();
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
	scene::game.loadWorldFile(@IniFile(worldPath + "/world.ini"));
	Engine.pushScene(@scene::game);
	
	return true;
}