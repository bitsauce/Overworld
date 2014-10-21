const int CHUNK_SIZE = 32;
const float CHUNK_SIZEF = float(CHUNK_SIZE);

class TerrainChunk : Serializable
{
	// CHUNK
	private int chunkX, chunkY;
	grid<TileID> tiles;
	grid<uint> tileState;
	
	// PHYSICS
	private b2Body @body;
	private grid<b2Fixture@> fixtures;
	
	// DRAWING
	private SpriteBatch @batch;
	private Texture @shadowMap;
	
	// MISC
	bool dummy;
	bool modified;
		
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
		modified = false;
		
		// Set chunk vars
		this.chunkX = chunkX;
		this.chunkY = chunkY;
		
		// Create body
		b2BodyDef def;
		def.type = b2_staticBody;
		def.position.set(chunkX * CHUNK_SIZE * TILE_SIZE, chunkY * CHUNK_SIZE * TILE_SIZE);
		def.allowSleep = true;
		
		@body = b2Body(def);
		
		// Resize tile grid
		fixtures.resize(CHUNK_SIZE, CHUNK_SIZE);
		tiles.resize(CHUNK_SIZE, CHUNK_SIZE);
		tileState.resize(CHUNK_SIZE, CHUNK_SIZE);
		for(int y = 0; y < CHUNK_SIZE; y++)
		{
			for(int x = 0; x < CHUNK_SIZE; x++)
			{
				tiles[x, y] = EMPTY_TILE;
				tileState[x, y] = 0;
			}
		}
		
