grid<float> TILE_TEXTURE_COORDS =
{
	{ 0.00f, 0.75f * 2.0f/3.0f, 0.25f, 1.00f * 2.0f/3.0f }, // 0
	{ 0.25f, 0.75f * 2.0f/3.0f, 0.50f, 1.00f * 2.0f/3.0f }, // 1
	{ 0.50f, 0.75f * 2.0f/3.0f, 0.75f, 1.00f * 2.0f/3.0f }, // 2
	{ 0.75f, 0.75f * 2.0f/3.0f, 1.00f, 1.00f * 2.0f/3.0f }, // 3
	{ 0.75f, 0.50f * 2.0f/3.0f, 1.00f, 0.75f * 2.0f/3.0f }, // 4
	{ 0.75f, 0.25f * 2.0f/3.0f, 1.00f, 0.50f * 2.0f/3.0f }, // 5
	{ 0.75f, 0.00f * 2.0f/3.0f, 1.00f, 0.25f * 2.0f/3.0f }, // 6
	{ 0.50f, 0.00f * 2.0f/3.0f, 0.75f, 0.25f * 2.0f/3.0f }, // 7
	{ 0.25f, 0.00f * 2.0f/3.0f, 0.50f, 0.25f * 2.0f/3.0f }, // 8
	{ 0.00f, 0.00f * 2.0f/3.0f, 0.25f, 0.25f * 2.0f/3.0f }, // 9
	{ 0.00f, 0.25f * 2.0f/3.0f, 0.25f, 0.50f * 2.0f/3.0f }, // 10
	{ 0.00f, 0.50f * 2.0f/3.0f, 0.25f, 0.75f * 2.0f/3.0f }, // 11
	{ 0.25f, 0.25f * 2.0f/3.0f, 0.75f, 0.75f * 2.0f/3.0f }, // 12
	
	{ 0.00f, 5.0f/6.0f, 0.25f, 1.0f }, 						// top-left inner-corner
	{ 0.25f, 5.0f/6.0f, 0.50f, 1.0f }, 						// top-right inner-corner
	{ 0.25f, 2.0f/3.0f, 0.50f, 5.0f/6.0f }, 				// bottom-right inner-corner
	{ 0.00f, 2.0f/3.0f, 0.25f, 5.0f/6.0f } 					// bottom-left inner-corner
};

class TileGrid
{
	private grid<int> tiles;
	private TextureAtlas @atlas;
	private SpriteBatch @batch;
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
		for(int y = 0; y < height; y++) {
			for(int x = 0; x < width; x++) {
				tiles[x, y] = NULL_TILE;
			}
		}
		
		// Store tile textures
		@atlas = @TextureAtlas(@textures);
			
		// Initialize terrain buffers
		@batch = @SpriteBatch();
		if(textures.size > 0) {
		for(int y = 0; y < height; y++)
		{
			for(int x = 0; x < width; x++)
			{
				for(int j = 0; j < 13; j++)
				{
					Sprite @sprite = @Sprite(getTextureRegion(1, j));
					sprite.setPosition(Vector2(x * TILE_SIZE + TILE_SIZE * 2 * (TILE_TEXTURE_COORDS[0, j] - 0.25f), y * TILE_SIZE + TILE_SIZE * 2 * (0.75 - TILE_TEXTURE_COORDS[3, j] * (3.0f/2.0f))));
					sprite.setColor(Vector4(0.0f));
					batch.add(@sprite);
				}
			}
		}
	}
		
		// Make it static
		batch.makeStatic();
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
		
		// Show tile
		int i = (y*width + x) * 13;
		for(int j = 0; j < 13; j++) {
			batch.get(i+j).setRegion(getTextureRegion(tile, j));
		}
		batch.get(i+12).setColor(Vector4(1.0f));
		
		// Set the tile value
		tiles[x, y] = tile;
		
