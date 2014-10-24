TerrainLayer getLayerByTile(TileID tile)
{
	if(tile < SCENE_TILES) return TERRAIN_SCENE;
	if(tile < BACKGROUND_TILES) return TERRAIN_BACKGROUND;
	return TERRAIN_FOREGROUND;
}

const int MAX_LOADED_CHUNKS = 128;

class Terrain : Serializable
{
	// Terrain chunks
	private array<TerrainChunk@> loadedChunks;
	private array<TerrainChunk@> chunkLoadNowQueue;
	private array<TerrainChunk@> chunkLoadQueue;
	private dictionary chunks;
	private VertexBuffer @chunkBuffer;
	private int chunkLoadSpeed;
	
	// Terrain generator
	TerrainGen generator;
	
	// For selecting a direction to generate in
	Vector2 prevCameraPos;
	
	Terrain()
	{
		init();
		generator.seed = Math.getRandomInt();
	}
	
	// SERIALIZATION
	private void init()
	{
		Console.log("Initializing terrain");
		
		// Setup vertex format
		VertexFormat fmt;
		fmt.set(VERTEX_POSITION, 2);
		fmt.set(VERTEX_TEX_COORD, 2);
		
		// Create chunk buffer
		@chunkBuffer = @VertexBuffer(fmt);
		for(int y = 0; y < CHUNK_SIZE; y++)
		{
			for(int x = 0; x < CHUNK_SIZE; x++)
			{
				array<Vertex> vertices = fmt.createVertices(4);
				
				vertices[0].set4f(VERTEX_POSITION, x     * TILE_SIZE + TILE_SIZE * 0.5f, y     * TILE_SIZE - TILE_SIZE * 0.5f);
				vertices[1].set4f(VERTEX_POSITION, (x+1) * TILE_SIZE + TILE_SIZE * 0.5f, y     * TILE_SIZE - TILE_SIZE * 0.5f);
				vertices[2].set4f(VERTEX_POSITION, (x+1) * TILE_SIZE + TILE_SIZE * 0.5f, (y+1) * TILE_SIZE - TILE_SIZE * 0.5f);
				vertices[3].set4f(VERTEX_POSITION, x     * TILE_SIZE + TILE_SIZE * 0.5f, (y+1) * TILE_SIZE - TILE_SIZE * 0.5f);
				
				chunkBuffer.addVertices(vertices, QUAD_INDICES);
				
				vertices[0].set4f(VERTEX_POSITION, x     * TILE_SIZE + TILE_SIZE * 0.5f, y     * TILE_SIZE + TILE_SIZE * 0.5f);
				vertices[1].set4f(VERTEX_POSITION, (x+1) * TILE_SIZE + TILE_SIZE * 0.5f, y     * TILE_SIZE + TILE_SIZE * 0.5f);
				vertices[2].set4f(VERTEX_POSITION, (x+1) * TILE_SIZE + TILE_SIZE * 0.5f, (y+1) * TILE_SIZE + TILE_SIZE * 0.5f);
				vertices[3].set4f(VERTEX_POSITION, x     * TILE_SIZE + TILE_SIZE * 0.5f, (y+1) * TILE_SIZE + TILE_SIZE * 0.5f);
				
				chunkBuffer.addVertices(vertices, QUAD_INDICES);
				
				vertices[0].set4f(VERTEX_POSITION, x     * TILE_SIZE - TILE_SIZE * 0.5f, y     * TILE_SIZE + TILE_SIZE * 0.5f);
				vertices[1].set4f(VERTEX_POSITION, (x+1) * TILE_SIZE - TILE_SIZE * 0.5f, y     * TILE_SIZE + TILE_SIZE * 0.5f);
				vertices[2].set4f(VERTEX_POSITION, (x+1) * TILE_SIZE - TILE_SIZE * 0.5f, (y+1) * TILE_SIZE + TILE_SIZE * 0.5f);
				vertices[3].set4f(VERTEX_POSITION, x     * TILE_SIZE - TILE_SIZE * 0.5f, (y+1) * TILE_SIZE + TILE_SIZE * 0.5f);
				
				chunkBuffer.addVertices(vertices, QUAD_INDICES);
				
				vertices[0].set4f(VERTEX_POSITION, x     * TILE_SIZE - TILE_SIZE * 0.5f, y     * TILE_SIZE - TILE_SIZE * 0.5f);
				vertices[1].set4f(VERTEX_POSITION, (x+1) * TILE_SIZE - TILE_SIZE * 0.5f, y     * TILE_SIZE - TILE_SIZE * 0.5f);
				vertices[2].set4f(VERTEX_POSITION, (x+1) * TILE_SIZE - TILE_SIZE * 0.5f, (y+1) * TILE_SIZE - TILE_SIZE * 0.5f);
				vertices[3].set4f(VERTEX_POSITION, x     * TILE_SIZE - TILE_SIZE * 0.5f, (y+1) * TILE_SIZE - TILE_SIZE * 0.5f);
				
				chunkBuffer.addVertices(vertices, QUAD_INDICES);
			}
		}
		
		chunkLoadSpeed = 12;
	}
	
