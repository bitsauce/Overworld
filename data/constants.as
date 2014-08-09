// Tile size
const int TILE_SIZE = 16;

// Drawing layers
enum Layer
{
	BACKGROUND,
	SCENE,
	FOREGROUND,
	GUI,
	UITEXT,
	LAYERS_MAX
}

// Terrain layers
enum TerrainLayer
{
	TERRAIN_BACKGROUND,
	TERRAIN_SCENE,
	TERRAIN_FOREGROUND,
	TERRAIN_LAYERS_MAX
}

// Directions
enum Direction
{
	NORTH		= 1,
	SOUTH		= 2,
	EAST		= 4,
	WEST		= 8,
	
	NESW = NORTH | EAST | SOUTH | WEST,
	
	NORTH_WEST 	= 16,
	NORTH_EAST 	= 32,
	SOUTH_WEST 	= 64,
	SOUTH_EAST 	= 128
}