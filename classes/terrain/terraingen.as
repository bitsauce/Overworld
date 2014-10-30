float step(float edge, float x)
{
	return x < edge ? 0.0f : 1.0f;
}

class TerrainGen
{
	int seed;
	Simplex2D noise;
	
	TerrainGen()
	{
		noise.octaves = 8;
		//noise.frequency = 0.01f;
		noise.gain = 0.5f;
	}
	
	TileID getTileAt(const int x, const int y)
	{
		TileID tile = EMPTY_TILE;

		float h = noise.valueAt(x, y + 710239) * 7;
		
		// Leafs
		if(Math.mod(x, 50) < 5 || Math.mod(x, 50) > 45)
		{
			//float dist = Math.sqrt(Math.pow((x/5 * 5) + 2.5 - x, 2) + Math.pow((y/10 * 10) + 5 - y, 2));
			if((noise.valueAt(Math.round(x/5.0f) * 5.0f, Math.floor(y/10.0f) * 10) * 0.5f + 0.5f) * step(8, y) * (1 - step(18, y)) > 0.5f)
				tile = LEAF_TILE;
		}
		
		// Tree
		if(x % 50 == 0)
		{
			if((noise.valueAt(x, Math.floor(y/10.0f) * 10) * 0.5f + 0.5f) * step(10, y + h) * (1 - step(20, y + h)) > 0.5f)
				tile = WOOD_TILE;
		}

		// Ground
		if((Math.clamp((80 - y)/100.0f, 0.0f, 1.0f) + (noise.valueAt(x, y) * 0.5f + 0.5f)) * step(20, y + h) > 0.5f)
		{
			tile = GRASS_TILE;
		}
		
		return tile;
	}
	
	int getGroundHeight(int x)
	{
		/*for(int y = 0; y < height; y++)
		{
			if(terrain.isTileAt(x, y))
			{
				return y-1;
			}
		}*/
		return -1;
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