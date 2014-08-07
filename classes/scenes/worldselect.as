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
		
		array<string> @worlds = @FileSystem.listFolders("saves:/Overworld/", "*");
		for(int i = 0; i < worlds.size; i++)
		{
			Button @button = @Button(IniFile(worlds[i] + "/world.ini").getValue("world", "name"), @ButtonCallbackThis(@worldClicked), null);
			button.anchor = CENTER;
			button.setPosition(Vector2(0.0f, -0.3f + i*0.1f));
			button.setSize(Vector2(0.2f, 0.05f));
			button.userData.store(worlds[i]);
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
		// Get world directory
		string worldPath;
		button.userData.retrieve(worldPath);
		
		// Load game
		loadGame(worldPath);
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