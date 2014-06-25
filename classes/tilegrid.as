enum Direction
{
	NORTH		= 1,
	SOUTH		= 2,
	EAST		= 4,
	WEST		= 8
}

class TileGrid
{
	private grid<int> tiles;
	private array<Animation@> tileAnims;
	private array<SpriteBatch@> batches;
	private int width;
	private int height;
	private bool initialized;
		
	TileGrid(const int width, const int height, array<Texture@> textures)
	{
		// Set size
		this.width = width;
		this.height = height;
		this.initialized = false;
		
		// Resize tile grid
		tiles.resize(width, height);
		
		// Load tile animations
		for(int i = 0; i < textures.size; i++)
		{
			tileAnims.insertLast(@Animation(@textures[i], 1, 21));
			batches.insertLast(@SpriteBatch());
		}
		
		// Initialize terrain buffers
		for(int y = 0; y < height; y++)
		{
			for(int x = 0; x < width; x++)
			{
				for(int i = 0; i < textures.size; i++)
				{
					Sprite @tile = @Sprite(tileAnims[i].getKeyFrame(0));
					tile.setPosition(Vector2(x * TILE_SIZE, y * TILE_SIZE));
					batches[i].add(@tile);
				}
				tiles[x, y] = 0;
			}
		}
		
		for(int i = 0; i < textures.size; i++) {
			batches[i].makeStatic();
		}
	}
	
	bool isValid(const int x, const int y)
	{
		return x >= 0 && x < width && y >= 0 && y < height;
	}
	
	int getTileAt(const int x, const int y)
	{
		if(!isValid(x, y))
			return NULL_TILE;
		return tiles[x, y];
	}
	
	bool isTileAt(const int x, const int y)
	{
		return getTileAt(x, y) != 0;
	}
	
	void setInitialized(bool value)
	{
		if(initialized == false && value == true)
		{
			// Update all tiles
			for(int y = 0; y < height; y++) {
				for(int x = 0; x < width; x++) {
					updateTile(x, y);
				}
			}
		}
		initialized = value;
	}
	
	void addTile(const int x, const int y, int tile)
	{
		// Make sure we can add a tile here
		if(!isValid(x, y) || isTileAt(x, y)) // Last check probably optional
			return;
		
		// Show this tile (alpha to 1)
		int i = (y*width + x);
		batches[tile-1].get(i).setColor(Vector4(1.0f, 1.0f, 1.0f, 1.0f));
		
		// Set the tile value
		tiles[x, y] = tile;
		
		// Update neighbouring tiles
		if(initialized) {
			updateTile(x, y);
			updateTile(x+1, y);
			updateTile(x-1, y);
			updateTile(x, y+1);
			updateTile(x, y-1);
		}
	}
	
	void removeTile(const int x, const int y)
	{
		// Make sure there is a tile to remove
		if(!isValid(x, y) || !isTileAt(x, y))
			return;
		
		// Hide this tile (alpha to 0)
		int i = (y*width + x);
		batches[getTileAt(x, y)-1].get(i).setColor(Vector4(1.0f, 1.0f, 1.0f, 0.0f));
		
		// Reset the tile value
		tiles[x, y] = 0;
		
		// Update neighbouring tiles
		if(initialized) {
			updateTile(x+1, y);
			updateTile(x-1, y);
			updateTile(x, y+1);
			updateTile(x, y-1);
		}
	}
	
	private uint getTileState(const int x, const int y)
	{
		// Set state
		uint state = 0;
		if(!isTileAt(x, y-1)) state |= NORTH;
		if(!isTileAt(x, y+1)) state |= SOUTH;
		if(!isTileAt(x+1, y)) state |= EAST;
		if(!isTileAt(x-1, y)) state |= WEST;
		return state;
	}
	
	private uint getTileFrame(const uint state)
	{
		// Get block frame
		bool r = (state & EAST) == 0;
		bool t = (state & NORTH) == 0;
		bool l = (state & WEST) == 0;
		bool b = (state & SOUTH) == 0;
		if(r) if(t) if(l) if(b)			return 1;
                             else		return 6;
                       else if(b)		return 8;
                       else				return 7;
                  else if(l) if(b)		return 2;
                             else		return 10;
                  else if(b)			return 9;
                  else					return 12;
		else if(t) if(l) if(b)			return 4;
                            else		return 5;
                      else if(b)		return 13;
		           else					return 15;
		     else if(l) if(b)			return 3;
		     else						return 11;
		else if(b)						return 14;
		else							return 16;
	}
	
	void updateTile(const int x, const int y)
	{
		if(!isTileAt(x, y)) return;
		
		// Update texture region
		int tile = getTileAt(x, y);
		int i = (y*width + x);
		TextureRegion @region = tileAnims[tile-1].getKeyFrame(getTileFrame(getTileState(x, y)));
		batches[tile-1].get(i).setRegion(@region);
	}
	
	void draw(Matrix4 mat)
	{
		for(int i = 0; i < batches.size; i++)
		{
			batches[i].setProjectionMatrix(mat);
			batches[i].draw();
		}
	}
}