const int CHUNK_SIZE = 32;
const float CHUNK_SIZEF = float(CHUNK_SIZE);
mutex physicsmtx;

class TerrainChunk : Serializable
{
	// CHUNK
	private int chunkX, chunkY;
	private grid<TileID> tiles;
	
	// PHYSICS
	private b2Body @body;
	private grid<b2Fixture@> fixtures;
	
	// DRAWING
	private SpriteBatch @batch;
	private Texture @shadowMap;
	
	// MISC
	private bool dummy;
	private bool generating;
		
	TerrainChunk()
	{
		// A dummy
		dummy = true;
	}
	
	TerrainChunk(Terrain @terrain, int chunkX, int chunkY)
	{
		init(chunkX, chunkY);
		setTerrain(@terrain);
	}
	
	// SERIALIZATION
	void init(int chunkX, int chunkY)
	{
		// Not a dummy
		dummy = false;
		generating = true;
		
		// Set chunk vars
		this.chunkX = chunkX;
		this.chunkY = chunkY;
		
		// Create body
		b2BodyDef def;
		def.type = b2_staticBody;
		def.position.set(chunkX * CHUNK_SIZE * TILE_SIZE, chunkY * CHUNK_SIZE * TILE_SIZE);
		def.allowSleep = true;
		
		physicsmtx.lock();
		@body = b2Body(def);
		physicsmtx.unlock();
		
		// Resize tile grid
		fixtures.resize(CHUNK_SIZE, CHUNK_SIZE);
		tiles.resize(CHUNK_SIZE, CHUNK_SIZE);
		for(int y = 0; y < CHUNK_SIZE; y++) {
			for(int x = 0; x < CHUNK_SIZE; x++) {
				tiles[x, y] = EMPTY_TILE;
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
					Sprite @sprite = @Sprite(game::tiles.getTextureRegion(EMPTY_TILE, j));
					sprite.setPosition(Vector2(x * TILE_SIZE + TILE_SIZE * 2 * (TILE_TEXTURE_COORDS[0, j] - 0.25f), y * TILE_SIZE + TILE_SIZE * 2 * (0.75 - TILE_TEXTURE_COORDS[3, j] * (3.0f/2.0f))));
					batch.add(@sprite);
				}
			}
		}
		
		@shadowMap = @Texture(CHUNK_SIZE, CHUNK_SIZE);
		shadowMap.setFiltering(LINEAR);
		shadowMap.setWrapping(CLAMP_TO_EDGE);
		
