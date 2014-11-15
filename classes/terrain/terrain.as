TerrainLayer getLayerByTile(TileID tile)
{
	if(tile < BACKGROUND_TILES) return TERRAIN_BACKGROUND;
	if(tile < SCENE_TILES) return TERRAIN_SCENE;
	return TERRAIN_FOREGROUND;
}

const int MAX_LOADED_CHUNKS = 128;

class TerrainManager
{
	// Terrain chunks
	private array<TerrainChunk@> loadedChunks;
	private array<TerrainChunk@> chunkLoadQueue;
	private dictionary chunks;
	private dictionary superChunks;
	private VertexFormat vertexFormat;
	
	// Terrain generator
	TerrainGen generator;
	
	// For selecting a direction to generate in
	Vector2 prevCameraPos;
	
	TerrainManager()
	{
		Console.log("Initializing terrain");
		
		// Setup vertex format
		vertexFormat.set(VERTEX_POSITION, 2);
		vertexFormat.set(VERTEX_TEX_COORD, 2);
		
		// Get terrain seed
		generator.seed = Random().nextInt();
	}
	
	// VERTEX FORMAT
	VertexFormat getVertexFormat() const
	{
		return vertexFormat;
	}
	
	// Move?
	void saveChunks()
	{
		Console.log("Saving chunks...");
		array<string> @keys = chunks.getKeys();
		for(int i = 0; i < keys.size; ++i)
		{
			string key = keys[i];
			if(cast<TerrainChunk@>(chunks[key]).modified)
			{
				Scripts.serialize(cast<Serializable@>(chunks[key]), World.getWorldPath() + "/chunks/" + key + ".obj");
			}
		}
	}
	
	void load(IniFile @file)
	{
		Console.log("Loading terrain...");
		
		generator.seed = parseInt(file.getValue("terrain", "seed"));
	}
	