	VertexBuffer @getEmptyChunkBuffer()
	{
		return @chunkBuffer.copy();
	}
	
	void serialize(StringStream &ss)
	{
		Console.log("Saving terrain...");
		
		ss.write(generator.seed);
		
		array<string> @keys = chunks.getKeys();
		for(int i = 0; i < keys.size; i++)
		{
			string key = keys[i];
			if(cast<TerrainChunk@>(chunks[key]).modified)
			{
				Scripts.serialize(cast<Serializable@>(chunks[key]), scene::game.getWorldDir() + "/chunks/" + key + ".obj");
			}
		}
	}
	
	void deserialize(StringStream &ss)
	{
		Console.log("Loading terrain...");
		
		init();
		
		ss.read(generator.seed);
	}
	
	// TILE HELPERS
	TileID getTileAt(const int x, const int y, const TerrainLayer layer = TERRAIN_SCENE)
	{
		return getChunk(Math.floor(x / CHUNK_SIZEF), Math.floor(y / CHUNK_SIZEF)).getTileAt(Math.mod(x, CHUNK_SIZE), Math.mod(y, CHUNK_SIZE));
	}
	
	bool isTileAt(const int x, const int y, TerrainLayer layer = TERRAIN_SCENE)
	{
		return getTileAt(x, y, layer) > RESERVED_TILE;
	}
	
	uint getTileState(const int x, const int y, TerrainLayer layer = TERRAIN_SCENE) const
	{
		// Set state
		uint state = 0;
		if(getChunk(Math.floor(x     / CHUNK_SIZEF), Math.floor((y-1) / CHUNK_SIZEF)).isTileAt(Math.mod(x,   CHUNK_SIZE), Math.mod(y-1, CHUNK_SIZE))) state |= NORTH;
		if(getChunk(Math.floor(x     / CHUNK_SIZEF), Math.floor((y+1) / CHUNK_SIZEF)).isTileAt(Math.mod(x,   CHUNK_SIZE), Math.mod(y+1, CHUNK_SIZE))) state |= SOUTH;
		if(getChunk(Math.floor((x+1) / CHUNK_SIZEF), Math.floor(y     / CHUNK_SIZEF)).isTileAt(Math.mod(x+1, CHUNK_SIZE), Math.mod(y,   CHUNK_SIZE))) state |= EAST;
		if(getChunk(Math.floor((x-1) / CHUNK_SIZEF), Math.floor(y     / CHUNK_SIZEF)).isTileAt(Math.mod(x-1, CHUNK_SIZE), Math.mod(y,   CHUNK_SIZE))) state |= WEST;
		if(getChunk(Math.floor((x+1) / CHUNK_SIZEF), Math.floor((y-1) / CHUNK_SIZEF)).isTileAt(Math.mod(x+1, CHUNK_SIZE), Math.mod(y-1, CHUNK_SIZE))) state |= NORTH_EAST;
		if(getChunk(Math.floor((x-1) / CHUNK_SIZEF), Math.floor((y-1) / CHUNK_SIZEF)).isTileAt(Math.mod(x-1, CHUNK_SIZE), Math.mod(y-1, CHUNK_SIZE))) state |= NORTH_WEST;
		if(getChunk(Math.floor((x+1) / CHUNK_SIZEF), Math.floor((y+1) / CHUNK_SIZEF)).isTileAt(Math.mod(x+1, CHUNK_SIZE), Math.mod(y+1, CHUNK_SIZE))) state |= SOUTH_EAST;
		if(getChunk(Math.floor((x-1) / CHUNK_SIZEF), Math.floor((y+1) / CHUNK_SIZEF)).isTileAt(Math.mod(x-1, CHUNK_SIZE), Math.mod(y+1, CHUNK_SIZE))) state |= SOUTH_WEST;
		return state;
	}
	
