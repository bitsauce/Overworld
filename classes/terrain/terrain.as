TerrainLayer getLayerByTile(TileID tile)
{
	if(tile < SCENE_TILES) return TERRAIN_SCENE;
	if(tile < BACKGROUND_TILES) return TERRAIN_BACKGROUND;
	return TERRAIN_FOREGROUND;
}

const int MAX_LOADED_CHUNKS = 128;

class TerrainManager : Serializable
{
	// Terrain chunks
	private array<TerrainChunk@> loadedChunks;
	private array<TerrainChunk@> chunkLoadQueue;
	private dictionary chunks;
	private VertexFormat vertexFormat;
	
	// Terrain generator
	TerrainGen generator;
	
	// For selecting a direction to generate in
	Vector2 prevCameraPos;
	
	TerrainManager()
	{
		init();
		generator.seed = Math.getRandomInt();
	}
	
	// SERIALIZATION
	private void init()
	{
		Console.log("Initializing terrain");
		
		// Setup vertex format
		vertexFormat.set(VERTEX_POSITION, 2);
		vertexFormat.set(VERTEX_TEX_COORD, 2);
	}
	
	VertexFormat getVertexFormat() const
	{
		return vertexFormat;
	}
	
	void serialize(StringStream &ss)
	{
		Console.log("Saving terrain...");
		
		ss.write(generator.seed);
		
		array<string> @keys = chunks.getKeys();
		for(int i = 0; i < keys.size; ++i)
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
		// Get state
		uint state = 0;
		int chunkX = Math.floor(x / CHUNK_SIZEF), chunkY = Math.floor(y / CHUNK_SIZEF), tileX = Math.mod(x, CHUNK_SIZE), tileY = Math.mod(y, CHUNK_SIZE);
		TerrainChunk @chunk = @getChunk(chunkX, chunkY), chunkN, chunkS;
		if(chunk.getState() == CHUNK_DUMMY) return 0;
		
		TileID tile = chunk.getTileAt(tileX, tileY);
		if(tileY == 0)
		{
			@chunkN = @getChunk(chunkX, chunkY-1);
			if(chunkN.getTileAt(tileX, CHUNK_SIZE-1) == tile) state |= NORTH;
			if(chunk.getTileAt(tileX, tileY+1) == tile) state |= SOUTH;
		}
		else if(tileY == CHUNK_SIZE-1)
		{
			@chunkS = @getChunk(chunkX, chunkY+1);
			if(chunkS.getTileAt(tileX, 0) == tile) state |= SOUTH;
			if(chunk.getTileAt(tileX, tileY-1) == tile) state |= NORTH;
		}
		else
		{
			if(chunk.getTileAt(tileX, tileY-1) == tile) state |= NORTH;
			if(chunk.getTileAt(tileX, tileY+1) == tile) state |= SOUTH;
		}
		
		if(tileX == 0)
		{
			TerrainChunk @chunkW = @getChunk(chunkX-1, chunkY);
			if(chunkW.getTileAt(CHUNK_SIZE-1, tileY) == tile) state |= WEST;
			if(tileY == 0)
			{
				if(getChunk(chunkX-1, chunkY-1).getTileAt(CHUNK_SIZE-1, CHUNK_SIZE-1) == tile) state |= NORTH_WEST;
				if(chunkW.getTileAt(CHUNK_SIZE-1, tileY+1) == tile) state |= SOUTH_WEST;
				if(chunkN.getTileAt(tileX+1, CHUNK_SIZE-1) == tile) state |= NORTH_EAST;
				if(chunk.getTileAt(tileX+1, tileY+1) == tile) state |= SOUTH_EAST;
			}
			else if(tileY == CHUNK_SIZE-1)
			{
				if(getChunk(chunkX-1, chunkY+1).getTileAt(CHUNK_SIZE-1, 0) == tile) state |= SOUTH_WEST;
				if(chunkW.getTileAt(CHUNK_SIZE-1, tileY-1) == tile) state |= NORTH_WEST;
				if(chunk.getTileAt(tileX+1, tileY-1) == tile) state |= NORTH_EAST;
				if(chunkS.getTileAt(tileX+1, 0) == tile) state |= SOUTH_EAST;
			}
			else
			{
				if(chunkW.getTileAt(CHUNK_SIZE-1, tileY-1) == tile) state |= NORTH_WEST;
				if(chunkW.getTileAt(CHUNK_SIZE-1, tileY+1) == tile) state |= SOUTH_WEST;
				if(chunk.getTileAt(tileX+1, tileY-1) == tile) state |= NORTH_EAST;
				if(chunk.getTileAt(tileX+1, tileY+1) == tile) state |= SOUTH_EAST;
			}
			if(chunk.getTileAt(tileX+1, tileY) == tile) state |= EAST;
		}
		else if(tileX == CHUNK_SIZE-1)
		{
			TerrainChunk @chunkE = @getChunk(chunkX+1, chunkY);
			if(chunkE.getTileAt(0, tileY) == tile) state |= EAST;
			if(tileY == 0)
			{
				if(getChunk(chunkX+1, chunkY-1).getTileAt(0, CHUNK_SIZE-1) == tile) state |= NORTH_EAST;
				if(chunkE.getTileAt(0, tileY+1) == tile) state |= SOUTH_EAST;
				if(chunkN.getTileAt(tileX-1, CHUNK_SIZE-1) == tile) state |= NORTH_WEST;
				if(chunk.getTileAt(tileX-1, tileY+1) == tile) state |= SOUTH_WEST;
			}
			else if(tileY == CHUNK_SIZE-1)
			{
				if(getChunk(chunkX+1, chunkY+1).getTileAt(0, 0) == tile) state |= SOUTH_EAST;
				if(chunkE.getTileAt(0, tileY-1) == tile) state |= NORTH_EAST;
				if(chunk.getTileAt(tileX-1, tileY-1) == tile) state |= NORTH_WEST;
				if(chunkS.getTileAt(tileX-1, 0) == tile) state |= SOUTH_WEST;
			}
			else
			{
				if(chunkE.getTileAt(0, tileY-1) == tile) state |= NORTH_EAST;
				if(chunkE.getTileAt(0, tileY+1) == tile) state |= SOUTH_EAST;
				if(chunk.getTileAt(tileX-1, tileY-1) == tile) state |= NORTH_WEST;
				if(chunk.getTileAt(tileX-1, tileY+1) == tile) state |= SOUTH_WEST;
			}
			if(chunk.getTileAt(tileX-1, tileY) == tile) state |= WEST;
		}
		else
		{
			if(chunk.getTileAt(tileX-1, tileY) == tile) state |= WEST;
			if(chunk.getTileAt(tileX+1, tileY) == tile) state |= EAST;
			if(tileY == 0)
			{
				if(chunkN.getTileAt(tileX+1, CHUNK_SIZE-1) == tile) state |= NORTH_EAST;
				if(chunkN.getTileAt(tileX-1, CHUNK_SIZE-1) == tile) state |= NORTH_WEST;
				if(chunk.getTileAt(tileX+1, tileY+1) == tile) state |= SOUTH_EAST;
				if(chunk.getTileAt(tileX-1, tileY+1) == tile) state |= SOUTH_WEST;
			}
			else if(tileY == CHUNK_SIZE-1)
			{
				if(chunkS.getTileAt(tileX+1, 0) == tile) state |= SOUTH_EAST;
				if(chunkS.getTileAt(tileX-1, 0) == tile) state |= SOUTH_WEST;
				if(chunk.getTileAt(tileX+1, tileY-1) == tile) state |= NORTH_EAST;
				if(chunk.getTileAt(tileX-1, tileY-1) == tile) state |= NORTH_WEST;
			}
			else
			{
				if(chunk.getTileAt(tileX+1, tileY-1) == tile) state |= NORTH_EAST;
				if(chunk.getTileAt(tileX-1, tileY-1) == tile) state |= NORTH_WEST;
				if(chunk.getTileAt(tileX+1, tileY+1) == tile) state |= SOUTH_EAST;
				if(chunk.getTileAt(tileX-1, tileY+1) == tile) state |= SOUTH_WEST;
			}
		}
		
		return state;
	}
	
