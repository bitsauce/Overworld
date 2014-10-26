float lerp(float v0, float v1, float t)
{
	return (1.0f-t)*v0 + t*v1;
}

class TerrainGen
{
	int seed;
	Simplex2D noise;
	
	TerrainGen()
	{
		noise.octaves = 8;
		noise.frequency = 0.01f;
		noise.gain = 0.5f;
	}
	
	TileID getTileAt(const int x, const int y)
	{
		float h = noise.valueAt((seed + x), seed) * 7;
		if(noise.valueAt(seed + x, seed + y) < lerp(0.0f, 1.0f, y/10.0f))
			return GRASS_TILE;
		return EMPTY_TILE;
	}
	
	void generate(TerrainChunk @chunk, const int chunkX, const int chunkY)
	{
		/*Console.log("Generating chunk ["+chunkX+";"+chunkY+"]...");
		
		int tileX = chunkX*CHUNK_SIZE;
		int tileY = chunkY*CHUNK_SIZE;
		
		for(int x = 0; x < CHUNK_SIZE; x++)
		{
			float h = 32;//noise.valueAt((seed + tileX + x), seed) * 7;
			for(int y = CHUNK_SIZE - 1; y >= 0 && tileY + y >= h; y--)
			{
				if(tileY+y > 0)
				//if(noise.valueAt(seed + tileX+x, seed + tileY+y) < 0.5f - Math.atan((tileY+y - h - 30) * 0.1f)/Math.PI)
				{
					chunk.addTile(x, y, GRASS_TILE);
				}
			}
		}
		Console.log("Chunk generated");*/
		
		/*@this.terrain = @terrain;
		width = terrain.getWidth();
		height = terrain.getHeight();
		
		// Add slope
		int slope = 0;
		float t = Math.PI*2;
		for(int x = 0; x < width; x++)
		{
			// Calculate new slope height
			if(t >= Math.PI*2)
			{
				slope = Math.getRandomInt(5, 10);
				t = 0.0f;
			}
			
			// Create slopes
			float h = (Math.sin(t)) * slope + 25;
			for(int y = height - 1; y >= 0 && y >= h; y--)
			{
				terrain.addTile(x, y, y > (height+h)*0.5f ? STONE_TILE : GRASS_TILE);
			}
			t += 0.05f;
		}
		
		// Add caves
		for(int x = Math.getRandomInt(50, 100); x < width; x += Math.getRandomInt(50, 100))
		{
			int x1 = x;
			int y1 = getGroundHeight(x1);
			int depth = Math.getRandomInt(10, 50);
			for(int z = 0; z < depth; z++)
			{
				int r = 5;
				for(int j = -r; j <= r; j++)
				{
					for(int i = -r; i <= r; ++i)
					{
						if(Math.sqrt(j*j+i*i) >= r)
							continue;
						terrain.removeTile(x1+i, y1+j);
					}
				}
				
				float ang = Math.getRandomInt(20, 160)*Math.PI/180.0f;
				x1 += Math.cos(ang) * r;
				y1 += Math.sin(ang) * r;
			}
		}
		
		// Add trees
		for(int x = Math.getRandomInt(10, 20); x < width; x += Math.getRandomInt(10, 20))
		{
			int ground = getGroundHeight(x);
			int treeHeight = Math.getRandomInt(10, 15);
			for(int y = -1; y < treeHeight; y++)
			{
				terrain.addTile(x, ground - y, WOOD_TILE);
			}
			
			int treeRadius = treeHeight/2.0f;
			for(int j = -treeRadius; j < treeHeight; j++)
			{
				for(int i = -treeRadius; i < treeHeight; ++i)
				{
					if(Math.sqrt(i*i+j*j) >= treeRadius) continue;
					terrain.addTile(x + i, ground + j - treeHeight + 3, LEAF_TILE);
				}
			}
		}
		
		// Add bushes
		int x = 0;
		do {
			// Get patch x position
			x += Math.getRandomInt(50, 120);
			
			// Place bush patch
			int bushCount = Math.getRandomInt(2, 4);
			for(int i = 0; i < width && bushCount > 0;)
			{
				if(isFlatStretch(x+i, 6))
				{
					Bush bush();
					int y = getGroundHeight(x+i+1)-1;
					bush.place(x+i+1, y);
					bushCount--;
					i += Math.getRandomInt(4, 8);
				}else{
					++i;
				}
			}
		} while(x < width);*/
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