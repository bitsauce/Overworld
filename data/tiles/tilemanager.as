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
		for(int i = 0; i < MAX_TILES; i++)
		{
			add(TileID(i));
		}
		
		// Store tile textures
		array<Texture@> textures;
		for(int i = 0; i < MAX_TILES; i++)
		{
			Tile @tile = @tiles[i];
			
			Batch @fbo = @Batch();
			
			// 1nd quadrant. NORTH, NORTH_EAST, EAST
			for(int j = 0; j < 8; j++)
			{
				Sprite @sprite1 = @Sprite(TextureRegion(tile.getTexture(), TILE_TEXTURE_COORDS[0, TILE_PERM_INDEX[0, j]], TILE_TEXTURE_COORDS[1, TILE_PERM_INDEX[0, j]], TILE_TEXTURE_COORDS[2, TILE_PERM_INDEX[0, j]], TILE_TEXTURE_COORDS[3, TILE_PERM_INDEX[0, j]]));
				Sprite @sprite2 = @Sprite(TextureRegion(tile.getTexture(), TILE_TEXTURE_COORDS[0, TILE_PERM_INDEX[1, j]], TILE_TEXTURE_COORDS[1, TILE_PERM_INDEX[1, j]], TILE_TEXTURE_COORDS[2, TILE_PERM_INDEX[1, j]], TILE_TEXTURE_COORDS[3, TILE_PERM_INDEX[1, j]]));
				Sprite @sprite3 = @Sprite(TextureRegion(tile.getTexture(), TILE_TEXTURE_COORDS[0, TILE_PERM_INDEX[2, j]], TILE_TEXTURE_COORDS[1, TILE_PERM_INDEX[2, j]], TILE_TEXTURE_COORDS[2, TILE_PERM_INDEX[2, j]], TILE_TEXTURE_COORDS[3, TILE_PERM_INDEX[2, j]]));
				Sprite @sprite4 = @Sprite(TextureRegion(tile.getTexture(), TILE_TEXTURE_COORDS[0, TILE_PERM_INDEX[3, j]], TILE_TEXTURE_COORDS[1, TILE_PERM_INDEX[3, j]], TILE_TEXTURE_COORDS[2, TILE_PERM_INDEX[3, j]], TILE_TEXTURE_COORDS[3, TILE_PERM_INDEX[3, j]]));
				
				sprite1.setPosition(16*j, 0);
				sprite2.setPosition(16*j+8, 0);
				sprite3.setPosition(16*j, 8);
				sprite4.setPosition(16*j+8, 8);
				
				sprite1.draw(@fbo);
				sprite2.draw(@fbo);
				sprite3.draw(@fbo);
				sprite4.draw(@fbo);
			}
			
			// 2nd quadrant. WEST, NORTH_WEST, NORTH
			
			/*for(int i = 0; i < 32; i++)
			{
				Sprite @sprite = @Sprite(TextureRegion(tile.getTexture(), 0.0f, 0.0f, 1.0f, 1.0f));
				sprite.setPosition(Vector2(32*i, 0));
				
				TileID tile = getTileAt(x, y);
				
				// Show/Hide north ledge
				batch.get(i+1).setColor(Vector4(state & NORTH == 0 ? 1.0f : 0.0f));
				batch.get(i+2).setColor(Vector4(state & NORTH == 0 ? 1.0f : 0.0f));
				
				// Show/Hide east ledge
				batch.get(i+4).setColor(Vector4(state & EAST == 0 ? 1.0f : 0.0f));
				batch.get(i+5).setColor(Vector4(state & EAST == 0 ? 1.0f : 0.0f));
				
				// Show/Hide south ledge
				batch.get(i+7).setColor(Vector4(state & SOUTH == 0 ? 1.0f : 0.0f));
				batch.get(i+8).setColor(Vector4(state & SOUTH == 0 ? 1.0f : 0.0f));
				
				// Show/Hide west ledge
				batch.get(i+10).setColor(Vector4(state & WEST == 0 ? 1.0f : 0.0f));
				batch.get(i+11).setColor(Vector4(state & WEST == 0 ? 1.0f : 0.0f));
				
				// NW corner
				if(state & NORTH_WEST == 0)
				{
					batch.get(i+1).setRegion(game::tiles.getTextureRegion(tile, 1));
					batch.get(i+11).setRegion(game::tiles.getTextureRegion(tile, 11));
					
					// Show/Hide outer corner
					batch.get(i+0).setColor(Vector4((state & NORTH == 0 && state & WEST == 0) ? 1.0f : 0.0f));
				}else{
					batch.get(i+1).setRegion(game::tiles.getTextureRegion(tile, 16));
					batch.get(i+11).setRegion(game::tiles.getTextureRegion(tile, 14));
					
					// Hide outer corner
					batch.get(i+0).setColor(Vector4(0.0f));
				}
				
				// NE corner
				if(state & NORTH_EAST == 0)
				{
					batch.get(i+2).setRegion(game::tiles.getTextureRegion(tile, 2));
					batch.get(i+4).setRegion(game::tiles.getTextureRegion(tile, 4));
					
					// Show/Hide outer corner
					batch.get(i+3).setColor(Vector4((state & NORTH == 0 && state & EAST == 0) ? 1.0f : 0.0f));
				}else{
					batch.get(i+2).setRegion(game::tiles.getTextureRegion(tile, 15));
					batch.get(i+4).setRegion(game::tiles.getTextureRegion(tile, 13));
					
					// Hide outer corner
					batch.get(i+3).setColor(Vector4(0.0f));
				}
				
				// SE corner
				if(state & SOUTH_EAST == 0)
				{
					// Show/Hide outer corner
					batch.get(i+6).setColor(Vector4((state & SOUTH == 0 && state & EAST == 0) ? 1.0f : 0.0f));
				}else{
					// Hide outer corner
					if(state & EAST == 0) batch.get(i+5).setColor(Vector4(0.0f));
					batch.get(i+6).setColor(Vector4(0.0f));
					if(state & SOUTH == 0) batch.get(i+7).setColor(Vector4(0.0f));
				}
				
				// SW corner
				if(state & SOUTH_WEST == 0)
				{
					// Show/Hide outer corner
					batch.get(i+9).setColor(Vector4((state & SOUTH == 0 && state & WEST == 0) ? 1.0f : 0.0f));
				}else{
					// Hide outer corner
					if(state & SOUTH == 0) batch.get(i+8).setColor(Vector4(0.0f));
					batch.get(i+9).setColor(Vector4(0.0f));
					if(state & WEST == 0) batch.get(i+10).setColor(Vector4(0.0f));
				}
				
				sprite.draw(@fbo);
			}*/
			
			Texture @texture = @Texture(32*32, 48);
			fbo.renderToTexture(@texture);
			
			textures.insertLast(texture);
		}
		@atlas = @TextureAtlas(@textures);
		
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
		for(int i = 0; i < tiles.size; i++)
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