	// TILE HELPERS
	TileID getTileAt(const int x, const int y, const TerrainLayer layer = TERRAIN_SCENE)
	{
		return getChunk(Math.floor(x / CHUNK_SIZEF), Math.floor(y / CHUNK_SIZEF)).getTileAt(Math.mod(x, CHUNK_SIZE), Math.mod(y, CHUNK_SIZE), layer);
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
		
		TileID tile = chunk.getTileAt(tileX, tileY, layer);
		if(tileY == 0)
		{
			@chunkN = @getChunk(chunkX, chunkY-1);
			if(chunkN.getTileAt(tileX, CHUNK_SIZE-1, layer) == tile) state |= NORTH;
			if(chunk.getTileAt(tileX, tileY+1, layer) == tile) state |= SOUTH;
		}
		else if(tileY == CHUNK_SIZE-1)
		{
			@chunkS = @getChunk(chunkX, chunkY+1);
			if(chunkS.getTileAt(tileX, 0, layer) == tile) state |= SOUTH;
			if(chunk.getTileAt(tileX, tileY-1, layer) == tile) state |= NORTH;
		}
		else
		{
			if(chunk.getTileAt(tileX, tileY-1, layer) == tile) state |= NORTH;
			if(chunk.getTileAt(tileX, tileY+1, layer) == tile) state |= SOUTH;
		}
		
		if(tileX == 0)
		{
			TerrainChunk @chunkW = @getChunk(chunkX-1, chunkY);
			if(chunkW.getTileAt(CHUNK_SIZE-1, tileY, layer) == tile) state |= WEST;
			if(tileY == 0)
			{
				if(getChunk(chunkX-1, chunkY-1).getTileAt(CHUNK_SIZE-1, CHUNK_SIZE-1, layer) == tile) state |= NORTH_WEST;
				if(chunkW.getTileAt(CHUNK_SIZE-1, tileY+1, layer) == tile) state |= SOUTH_WEST;
				if(chunkN.getTileAt(tileX+1, CHUNK_SIZE-1, layer) == tile) state |= NORTH_EAST;
				if(chunk.getTileAt(tileX+1, tileY+1, layer) == tile) state |= SOUTH_EAST;
			}
			else if(tileY == CHUNK_SIZE-1)
			{
				if(getChunk(chunkX-1, chunkY+1).getTileAt(CHUNK_SIZE-1, 0, layer) == tile) state |= SOUTH_WEST;
				if(chunkW.getTileAt(CHUNK_SIZE-1, tileY-1, layer) == tile) state |= NORTH_WEST;
				if(chunk.getTileAt(tileX+1, tileY-1, layer) == tile) state |= NORTH_EAST;
				if(chunkS.getTileAt(tileX+1, 0, layer) == tile) state |= SOUTH_EAST;
			}
			else
			{
				if(chunkW.getTileAt(CHUNK_SIZE-1, tileY-1, layer) == tile) state |= NORTH_WEST;
				if(chunkW.getTileAt(CHUNK_SIZE-1, tileY+1, layer) == tile) state |= SOUTH_WEST;
				if(chunk.getTileAt(tileX+1, tileY-1, layer) == tile) state |= NORTH_EAST;
				if(chunk.getTileAt(tileX+1, tileY+1, layer) == tile) state |= SOUTH_EAST;
			}
			if(chunk.getTileAt(tileX+1, tileY, layer) == tile) state |= EAST;
		}
		else if(tileX == CHUNK_SIZE-1)
		{
			TerrainChunk @chunkE = @getChunk(chunkX+1, chunkY);
			if(chunkE.getTileAt(0, tileY, layer) == tile) state |= EAST;
			if(tileY == 0)
			{
				if(getChunk(chunkX+1, chunkY-1).getTileAt(0, CHUNK_SIZE-1, layer) == tile) state |= NORTH_EAST;
				if(chunkE.getTileAt(0, tileY+1, layer) == tile) state |= SOUTH_EAST;
				if(chunkN.getTileAt(tileX-1, CHUNK_SIZE-1, layer) == tile) state |= NORTH_WEST;
				if(chunk.getTileAt(tileX-1, tileY+1, layer) == tile) state |= SOUTH_WEST;
			}
			else if(tileY == CHUNK_SIZE-1)
			{
				if(getChunk(chunkX+1, chunkY+1).getTileAt(0, 0, layer) == tile) state |= SOUTH_EAST;
				if(chunkE.getTileAt(0, tileY-1, layer) == tile) state |= NORTH_EAST;
				if(chunk.getTileAt(tileX-1, tileY-1, layer) == tile) state |= NORTH_WEST;
				if(chunkS.getTileAt(tileX-1, 0, layer) == tile) state |= SOUTH_WEST;
			}
			else
			{
				if(chunkE.getTileAt(0, tileY-1, layer) == tile) state |= NORTH_EAST;
				if(chunkE.getTileAt(0, tileY+1, layer) == tile) state |= SOUTH_EAST;
				if(chunk.getTileAt(tileX-1, tileY-1, layer) == tile) state |= NORTH_WEST;
				if(chunk.getTileAt(tileX-1, tileY+1, layer) == tile) state |= SOUTH_WEST;
			}
			if(chunk.getTileAt(tileX-1, tileY, layer) == tile) state |= WEST;
		}
		else
		{
			if(chunk.getTileAt(tileX-1, tileY, layer) == tile) state |= WEST;
			if(chunk.getTileAt(tileX+1, tileY, layer) == tile) state |= EAST;
			if(tileY == 0)
			{
				if(chunkN.getTileAt(tileX+1, CHUNK_SIZE-1, layer) == tile) state |= NORTH_EAST;
				if(chunkN.getTileAt(tileX-1, CHUNK_SIZE-1, layer) == tile) state |= NORTH_WEST;
				if(chunk.getTileAt(tileX+1, tileY+1, layer) == tile) state |= SOUTH_EAST;
				if(chunk.getTileAt(tileX-1, tileY+1, layer) == tile) state |= SOUTH_WEST;
			}
			else if(tileY == CHUNK_SIZE-1)
			{
				if(chunkS.getTileAt(tileX+1, 0, layer) == tile) state |= SOUTH_EAST;
				if(chunkS.getTileAt(tileX-1, 0, layer) == tile) state |= SOUTH_WEST;
				if(chunk.getTileAt(tileX+1, tileY-1, layer) == tile) state |= NORTH_EAST;
				if(chunk.getTileAt(tileX-1, tileY-1, layer) == tile) state |= NORTH_WEST;
			}
			else
			{
				if(chunk.getTileAt(tileX+1, tileY-1, layer) == tile) state |= NORTH_EAST;
				if(chunk.getTileAt(tileX-1, tileY-1, layer) == tile) state |= NORTH_WEST;
				if(chunk.getTileAt(tileX+1, tileY+1, layer) == tile) state |= SOUTH_EAST;
				if(chunk.getTileAt(tileX-1, tileY+1, layer) == tile) state |= SOUTH_WEST;
			}
		}
		
		return state;
	}
	
