class TileManager
{
	private array<Tile@> tiles(MAX_TILES);
	private bool initialized = false;
	
	void init()
	{
		// Make sure the manager is not initialized already
		if(initialized)
			return;
		
		// Add tiles
		add(GRASS_TILE, Tile(@Texture(":/sprites/tiles/grass_tile.png"), GRASS_BLOCK));
		add(STONE_TILE, Tile(@Texture(":/sprites/tiles/stone_tile.png"), GRASS_BLOCK));
		add(LEAF_TILE, Tile(@Texture(":/sprites/tiles/leaf_tile.png"), GRASS_BLOCK));
		
		// Mark as initialized
		initialized = true;
	}
	
	void add(TileID id, Tile @tile)
	{
		// Make sure the manager is not initialized
		if(initialized)
			return;
		
		// Set tile
		@tiles[id] = @tile;
	}
	
	Tile @opIndex(int idx)
	{
		// Validate index and manager state
		if(!initialized || idx < 0 || idx >= MAX_TILES)
			return null;
		return @tiles[idx];
	}
	
	TileID getByItem(ItemID item)
	{
		// Make sure the manager is initalized
		if(!initialized)
			return NULL_TILE;
		
		// Find the tile which cooresponds to the given item
		for(int i = 0; i < tiles.size; i++)
		{
			Tile @tile = @tiles[i];
			if(@tile != null && tile.item == item) {
				return TileID(i);
			}
		}
		return NULL_TILE;
	}
}