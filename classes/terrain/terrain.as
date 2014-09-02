TerrainLayer getLayerByTile(TileID tile)
{
	if(tile < SCENE_TILES) return TERRAIN_SCENE;
	if(tile < BACKGROUND_TILES) return TERRAIN_BACKGROUND;
	return TERRAIN_FOREGROUND;
}
	
class Terrain : Serializable
{
	// Terrain chunks
	private dictionary chunks;
	
	// Terrain generator
	TerrainGen generator;
	
	// SERIALIZATION
	private void init()
	{
		Console.log("Initializing terrain");
	}
	
	void serialize(StringStream &ss)
	{
		Console.log("Saving terrain...");
		
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
		return getChunk(x / CHUNK_SIZE, y / CHUNK_SIZE).getTileAt(x % CHUNK_SIZE, y % CHUNK_SIZE);
	}
	
	bool isTileAt(const int x, const int y, TerrainLayer layer = TERRAIN_SCENE)
	{
		return getTileAt(x, y, layer) > RESERVED_TILE;
	}
	
	uint getTileState(const int x, const int y, TerrainLayer layer = TERRAIN_SCENE) const
	{
		// Set state
		uint state = 0;
		if(getChunk(x     / CHUNK_SIZE, (y-1) / CHUNK_SIZE).isTileAt(x     % CHUNK_SIZE, (y-1) % CHUNK_SIZE)) state |= NORTH;
		if(getChunk(x     / CHUNK_SIZE, (y+1) / CHUNK_SIZE).isTileAt(x     % CHUNK_SIZE, (y+1) % CHUNK_SIZE)) state |= SOUTH;
		if(getChunk((x+1) / CHUNK_SIZE, y     / CHUNK_SIZE).isTileAt((x+1) % CHUNK_SIZE, y     % CHUNK_SIZE)) state |= EAST;
		if(getChunk((x-1) / CHUNK_SIZE, y     / CHUNK_SIZE).isTileAt((x-1) % CHUNK_SIZE, y     % CHUNK_SIZE)) state |= WEST;
		if(getChunk((x+1) / CHUNK_SIZE, (y-1) / CHUNK_SIZE).isTileAt((x+1) % CHUNK_SIZE, (y-1) % CHUNK_SIZE)) state |= NORTH_EAST;
		if(getChunk((x-1) / CHUNK_SIZE, (y-1) / CHUNK_SIZE).isTileAt((x-1) % CHUNK_SIZE, (y-1) % CHUNK_SIZE)) state |= NORTH_WEST;
		if(getChunk((x+1) / CHUNK_SIZE, (y+1) / CHUNK_SIZE).isTileAt((x+1) % CHUNK_SIZE, (y+1) % CHUNK_SIZE)) state |= SOUTH_EAST;
		if(getChunk((x-1) / CHUNK_SIZE, (y+1) / CHUNK_SIZE).isTileAt((x-1) % CHUNK_SIZE, (y+1) % CHUNK_SIZE)) state |= SOUTH_WEST;
		return state;
	}
	
	// TILE MODIFICATION
	bool addTile(const int x, const int y, TileID tile)
	{
		if(getChunk(x / CHUNK_SIZE, y / CHUNK_SIZE).addTile(x % CHUNK_SIZE, y % CHUNK_SIZE, tile))
		{
			// Update neighbouring tiles
			getChunk(x     / CHUNK_SIZE, y     / CHUNK_SIZE).updateTile(x     % CHUNK_SIZE, y     % CHUNK_SIZE, getTileState(x, y), true);
			getChunk((x+1) / CHUNK_SIZE, y     / CHUNK_SIZE).updateTile((x+1) % CHUNK_SIZE, y     % CHUNK_SIZE, getTileState(x+1, y), true);
			getChunk((x-1) / CHUNK_SIZE, y     / CHUNK_SIZE).updateTile((x-1) % CHUNK_SIZE, y     % CHUNK_SIZE, getTileState(x-1, y), true);
			getChunk(x     / CHUNK_SIZE, (y+1) / CHUNK_SIZE).updateTile(x     % CHUNK_SIZE, (y+1) % CHUNK_SIZE, getTileState(x, y+1), true);
			getChunk(x     / CHUNK_SIZE, (y-1) / CHUNK_SIZE).updateTile(x     % CHUNK_SIZE, (y-1) % CHUNK_SIZE, getTileState(x, y-1), true);
			
			getChunk((x+1) / CHUNK_SIZE, (y+1) / CHUNK_SIZE).updateTile((x+1) % CHUNK_SIZE, (y+1) % CHUNK_SIZE, getTileState(x+1, y+1));
			getChunk((x-1) / CHUNK_SIZE, (y+1) / CHUNK_SIZE).updateTile((x-1) % CHUNK_SIZE, (y+1) % CHUNK_SIZE, getTileState(x-1, y+1));
			getChunk((x-1) / CHUNK_SIZE, (y-1) / CHUNK_SIZE).updateTile((x-1) % CHUNK_SIZE, (y-1) % CHUNK_SIZE, getTileState(x-1, y-1));
			getChunk((x+1) / CHUNK_SIZE, (y-1) / CHUNK_SIZE).updateTile((x+1) % CHUNK_SIZE, (y-1) % CHUNK_SIZE, getTileState(x+1, y-1));
			
			return true;
		}
		return false;
	}
	
