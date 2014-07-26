enum MouseState
{
	MOUSE_PRESSED = 1,
	MOUSE_HOVERED = 2
}

class MainMenu : Scene
{
	private Batch @batch = @Batch();
	private array<UiObject@> uiObjects;
	
	MainMenu()
	{
	}
	
	void show()
	{
		Console.log("MainMenu: Show");
		
		Button @singlePlayerButton = @Button("Singleplayer", @ButtonCallback(@showSinglePlayer), null);
		Button @multiPlayerButton = @Button("Multiplayer", @exit, null);
		Button @optionButton = @Button("Options", @exit, null);
		Button @quitButton = @Button("Quit", @exit, null);
		
		singlePlayerButton.setSize(Vector2(0.2f, 0.05f));
		multiPlayerButton.setSize(Vector2(0.2f, 0.05f));
		optionButton.setSize(Vector2(0.2f, 0.05f));
		quitButton.setSize(Vector2(0.2f, 0.05f));
		
		singlePlayerButton.anchor = CENTER;
		multiPlayerButton.anchor = CENTER;
		optionButton.anchor = CENTER;
		quitButton.anchor = CENTER;
		
		singlePlayerButton.setPosition(Vector2(0.0f, -0.3f));
		multiPlayerButton.setPosition(Vector2(0.0f, -0.2f));
		optionButton.setPosition(Vector2(0.0f, -0.1f));
		quitButton.setPosition(Vector2(0.0f, 0.0f));
		
		uiObjects.insertLast(@singlePlayerButton);
		uiObjects.insertLast(@multiPlayerButton);
		uiObjects.insertLast(@optionButton);
		uiObjects.insertLast(@quitButton);
	}
	
	void hide()
	{
		Console.log("MainMenu: Hide");
		
		uiObjects.clear();
	}
	
	void showSinglePlayer()
	{
		Engine.pushScene(@global::worldSelectMenu);
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