		// Update neighbouring tiles
		if(initialized)
		{
			updateTile(x, y);
			
			updateTile(x+1, y);
			updateTile(x-1, y);
			updateTile(x, y+1);
			updateTile(x, y-1);
			
			updateTile(x+1, y+1);
			updateTile(x-1, y+1);
			updateTile(x+1, y-1);
			updateTile(x-1, y-1);
		}
	}
	
	void removeTile(const int x, const int y)
	{
		// Make sure there is a tile to remove
		if(!isValid(x, y) || !isTileAt(x, y))
			return;
		
		// Hide tile
		int tile = tiles[x, y];
		int i = (y*width + x) * 13;
		for(int j = 0; j < 13; j++) {
			batch.get(i+j).setColor(Vector4(0.0f));
		}
		
		// Reset the tile value
		tiles[x, y] = 0;
		
		// Update neighbouring tiles
		if(initialized)
		{
			updateTile(x+1, y);
			updateTile(x-1, y);
			updateTile(x, y+1);
			updateTile(x, y-1);
			
			updateTile(x+1, y+1);
			updateTile(x-1, y+1);
			updateTile(x+1, y-1);
			updateTile(x-1, y-1);
		}
	}
	
	private uint getTileState(const int x, const int y)
	{
		// Set state
		uint state = 0;
		if(isTileAt(x, y-1)) state |= NORTH;
		if(isTileAt(x, y+1)) state |= SOUTH;
		if(isTileAt(x+1, y)) state |= EAST;
		if(isTileAt(x-1, y)) state |= WEST;
		if(isTileAt(x+1, y-1)) state |= NORTH_EAST;
		if(isTileAt(x-1, y-1)) state |= NORTH_WEST;
		if(isTileAt(x+1, y+1)) state |= SOUTH_EAST;
		if(isTileAt(x-1, y+1)) state |= SOUTH_WEST;
		return state;
	}
	
	private TextureRegion getTextureRegion(int tile, int i)
	{
		return atlas.get(tile-1, TILE_TEXTURE_COORDS[0, i], TILE_TEXTURE_COORDS[1, i], TILE_TEXTURE_COORDS[2, i], TILE_TEXTURE_COORDS[3, i]);
	}
	
	void updateTile(const int x, const int y)
	{
		int tile = getTileAt(x, y);
		if(tile != NULL_TILE)
		{
			int i = (y*width + x) * 13;
			uint state = getTileState(x, y);
			
			// Show/Hide north ledge
			batch.get(i+1).setColor(Vector4(state & NORTH == 0 ? 1.0f : 0.0f));
			batch.get(i+2).setColor(Vector4(state & NORTH == 0 ? 1.0f : 0.0f));
			
			// Show/Hide east ledge
			batch.get(i+4).setColor(Vector4(state & EAST == 0 ? 1.0f : 0.0f));
			batch.get(i+5).setColor(Vector4(state & EAST == 0 ? 1.0f : 0.0f));
			
			// Show/Hide south ledge
			batch.get(i+7).setColor(Vector4(state & SOUTH == 0 ? 1.0f : 0.0f));
			batch.get(i+8).setColor(Vector4(state & SOUTH == 0 ? 1.0f : 0.0f));
			
			// Show/Hide west ledge
			batch.get(i+10).setColor(Vector4(state & WEST == 0 ? 1.0f : 0.0f));
			batch.get(i+11).setColor(Vector4(state & WEST == 0 ? 1.0f : 0.0f));
			
			// NW corner
			if(state & NORTH_WEST == 0)
			{
				batch.get(i+1).setRegion(getTextureRegion(tile, 1));
				batch.get(i+11).setRegion(getTextureRegion(tile, 11));
				
				// Show/Hide outer corner
				batch.get(i+0).setColor(Vector4((state & NORTH == 0 && state & WEST == 0) ? 1.0f : 0.0f));
			}else{
				batch.get(i+1).setRegion(getTextureRegion(tile, 16));
				batch.get(i+11).setRegion(getTextureRegion(tile, 14));
				
				// Hide outer corner
				batch.get(i+0).setColor(Vector4(0.0f));
			}
			
			// NE corner
			if(state & NORTH_EAST == 0)
			{
				batch.get(i+2).setRegion(getTextureRegion(tile, 2));
				batch.get(i+4).setRegion(getTextureRegion(tile, 4));
				
				// Show/Hide outer corner
				batch.get(i+3).setColor(Vector4((state & NORTH == 0 && state & EAST == 0) ? 1.0f : 0.0f));
			}else{
				batch.get(i+2).setRegion(getTextureRegion(tile, 15));
				batch.get(i+4).setRegion(getTextureRegion(tile, 13));
				
				// Hide outer corner
				batch.get(i+3).setColor(Vector4(0.0f));
			}
			
			// SE corner
			if(state & SOUTH_EAST == 0)
			{
				// Show/Hide outer corner
				batch.get(i+6).setColor(Vector4((state & SOUTH == 0 && state & EAST == 0) ? 1.0f : 0.0f));
			}else{
				// Hide outer corner
				if(state & EAST == 0) batch.get(i+5).setColor(Vector4(0.0f));
				batch.get(i+6).setColor(Vector4(0.0f));
				if(state & SOUTH == 0) batch.get(i+7).setColor(Vector4(0.0f));
			}
			
			// SW corner
			if(state & SOUTH_WEST == 0)
			{
				// Show/Hide outer corner
				batch.get(i+9).setColor(Vector4((state & SOUTH == 0 && state & WEST == 0) ? 1.0f : 0.0f));
			}else{
				// Hide outer corner
				if(state & SOUTH == 0) batch.get(i+8).setColor(Vector4(0.0f));
				batch.get(i+9).setColor(Vector4(0.0f));
				if(state & WEST == 0) batch.get(i+10).setColor(Vector4(0.0f));
			}
		}
	}
	
	void draw(Texture @texture, Matrix4 mat)
	{
		batch.setProjectionMatrix(mat);
		batch.renderToTexture(@texture);
	}
}