// TERRAIN CONSTANTS
const int TILE_PX = 16;
const float TILE_PXF = TILE_PX;

const int BORDER_PX = 4;
const float BORDER_PXF = BORDER_PX;

const int FULL_TILE_PX = TILE_PX + BORDER_PX*2;
const float FULL_TILE_PXF = FULL_TILE_PX;

const int QUADRANT_PX = TILE_PX * 0.5f + BORDER_PX;
const float QUADRANT_PXF = QUADRANT_PX;

const int CHUNK_SIZE = 16;
const float CHUNK_SIZEF = CHUNK_SIZE;
const int CHUNK_SIZE_PX = CHUNK_SIZE*TILE_PX;
const int CHUNK_SIZE_PXF = CHUNK_SIZEF*TILE_PXF;

const int SUPER_CHUNK_SIZE = 512;
const float SUPER_CHUNK_SIZEF = SUPER_CHUNK_SIZE;
const int SUPER_CHUNK_TILE_PX = SUPER_CHUNK_SIZE*CHUNK_SIZE;
const int SUPER_CHUNK_TILE_PXF = SUPER_CHUNK_SIZEF*CHUNK_SIZEF;
const int SUPER_CHUNK_PX = SUPER_CHUNK_SIZE*CHUNK_SIZE*TILE_PX;
const int SUPER_CHUNK_PXF = SUPER_CHUNK_SIZEF*CHUNK_SIZEF*TILE_PXF;
// Tile texture coordinates
const float TILE_U0 = 0.000f;
const float TILE_V0 = 0.000f;
const float TILE_U1 = BORDER_PXF/FULL_TILE_PXF;
const float TILE_V1 = BORDER_PXF/FULL_TILE_PXF;
const float TILE_U2 = 0.500f;
const float TILE_V2 = 0.500f;
const float TILE_U3 = (TILE_PXF + BORDER_PXF)/FULL_TILE_PXF;
const float TILE_V3 = (TILE_PXF + BORDER_PXF)/FULL_TILE_PXF;
const float TILE_U4 = 1.000f;
const float TILE_V4 = 1.000f;
grid<float> TILE_TEXTURE_COORDS =
{
	{ TILE_U0, TILE_V0, TILE_U1, TILE_V1 }, // 0
	{ TILE_U1, TILE_V0, TILE_U3, TILE_V1 }, // 1
	{ TILE_U3, TILE_V0, TILE_U4, TILE_V1 }, // 2
	{ TILE_U3, TILE_V1, TILE_U4, TILE_V3 }, // 3
	{ TILE_U3, TILE_V3, TILE_U4, TILE_V4 }, // 4
	{ TILE_U1, TILE_V3, TILE_U3, TILE_V4 }, // 5
	{ TILE_U0, TILE_V3, TILE_U1, TILE_V4 }, // 6
	{ TILE_U0, TILE_V1, TILE_U1, TILE_V3 }, // 7
	{ TILE_U1, TILE_V1, TILE_U3, TILE_V3 }  // 8
};

// INVENTORY CONSTANTS
const int INV_WIDTH = 9;
const int INV_HEIGHT = 3;

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