	// TILE MODIFICATION
	bool addTile(const int x, const int y, TileID tile)
	{
		if(getChunk(Math.floor(x / CHUNK_SIZEF), Math.floor(y / CHUNK_SIZEF)).addTile(Math.mod(x, CHUNK_SIZE), Math.mod(y, CHUNK_SIZE), tile))
		{	
			// Update neighbouring tiles
			getChunk(Math.floor(x     / CHUNK_SIZEF), Math.floor(y     / CHUNK_SIZEF)).updateTile(Math.mod(x,   CHUNK_SIZE), Math.mod(y,   CHUNK_SIZE), getTileState(x,   y), true);
			getChunk(Math.floor((x+1) / CHUNK_SIZEF), Math.floor(y     / CHUNK_SIZEF)).updateTile(Math.mod(x+1, CHUNK_SIZE), Math.mod(y,   CHUNK_SIZE), getTileState(x+1, y), true);
			getChunk(Math.floor((x-1) / CHUNK_SIZEF), Math.floor(y     / CHUNK_SIZEF)).updateTile(Math.mod(x-1, CHUNK_SIZE), Math.mod(y,   CHUNK_SIZE), getTileState(x-1, y), true);
			getChunk(Math.floor(x     / CHUNK_SIZEF), Math.floor((y+1) / CHUNK_SIZEF)).updateTile(Math.mod(x,   CHUNK_SIZE), Math.mod(y+1, CHUNK_SIZE), getTileState(x, y+1), true);
			getChunk(Math.floor(x     / CHUNK_SIZEF), Math.floor((y-1) / CHUNK_SIZEF)).updateTile(Math.mod(x,   CHUNK_SIZE), Math.mod(y-1, CHUNK_SIZE), getTileState(x, y-1), true);
			
			getChunk(Math.floor((x+1) / CHUNK_SIZEF), Math.floor((y+1) / CHUNK_SIZEF)).updateTile(Math.mod(x+1, CHUNK_SIZE), Math.mod(y+1, CHUNK_SIZE), getTileState(x+1, y+1));
			getChunk(Math.floor((x-1) / CHUNK_SIZEF), Math.floor((y+1) / CHUNK_SIZEF)).updateTile(Math.mod(x-1, CHUNK_SIZE), Math.mod(y+1, CHUNK_SIZE), getTileState(x-1, y+1));
			getChunk(Math.floor((x-1) / CHUNK_SIZEF), Math.floor((y-1) / CHUNK_SIZEF)).updateTile(Math.mod(x-1, CHUNK_SIZE), Math.mod(y-1, CHUNK_SIZE), getTileState(x-1, y-1));
			getChunk(Math.floor((x+1) / CHUNK_SIZEF), Math.floor((y-1) / CHUNK_SIZEF)).updateTile(Math.mod(x+1, CHUNK_SIZE), Math.mod(y-1, CHUNK_SIZE), getTileState(x+1, y-1));
			
			return true;
		}
		return false;
	}
	
