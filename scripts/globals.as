namespace global
{
	// Global arrays
	array<GameObject@> gameObjects;
	array<Interactable@> interactables;
	array<Player@> players;
	
	// Fonts
	Font @largeFont = @Font("Arial Bold", 42);
	Font @smallFont = @Font("Arial", 12);
	
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