	bool removeTile(const int x, const int y, TerrainLayer layer = TERRAIN_SCENE)
	{
		if(getChunk(x / CHUNK_SIZE, y / CHUNK_SIZE).removeTile(x % CHUNK_SIZE, y % CHUNK_SIZE))
		{
			// Update neighbouring tiles
			getChunk(x     / CHUNK_SIZE, y     / CHUNK_SIZE).updateTile(x     % CHUNK_SIZE, y     % CHUNK_SIZE, getTileState(x, y), true);
			getChunk((x+1) / CHUNK_SIZE, y     / CHUNK_SIZE).updateTile((x+1) % CHUNK_SIZE, y     % CHUNK_SIZE, getTileState(x+1, y), true);
			getChunk((x-1) / CHUNK_SIZE, y     / CHUNK_SIZE).updateTile((x-1) % CHUNK_SIZE, y     % CHUNK_SIZE, getTileState(x-1, y), true);
			getChunk(x     / CHUNK_SIZE, (y+1) / CHUNK_SIZE).updateTile(x     % CHUNK_SIZE, (y+1) % CHUNK_SIZE, getTileState(x, y+1), true);
			getChunk(x     / CHUNK_SIZE, (y-1) / CHUNK_SIZE).updateTile(x     % CHUNK_SIZE, (y-1) % CHUNK_SIZE, getTileState(x, y-1), true);
			
			getChunk((x+1) / CHUNK_SIZE, (y+1) / CHUNK_SIZE).updateTile((x+1) % CHUNK_SIZE, (y+1) % CHUNK_SIZE, getTileState(x+1, y+1));
			getChunk((x-1) / CHUNK_SIZE, (y+1) / CHUNK_SIZE).updateTile((x-1) % CHUNK_SIZE, (y+1) % CHUNK_SIZE, getTileState(x-1, y+1));
			getChunk((x-1) / CHUNK_SIZE, (y-1) / CHUNK_SIZE).updateTile((x-1) % CHUNK_SIZE, (y-1) % CHUNK_SIZE, getTileState(x-1, y-1));
			getChunk((x+1) / CHUNK_SIZE, (y-1) / CHUNK_SIZE).updateTile((x+1) % CHUNK_SIZE, (y-1) % CHUNK_SIZE, getTileState(x+1, y-1));
			
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
				TerrainChunk @chunk = @TerrainChunk(@this, chunkX, chunkY);
				@chunks[key] = @chunk;
				generator.generate(@chunk, chunkX, chunkY);
				updateChunk(chunkX, chunkY);
				return @chunk;
			}
			return @TerrainChunk();
		}
		return cast<TerrainChunk@>(chunks[key]);
	}
	
	private void updateChunk(const int chunkX, const int chunkY)
	{
		TerrainChunk @chunk = getChunk(chunkX, chunkY);
		if(@chunk != null) {
			for(int y = 0; y < CHUNK_SIZE; y++) {
				for(int x = 0; x < CHUNK_SIZE; x++) {
					chunk.updateTile(x, y, getTileState(chunkX * CHUNK_SIZE + x, chunkY * CHUNK_SIZE + y), true);
				}
			}
		}
	}
	
	// DRAWING
	void draw(const TerrainLayer layer, Matrix4)
	{
		int x0 = game::camera.position.x/CHUNK_SIZE/TILE_SIZE;
		int y0 = game::camera.position.y/CHUNK_SIZE/TILE_SIZE;
		int x1 = (game::camera.position.x+Window.getSize().x)/CHUNK_SIZE/TILE_SIZE;
		int y1 = (game::camera.position.y+Window.getSize().y)/CHUNK_SIZE/TILE_SIZE;
		
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

	private void updateOpacity(const int x, const int y)
	{
		/*float opacity = 0.0f;
		for(int i = 0; i < TERRAIN_LAYERS_MAX; i++) {
			opacity += game::tiles[getTileAt(x, y, TerrainLayer(i))].getOpacity();
		}

		array<Vector4> pixel = {
			Vector4(0.0f, 0.0f, 0.0f, opacity)
		};

		shadowMap.updateSection(x, y, Pixmap(1, 1, pixel));*/
	}
}