enum ChunkState
{
	CHUNK_DUMMY,
	CHUNK_GENERATING,
	CHUNK_INITIALIZED
}

Shader @blurHShader = @Shader(":/shaders/blur_h.vert", ":/shaders/blur_h.frag");
Shader @blurVShader = @Shader(":/shaders/blur_v.vert", ":/shaders/blur_v.frag");

class TerrainChunk : Serializable
{
	// CHUNK
	private int chunkX, chunkY;
	private array<grid<TileID>> tiles(TERRAIN_LAYERS_MAX);
	
	// PHYSICS
	private b2Body @body;
	private grid<b2Fixture@> fixtures;
	
	// DRAWING
	private VertexBuffer vbo;
	private Texture @shadowMap;
	private Texture @shadowPass1;
	private Texture @shadowPass2;
	private int shadowRadius;
	
	// MISC
	/*private*/ bool modified;
	private bool generateBuffers;
	private ChunkState state;
		
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
		this.state = CHUNK_GENERATING;
		this.chunkX = chunkX;
		this.chunkY = chunkY;
		this.generateBuffers = this.modified = false; // not modified
		this.shadowRadius = 4;
		@this.shadowMap = @Texture(CHUNK_SIZE + shadowRadius*2, CHUNK_SIZE + shadowRadius*2);
		@this.shadowPass1 = @Texture(CHUNK_SIZE + shadowRadius*2, CHUNK_SIZE + shadowRadius*2);
		@this.shadowPass2 = @Texture(CHUNK_SIZE + shadowRadius*2, CHUNK_SIZE + shadowRadius*2);
		this.shadowPass2.setFiltering(LINEAR);
		
		// Create body
		b2BodyDef def;
		def.type = b2_staticBody;
		def.position.set(chunkX * CHUNK_SIZE * TILE_SIZE, chunkY * CHUNK_SIZE * TILE_SIZE);
		def.allowSleep = true;
		@body = @b2Body(def);
		body.setObject(@Terrain);
		
