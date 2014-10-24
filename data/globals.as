// Scenes
namespace scene
{
	MainMenu main;
	WorldSelectMenu worldSelect;
	CreateWorldMenu createWorld;
	GameScene game;
}

DebugManager Debug;
TerrainManager Terrain;
CameraManager Camera;
BackgroundManager Background;
TimeOfDayManager TimeOfDay;
SpawnManager Spawner;

// Fonts
namespace font
{
	Font @large = @Font(":/PressStart2P.ttf", 20);
	Font @small = @Font(":/PressStart2P.ttf", 8);
}

namespace game
{
	// Global managers
	ItemManager items;
	TextureManager textures;
	TileManager tiles;
}