	// TILE MODIFICATION
	bool setTile(const int x, const int y, TileID tile)
	{
		if(getChunk(Math.floor(x / CHUNK_SIZEF), Math.floor(y / CHUNK_SIZEF)).setTile(Math.mod(x, CHUNK_SIZE), Math.mod(y, CHUNK_SIZE), tile))
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
		if(getChunk(Math.floor(x / CHUNK_SIZEF), Math.floor(y / CHUNK_SIZEF)).setTile(Math.mod(x, CHUNK_SIZE), Math.mod(y, CHUNK_SIZE), EMPTY_TILE))
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
	TerrainChunk @getChunk(const int chunkX, const int chunkY, const bool generate = false)
	{
		string key = chunkX+";"+chunkY;
		if(!chunks.exists(key))
		{
			if(generate)
			{
				Console.log("Chunk ["+chunkX+", "+chunkY+"] added to queue");
			
				// Create new chunk
				TerrainChunk @chunk = @TerrainChunk(chunkX, chunkY);
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
	
	void loadVisibleChunks()
	{
		int x0 = Math.floor(Camera.position.x/CHUNK_SIZE/TILE_SIZE);
		int y0 = Math.floor(Camera.position.y/CHUNK_SIZE/TILE_SIZE);
		int x1 = Math.floor((Camera.position.x+Window.getSize().x)/CHUNK_SIZE/TILE_SIZE);
		int y1 = Math.floor((Camera.position.y+Window.getSize().y)/CHUNK_SIZE/TILE_SIZE);
		
		TerrainChunk @chunk;
		for(int y = y0; y <= y1; y++)
		{
			for(int x = x0; x <= x1; x++)
			{
				if((@chunk = @getChunk(x, y, true)).getState() != CHUNK_INITIALIZED)
				{
					chunk.generate();
				}
			}
		}
		chunkLoadQueue.clear();
	}
	
	// UPDATING
	void update()
	{
		Debug.setVariable("Chunks", "" + chunks.getSize());
		
		int cx = Math.floor(Camera.getCenter().x/CHUNK_SIZEF/TILE_SIZEF);
		int cy = Math.floor(Camera.getCenter().y/CHUNK_SIZEF/TILE_SIZEF);
		TerrainChunk @chunk;
		if((@chunk = @getChunk(cx, cy, true)).getState() != CHUNK_INITIALIZED)
		{
			Console.log("Insta-generate chunk ["+cx+", "+cy+"]");
			int idx = chunkLoadQueue.findByRef(@chunk);
			if(idx >= 0) chunkLoadQueue.removeAt(idx);
			chunk.generate();
		}
		
		if(!chunkLoadQueue.isEmpty())
		{
			// Load queued chunk
			chunkLoadQueue[chunkLoadQueue.size-1].generate();
			chunkLoadQueue.removeLast();
		}
	}
	
	// DRAWING
	void draw(const TerrainLayer layer, Batch @batch)
	{
		int x0 = Math.floor(Camera.position.x/CHUNK_SIZE/TILE_SIZE);
		int y0 = Math.floor(Camera.position.y/CHUNK_SIZE/TILE_SIZE);
		int x1 = Math.floor((Camera.position.x+Window.getSize().x)/CHUNK_SIZE/TILE_SIZE);
		int y1 = Math.floor((Camera.position.y+Window.getSize().y)/CHUNK_SIZE/TILE_SIZE);
		
		for(int y = y0; y <= y1; y++)
		{
			for(int x = x0; x <= x1; x++)
			{
				Matrix4 projmat = Camera.getProjectionMatrix();
				projmat.translate(x * CHUNK_SIZE * TILE_SIZE, y * CHUNK_SIZE * TILE_SIZE, 0.0f);
				getChunk(x, y, true).draw(projmat);
			}
		}
	}
}