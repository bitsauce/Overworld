class WorldSelectMenu : Menu
{
	array<Button@> buttons;
	Button @createWorldButton;
	
	WorldSelectMenu()
	{
	}
	
	void show()
	{
		array<string> @worldFiles = @FileSystem.listFiles("saves:/Overworld/worlds/", "*");
		for(int i = 0; i < worldFiles.size; i++)
		{
			IniFile @file = @IniFile(worldFiles[i]);
			
			string worldName = file.getValue("world", "name");
			Button @button = @Button(worldName, @ButtonCallbackThis(@worldClicked));
			button.position.y = 100 + i*50;
			button.userData = worldFiles[i];
			buttons.insertLast(@button);
		}
		@createWorldButton = @Button("Create World", ButtonCallback(@createWorld));
		createWorldButton.position.y = Window.getSize().y-50;
	}
	
	void createWorld()
	{
		IniFile @file = @IniFile("saves:/Overworld/worlds/world_0.ini");
		file.setValue("world", "name", "New World");
		file.setValue("world", "width", "250");
		file.setValue("world", "height", "50");
		
		//global::terrain.generate(250, 50, @file);
		
		file.save();
	}
	
	void worldClicked(Button @button)
	{
		loadWorld(button.userData);
	}
	
	void draw(Batch @batch)
	{
		for(int i = 0; i < buttons.size; i++)
		{
			buttons[i].draw(@batch);
		}
		createWorldButton.draw(@batch);
	}
}

void loadWorld(string path)
{
	Console.log("Loading world: " + path + "...");
	
	popMenu();
	popMenu();
	
	// Update time of day
	//global::timeOfDay.setTime(file.getValue("world", "time"));
	
	// Create background
	Background();
	
	// Load terrain
	Console.log("Loading terrain...");
	global::terrain.load(path);
	
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