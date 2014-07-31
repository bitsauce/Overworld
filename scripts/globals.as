namespace global
{
	// Global arrays
	array<GameObject@> gameObjects;
	array<Interactable@> interactables;
	array<Player@> players;
	
	// Fonts
	Font @arial12 = @Font("Arial Bold", 18);
	Font @arial8 = @Font("Arial", 8);
	
	// Drawing batches
	array<Batch@> batches(LAYERS_MAX);
	
	// Global objects
	TimeOfDay timeOfDay;
	Terrain terrain;
	
	Camera camera;
	ItemManager items;
	DebugTextDrawer debug;
	TextureManager textures;
	Spawner spawner;
	
	// Menues
	MainMenu mainMenu;
	WorldSelectMenu worldSelectMenu;
	CreateWorldMenu createWorldMenu;
	GameScene gameScene;
}