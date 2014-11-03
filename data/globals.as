// Scenes
namespace scene
{
	MainMenu main;
	WorldSelectMenu worldSelect;
	CreateWorldMenu createWorld;
	GameScene game;
}

// Global managers
DebugManager Debug;
TerrainManager Terrain;
CameraManager Camera;
BackgroundManager Background;
TimeOfDayManager TimeOfDay;
SpawnManager Spawner;
ItemManager Items;
TextureManager Textures;
TileManager Tiles;

// Fonts
namespace font
{
	Font @large = @Font(":/PressStart2P.ttf", 20);
	Font @small = @Font(":/PressStart2P.ttf", 8);
}
