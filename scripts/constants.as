// Tile size
const int TILE_SIZE = 16;

// Tiles
enum Tile
{
	NULL_TILE = 0,
	
	// SCENE_TILES BEGIN
	GRASS_TILE,
	STONE_TILE,
	// SCENE_TILES END
	
	SCENE_TILES,
	
	// BACKGROUND_TILES BEGIN
	//TREE_TILE,
	// BACKGROUND_TILES END
	
	BACKGROUND_TILES,
	
	// FOREGROUND_TILES BEGIN
	LEAF_TILE,
	// FOREGROUND_TILES END
	
	FOREGROUND_TILES,
	
	MAX_TILES
}

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

// Texture enum
enum TextureId
{
	BERRY_BUSH_TEXTURE,
	MAX_TEXTURES
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