		// Resize tile grid
		fixtures = grid<b2Fixture@>(CHUNK_SIZE, CHUNK_SIZE, null);
		for(int i = 0; i < TERRAIN_LAYERS_MAX; ++i)
		{
			tiles[i] = grid<TileID>(CHUNK_SIZE, CHUNK_SIZE, EMPTY_TILE);
		}
		vbo = VertexBuffer(Terrain.getVertexFormat());
	}
	
	void generate()
	{
		if(state == CHUNK_GENERATING)
		{
			// Set all tiles
			for(uint y = 0; y < CHUNK_SIZE; ++y)
			{
				for(uint x = 0; x < CHUNK_SIZE; ++x)
				{
					for(int i = TERRAIN_LAYERS_MAX-1; i >= 0; --i)
					{
						tiles[i][x, y] = Terrain.generator.getTileAt(chunkX * CHUNK_SIZE + x, chunkY * CHUNK_SIZE + y, TerrainLayer(i));
					}
				}
			}
		
			// Load all vertex data
			for(uint y = 0; y < CHUNK_SIZE; ++y)
			{
				for(uint x = 0; x < CHUNK_SIZE; ++x)
				{
					for(int i = TERRAIN_LAYERS_MAX-1; i >= 0; --i)
					{
						TileID tile = tiles[i][x, y];
						if(tile > RESERVED_TILE) // no point in updating air/reserved tiles
						{
							uint state = Terrain.getTileState(chunkX * CHUNK_SIZE + x, chunkY * CHUNK_SIZE + y, TerrainLayer(i));
							vbo.addVertices(Tiles[tile].getVertices(x, y, state), Tiles[tile].getIndices());
							updateFixture(x, y, state);
							//if(tileIsOpaque)
								break;
						}
					}
				}
			}
			
			// Make the chunk buffer static
			vbo.setBufferType(STATIC_BUFFER);
			
			// Mark chunk as initialized
			state = CHUNK_INITIALIZED;
			Console.log("Chunk ["+chunkX+", "+chunkY+"] generated");
		}
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
				for(int i = TERRAIN_LAYERS_MAX-1; i >= 0; --i)
				{
					TileID tile = getTileAt(x, y, TerrainLayer(i));
					if(tile <= RESERVED_TILE) tile = EMPTY_TILE;
					ss.write(int(tile));
				}
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
				for(int i = TERRAIN_LAYERS_MAX-1; i >= 0; --i)
				{
					int tile;
					ss.read(tile);
					setTile(x, y, TileID(tile), TerrainLayer(i));
				}
			}
		}
	}
	
	int getX() const { return chunkX; }
	int getY() const { return chunkY; }
	
	ChunkState getState() const
	{
		return state;
	}
	
	TileID getTileAt(const int x, const int y, TerrainLayer layer) const
	{
		return state != CHUNK_DUMMY ? tiles[layer][x, y] : NULL_TILE;
	}
	
	bool isTileAt(const int x, const int y, TerrainLayer layer) const
	{
		return state != CHUNK_DUMMY && tiles[layer][x, y] != EMPTY_TILE;
	}
	
	bool isReservedTileAt(const int x, const int y, TerrainLayer layer) const
	{
		return state != CHUNK_DUMMY && tiles[layer][x, y] > RESERVED_TILE;
	}
	
	bool setTile(const int x, const int y, const TileID tile, TerrainLayer layer)
	{
		// Make sure we can add a tile here
		if(state == CHUNK_INITIALIZED && tiles[layer][x, y] != tile)
		{
			// Set the tile value
			tiles[layer][x, y] = tile;
			generateBuffers = modified = true; // mark chunk as modified
			return true; // return true as something was changed
		}
		return false; // nothing changed
	}
	
	void updateTile(const int x, const int y, const uint tileState, const bool fixture = false)
	{
		if(state == CHUNK_INITIALIZED)
		{
			// Update shadow map
			/*float opacity = getOpacity(x, y);
			array<Vector4> pixel = { Vector4(0.0f, 0.0f, 0.0f, opacity) };
			shadowMap.updateSection(x + shadowRadius, CHUNK_SIZE - y - 1 + shadowRadius, Pixmap(1, 1, pixel));*/
			
			// Get tile
			/*TileID tile = tiles[x, y];
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
			}*/
			
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
		for(int i = TERRAIN_LAYERS_MAX-1; i >= 0; --i)
		{
			opacity += Tiles[getTileAt(x, y, TerrainLayer(i))].getOpacity();
		}
		return opacity;
	}
	
	// PHYSICS
	private void createFixture(const int x, const int y)
	{
		b2Fixture @fixture = @body.createFixture(Rect(x * TILE_SIZE - TILE_SIZE * 0.5f, y * TILE_SIZE - TILE_SIZE * 0.5f, TILE_SIZE*2, TILE_SIZE*2), 0.0f);
		Tiles[getTileAt(x, y, TERRAIN_SCENE)].setupFixture(@fixture);
		@fixtures[x, y] = @fixture;
	}
	
	private void removeFixture(const int x, const int y)
	{
		body.removeFixture(@fixtures[x, y]);
		@fixtures[x, y] = null;
	}
	
	private bool isFixtureAt(const int x, const int y)
	{
		return state != CHUNK_DUMMY ? @fixtures[x, y] != null : false;
	}
	
	private void updateFixture(const int x, const int y, const uint state)
	{
		// Find out if this tile should contain a fixture
		bool shouldContainFixture = isReservedTileAt(x, y, TERRAIN_SCENE) && (state & NESW != NESW);
		
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
	
	private void updateShadows()
	{
		for(int y = -shadowRadius; y <= CHUNK_SIZE + shadowRadius; ++y)
		{
			for(int x = -shadowRadius; x <= CHUNK_SIZE + shadowRadius; ++x)
			{
				int tileX = chunkX*CHUNK_SIZE + x, tileY = chunkY*CHUNK_SIZE + y;
				float opacity = Terrain.getChunk(Math.floor(tileX / CHUNK_SIZEF), Math.floor(tileY / CHUNK_SIZEF)).getOpacity(Math.mod(tileX, CHUNK_SIZE), Math.mod(tileY, CHUNK_SIZE));
				array<Vector4> pixel = { Vector4(0.0f, 0.0f, 0.0f, opacity) };
				shadowMap.updateSection(x + shadowRadius, CHUNK_SIZE - y - 1 + shadowRadius, Pixmap(1, 1, pixel));
			}
		}
		
		Batch @batch = @Batch();
		
		// Blur horizontally
		shadowPass1.clear();
		blurHShader.setSampler2D("u_texture", @shadowMap);
		blurHShader.setUniform1i("u_width", CHUNK_SIZE + shadowRadius*2);
		blurHShader.setUniform1i("u_radius", shadowRadius-1);
		batch.setShader(@blurHShader);
		Shape(Rect(0, 0, CHUNK_SIZE + shadowRadius*2, CHUNK_SIZE + shadowRadius*2)).draw(@batch);
		batch.renderToTexture(@shadowPass1);
		batch.clear();
		
		// Blur vertically
		shadowPass2.clear();
		blurVShader.setSampler2D("u_texture", @shadowPass1);
		blurVShader.setSampler2D("u_filter", @shadowMap);
		blurVShader.setUniform1i("u_height", CHUNK_SIZE + shadowRadius*2);
		blurVShader.setUniform1i("u_radius", shadowRadius-1);
		batch.setShader(@blurVShader);
		Shape(Rect(0, 0, CHUNK_SIZE + shadowRadius*2, CHUNK_SIZE + shadowRadius*2)).draw(@batch);
		batch.renderToTexture(@shadowPass2);
		batch.clear();
	}
	
	// DRAWING
	void draw(const Matrix4 &in projmat)
	{
		if(state == CHUNK_INITIALIZED)
		{
			if(generateBuffers)
			{
				// Load all vertex data
				vbo = VertexBuffer(Terrain.getVertexFormat());
				for(uint y = 0; y < CHUNK_SIZE; ++y)
				{
					for(uint x = 0; x < CHUNK_SIZE; ++x)
					{
						for(int i = TERRAIN_LAYERS_MAX-1; i >= 0; --i)
						{
							TileID tile = tiles[i][x, y];
							if(tile > RESERVED_TILE) // no point in updating air/reserved tiles initially
							{
								uint state = Terrain.getTileState(chunkX * CHUNK_SIZE + x, chunkY * CHUNK_SIZE + y, TerrainLayer(i));
								vbo.addVertices(Tiles[tile].getVertices(x, y, state), Tiles[tile].getIndices());
								break;
							}
						}
					}
				}
				
				generateBuffers = false;
			}
			
			// Draw tiles
			Batch @batch = @Batch();
			batch.setProjectionMatrix(projmat);
			vbo.draw(@batch, @Tiles.getAtlas().getTexture());
			batch.draw();
			batch.clear();
			//updateShadows();
			
			// Draw shadows
			/*float f = shadowRadius/(CHUNK_SIZEF + shadowRadius*2);
			Sprite @shadows = @Sprite(TextureRegion(@shadowPass2, f, f, 1.0-f, 1.0-f));
			shadows.setPosition(CHUNK_SIZE*TILE_SIZE*chunkX, CHUNK_SIZE*TILE_SIZE*chunkY);
			shadows.setSize(CHUNK_SIZE*TILE_SIZE, CHUNK_SIZE*TILE_SIZE);
			shadows.draw(@Shadows);*/
		}
	}
}

Batch @Shadows = @Batch();