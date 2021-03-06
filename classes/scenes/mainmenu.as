grid<int> TITLE_TILES = {
	{ 1, 1, 1, 0, 1, 0, 1, 0, 1, 1, 1, 0, 1, 1, 0, 0, 1, 0, 0, 0, 1, 0, 1, 1, 1, 0, 1, 1, 0, 0, 1, 0, 0, 0, 1, 1, 0 },
	{ 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 0, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 0, 0, 1, 0, 1 },
	{ 1, 0, 1, 0, 1, 0, 1, 0, 1, 1, 0, 0, 1, 1, 0, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 1, 0, 0, 1, 0, 0, 0, 1, 0, 1 },
	{ 1, 1, 1, 0, 0, 1, 0, 0, 1, 1, 1, 0, 1, 0, 1, 0, 0, 1, 0, 1, 0, 0, 1, 1, 1, 0, 1, 0, 1, 0, 1, 1, 1, 0, 1, 1, 0 }
};

class MainMenu : Scene
{
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
		Button @mpBtn = @Button("Multiplayer", @Exit, null);
		Button @opBtn = @Button("Options", @Exit, null);
		Button @qtBtn = @Button("Quit", @Exit, null);
		
		spBtn.anchor = CENTER;
		mpBtn.anchor = CENTER;
		opBtn.anchor = CENTER;
		qtBtn.anchor = CENTER;
		
		spBtn.setPosition(Vector2(0.0f, -0.1f));
		mpBtn.setPosition(Vector2(0.0f,  0.0f));
		opBtn.setPosition(Vector2(0.0f,  0.1f));
		qtBtn.setPosition(Vector2(0.0f,  0.2f));
		
		uiObjects.insertLast(@spBtn);
		uiObjects.insertLast(@mpBtn);
		uiObjects.insertLast(@opBtn);
		uiObjects.insertLast(@qtBtn);
		
		Camera.lookAt(Vector2(0, -300.0f));
		Terrain.loadVisibleChunks();
		
		for(int y = 0; y < TITLE_TILES.height(); ++y)
		{
			for(int x = 0; x < TITLE_TILES.width(); ++x)
			{
				if(TITLE_TILES[x, y] == 1)
				{
					Terrain.setTile(x - 18, y - 38, LEAF_TILE);
				}
			}
		}
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
		// Update all ui objects
		for(uint i = 0; i < uiObjects.size; ++i)
		{
			uiObjects[i].update();
		}
		
		::update();
	}
	
	void draw()
	{
		// Draw all ui objects
		for(uint i = 0; i < uiObjects.size; ++i)
		{
			uiObjects[i].draw(@Layers[LAYER_GUI]);
		}
		
		::draw();
	}
}