		// Initialize terrain buffers
		@batch = @SpriteBatch();
		TextureAtlas @atlas = @game::tiles.getAtlas();
		for(int y = 0; y < CHUNK_SIZE; y++)
		{
			for(int x = 0; x < CHUNK_SIZE; x++)
			{
				Sprite @q1 = @Sprite(atlas.get(EMPTY_TILE, 0.1f, 0.1f, 0.1f, 0.1f));
				Sprite @q2 = @Sprite(atlas.get(EMPTY_TILE, 0.1f, 0.1f, 0.1f, 0.1f));
				Sprite @q3 = @Sprite(atlas.get(EMPTY_TILE, 0.1f, 0.1f, 0.1f, 0.1f));
				Sprite @q4 = @Sprite(atlas.get(EMPTY_TILE, 0.1f, 0.1f, 0.1f, 0.1f));
				
				q1.setSize(TILE_SIZE, TILE_SIZE);
				q2.setSize(TILE_SIZE, TILE_SIZE);
				q3.setSize(TILE_SIZE, TILE_SIZE);
				q4.setSize(TILE_SIZE, TILE_SIZE);
				
				q1.setPosition(x * TILE_SIZE + TILE_SIZE * 0.5f, y * TILE_SIZE - TILE_SIZE * 0.5f);
				q2.setPosition(x * TILE_SIZE + TILE_SIZE * 0.5f, y * TILE_SIZE + TILE_SIZE * 0.5f);
				q3.setPosition(x * TILE_SIZE - TILE_SIZE * 0.5f, y * TILE_SIZE + TILE_SIZE * 0.5f);
				q4.setPosition(x * TILE_SIZE - TILE_SIZE * 0.5f, y * TILE_SIZE - TILE_SIZE * 0.5f);
				
				batch.add(@q1);
				batch.add(@q2);
				batch.add(@q3);
				batch.add(@q4);
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
		/*int i = (y * CHUNK_SIZE + x) * 13;
		for(int j = 0; j < 13; j++) {
			batch.get(i+j).setRegion(game::tiles.getTextureRegion(tile, j));
		}*/
		
		// Set the tile value
		tiles[x, y] = tile;
	}
	
	void updateTile(const int x, const int y, const bool fixture = false)
	{
		float opacity = getOpacity(x, y);
		array<Vector4> pixel = {
			Vector4(0.0f, 0.0f, 0.0f, opacity)
		};
		shadowMap.updateSection(x, CHUNK_SIZE - y - 1, Pixmap(1, 1, pixel));
		
		TileID tile = tiles[x, y];
		int i = (y * CHUNK_SIZE + x) * 4;
		uint state = tileState[x, y];
		TextureAtlas @atlas = @game::tiles.getAtlas();
		if(tile > RESERVED_TILE)
		{
			uint8 q1 = ((state >> 0) & 0x7) + 0x00;
			uint8 q2 = ((state >> 2) & 0x7) + 0x08;
			uint8 q3 = ((state >> 4) & 0x7) + 0x10;
			uint8 q4 = (((state >> 6) & 0x7) | ((state << 2) & 0x7)) + 0x18;
			
			Console.log("x: "+x);
			Console.log("y: "+y);
			Console.log("q1: "+q1);
			Console.log("q2: "+q2);
			Console.log("q3: "+q3);
			Console.log("q4: "+q4);
			
			batch.get(i+0).setRegion(atlas.get(tile, q1/32.0f, 0.0f, (q1+1)/32.0f, 1.0f));
			batch.get(i+1).setRegion(atlas.get(tile, q2/32.0f, 0.0f, (q2+1)/32.0f, 1.0f));
			batch.get(i+2).setRegion(atlas.get(tile, q3/32.0f, 0.0f, (q3+1)/32.0f, 1.0f));
			batch.get(i+3).setRegion(atlas.get(tile, q4/32.0f, 0.0f, (q4+1)/32.0f, 1.0f));
		}
		else
		{
			batch.get(i+0).setRegion(atlas.get(EMPTY_TILE));
			batch.get(i+1).setRegion(atlas.get(EMPTY_TILE));
			batch.get(i+2).setRegion(atlas.get(EMPTY_TILE));
			batch.get(i+3).setRegion(atlas.get(EMPTY_TILE));
		}
		
		if(fixture) {
			updateFixture(x, y, state);
		}
	}
	
	void updateTile(const int x, const int y, const uint state, const bool fixture = false)
	{
		tileState[x, y] = state;
		updateTile(x, y, fixture);
	}
	
	void updateAllTiles()
	{
		TextureAtlas @atlas = @game::tiles.getAtlas();
		for(int y = 0; y < CHUNK_SIZE; y++)
		{
			for(int x = 0; x < CHUNK_SIZE; x++)
			{
				float opacity = getOpacity(x, y);
				array<Vector4> pixel = {
					Vector4(0.0f, 0.0f, 0.0f, opacity)
				};
				shadowMap.updateSection(x, CHUNK_SIZE - y - 1, Pixmap(1, 1, pixel));
				
				TileID tile = tiles[x, y];
				int i = (y * CHUNK_SIZE + x) * 4;
				uint state = tileState[x, y];
				if(tile > RESERVED_TILE)
				{
					uint8 q1 = ((state >> 0) & 0x7) + 0x00;
					uint8 q2 = ((state >> 2) & 0x7) + 0x08;
					uint8 q3 = ((state >> 4) & 0x7) + 0x10;
					uint8 q4 = (((state >> 6) & 0x7) | ((state << 2) & 0x7)) + 0x18;
					
					batch.get(i+0).setRegion(atlas.get(tile, q1/32.0f, 0.0f, (q1+1)/32.0f, 1.0f));
					batch.get(i+1).setRegion(atlas.get(tile, q2/32.0f, 0.0f, (q2+1)/32.0f, 1.0f));
					batch.get(i+2).setRegion(atlas.get(tile, q3/32.0f, 0.0f, (q3+1)/32.0f, 1.0f));
					batch.get(i+3).setRegion(atlas.get(tile, q4/32.0f, 0.0f, (q4+1)/32.0f, 1.0f));
				}
				else
				{
					batch.get(i+0).setRegion(atlas.get(EMPTY_TILE));
					batch.get(i+1).setRegion(atlas.get(EMPTY_TILE));
					batch.get(i+2).setRegion(atlas.get(EMPTY_TILE));
					batch.get(i+3).setRegion(atlas.get(EMPTY_TILE));
				}
				updateFixture(x, y, state);
			}
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
		//shadows.draw(@scene::game.getBatch(SCENE));
	}
}