	bool removeTile(const int x, const int y, TerrainLayer layer = TERRAIN_SCENE)
	{
		if(getChunk(Math.floor(x / CHUNK_SIZEF), Math.floor(y / CHUNK_SIZEF)).removeTile(Math.mod(x, CHUNK_SIZE), Math.mod(y, CHUNK_SIZE)))
		{
			// Update neighbouring tiles
			getChunk(Math.floor(x     / CHUNK_SIZEF), Math.floor(y     / CHUNK_SIZEF)).updateTile(Math.mod(x,   CHUNK_SIZE), Math.mod(y,   CHUNK_SIZE), getTileState(x,   y), true);
			getChunk(Math.floor((x+1) / CHUNK_SIZEF), Math.floor(y     / CHUNK_SIZEF)).updateTile(Math.mod(x+1, CHUNK_SIZE), Math.mod(y,   CHUNK_SIZE), getTileState(x+1, y), true);
			getChunk(Math.floor((x-1) / CHUNK_SIZEF), Math.floor(y     / CHUNK_SIZEF)).updateTile(Math.mod(x-1, CHUNK_SIZE), Math.mod(y,   CHUNK_SIZE), getTileState(x-1, y), true);
			getChunk(Math.floor(x     / CHUNK_SIZEF), Math.floor((y+1) / CHUNK_SIZEF)).updateTile(Math.mod(x,   CHUNK_SIZE), Math.mod(y+1, CHUNK_SIZE), getTileState(x, y+1), true);
			getChunk(Math.floor(x     / CHUNK_SIZEF), Math.floor((y-1) / CHUNK_SIZEF)).updateTile(Math.mod(x,   CHUNK_SIZE), Math.mod(y-1, CHUNK_SIZE), getTileState(x, y-1), true);
			
			getChunk(Math.floor((x+1) / CHUNK_SIZEF), Math.floor((y+1) / CHUNK_SIZEF)).updateTile(Math.mod(x+1, CHUNK_SIZE), Math.mod(y+1, CHUNK_SIZE), getTileState(x+1, y+1));
			getChunk(Math.floor((x-1) / CHUNK_SIZEF), Math.floor((y+1) / CHUNK_SIZEF)).updateTile(Math.mod(x-1, CHUNK_SIZE), Math.mod(y+1, CHUNK_SIZE), getTileState(x-1, y+1));
			getChunk(Math.floor((x-1) / CHUNK_SIZEF), Math.floor((y-1) / CHUNK_SIZEF)).updateTile(Math.mod(x-1, CHUNK_SIZE), Math.mod(y-1, CHUNK_SIZE), getTileState(x-1, y-1));
			getChunk(Math.floor((x+1) / CHUNK_SIZEF), Math.floor((y-1) / CHUNK_SIZEF)).updateTile(Math.mod(x+1, CHUNK_SIZE), Math.mod(y-1, CHUNK_SIZE), getTileState(x+1, y-1));
			
			return true;
		}
		return false;
	}
	
	// CHUNKS
	private TerrainChunk @getChunk(const int chunkX, const int chunkY, const bool generate = false)
	{
		string key = chunkX+";"+chunkY;
		if(!chunks.exists(key))
		{
			if(generate)
			{
				Console.log("Chunk ["+chunkX+", "+chunkY+"] added to queue");
			
				// Create new chunk
				TerrainChunk @chunk = @TerrainChunk(@this, chunkX, chunkY);
				@chunks[key] = @chunk;
				chunkLoadQueue.insertAt(0, @chunk); // Add to load queue
				return @chunk;
			}
			return @TerrainChunk(); // Create dummy
		}
		return cast<TerrainChunk@>(chunks[key]);
	}
	