		// Make it static
		batch.makeStatic();
	}
	
	void serialize(StringStream &ss)
	{
		Console.log("Saving chunk ["+chunkX+";"+chunkY+"]...");
		
		// Write chunk pos
		ss.write(chunkX);
		ss.write(chunkY);
		
		// Write chunk tiles
		for(int y = 0; y < CHUNK_SIZE; y++)
		{
			for(int x = 0; x < CHUNK_SIZE; x++)
			{
				TileID tile = getTileAt(x, y);
				if(tile <= RESERVED_TILE) tile = EMPTY_TILE;
				ss.write(int(tile));
			}
		}
	}
	
	void deserialize(StringStream &ss)
	{
		// Initialize chunk
		int chunkX, chunkY;
		ss.read(chunkX);
		ss.read(chunkY);
		
		Console.log("Loading chunk ["+chunkX+";"+chunkY+"]...");
		
		init(chunkX, chunkY);
		
		// Load tiles from file
		for(int y = 0; y < CHUNK_SIZE; y++)
		{
			for(int x = 0; x < CHUNK_SIZE; x++)
			{
				int tile;
				ss.read(tile);
				addTile(x, y, TileID(tile));
			}
		}
	}
	
	// TODO: Better solution?
	void setTerrain(Terrain @terrain)
	{
		body.setObject(@terrain);
	}
	
	int getX() const { return chunkX; }
	int getY() const { return chunkY; }
	
	bool isGenerating() const
	{
		return generating;
	}
	
	bool isValid(const int x, const int y) const
	{
		return !dummy && x >= 0 && x < CHUNK_SIZE && y >= 0 && y < CHUNK_SIZE;
	}
	
	TileID getTileAt(const int x, const int y) const
	{
		return isValid(x, y) ? tiles[x, y] : NULL_TILE;
	}
	
	bool isTileAt(const int x, const int y, const bool reserved = true) const
	{
		return reserved ? (getTileAt(x, y) > RESERVED_TILE) : (getTileAt(x, y) != EMPTY_TILE);
	}
	
	bool addTile(const int x, const int y, const TileID tile)
	{
		// Make sure we can add a tile here
		if(!isValid(x, y) || isTileAt(x, y) || tile == EMPTY_TILE)
			return false;
		
		// Set tile
		setTile(x, y, tile);
		
		// Return true
		return true;
	}
	
	bool removeTile(const int x, const int y)
	{
		// Make sure there is a tile to remove
		if(!isValid(x, y) || !isTileAt(x, y))
			return false;
		
		// Set tile
		setTile(x, y, EMPTY_TILE);
		
		// Return true
		return true;
	}
	
	private void setTile(const int x, const int y, const TileID tile)
	{
		// Setup tile regions
		int i = (y * CHUNK_SIZE + x) * 13;
		for(int j = 0; j < 13; j++) {
			batch.get(i+j).setRegion(game::tiles.getTextureRegion(tile, j));
		}
		
		// Set the tile value
		tiles[x, y] = tile;
	}
	
	void updateTile(const int x, const int y, const uint state, const bool fixture = false)
	{
		if(!isValid(x, y))
			return;
		
		setOpacity(x, y, getOpacity(x, y));
		
		TileID tile = getTileAt(x, y);
		int i = (y * CHUNK_SIZE + x) * 13;
		if(tile > RESERVED_TILE)
		{
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
		
		if(fixture) {
			updateFixture(x, y, state);
		}
	}

	// SHADOWS
	float getOpacity(const int x, const int y)
	{
		if(!isValid(x, y))
			return 0.0f;
		
		float opacity = 0.0f;
		opacity += game::tiles[getTileAt(x, y)].getOpacity();
		return opacity;
	}
	
	void setOpacity(const int x, const int y, const float opacity)
	{
		if(dummy)
			return;

		array<Vector4> pixel = {
			Vector4(0.0f, 0.0f, 0.0f, opacity)
		};

		shadowMap.updateSection(x, CHUNK_SIZE - y - 1, Pixmap(1, 1, pixel));
	}
	
	// PHYSICS
	private void createFixture(const int x, const int y)
	{
		physicsmtx.lock();
		b2Fixture @fixture = @body.createFixture(Rect(x * TILE_SIZE - TILE_SIZE * 0.5f, y * TILE_SIZE - TILE_SIZE * 0.5f, TILE_SIZE*2, TILE_SIZE*2), 0.0f);
		physicsmtx.unlock();
		
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
	
	private void updateFixture(const int x, const int y, const uint state)
	{
		// Find out if this tile should contain a fixture
		bool shouldContainFixture = isTileAt(x, y, true) && (state & NESW != NESW);
		
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
		if(dummy)
			return;
			
		batch.setProjectionMatrix(projmat);
		batch.draw();
		
		Sprite @shadows = @Sprite(TextureRegion(@shadowMap, 0.0f, 0.0f, 1.0f, 1.0f));
		shadows.setPosition(chunkX*CHUNK_SIZE*TILE_SIZE, chunkY*CHUNK_SIZE*TILE_SIZE);
		shadows.setSize(CHUNK_SIZE*TILE_SIZE, CHUNK_SIZE*TILE_SIZE);
		shadows.draw(@scene::game.getBatch(SCENE));
	}
}