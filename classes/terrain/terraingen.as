float step(float edge, float x)
{
	return x < edge ? 0.0f : 1.0f;
}

class Structure
{
	int x = 0;
	int y = 0;
	int width;
	int height;
	int originX;
	int originY;
	
	TileID getTileAt(const int x, const int y, TerrainLayer layer)
	{
		return EMPTY_TILE;
	}
}

class Tree : Structure
{
	Tree()
	{
		width = 10;
		height = 15;
		originX = 5;
		originY = 15;
	}
	
	TileID getTileAt(const int x, const int y, TerrainLayer layer)
	{
		switch(layer)
		{
			case TERRAIN_BACKGROUND:
			{
				if(x == 5 && y >= 5)
				{
					return WOOD_TILE;
				}
			}
			
			case TERRAIN_FOREGROUND:
			{
				if(Math.sqrt((y-5)**2+(x-5)**2) < 5.0f)
				{
					return LEAF_TILE;
				}
			}
		}
		return NULL_TILE;
	}
}

class TerrainGen
{
	int seed;
	Simplex2D noise;
	Random rand;
	
	array<dictionary> structureTiles(TERRAIN_LAYERS_MAX);
	array<string> generatedSuperChunks;
	
	TerrainGen()
	{
		noise.octaves = 8;
		//noise.frequency = 0.01f;
		noise.gain = 0.5f;
	}
	
	TileID getTileAt(const int x, const int y, TerrainLayer layer)
	{
		TileID tile = getGroundAt(x, y, layer);
		
		// TODO: Move this check somewhere else
		int superChunkX = Math.floor(x/SUPER_CHUNK_TILE_SIZEF), superChunkY = Math.floor(y/SUPER_CHUNK_TILE_SIZEF);
		string key = superChunkX+";"+superChunkY;
		if(generatedSuperChunks.find(key) < 0)
		{
			loadStructures(superChunkX, superChunkY);
			generatedSuperChunks.insertLast(key);
		}
		
		// Apply structures
		TileID structTile = TileID(structureTiles[layer][x+";"+y]);
		if(structTile != NULL_TILE)
		{
			tile = structTile;
		}
		
		return tile;
	}
	
	private TileID getGroundAt(const int x, const int y, TerrainLayer layer)
	{
		switch(layer)
		{
			case TERRAIN_SCENE:
			{
				float h = noise.valueAt(x, y + 710239) * 7;

				// Ground
				if((Math.clamp((80 - y)/100.0f, 0.0f, 1.0f) + (noise.valueAt(x, y) * 0.5f + 0.5f)) * step(20, y + h) > 0.5f)
				{
					return GRASS_TILE;
				}
			}
			
			case TERRAIN_BACKGROUND:
			{
			}
		}
		return EMPTY_TILE;
	}
	
	void loadStructures(const int superChunkX, const int superChunkY)
	{
		Console.log("Placing structures in super chunk ["+superChunkX+", "+superChunkY+"]");
		array<Structure@> structures;
		for(int x = 5; x < SUPER_CHUNK_TILE_SIZE-5; ++x)
		{
			int tileX = SUPER_CHUNK_TILE_SIZE * superChunkX + x;
			if(rand.getDouble(x + seed) < 0.05/*TREE_CHANCE*/)
			{
				Tree tree;
				tree.x = tileX;
				tree.y = getGroundHeight(tileX);
				structures.insertLast(tree);
			}
		}
		
		// Place structures
		for(int i = 0; i < structures.size; ++i)
		{
			Structure @struct = @structures[i];
			for(int y = 0; y < struct.height; ++y)
			{
				for(int x = 0; x < struct.width; ++x)
				{
					int structX = struct.x+x-struct.originX, structY = struct.y+y-struct.originY;
					for(int i = 0; i < TERRAIN_LAYERS_MAX; ++i)
					{
						TileID structTile = struct.getTileAt(x, y, TerrainLayer(i));
						if(structTile != NULL_TILE)
							structureTiles[TerrainLayer(i)][structX+";"+structY] = structTile;
					}
				}
			}
		}
	}
	
	int getGroundHeight(int x)
	{
		int y = 0;
		while(getGroundAt(x, y++, TERRAIN_SCENE) == EMPTY_TILE);
		return y-1;
	}
	
	bool isFlatStretch(int start, int size)
	{
		/*int height = getGroundHeight(start);
		for(int x = start+1; x < start+size; x++)
		{
			if(getGroundHeight(x) != height)
				return false;
		}*/
		return true;
	}
}