	/*private TerrainChunk @generateChunk(const int chunkX, const int chunkY)
	{
		string key = chunkX+";"+chunkY;
		string chunkFile = scene::game.getWorldDir() + "/chunks/"+key+".obj";
		TerrainChunk@ chunk;
		if(FileSystem.fileExists(chunkFile))
		{
			// Load chunk from file
			@chunk = cast<TerrainChunk@>(Scripts.deserialize(chunkFile));
			chunk.setTerrain(@this);
			@chunks[key] = @chunk;
		}
		else
		{
			// Generate chunk
			@chunk = @TerrainChunk(@this, chunkX, chunkY);
			@chunks[key] = @chunk;
			generator.generate(@chunk, chunkX, chunkY);
		}
		
		updateChunk(chunkX, chunkY);
		return @chunk;
	}
	
	private void updateChunk(const int chunkX, const int chunkY)
	{
		TerrainChunk @chunk = getChunk(chunkX,   chunkY);
		if(!chunk.dummy)
		{
			for(int y = 0; y < CHUNK_SIZE; y++)
			{
				for(int x = 0; x < CHUNK_SIZE; x++)
				{
					chunk.updateTile(x, y, getTileState(chunkX *CHUNK_SIZE + x, chunkY *CHUNK_SIZE + y), true);
				}
			}
		}
	}*/
	
	// UPDATING
	void update()
	{
		game::debug.setVariable("Chunks", "" + chunks.getSize());
		
		int cx = Math.floor(game::camera.getCenter().x/CHUNK_SIZEF/TILE_SIZEF);
		int cy = Math.floor(game::camera.getCenter().y/CHUNK_SIZEF/TILE_SIZEF);
		TerrainChunk @chunk;
		if((@chunk = @getChunk(cx, cy, true)).getState() != CHUNK_INITIALIZED)
		{
			Console.log("Insta-loading chunk ["+cx+", "+cy+"]");
			
			// Since we're not a big fan of invisible collisions, we
			// will force a instantanious load of the chunk where
			// the player currently is
			int idx = chunkLoadQueue.findByRef(@chunk);
			TerrainChunk @chunk = @chunkLoadQueue[idx];
			chunkLoadQueue.removeAt(idx);
			while(!chunk.loadNext());
		}
		
		if(chunkLoadQueue.isEmpty())
		{
			return;
			//(@chunk = @getChunk(cx, cy, true))
		}
		
		// Load queued chunk
		@chunk = @chunkLoadQueue[chunkLoadQueue.size-1];
		for(int i = 0; i < chunkLoadSpeed; i++)
		{
			if(chunk.loadNext())
			{
				chunkLoadQueue.removeLast();
				break;
			}
		}
	}
	
	// DRAWING
	void draw(const TerrainLayer layer, Batch @batch)
	{
		int x0 = Math.floor(game::camera.position.x/CHUNK_SIZE/TILE_SIZE);
		int y0 = Math.floor(game::camera.position.y/CHUNK_SIZE/TILE_SIZE);
		int x1 = Math.floor((game::camera.position.x+Window.getSize().x)/CHUNK_SIZE/TILE_SIZE);
		int y1 = Math.floor((game::camera.position.y+Window.getSize().y)/CHUNK_SIZE/TILE_SIZE);
		
		/*int i = 0;
		while(Input.getKeyState(KEY_L))
		{
			getChunk(x0 + i++, y0, true);
		}*/
		
		for(int y = y0; y <= y1; y++)
		{
			for(int x = x0; x <= x1; x++)
			{
				Matrix4 projmat = game::camera.getProjectionMatrix();
				projmat.translate(x * CHUNK_SIZE * TILE_SIZE, y * CHUNK_SIZE * TILE_SIZE, 0.0f);
				getChunk(x, y, true).draw(projmat);
			}
		}
	}
}