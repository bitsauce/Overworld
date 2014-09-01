bool isValidTile(TileID tile)
{
	return tile != SCENE_TILES && tile != BACKGROUND_TILES &&
			tile != FOREGROUND_TILES && tile != MAX_TILES;
}

TerrainLayer getLayerByTile(TileID tile)
{
	if(tile < SCENE_TILES) return TERRAIN_SCENE;
	if(tile < BACKGROUND_TILES) return TERRAIN_BACKGROUND;
	return TERRAIN_FOREGROUND;
}
	
class Terrain : Serializable
{
	// Box2D body
	private b2Body @body;
	
	// Box2D tile fixtures
	private dictionary fixtures;
	
	// Terrain chunks
	private dictionary chunks;
	
	// Terrain generator
	TerrainGen generator;
	
	private void init()
	{
		Console.log("Initializing terrain");
	}
	
	void serialize(StringStream &ss)
	{
		Console.log("Saving terrain...");
		
		/*ss.write(width);
		ss.write(height);
		
		for(int i = 0; i < TERRAIN_LAYERS_MAX; i++)
		{
			string tileString;
			for(int y = 0; y < height; y++)
			{
				for(int x = 0; x < width; x++)
				{
					TileID tile = getTileAt(x, y, TerrainLayer(i));
					if(tile <= RESERVED_TILE) tile = NULL_TILE;
					tileString += formatInt(tile, "0", 3);
				}
			}
			ss.write(tileString);
		}*/
	}
	
	void deserialize(StringStream &ss)
	{
		init();
		/*Console.log("Loading terrain...");
		
		// Initialize terrain
		int width, height;
		ss.read(width);
		ss.read(height);
		init(width, height);
		
		// Load tiles from file
		for(int i = 0; i < TERRAIN_LAYERS_MAX; i++)
		{
			string tileString;
			ss.read(tileString);
			for(int y = 0; y < height; y++)
			{
				for(int x = 0; x < width; x++)
				{
					int j = (x + y*width) * 3;
					addTile(x, y, TileID(parseInt(tileString.substr(j, 3))));
				}
			}
		}
		
		// Set layers as initialized
		setInitialized(true);*/
	}
	
	// TILES
	TileID getTileAt(const int x, const int y, const TerrainLayer layer = TERRAIN_SCENE)
	{
		return getChunk(x / CHUNK_SIZE, y / CHUNK_SIZE).getTileAt(x % CHUNK_SIZE, y % CHUNK_SIZE);
	}
	
	bool isTileAt(const int x, const int y, TerrainLayer layer = TERRAIN_SCENE)
	{
		return getTileAt(x, y, layer) != NULL_TILE;
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
	
	// Terrain modification
	void addTile(const int x, const int y, TileID tile)
	{
		// Check for null tile
		if(tile == NULL_TILE)
			return;
		getChunk(x / CHUNK_SIZE, y / CHUNK_SIZE).addTile(x % CHUNK_SIZE, y % CHUNK_SIZE, tile);
	}
	
	void removeTile(const int x, const int y, TerrainLayer layer = TERRAIN_SCENE)
	{
		getChunk(x / CHUNK_SIZE, y / CHUNK_SIZE).removeTile(x % CHUNK_SIZE, y % CHUNK_SIZE);
	}
	
	// CHUNKS
	private TerrainChunk @getChunk(const int x, const int y)
	{
		string key = x+";"+y;
		if(!chunks.exists(key))
		{
			Console.log("Generate chunk ["+key+"]");
		
			b2BodyDef def;
			def.type = b2_staticBody;
			def.position.set(x * CHUNK_SIZE * TILE_SIZE, y * CHUNK_SIZE * TILE_SIZE);
			def.allowSleep = true;
			
			@body = b2Body(def);
			body.setObject(@this);
			
			TerrainChunk @chunk = @TerrainChunk(@body);
			@chunks[key] = @chunk;
			generator.generate(@chunk, x, y);
			return @chunk;
		}
		
		return cast<TerrainChunk@>(chunks[key]);
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
				getChunk(x, y).draw(projmat);
			}
		}
	}
}