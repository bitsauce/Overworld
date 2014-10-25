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
			Tile @tile = @tiles[i];
			
			Batch @fbo = @Batch();
			
			Sprite @sprite1 = @Sprite(TextureRegion(null, 0.0f, 0.0f, 1.0f, 1.0f));
			Sprite @sprite2 = @Sprite(TextureRegion(null, 0.0f, 0.0f, 1.0f, 1.0f));
			Sprite @sprite3 = @Sprite(TextureRegion(null, 0.0f, 0.0f, 1.0f, 1.0f));
			Sprite @sprite4 = @Sprite(TextureRegion(null, 0.0f, 0.0f, 1.0f, 1.0f));
			
			sprite1.setSize(8, 8);
			sprite2.setSize(8, 8);
			sprite3.setSize(8, 8);
			sprite4.setSize(8, 8);
			
			// Render all permutations
			for(int j = 0; j < 32; j++)
			{
				sprite1.setRegion(TextureRegion(tile.getTexture(), TILE_TEXTURE_COORDS[0, TILE_PERM_INDICES[0, j]], TILE_TEXTURE_COORDS[1, TILE_PERM_INDICES[0, j]], TILE_TEXTURE_COORDS[2, TILE_PERM_INDICES[0, j]], TILE_TEXTURE_COORDS[3, TILE_PERM_INDICES[0, j]]));
				sprite2.setRegion(TextureRegion(tile.getTexture(), TILE_TEXTURE_COORDS[0, TILE_PERM_INDICES[1, j]], TILE_TEXTURE_COORDS[1, TILE_PERM_INDICES[1, j]], TILE_TEXTURE_COORDS[2, TILE_PERM_INDICES[1, j]], TILE_TEXTURE_COORDS[3, TILE_PERM_INDICES[1, j]]));
				sprite3.setRegion(TextureRegion(tile.getTexture(), TILE_TEXTURE_COORDS[0, TILE_PERM_INDICES[2, j]], TILE_TEXTURE_COORDS[1, TILE_PERM_INDICES[2, j]], TILE_TEXTURE_COORDS[2, TILE_PERM_INDICES[2, j]], TILE_TEXTURE_COORDS[3, TILE_PERM_INDICES[2, j]]));
				sprite4.setRegion(TextureRegion(tile.getTexture(), TILE_TEXTURE_COORDS[0, TILE_PERM_INDICES[3, j]], TILE_TEXTURE_COORDS[1, TILE_PERM_INDICES[3, j]], TILE_TEXTURE_COORDS[2, TILE_PERM_INDICES[3, j]], TILE_TEXTURE_COORDS[3, TILE_PERM_INDICES[3, j]]));

				sprite1.setPosition(16*j, 0);
				sprite2.setPosition(16*j+8, 0);
				sprite3.setPosition(16*j, 8);
				sprite4.setPosition(16*j+8, 8);
				
				sprite1.draw(@fbo);
				sprite2.draw(@fbo);
				sprite3.draw(@fbo);
				sprite4.draw(@fbo);
			}
			
			Texture @texture = @Texture(32*TILE_SIZE, TILE_SIZE);
			fbo.renderToTexture(@texture);
			textures.insertLast(@texture);
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