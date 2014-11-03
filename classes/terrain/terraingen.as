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
	dictionary structures;
	
	TerrainGen()
	{
		noise.octaves = 8;
		//noise.frequency = 0.01f;
		noise.gain = 0.5f;
	}
	
	TileID getTileAt(const int x, const int y, TerrainLayer layer)
	{
		TileID tile = getGroundAt(x, y, layer);
		
		int superChunkX = Math.floor(x/SUPER_CHUNK_TILE_SIZEF), superChunkY = Math.floor(y/SUPER_CHUNK_TILE_SIZEF);
		string key = superChunkX+";"+superChunkY;
		if(!structures.exists(key))
		{
			@structures[key] = @getStructures(superChunkX, superChunkY);
		}
		
		array<Structure@> @structs = cast<array<Structure@>@>(structures[key]);
		for(int i = 0; i < structs.size; ++i)
		{
			Structure @struct = @structs[i];
			int structX = x-struct.x+struct.originX, structY = y-struct.y+struct.originY;
			if(structX >= 0 && structX < struct.width && structY >= 0 && structY < struct.height)
			{
				TileID structTile = struct.getTileAt(structX, structY, layer);
				if(structTile != NULL_TILE)
					tile = structTile;
			}
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
	
	array<Structure@> @getStructures(const int superChunkX, const int superChunkY)
	{
		Console.log("Placing structures in super chunk ["+superChunkX+", "+superChunkY+"]");
		array<Structure@> structs;
		for(int x = 5; x < SUPER_CHUNK_TILE_SIZE-5; ++x)
		{
			int tileX = SUPER_CHUNK_TILE_SIZE * superChunkX + x;
			if(rand.getDouble(x + seed) < 0.05/*TREE_CHANCE*/)
			{
				Tree tree;
				tree.x = tileX;
				tree.y = getGroundHeight(tileX);
				structs.insertLast(tree);
			}
		}
		return structs;
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