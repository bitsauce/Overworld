class TerrainChunk : Serializable
{
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
	bool dummy;
	bool modified;
		
	TerrainChunk()
	{
		// A dummy
		dummy = true;
	}
	
	TerrainChunk(Terrain @terrain, int chunkX, int chunkY)
	{
		init(chunkX, chunkY, @terrain);
		setTerrain(@terrain);
	}
	
	// SERIALIZATION
	void init(int chunkX, int chunkY, Terrain @terrain)
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
		fixtures = grid<b2Fixture@>(CHUNK_SIZE, CHUNK_SIZE, null);
		tiles = grid<TileID>(CHUNK_SIZE, CHUNK_SIZE, EMPTY_TILE);
		
		// Store texture atlas
		@tileAtlas = @game::tiles.getAtlas();
		
		// Make the chunk buffer static
		@vbo = @terrain.getEmptyChunkBuffer();
		vbo.makeStatic();
		
		// Setup shadow map
		@shadowMap = @Texture(CHUNK_SIZE, CHUNK_SIZE);
		shadowMap.setFiltering(LINEAR);
		shadowMap.setWrapping(CLAMP_TO_EDGE);
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
		
		init(chunkX, chunkY, scene::game.getTerrain());
		
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
		
		// Set the tile value
		tiles[x, y] = tile;
		
		// Return true
		return true;
	}
	
	bool removeTile(const int x, const int y)
	{
		// Make sure there is a tile to remove
		if(!isValid(x, y) || !isTileAt(x, y))
			return false;
		
		// Set the tile value
		tiles[x, y] = EMPTY_TILE;
		
		// Return true
		return true;
	}
	
	void updateTile(const int x, const int y, const uint state, const bool fixture = false)
	{
		float opacity = getOpacity(x, y);
		array<Vector4> pixel = {
			Vector4(0.0f, 0.0f, 0.0f, opacity)
		};
		shadowMap.updateSection(x, CHUNK_SIZE - y - 1, Pixmap(1, 1, pixel));
		
		TileID tile = tiles[x, y];
		int i = (y * CHUNK_SIZE + x) * 16;
		TextureRegion region;
		if(tile > RESERVED_TILE)
		{
			uint8 q1 = ((state >> 0) & 0x7) + 0x00;
			uint8 q2 = ((state >> 2) & 0x7) + 0x08;
			uint8 q3 = ((state >> 4) & 0x7) + 0x10;
			uint8 q4 = (((state >> 6) & 0x7) | ((state << 2) & 0x7)) + 0x18;
			
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
		}
		else if(!shouldContainFixture && isFixtureAt(x, y))
		{
			removeFixture(x, y);
		}
	}
	
	// DRAWING
	void draw(const Matrix4 &in projmat)
	{
		if(!dummy)
		{
			Batch @batch = @Batch();
			batch.setProjectionMatrix(projmat);
			vbo.draw(@batch, @tileAtlas.getTexture());
			batch.draw();
			
			//Sprite @shadows = @Sprite(TextureRegion(@shadowMap, 0.0f, 0.0f, 1.0f, 1.0f));
			//shadows.setPosition(chunkX*CHUNK_SIZE*TILE_SIZE, chunkY*CHUNK_SIZE*TILE_SIZE);
			//shadows.setSize(CHUNK_SIZE*TILE_SIZE, CHUNK_SIZE*TILE_SIZE);
			//shadows.draw(@scene::game.getBatch(SCENE));
		}
	}
}