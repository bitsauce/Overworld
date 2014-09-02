enum TileID
{
	NULL_TILE = 0,
	EMPTY_TILE,
	RESERVED_TILE,
	
	// SCENE_TILES BEGIN
	GRASS_TILE,
	STONE_TILE,
	// SCENE_TILES END
	
	SCENE_TILES,
	
	// BACKGROUND_TILES BEGIN
	WOOD_TILE,
	// BACKGROUND_TILES END
	
	BACKGROUND_TILES,
	
	// FOREGROUND_TILES BEGIN
	LEAF_TILE,
	// FOREGROUND_TILES END
	
	FOREGROUND_TILES,
	
	MAX_TILES
}

array<Texture@> TILE_TEXTURES = {
	null, // NULL_TILE
	null, // EMPTY_TILE
	null, // RESERVED_TILE
	@Texture(":/sprites/tiles/grass_tile.png"),
	@Texture(":/sprites/tiles/stone_tile.png"),
	null, // SCENE_TILES
	@Texture(":/sprites/tiles/wood_tile.png"),
	null, // BACKGROUND_TILES
	@Texture(":/sprites/tiles/leaf_tile.png"),
	null, // FOREGROUND_TILES
	null  // MAX_TILES
};

array<ItemID> TILE_ITEMS = {
	NULL_ITEM, // NULL_TILE
	NULL_ITEM, // EMPTY_TILE
	NULL_ITEM, // RESERVED_TILE
	GRASS_BLOCK,
	STONE_BLOCK,
	NULL_ITEM, // SCENE_TILES
	WOOD_BLOCK,
	NULL_ITEM, // BACKGROUND_TILES
	LEAF_BLOCK,
	NULL_ITEM, // FOREGROUND_TILES
	NULL_ITEM  // MAX_TILES
};

array<float> TILE_OPACITIES = {
	0.0f, // NULL_TILE
	0.0f, // EMPTY_TILE
	0.0f, // RESERVED_TILE
	1.0f,
	1.0f,
	0.0f, // SCENE_TILES
	0.0f,
	0.0f, // BACKGROUND_TILES
	0.0f,
	0.0f, // FOREGROUND_TILES
	0.0f  // MAX_TILES
};