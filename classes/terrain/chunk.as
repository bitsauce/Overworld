enum ChunkState
{
	CHUNK_DUMMY,
	CHUNK_LOAD_BUFFERS,
	CHUNK_LOAD_TILES,
	CHUNK_UPDATE_TILES,
	CHUNK_INITIALIZED
}

class TerrainChunk : Serializable
{
	// PARTIAL LOADING
	private ChunkState state;
	private int loadPos;
	
	// CHUNK
	private int chunkX, chunkY;
	private grid<TileID> tiles;
	
	// PHYSICS
	private b2Body @body;
	private grid<b2Fixture@> fixtures;
	
	// DRAWING
	private VertexBuffer @vbo;
	private Texture @shadowMap;
	private TextureAtlas @tileAtlas;
	
	// MISC
	bool modified;
		
	TerrainChunk()
	{
		// A dummy
		state = CHUNK_DUMMY;
	}
	
	TerrainChunk(int chunkX, int chunkY)
	{
		init(chunkX, chunkY);
	}
	
	// SERIALIZATION
	void init(int chunkX, int chunkY)
	{
		// Set chunk vars
		this.chunkX = chunkX;
		this.chunkY = chunkY;
		this.state = CHUNK_LOAD_BUFFERS;
		this.loadPos = 0;
		this.modified = false; // not modified
		@this.tileAtlas = @game::tiles.getAtlas();
	}
	
	bool loadNext()
	{
		switch(state)
		{
		case CHUNK_LOAD_BUFFERS:
		{
			// Create body
			b2BodyDef def;
			def.type = b2_staticBody;
			def.position.set(chunkX * CHUNK_SIZE * TILE_SIZE, chunkY * CHUNK_SIZE * TILE_SIZE);
			def.allowSleep = true;
			@body = @b2Body(def);
			body.setObject(@Terrain);
			
			// Resize tile grid
			fixtures = grid<b2Fixture@>(CHUNK_SIZE, CHUNK_SIZE, null);
			tiles = grid<TileID>(CHUNK_SIZE, CHUNK_SIZE, EMPTY_TILE);
			
			// Make the chunk buffer static
			@vbo = @Terrain.getEmptyChunkBuffer();
			vbo.makeStatic();
			
			// Setup shadow map
			@shadowMap = @Texture(CHUNK_SIZE, CHUNK_SIZE);
			shadowMap.setFiltering(LINEAR);
			shadowMap.setWrapping(CLAMP_TO_EDGE);
			
			// Go to next load state
			state = CHUNK_LOAD_TILES;
			break;
		}
		
		case CHUNK_LOAD_TILES:
		{
			int x = loadPos % CHUNK_SIZE;
			int y = loadPos / CHUNK_SIZE;
			TileID tile = Terrain.generator.getTileAt(chunkX * CHUNK_SIZE + x, chunkY * CHUNK_SIZE + y);
			
			if(x == 0 || y == 0 || x == CHUNK_SIZE-1 || y == CHUNK_SIZE-1)
				Terrain.setTile(chunkX * CHUNK_SIZE + x, chunkY * CHUNK_SIZE + y, tile);
			else
				setTile(x, y, tile);
				
			loadPos++;
			if(loadPos >= CHUNK_SIZE*CHUNK_SIZE)
			{
				state = CHUNK_UPDATE_TILES;
				loadPos = 0;
			}
			break;
		}
		
		case CHUNK_UPDATE_TILES:
		{
			int x = loadPos % CHUNK_SIZE;
			int y = loadPos / CHUNK_SIZE;
			if(tiles[x, y] > RESERVED_TILE) // no point in updating air/reserved tiles initially
			{
				updateTile(x, y, Terrain.getTileState(chunkX * CHUNK_SIZE + x, chunkY * CHUNK_SIZE + y), true);
			}
			loadPos++;
			if(loadPos >= CHUNK_SIZE*CHUNK_SIZE)
			{
				state = CHUNK_INITIALIZED;
				loadPos = 0;
				Console.log("Chunk ["+chunkX+", "+chunkY+"] loaded");
				return true; // loading done
			}
			break;
		}
		
		case CHUNK_INITIALIZED:
			return true;
		}
		return false;
	}
	
