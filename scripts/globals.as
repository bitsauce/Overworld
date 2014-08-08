// Scenes
namespace scene
{
	MainMenu main;
	WorldSelectMenu worldSelect;
	CreateWorldMenu createWorld;
	GameScene game;
}

// Fonts
namespace font
{
	Font @large = @Font("Arial Bold", 42);
	Font @small = @Font("Arial", 12);
}

namespace game
{
	// Global arrays
	array<GameObject@> objects;
	array<Furniture@> furnitures;
	array<Player@> players;
	
	// Global objects
	TimeOfDay timeOfDay;
	Terrain terrain;
	
	Camera camera;
	ItemManager items;
	DebugTextDrawer debug;
	TextureManager textures;
	Spawner spawner;
	
	// Drawing batches
	array<Batch@> batches(LAYERS_MAX);
}