class TileManager
{
	private array<Tile@> tiles(MAX_TILES);
	private TextureAtlas @atlas;
	private bool initialized = false;
	
	void init()
	{
		// Make sure the manager is not initialized already
		if(initialized)
			return;
		
		// Add tiles
		for(int i = 0; i < MAX_TILES; ++i)
		{
			add(TileID(i));
		}
		
		// Store tile textures
		array<Texture@> textures;
		for(int i = 0; i < MAX_TILES; ++i)
		{
			textures.insertLast(@tiles[i].getTexture());
		}
		@atlas = @TextureAtlas(@textures, 0);
		
		// Mark as initialized
		initialized = true;
	}
	
	void add(TileID id)
	{
		// Make sure the manager is not initialized
		if(initialized)
			return;
		
		// Set tile
		@tiles[id] = @Tile(id);
		
		// TODO: This is a temporary hack
		BlockItem @item = cast<BlockItem@>(Items[TILE_ITEMS[id]]);
		if(@item != null)
			item.tile = id;
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
			return EMPTY_TILE;
		
		// Find the tile which cooresponds to the given item
		for(int i = 0; i < tiles.size; ++i)
		{
			Tile @tile = @tiles[i];
			if(tile.getItemID() == item)
			{
				return TileID(i);
			}
		}
		return EMPTY_TILE;
	}
	
	TextureAtlas @getAtlas()
	{
		return @atlas;
	}
	
	TextureRegion getTextureRegion(TileID tile, int i)
	{
		return atlas.get(tile, TILE_TEXTURE_COORDS[0, i], TILE_TEXTURE_COORDS[1, i], TILE_TEXTURE_COORDS[2, i], TILE_TEXTURE_COORDS[3, i]);
	}
}