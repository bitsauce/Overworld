const int CHUNK_SIZE = 64;

class TerrainChunk
{
	private b2Body @body;
	private grid<b2Fixture@> fixtures;
	private grid<TileID> tiles;
	private SpriteBatch @batch;
	private bool initialized;
	
	TerrainChunk(b2Body @body)
	{
		// Set as uninitialized
		initialized = false;
		
		// Set body
		@this.body = @body;
		
		// Resize tile grid
		fixtures.resize(CHUNK_SIZE, CHUNK_SIZE);
		tiles.resize(CHUNK_SIZE, CHUNK_SIZE);
		for(int y = 0; y < CHUNK_SIZE; y++) {
			for(int x = 0; x < CHUNK_SIZE; x++) {
				tiles[x, y] = NULL_TILE;
			}
		}
		
		// Initialize terrain buffers
		@batch = @SpriteBatch();
		for(int y = 0; y < CHUNK_SIZE; y++)
		{
			for(int x = 0; x < CHUNK_SIZE; x++)
			{
				for(int j = 0; j < 13; j++)
				{
					Sprite @sprite = @Sprite(game::tiles.getTextureRegion(NULL_TILE, j));
					sprite.setPosition(Vector2(x * TILE_SIZE + TILE_SIZE * 2 * (TILE_TEXTURE_COORDS[0, j] - 0.25f), y * TILE_SIZE + TILE_SIZE * 2 * (0.75 - TILE_TEXTURE_COORDS[3, j] * (3.0f/2.0f))));
					sprite.setColor(Vector4(0.0f));
					batch.add(@sprite);
				}
			}
		}
		
		// Make it static
		batch.makeStatic();
	}
	
	void init()
	{
		// Create shadow map
		//@shadowMap = @Texture(width, height);
		//shadowMap.setFiltering(LINEAR);
		
		// Update all tiles
		for(int y = 0; y < CHUNK_SIZE; y++)
		{
			for(int x = 0; x < CHUNK_SIZE; x++)
			{
				updateTile(x, y);
				updateFixture(x, y);
			}
		}
		initialized = true;
	}
	
	bool isValid(const int x, const int y) const
	{
		return x >= 0 && x < CHUNK_SIZE && y >= 0 && y < CHUNK_SIZE;
	}
	
	TileID getTileAt(const int x, const int y) const
	{
		return isValid(x, y) ? tiles[x, y] : NULL_TILE;
	}
	
	bool isTileAt(const int x, const int y, const bool reserved = false)
	{
		return reserved ? (getTileAt(x, y) > RESERVED_TILE) : (getTileAt(x, y) != NULL_TILE);
	}
	
	bool addTile(const int x, const int y, const TileID tile)
	{
		// Make sure we can add a tile here
		if(!isValid(x, y) || isTileAt(x, y))
			return false;
		
		// Show tile
		int i = (y * CHUNK_SIZE + x) * 13;
		for(int j = 0; j < 13; j++) {
			batch.get(i+j).setRegion(game::tiles.getTextureRegion(tile, j));
		}
		batch.get(i+12).setColor(Vector4(1.0f));
		
		// Set the tile value
		tiles[x, y] = tile;
		
		if(initialized)
		{
			// Update neighbouring tiles
			updateTile(x, y);
			updateTile(x+1, y);
			updateTile(x-1, y);
			updateTile(x, y+1);
			updateTile(x, y-1);
			updateTile(x+1, y+1);
			updateTile(x-1, y+1);
			updateTile(x+1, y-1);
			updateTile(x-1, y-1);
			
			// Update fixtures
			updateFixture(x, y);
			updateFixture(x+1, y);
			updateFixture(x-1, y);
			updateFixture(x, y+1);
			updateFixture(x, y-1);
		}
		return true;
	}
	
	bool removeTile(const int x, const int y)
	{
		// Make sure there is a tile to remove
		if(!isValid(x, y) || !isTileAt(x, y))
			return false;
		
		// Hide tile
		int i = (y * CHUNK_SIZE + x) * 13;
		for(int j = 0; j < 13; j++) {
			batch.get(i+j).setColor(Vector4(0.0f));
		}
		
		// Reset the tile value
		tiles[x, y] = NULL_TILE;
		
		if(initialized)
		{
			// Update neighbouring tiles
			updateTile(x+1, y);
			updateTile(x-1, y);
			updateTile(x, y+1);
			updateTile(x, y-1);
			updateTile(x+1, y+1);
			updateTile(x-1, y+1);
			updateTile(x+1, y-1);
			updateTile(x-1, y-1);
			
			// Update fixtures
			updateFixture(x, y);
			updateFixture(x+1, y);
			updateFixture(x-1, y);
			updateFixture(x, y+1);
			updateFixture(x, y-1);
		}
		return true;
	}
	
	private uint getTileState(const int x, const int y, const bool reserved = false)
	{
		// Set state
		uint state = 0;
		if(isTileAt(x, y-1, reserved)) state |= NORTH;
		if(isTileAt(x, y+1, reserved)) state |= SOUTH;
		if(isTileAt(x+1, y, reserved)) state |= EAST;
		if(isTileAt(x-1, y, reserved)) state |= WEST;
		if(isTileAt(x+1, y-1, reserved)) state |= NORTH_EAST;
		if(isTileAt(x-1, y-1, reserved)) state |= NORTH_WEST;
		if(isTileAt(x+1, y+1, reserved)) state |= SOUTH_EAST;
		if(isTileAt(x-1, y+1, reserved)) state |= SOUTH_WEST;
		return state;
	}
	
	private void updateTile(const int x, const int y)
	{
		TileID tile = getTileAt(x, y);
		if(tile != NULL_TILE)
		{
			int i = (y * CHUNK_SIZE + x) * 13;
			uint state = getTileState(x, y, true);
			
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
		}
	}
	
	// PHYSICS
	private void createFixture(const int x, const int y)
	{
		b2Fixture @fixture = @body.createFixture(Rect(x * TILE_SIZE - TILE_SIZE * 0.5f, y * TILE_SIZE - TILE_SIZE * 0.5f, TILE_SIZE*2, TILE_SIZE*2), 0.0f);
		game::tiles[getTileAt(x, y)].setupFixture(@fixture);
		@fixtures[x, y] = @fixture;
	}
	
	private void removeFixture(const int x, const int y)
	{
		body.removeFixture(@fixtures[x, y]);
		@fixtures[x, y] = null;
	}
	
	private bool isFixtureAt(const int x, const int y)
	{
		return isValid(x, y) ? @fixtures[x, y] != null : false;
	}
	
	private void updateFixture(const int x, const int y)
	{
		// Find out if this tile should contain a fixture
		bool shouldContainFixture = isTileAt(x, y, true) && (getTileState(x, y, true) & NESW != NESW);
		
		// Create or remove fixture
		if(shouldContainFixture && !isFixtureAt(x, y))
		{
			createFixture(x, y);
		}else if(!shouldContainFixture && isFixtureAt(x, y))
		{
			removeFixture(x, y);
		}
	}
	
	// DRAWING
	void draw(const Matrix4 &in projmat)
	{
		batch.setProjectionMatrix(projmat);
		batch.draw();
	}
}