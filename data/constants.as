// Tile size
const int TILE_SIZE = 16;
const float TILE_SIZEF = TILE_SIZE;
// Tile texture coordinates
grid<float> TILE_TEXTURE_COORDS =
{
	// 1st row
	{ 0.00f, 0.75f * 2.0f/3.0f, 0.25f, 1.00f * 2.0f/3.0f }, // 0
	{ 0.25f, 0.75f * 2.0f/3.0f, 0.50f, 1.00f * 2.0f/3.0f }, // 1
	{ 0.50f, 0.75f * 2.0f/3.0f, 0.75f, 1.00f * 2.0f/3.0f }, // 2
	{ 0.75f, 0.75f * 2.0f/3.0f, 1.00f, 1.00f * 2.0f/3.0f }, // 3
	
	// 2nd row
	{ 0.00f, 0.50f * 2.0f/3.0f, 0.25f, 0.75f * 2.0f/3.0f }, // 4
	{ 0.25f, 0.50f * 2.0f/3.0f, 0.50f, 0.75f * 2.0f/3.0f }, // 5
	{ 0.50f, 0.50f * 2.0f/3.0f, 0.75f, 0.75f * 2.0f/3.0f }, // 6
	{ 0.75f, 0.50f * 2.0f/3.0f, 1.00f, 0.75f * 2.0f/3.0f }, // 7
	
	// 3rd row
	{ 0.00f, 0.25f * 2.0f/3.0f, 0.25f, 0.50f * 2.0f/3.0f }, // 8
	{ 0.25f, 0.25f * 2.0f/3.0f, 0.50f, 0.50f * 2.0f/3.0f }, // 9
	{ 0.50f, 0.25f * 2.0f/3.0f, 0.75f, 0.50f * 2.0f/3.0f }, // 10
	{ 0.75f, 0.25f * 2.0f/3.0f, 1.00f, 0.50f * 2.0f/3.0f }, // 11
	
	// 4th row
	{ 0.00f, 0.00f * 2.0f/3.0f, 0.25f, 0.25f * 2.0f/3.0f }, // 12
	{ 0.25f, 0.00f * 2.0f/3.0f, 0.50f, 0.25f * 2.0f/3.0f }, // 13
	{ 0.50f, 0.00f * 2.0f/3.0f, 0.75f, 0.25f * 2.0f/3.0f }, // 14
	{ 0.75f, 0.00f * 2.0f/3.0f, 1.00f, 0.25f * 2.0f/3.0f }, // 15
	// inner corners
	{ 0.00f, 5.0f/6.0f, 0.25f, 1.0f }, 						// 16 top-left inner-corner
	{ 0.25f, 5.0f/6.0f, 0.50f, 1.0f }, 						// 17 top-right inner-corner
	{ 0.00f, 2.0f/3.0f, 0.25f, 5.0f/6.0f },					// 18 bottom-left inner-corner
	{ 0.25f, 2.0f/3.0f, 0.50f, 5.0f/6.0f } 					// 19 bottom-right inner-corner
};

grid<int> TILE_PERM_INDICES =
{
	// Top-right quadrant
	{ 2,  3,  6,  7 },
	{ 10, 11, 6,  7 },
	{ 19, 9,  6, 16 },
	{ 10, 9,  6, 16 },
	{ 2,  1,  6,  5 },
	{ 10, 18, 6,  5 },
	{ 19, 9,  6,  5 },
	{ 10, 9,  6,  5 },
	
	// Bottom-right quadrant
	{ 10, 11, 14, 15 },
	{ 10,  9, 14, 13 },
	{ 10, 18, 17,  5 },
	{ 10, 11,  6,  7 },
	{ 10,  9, 17,  5 },
	{ 10,  9,  6, 16 },
	{ 10, 18,  6,  5 },
	{ 10,  9,  6,  5 },
	
	// Bottom-left quadrant
	{ 8,  9, 12, 13 },
	{ 8,  9,  4,  5 },
	{ 19, 9,  6, 16 },
	{ 10, 9, 14, 13 },
	{ 19, 9,  6,  5 },
	{ 10, 9, 17,  5 },
	{ 10, 9, 16, 13 },
	{ 10, 9,  6,  5 },
	
	// Top-left quadrant
	{  0,  1,  4,  5 },
	{  2,  1,  6,  5 },
	{ 10, 18, 17,  5 },
	{  8,  9,  4,  5 },
	{ 10, 18,  6,  5 },
	{ 19,  9,  6,  5 },
	{ 10,  9, 17,  5 },
	{ 10,  9,  6,  5 }
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

// Tile directions
enum Direction
{
	NORTH		= 1,
	NORTH_EAST 	= 2,
	EAST		= 4,
	SOUTH_EAST 	= 8,
	SOUTH		= 16,
	SOUTH_WEST 	= 32,
	WEST		= 64,
	NORTH_WEST 	= 128,
	NESW = NORTH | EAST | SOUTH | WEST
}