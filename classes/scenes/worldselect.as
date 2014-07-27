class WorldSelectMenu : Scene
{
	private Batch @batch = @Batch();
	private array<UiObject@> uiObjects;
	
	WorldSelectMenu()
	{
	}
	
	void show()
	{
		Console.log("WorldSelectMenu: Show");
		
		array<string> @worldFiles = @FileSystem.listFiles("saves:/Overworld/worlds/", "*");
		for(int i = 0; i < worldFiles.size; i++)
		{
			IniFile @file = @IniFile(worldFiles[i]);
			
			string worldName = file.getValue("world", "name");
			Button @button = @Button(worldName, @ButtonCallbackThis(@worldClicked), null);
			button.anchor = CENTER;
			button.setPosition(Vector2(0.0f, -0.3f + i*0.1f));
			button.setSize(Vector2(0.2f, 0.05f));
			button.userData.store(worldFiles[i]);
			uiObjects.insertLast(@button);
		}
		
		Button @createWorldButton = @Button("Create World", ButtonCallback(@showCreateWorld), null);
		createWorldButton.anchor = BOTTOM_CENTER;
		createWorldButton.setPosition(Vector2(0.0f, -0.1f));
		createWorldButton.setSize(Vector2(0.2f, 0.05f));
		uiObjects.insertLast(@createWorldButton);
	}
	
	void hide()
	{
		Console.log("WorldSelectMenu: Hide");
		
		uiObjects.clear();
	}
	
	void showCreateWorld()
	{
		Engine.pushScene(@global::createWorldMenu);
	}
	
	void worldClicked(Button @button)
	{
		string path;
		button.userData.retrieve(path);
		Console.log("Loading world: " + path + "...");
		
		// Get world file
		IniFile @worldFile = @IniFile(path);
		
		// Load terrain
		Console.log("Loading terrain...");
		global::terrain.load(@worldFile);
		
		// Load game
		loadGame(@worldFile);
	}
	
	void update()
	{
		// Update all ui objects
		for(int i = 0; i < uiObjects.size; i++) {
			uiObjects[i].update();
		}
	}
	
	void draw()
	{
		batch.clear();
		
		Shape @shape = @Shape(Rect(Vector2(0.0f), Vector2(Window.getSize())));
		shape.setFillColor(Vector4(0.5f, 0.5f, 0.8f, 1.0f));
		shape.draw(@batch);
		
		// Draw all ui objects
		for(int i = 0; i < uiObjects.size; i++) {
			uiObjects[i].draw(@batch);
		}
		
		batch.draw();
	}
}

void loadGame(IniFile @worldFile)
{
	Engine.pushScene(@global::gameScene);
	
	// Update time of day
	//global::timeOfDay.setTime(file.getValue("world", "time"));
	
	// Create background
	Background();
	
	// Create player
	Console.log("Setting up player...");
	Player player();
	
	// Move the player to his last position
	//player.body.setPosition(file.getValue("player", "position"));
	
	// Spawn in the middle of the world
	int x = 250/2;
	int y = global::terrain.gen.getGroundHeight(x);
	player.body.setPosition(Vector2(x*TILE_SIZE, y*TILE_SIZE));
	
	// Give loadout
	player.inventory.addItem(@global::items[PICKAXE_IRON]);
	player.inventory.addItem(@global::items[STONE_BLOCK], 50);
}