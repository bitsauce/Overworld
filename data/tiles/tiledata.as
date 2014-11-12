enum TileID
{
	NULL_TILE = 0,
	EMPTY_TILE,
	RESERVED_TILE,
	
	// BACKGROUND_TILES BEGIN
	WOOD_TILE,
	STONE_WALL,
	// BACKGROUND_TILES END
	
	BACKGROUND_TILES,
	
	// SCENE_TILES BEGIN
	GRASS_TILE,
	STONE_TILE,
	// SCENE_TILES END
	
	SCENE_TILES,
	
	// FOREGROUND_TILES BEGIN
	LEAF_TILE,
	// FOREGROUND_TILES END
	
	FOREGROUND_TILES,
	
	MAX_TILES
}

array<Texture@> TILE_TEXTURES = {
	@Texture(":/sprites/tiles/empty_tile.png"), // NULL_TILE
	@Texture(":/sprites/tiles/empty_tile.png"), // EMPTY_TILE
	@Texture(":/sprites/tiles/empty_tile.png"), // RESERVED_TILE
	@Texture(":/sprites/tiles/wood_tile.png"),
	@Texture(":/sprites/tiles/stone_tile.png"),
	@Texture(":/sprites/tiles/empty_tile.png"), // BACKGROUND_TILES
	@Texture(":/sprites/tiles/grass_tile.png"),
	@Texture(":/sprites/tiles/stone_tile.png"),
	@Texture(":/sprites/tiles/empty_tile.png"), // SCENE_TILES
	@Texture(":/sprites/tiles/leaf_tile.png"),
	@Texture(":/sprites/tiles/empty_tile.png"), // FOREGROUND_TILES
	@Texture(":/sprites/tiles/empty_tile.png")  // MAX_TILES
};

array<ItemID> TILE_ITEMS = {
	NULL_ITEM, // NULL_TILE
	NULL_ITEM, // EMPTY_TILE
	NULL_ITEM, // RESERVED_TILE
	WOOD_BLOCK,
	STONE_BLOCK,
	NULL_ITEM, // BACKGROUND_TILES
	GRASS_BLOCK,
	STONE_BLOCK,
	NULL_ITEM, // SCENE_TILES
	LEAF_BLOCK,
	NULL_ITEM, // FOREGROUND_TILES
	NULL_ITEM  // MAX_TILES
};

array<float> TILE_OPACITIES = {
	0.0f, // NULL_TILE
	0.0f, // EMPTY_TILE
	0.0f, // RESERVED_TILE
	0.0f,
	0.0f,
	0.0f, // BACKGROUND_TILES
	1.0f,
	1.0f,
	0.0f, // SCENE_TILES
	0.0f,
	0.0f, // FOREGROUND_TILES
	0.0f  // MAX_TILES
};