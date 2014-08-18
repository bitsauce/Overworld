// Tile size
const int TILE_SIZE = 16;

// Tile texture coordinates
grid<float> TILE_TEXTURE_COORDS =
{
	{ 0.00f, 0.75f * 2.0f/3.0f, 0.25f, 1.00f * 2.0f/3.0f }, // 0
	{ 0.25f, 0.75f * 2.0f/3.0f, 0.50f, 1.00f * 2.0f/3.0f }, // 1
	{ 0.50f, 0.75f * 2.0f/3.0f, 0.75f, 1.00f * 2.0f/3.0f }, // 2
	{ 0.75f, 0.75f * 2.0f/3.0f, 1.00f, 1.00f * 2.0f/3.0f }, // 3
	{ 0.75f, 0.50f * 2.0f/3.0f, 1.00f, 0.75f * 2.0f/3.0f }, // 4
	{ 0.75f, 0.25f * 2.0f/3.0f, 1.00f, 0.50f * 2.0f/3.0f }, // 5
	{ 0.75f, 0.00f * 2.0f/3.0f, 1.00f, 0.25f * 2.0f/3.0f }, // 6
	{ 0.50f, 0.00f * 2.0f/3.0f, 0.75f, 0.25f * 2.0f/3.0f }, // 7
	{ 0.25f, 0.00f * 2.0f/3.0f, 0.50f, 0.25f * 2.0f/3.0f }, // 8
	{ 0.00f, 0.00f * 2.0f/3.0f, 0.25f, 0.25f * 2.0f/3.0f }, // 9
	{ 0.00f, 0.25f * 2.0f/3.0f, 0.25f, 0.50f * 2.0f/3.0f }, // 10
	{ 0.00f, 0.50f * 2.0f/3.0f, 0.25f, 0.75f * 2.0f/3.0f }, // 11
	{ 0.25f, 0.25f * 2.0f/3.0f, 0.75f, 0.75f * 2.0f/3.0f }, // 12
	
	{ 0.00f, 5.0f/6.0f, 0.25f, 1.0f }, 						// top-left inner-corner
	{ 0.25f, 5.0f/6.0f, 0.50f, 1.0f }, 						// top-right inner-corner
	{ 0.25f, 2.0f/3.0f, 0.50f, 5.0f/6.0f }, 				// bottom-right inner-corner
	{ 0.00f, 2.0f/3.0f, 0.25f, 5.0f/6.0f } 					// bottom-left inner-corner
};

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