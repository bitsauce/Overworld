class MainMenu : Scene
{
	// Draw batch
	private Batch @batch = @Batch();
	// Ui objects
	private array<UiObject@> uiObjects;
	// Constructor
	MainMenu()
	{
	}
	
	void show()
	{
		Console.log("MainMenu: Show");
		
		// Create buttons
		Button @spBtn = @Button("Singleplayer", @ButtonCallback(@showSinglePlayer), null);
		Button @mpBtn = @Button("Multiplayer", @exit, null);
		Button @opBtn = @Button("Options", @exit, null);
		Button @qtBtn = @Button("Quit", @exit, null);
		
		spBtn.anchor = CENTER;
		mpBtn.anchor = CENTER;
		opBtn.anchor = CENTER;
		qtBtn.anchor = CENTER;
		
		spBtn.setPosition(Vector2(0.0f, -0.3f));
		mpBtn.setPosition(Vector2(0.0f, -0.2f));
		opBtn.setPosition(Vector2(0.0f, -0.1f));
		qtBtn.setPosition(Vector2(0.0f,  0.0f));
		
		uiObjects.insertLast(@spBtn);
		uiObjects.insertLast(@mpBtn);
		uiObjects.insertLast(@opBtn);
		uiObjects.insertLast(@qtBtn);
		
		Camera.lookAt(Vector2(0, -200.0f));
		Terrain.loadVisibleChunks();
	}
	
	void hide()
	{
		Console.log("MainMenu: Hide");
		
		uiObjects.clear();
	}
	
	void showSinglePlayer()
	{
		Engine.pushScene(@scene::worldSelect);
	}
	
	void update()
	{
		Terrain.update();
		
		// Update all ui objects
		for(int i = 0; i < uiObjects.size; i++)
		{
			uiObjects[i].update();
		}
	}
	
	void draw()
	{
		// Clear batch
		batch.clear();
		
		// Draw background first
		Background.draw(@batch);
		
		batch.draw();
		batch.clear();
		
		// Draw terrain
		Terrain.draw(TERRAIN_BACKGROUND, @batch);
		
		Shadows.setProjectionMatrix(Camera.getProjectionMatrix());
		Shadows.draw();
		Shadows.clear();
		
		// Draw all ui objects
		for(int i = 0; i < uiObjects.size; i++)
		{
			uiObjects[i].draw(@batch);
		}
		
		if(Input.getKeyState(KEY_Z)) {
			Debug.draw();
		}
		
		// Draw batch
		batch.draw();
	}
}