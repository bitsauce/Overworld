TerrainLayer getLayerByTile(TileID tile)
{
	if(tile < SCENE_TILES) return TERRAIN_SCENE;
	if(tile < BACKGROUND_TILES) return TERRAIN_BACKGROUND;
	return TERRAIN_FOREGROUND;
}

int mod(int a, int b)
{
   int r = a % b;
   return r < 0 ? r + b : r;
}

const int MAX_PRELOADED_CHUNKS = 128;

class Terrain : Serializable
{
	// Terrain chunks
	private dictionary chunks;
	
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
	}
	
	void serialize(StringStream &ss)
	{
		Console.log("Saving terrain...");
		
		ss.write(generator.seed);
		
		array<string> @keys = chunks.getKeys();
		for(int i = 0; i < keys.size; i++)
		{
			string key = keys[i];
			ss.write(key);
			Scripts.serialize(cast<Serializable@>(chunks[key]), scene::game.getWorldDir() + "/chunks/" + key + ".obj");
		}
	}
	
	void deserialize(StringStream &ss)
	{
		Console.log("Loading terrain...");
		
		init();
		
		ss.read(generator.seed);
		
		array<string> @chunkFiles = @FileSystem.listFiles(scene::game.getWorldDir() + "/chunks", "*.obj");
		for(int i = 0; i < chunkFiles.size; i++)
		{
			string key;
			ss.read(key);
			
			TerrainChunk@ chunk = cast<TerrainChunk@>(Scripts.deserialize(chunkFiles[i]));
			chunk.setTerrain(@this);
			@chunks[key] = @chunk;
			
			updateChunk(chunk.getX(), chunk.getY());
		}
	}
	
	// TILE HELPERS
	TileID getTileAt(const int x, const int y, const TerrainLayer layer = TERRAIN_SCENE)
	{
		return getChunk(Math.floor(x / CHUNK_SIZEF), Math.floor(y / CHUNK_SIZEF)).getTileAt(mod(x, CHUNK_SIZE), mod(y, CHUNK_SIZE));
	}
	
	bool isTileAt(const int x, const int y, TerrainLayer layer = TERRAIN_SCENE)
	{
		return getTileAt(x, y, layer) > RESERVED_TILE;
	}
	
	uint getTileState(const int x, const int y, TerrainLayer layer = TERRAIN_SCENE) const
	{
		// Set state
		uint state = 0;
		if(getChunk(Math.floor(x     / CHUNK_SIZEF), Math.floor((y-1) / CHUNK_SIZEF)).isTileAt(mod(x,   CHUNK_SIZE), mod(y-1, CHUNK_SIZE))) state |= NORTH;
		if(getChunk(Math.floor(x     / CHUNK_SIZEF), Math.floor((y+1) / CHUNK_SIZEF)).isTileAt(mod(x,   CHUNK_SIZE), mod(y+1, CHUNK_SIZE))) state |= SOUTH;
		if(getChunk(Math.floor((x+1) / CHUNK_SIZEF), Math.floor(y     / CHUNK_SIZEF)).isTileAt(mod(x+1, CHUNK_SIZE), mod(y,   CHUNK_SIZE))) state |= EAST;
		if(getChunk(Math.floor((x-1) / CHUNK_SIZEF), Math.floor(y     / CHUNK_SIZEF)).isTileAt(mod(x-1, CHUNK_SIZE), mod(y,   CHUNK_SIZE))) state |= WEST;
		if(getChunk(Math.floor((x+1) / CHUNK_SIZEF), Math.floor((y-1) / CHUNK_SIZEF)).isTileAt(mod(x+1, CHUNK_SIZE), mod(y-1, CHUNK_SIZE))) state |= NORTH_EAST;
		if(getChunk(Math.floor((x-1) / CHUNK_SIZEF), Math.floor((y-1) / CHUNK_SIZEF)).isTileAt(mod(x-1, CHUNK_SIZE), mod(y-1, CHUNK_SIZE))) state |= NORTH_WEST;
		if(getChunk(Math.floor((x+1) / CHUNK_SIZEF), Math.floor((y+1) / CHUNK_SIZEF)).isTileAt(mod(x+1, CHUNK_SIZE), mod(y+1, CHUNK_SIZE))) state |= SOUTH_EAST;
		if(getChunk(Math.floor((x-1) / CHUNK_SIZEF), Math.floor((y+1) / CHUNK_SIZEF)).isTileAt(mod(x-1, CHUNK_SIZE), mod(y+1, CHUNK_SIZE))) state |= SOUTH_WEST;
		return state;
	}
	
	// TILE MODIFICATION
	bool addTile(const int x, const int y, TileID tile)
	{
		if(getChunk(Math.floor(x / CHUNK_SIZEF), Math.floor(y / CHUNK_SIZEF)).addTile(mod(x, CHUNK_SIZE), mod(y, CHUNK_SIZE), tile))
		{
			// Update neighbouring tiles
			getChunk(Math.floor(x     / CHUNK_SIZEF), Math.floor(y     / CHUNK_SIZEF)).updateTile(mod(x,   CHUNK_SIZE), mod(y,   CHUNK_SIZE), getTileState(x,   y), true);
			getChunk(Math.floor((x+1) / CHUNK_SIZEF), Math.floor(y     / CHUNK_SIZEF)).updateTile(mod(x+1, CHUNK_SIZE), mod(y,   CHUNK_SIZE), getTileState(x+1, y), true);
			getChunk(Math.floor((x-1) / CHUNK_SIZEF), Math.floor(y     / CHUNK_SIZEF)).updateTile(mod(x-1, CHUNK_SIZE), mod(y,   CHUNK_SIZE), getTileState(x-1, y), true);
			getChunk(Math.floor(x     / CHUNK_SIZEF), Math.floor((y+1) / CHUNK_SIZEF)).updateTile(mod(x,   CHUNK_SIZE), mod(y+1, CHUNK_SIZE), getTileState(x, y+1), true);
			getChunk(Math.floor(x     / CHUNK_SIZEF), Math.floor((y-1) / CHUNK_SIZEF)).updateTile(mod(x,   CHUNK_SIZE), mod(y-1, CHUNK_SIZE), getTileState(x, y-1), true);
			
			getChunk(Math.floor((x+1) / CHUNK_SIZEF), Math.floor((y+1) / CHUNK_SIZEF)).updateTile(mod(x+1, CHUNK_SIZE), mod(y+1, CHUNK_SIZE), getTileState(x+1, y+1));
			getChunk(Math.floor((x-1) / CHUNK_SIZEF), Math.floor((y+1) / CHUNK_SIZEF)).updateTile(mod(x-1, CHUNK_SIZE), mod(y+1, CHUNK_SIZE), getTileState(x-1, y+1));
			getChunk(Math.floor((x-1) / CHUNK_SIZEF), Math.floor((y-1) / CHUNK_SIZEF)).updateTile(mod(x-1, CHUNK_SIZE), mod(y-1, CHUNK_SIZE), getTileState(x-1, y-1));
			getChunk(Math.floor((x+1) / CHUNK_SIZEF), Math.floor((y-1) / CHUNK_SIZEF)).updateTile(mod(x+1, CHUNK_SIZE), mod(y-1, CHUNK_SIZE), getTileState(x+1, y-1));
			
			return true;
		}
		return false;
	}
	
	bool removeTile(const int x, const int y, TerrainLayer layer = TERRAIN_SCENE)
	{
		if(getChunk(Math.floor(x / CHUNK_SIZEF), Math.floor(y / CHUNK_SIZEF)).removeTile(mod(x, CHUNK_SIZE), mod(y, CHUNK_SIZE)))
		{
			// Update neighbouring tiles
			getChunk(Math.floor(x     / CHUNK_SIZEF), Math.floor(y     / CHUNK_SIZEF)).updateTile(mod(x,   CHUNK_SIZE), mod(y,   CHUNK_SIZE), getTileState(x,   y), true);
			getChunk(Math.floor((x+1) / CHUNK_SIZEF), Math.floor(y     / CHUNK_SIZEF)).updateTile(mod(x+1, CHUNK_SIZE), mod(y,   CHUNK_SIZE), getTileState(x+1, y), true);
			getChunk(Math.floor((x-1) / CHUNK_SIZEF), Math.floor(y     / CHUNK_SIZEF)).updateTile(mod(x-1, CHUNK_SIZE), mod(y,   CHUNK_SIZE), getTileState(x-1, y), true);
			getChunk(Math.floor(x     / CHUNK_SIZEF), Math.floor((y+1) / CHUNK_SIZEF)).updateTile(mod(x,   CHUNK_SIZE), mod(y+1, CHUNK_SIZE), getTileState(x, y+1), true);
			getChunk(Math.floor(x     / CHUNK_SIZEF), Math.floor((y-1) / CHUNK_SIZEF)).updateTile(mod(x,   CHUNK_SIZE), mod(y-1, CHUNK_SIZE), getTileState(x, y-1), true);
			
			getChunk(Math.floor((x+1) / CHUNK_SIZEF), Math.floor((y+1) / CHUNK_SIZEF)).updateTile(mod(x+1, CHUNK_SIZE), mod(y+1, CHUNK_SIZE), getTileState(x+1, y+1));
			getChunk(Math.floor((x-1) / CHUNK_SIZEF), Math.floor((y+1) / CHUNK_SIZEF)).updateTile(mod(x-1, CHUNK_SIZE), mod(y+1, CHUNK_SIZE), getTileState(x-1, y+1));
			getChunk(Math.floor((x-1) / CHUNK_SIZEF), Math.floor((y-1) / CHUNK_SIZEF)).updateTile(mod(x-1, CHUNK_SIZE), mod(y-1, CHUNK_SIZE), getTileState(x-1, y-1));
			getChunk(Math.floor((x+1) / CHUNK_SIZEF), Math.floor((y-1) / CHUNK_SIZEF)).updateTile(mod(x+1, CHUNK_SIZE), mod(y-1, CHUNK_SIZE), getTileState(x+1, y-1));
			
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
				return @generateChunk(chunkX, chunkY);
			}
			return @TerrainChunk();
		}
		return cast<TerrainChunk@>(chunks[key]);
	}
	
	private TerrainChunk @generateChunk(const int chunkX, const int chunkY)
	{
		TerrainChunk @chunk = @TerrainChunk(@this, chunkX, chunkY);
		@chunks[chunkX+";"+chunkY] = @chunk;
		generator.generate(@chunk, chunkX, chunkY);
		updateChunk(chunkX, chunkY);
		return @chunk;
	}
	
	private void updateChunk(const int chunkX, const int chunkY)
	{
		TerrainChunk @chunk = getChunk(chunkX, chunkY);
		if(@chunk != null)
		{
			for(int y = 0; y < CHUNK_SIZE; y++)
			{
				for(int x = 0; x < CHUNK_SIZE; x++)
				{
					chunk.updateTile(x, y, getTileState(chunkX * CHUNK_SIZE + x, chunkY * CHUNK_SIZE + y), true);
				}
			}
		}
	}
	
	bool test = true;
	
	// UPDATING
	void update()
	{
		if(test)
		{
			thread th(funccall(@this, "findAndGenerateChunk"));
			th.detach();
			test = false;
		}
	}
	
	void findAndGenerateChunk()
	{
		if(chunks.getSize() >= MAX_PRELOADED_CHUNKS)
			return;
		Vector2 center = game::camera.position + Vector2(Window.getSize())*0.5f;
		int chunkX = center.x/CHUNK_SIZE/TILE_SIZE;
		int chunkY = center.x/CHUNK_SIZE/TILE_SIZE;
		
		int step = 1;
		int dir = 1;
		bool found = false;
		while(!found)
		{
			dir = step % 2 == 0 ? -1 : 1;
			for(int j = 0; !found && j < 2; j++)
			{
				int dx = (1-j)*dir;
				int dy = j*dir;
				for(int i = 0; !found && i < step; i++)
				{
					chunkX += dx;
					chunkY += dy;
					found = !chunks.exists(chunkX+";"+chunkY);
				}
			}
			step++;
		}
		
		generateChunk(chunkX, chunkY);
		test = true;
	}
	
	// DRAWING
	void draw(const TerrainLayer layer, Matrix4)
	{
		int x0 = Math.floor(game::camera.position.x/CHUNK_SIZE/TILE_SIZE);
		int y0 = Math.floor(game::camera.position.y/CHUNK_SIZE/TILE_SIZE);
		int x1 = Math.floor((game::camera.position.x+Window.getSize().x)/CHUNK_SIZE/TILE_SIZE);
		int y1 = Math.floor((game::camera.position.y+Window.getSize().y)/CHUNK_SIZE/TILE_SIZE);
		
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