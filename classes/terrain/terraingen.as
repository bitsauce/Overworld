class TerrainGen
{
	Terrain @terrain;
	int width;
	int height;
	
	void generate(Terrain @terrain)
	{
		@this.terrain = @terrain;
		width = terrain.getWidth();
		height = terrain.getHeight();
		
		// Add slope
		int slope = Math.getRandomInt(10, 20);
		float t = 0;
		for(int x = 0; x < width; x++)
		{
			if(t >= Math.PI*2)
			{
				slope = Math.getRandomInt(5, 10);
				t = 0.0f;
			}
			float h = (Math.sin(t)) * slope + 25;
			for(int y = height - 1; y >= 0 && y > h; y--)
			{
				terrain.addTile(x, y, GRASS_TILE);
			}
			t += 0.05f;
		}
		
		// Add trees
		for(int x = 5; x < width; x += Math.getRandomInt(10, 20))
		{
			int ground = getGroundHeight(x);
			int treeHeight = Math.getRandomInt(10, 15);
			for(int y = -1; y < treeHeight; y++)
			{
				//terrain.addTile(x, ground - y, TREE_TILE);
			}
			
			int treeRadius = treeHeight/2.0f;
			for(int j = -treeRadius; j < treeHeight; j++)
			{
				for(int i = -treeRadius; i < treeHeight; i++)
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
					bush.sprite.setPosition(Vector2((x+i+1)*TILE_SIZE, y*TILE_SIZE - 4));
					bushCount--;
					i += Math.getRandomInt(4, 8);
				}else{
					i++;
				}
			}
		} while(x < width);
	}
	
	int getGroundHeight(int x)
	{
		for(int y = 0; y < height; y++)
		{
			if(terrain.isTileAt(x, y))
			{
				return y-1;
			}
		}
		return -1;
	}
	
	bool isFlatStretch(int start, int size)
	{
		int height = getGroundHeight(start);
		for(int x = start+1; x < start+size; x++)
		{
			if(getGroundHeight(x) != height)
				return false;
		}
		return true;
	}
}