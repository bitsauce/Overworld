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
	Font @large = @Font(":/PressStart2P.ttf", 20);
	Font @small = @Font(":/PressStart2P.ttf", 8);
}

namespace game
{
	// Global objects
	TimeOfDay @get_timeOfDay()		{ return @scene::game.getTimeOfDay(); }
	Terrain @get_terrain()			{ return @scene::game.getTerrain(); }
	Camera @get_camera()			{ return @scene::game.getCamera(); }
	DebugTextDrawer @get_debug()	{ return @scene::game.getDebug(); }
	Spawner @get_spawner()			{ return @scene::game.getSpawner(); }
	
	// Global managers
	ItemManager items;
	TextureManager textures;
	TileManager tiles;
}