	ChunkState getState() const
	{
		return state;
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
				setTile(x, y, TileID(tile));
			}
		}
	}
	
	int getX() const { return chunkX; }
	int getY() const { return chunkY; }
	
	TileID getTileAt(const int x, const int y) const
	{
		return state > CHUNK_LOAD_BUFFERS ? tiles[x, y] : NULL_TILE;
	}
	
	bool isTileAt(const int x, const int y) const
	{
		return state > CHUNK_LOAD_BUFFERS && tiles[x, y] != EMPTY_TILE;
	}
	
	bool isReservedTileAt(const int x, const int y) const
	{
		return state > CHUNK_LOAD_BUFFERS && tiles[x, y] > RESERVED_TILE;
	}
	
	bool setTile(const int x, const int y, const TileID tile)
	{
		// Make sure we can add a tile here
		if(state > CHUNK_LOAD_BUFFERS && tiles[x, y] != tile)
		{
			// Set the tile value
			tiles[x, y] = tile;
			if(state == CHUNK_INITIALIZED) modified = true; // mark chunk as modified
			return true; // return true as something was changed
		}
		return false; // nothing changed
	}
	
	void updateTile(const int x, const int y, const uint tileState, const bool fixture = false)
	{
		if(state >= CHUNK_UPDATE_TILES)
		{
			// Update shadow map
			float opacity = getOpacity(x, y);
			array<Vector4> pixel = {
				Vector4(0.0f, 0.0f, 0.0f, opacity)
			};
			shadowMap.updateSection(x, CHUNK_SIZE - y - 1, Pixmap(1, 1, pixel));
			
			// Get tile
			TileID tile = tiles[x, y];
			int i = (y * CHUNK_SIZE + x) * 16;
			TextureRegion region;
			if(tile > RESERVED_TILE)
			{
				uint8 q1 = ((tileState >> 0) & 0x7) + 0x0;
				uint8 q2 = ((tileState >> 2) & 0x7) + 0x8;
				uint8 q3 = ((tileState >> 4) & 0x7) + 0x10;
				uint8 q4 = (((tileState >> 6) & 0x7) | ((tileState << 2) & 0x7)) + 0x18;
				
				array<Vertex> vertices = vbo.getVertices(i, 16);
				
				region = tileAtlas.get(tile, q1/32.0f, 0.0f, (q1+1)/32.0f, 1.0f);
				vertices[0].set4f(VERTEX_TEX_COORD, region.uv0.x, region.uv1.y);
				vertices[1].set4f(VERTEX_TEX_COORD, region.uv1.x, region.uv1.y);
				vertices[2].set4f(VERTEX_TEX_COORD, region.uv1.x, region.uv0.y);
				vertices[3].set4f(VERTEX_TEX_COORD, region.uv0.x, region.uv0.y);
				
				region = tileAtlas.get(tile, q2/32.0f, 0.0f, (q2+1)/32.0f, 1.0f);
				vertices[4].set4f(VERTEX_TEX_COORD, region.uv0.x, region.uv1.y);
				vertices[5].set4f(VERTEX_TEX_COORD, region.uv1.x, region.uv1.y);
				vertices[6].set4f(VERTEX_TEX_COORD, region.uv1.x, region.uv0.y);
				vertices[7].set4f(VERTEX_TEX_COORD, region.uv0.x, region.uv0.y);
				
				region = tileAtlas.get(tile, q3/32.0f, 0.0f, (q3+1)/32.0f, 1.0f);
				vertices[8].set4f(VERTEX_TEX_COORD, region.uv0.x, region.uv1.y);
				vertices[9].set4f(VERTEX_TEX_COORD, region.uv1.x, region.uv1.y);
				vertices[10].set4f(VERTEX_TEX_COORD, region.uv1.x, region.uv0.y);
				vertices[11].set4f(VERTEX_TEX_COORD, region.uv0.x, region.uv0.y);
				
				region = tileAtlas.get(tile, q4/32.0f, 0.0f, (q4+1)/32.0f, 1.0f);
				vertices[12].set4f(VERTEX_TEX_COORD, region.uv0.x, region.uv1.y);
				vertices[13].set4f(VERTEX_TEX_COORD, region.uv1.x, region.uv1.y);
				vertices[14].set4f(VERTEX_TEX_COORD, region.uv1.x, region.uv0.y);
				vertices[15].set4f(VERTEX_TEX_COORD, region.uv0.x, region.uv0.y);
				
				vbo.modifyVertices(i, vertices);
			}
			else
			{
				array<Vertex> vertices = vbo.getVertices(i, 16);
				
				vertices[0].set4f(VERTEX_TEX_COORD, 0.0f, 0.0f);
				vertices[1].set4f(VERTEX_TEX_COORD, 0.0f, 0.0f);
				vertices[2].set4f(VERTEX_TEX_COORD, 0.0f, 0.0f);
				vertices[3].set4f(VERTEX_TEX_COORD, 0.0f, 0.0f);
				
				vertices[4].set4f(VERTEX_TEX_COORD, 0.0f, 0.0f);
				vertices[5].set4f(VERTEX_TEX_COORD, 0.0f, 0.0f);
				vertices[6].set4f(VERTEX_TEX_COORD, 0.0f, 0.0f);
				vertices[7].set4f(VERTEX_TEX_COORD, 0.0f, 0.0f);
				
				vertices[8].set4f(VERTEX_TEX_COORD, 0.0f, 0.0f);
				vertices[9].set4f(VERTEX_TEX_COORD, 0.0f, 0.0f);
				vertices[10].set4f(VERTEX_TEX_COORD, 0.0f, 0.0f);
				vertices[11].set4f(VERTEX_TEX_COORD, 0.0f, 0.0f);
				
				vertices[12].set4f(VERTEX_TEX_COORD, 0.0f, 0.0f);
				vertices[13].set4f(VERTEX_TEX_COORD, 0.0f, 0.0f);
				vertices[14].set4f(VERTEX_TEX_COORD, 0.0f, 0.0f);
				vertices[15].set4f(VERTEX_TEX_COORD, 0.0f, 0.0f);
				
				vbo.modifyVertices(i, vertices);
			}
			
			// Update fixtures
			if(fixture)
			{
				updateFixture(x, y, tileState);
			}
		}
	}

	// SHADOWS
	float getOpacity(const int x, const int y)
	{
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
		return state > CHUNK_LOAD_BUFFERS ? @fixtures[x, y] != null : false;
	}
	
	private void updateFixture(const int x, const int y, const uint state)
	{
		// Find out if this tile should contain a fixture
		bool shouldContainFixture = isReservedTileAt(x, y) && (state & NESW != NESW);
		
		// Create or remove fixture
		if(shouldContainFixture && !isFixtureAt(x, y))
		{
			createFixture(x, y);
		}
		else if(!shouldContainFixture && isFixtureAt(x, y))
		{
			removeFixture(x, y);
		}
	}
	
	// DRAWING
	void draw(const Matrix4 &in projmat)
	{
		if(state == CHUNK_INITIALIZED)
		{
			Batch @batch = @Batch();
			batch.setProjectionMatrix(projmat);
			vbo.draw(@batch, @tileAtlas.getTexture());
			
			Sprite @shadows = @Sprite(TextureRegion(@shadowMap, 0.0f, 0.0f, 1.0f, 1.0f));
			shadows.setPosition(CHUNK_SIZE*TILE_SIZE*chunkX, CHUNK_SIZE*TILE_SIZE*chunkY);
			shadows.setSize(CHUNK_SIZE*TILE_SIZE, CHUNK_SIZE*TILE_SIZE);
			shadows.draw(@Shadows);
			
			batch.draw();
		}
	}
}

Batch @Shadows = @Batch();