	// TILE MODIFICATION
	bool setTile(const int x, const int y, TileID tile, const TerrainLayer layer = TERRAIN_SCENE)
	{
		if(getChunk(Math.floor(x / CHUNK_SIZEF), Math.floor(y / CHUNK_SIZEF)).setTile(Math.mod(x, CHUNK_SIZE), Math.mod(y, CHUNK_SIZE), tile, layer))
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
		if(getChunk(Math.floor(x / CHUNK_SIZEF), Math.floor(y / CHUNK_SIZEF)).setTile(Math.mod(x, CHUNK_SIZE), Math.mod(y, CHUNK_SIZE), EMPTY_TILE, layer))
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
				TerrainChunk @chunk;
				string chunkFile = World.getWorldPath() + "/chunks/" + key + ".obj";
				if(FileSystem.fileExists(chunkFile))
				{
					@chunk = cast<TerrainChunk>(@Scripts.deserialize(chunkFile));
				}
				else
				{
					@chunk = @TerrainChunk(chunkX, chunkY);
					chunkLoadQueue.insertAt(0, @chunk); // Add to load queue
				}
				
				@chunks[key] = @chunk;
				return @chunk;
			}
			return @TerrainChunk(); // Create dummy
		}
		return cast<TerrainChunk@>(chunks[key]);
	}
	
	void loadVisibleChunks()
	{
		int x0 = Math.floor(Camera.position.x/CHUNK_SIZE/TILE_PX);
		int y0 = Math.floor(Camera.position.y/CHUNK_SIZE/TILE_PX);
		int x1 = Math.floor((Camera.position.x+Window.getSize().x)/CHUNK_SIZE/TILE_PX);
		int y1 = Math.floor((Camera.position.y+Window.getSize().y)/CHUNK_SIZE/TILE_PX);
		
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
		
		int cx = Math.floor(Camera.getCenter().x/CHUNK_SIZEF/TILE_PXF);
		int cy = Math.floor(Camera.getCenter().y/CHUNK_SIZEF/TILE_PXF);
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
		int x0 = Math.floor(Camera.position.x/CHUNK_SIZE/TILE_PX);
		int y0 = Math.floor(Camera.position.y/CHUNK_SIZE/TILE_PX);
		int x1 = Math.floor((Camera.position.x+Window.getSize().x)/CHUNK_SIZE/TILE_PX);
		int y1 = Math.floor((Camera.position.y+Window.getSize().y)/CHUNK_SIZE/TILE_PX);
		
		for(int y = y0; y <= y1; y++)
		{
			for(int x = x0; x <= x1; x++)
			{
				Matrix4 projmat = Camera.getProjectionMatrix();
				projmat.translate(x * CHUNK_SIZE * TILE_PX, y * CHUNK_SIZE * TILE_PX, 0.0f);
				getChunk(x, y, true).draw(projmat);
			}
		}
	}
}