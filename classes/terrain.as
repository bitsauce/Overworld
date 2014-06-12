const int TILE_SIZE = 16;

enum Direction
{
	NORTH		= 2,
	SOUTH		= 4,
	EAST		= 16,
	WEST		= 32
}

enum Tile
{
	NULL_TILE = 0,
	GRASS_TILE,
	STONE_TILE,
	MAX_TILES
}

class Terrain
{
	grid<Tile> tiles;
	
	
	
	Animation @grassAnim;
	Animation @stoneAnim;
	Batch @batch = Batch();
	private int width = 0;
	private int height = 0;
	
	Terrain(const int width, const int height)
	{
		@TILE_TEXTURES[GRASS_TILE] = @Texture(":/sprites/tiles/grass_tile.png");
		@TILE_TEXTURES[STONE_TILE] = @Texture(":/sprites/tiles/stone_tile.png");
		
		@grassAnim = @Animation(@TILE_TEXTURES[GRASS_TILE], 1, 21);
		@stoneAnim = @Animation(@TILE_TEXTURES[STONE_TILE], 1, 21);
		
		tiles.resize(width, height);
		
		Sprite @tile = Sprite(grassAnim.getKeyFrame(0));
		for(int y = 0; y < height; y++) {
			for(int x = 0; x < width; x++) {
				tile.setPosition(Vector2(x * TILE_SIZE, y * TILE_SIZE));
				
				if(y > height/2) {
					tile.setRegion(grassAnim.getKeyFrame(0));
				}else{
					tile.setRegion(grassAnim.getKeyFrame(1));
					tiles[x, y] = GRASS_TILE;
				}
				tile.draw(@batch);
				
				if(y > height/2) {
					tile.setRegion(stoneAnim.getKeyFrame(1));
					tiles[x, y] = STONE_TILE;
				}else{
					tile.setRegion(stoneAnim.getKeyFrame(0));
				}
				tile.draw(@batch);
			}
		}
		batch.makeStatic();
		
		this.width = width;
		this.height = height;
	}
	
	bool isValid(const int x, const int y)
	{
		return x >= 0 && x < width && y >= 0 && y < height;
	}
	
	void addTile(const int x, const int y, Tile tile)
	{
		// Make sure we can add a tile here
		if(!isValid(x, y) || isTileAt(x, y)) // Last check probably optional
			return;
		
		// Set the correct layer
		batch.setTexture(@TILE_TEXTURES[tile]);
		
		int i = (y*width + x) * 4;
		for(int j = 0; j < 4; j++) {
			Vertex vertex = batch.getVertex(i+j);
			vertex.color.set(1.0f, 1.0f, 1.0f, 1.0f);
			batch.modifyVertex(i+j, vertex);
		}
		
		tiles[x, y] = tile;
		updateTile(x, y);
		updateTile(x+1, y);
		updateTile(x-1, y);
		updateTile(x, y+1);
		updateTile(x, y-1);
	}
	
	Tile getTileAt(const int x, const int y)
	{
		if(!isValid(x, y))
			return NULL_TILE;
		return tiles[x, y];
	}
	
	bool isTileAt(const int x, const int y)
	{
		return getTileAt(x, y) != NULL_TILE;
	}
	
	void removeTile(const int x, const int y)
	{
		// Make sure there is a tile to remove
		if(!isValid(x, y) || !isTileAt(x, y))
			return;
		
		// Set the correct layer
		batch.setTexture(@TILE_TEXTURES[getTileAt(x, y)]);
		
		// Hide this tile (by setting its vertices alpha channels to 0)
		int i = (y*width + x) * 4;
		for(int j = 0; j < 4; j++) {
			Vertex vertex = batch.getVertex(i+j);
			vertex.color.set(1.0f, 1.0f, 1.0f, 0.0f);
			batch.modifyVertex(i+j, vertex);
		}
		
		// Mark as a null tile
		tiles[x, y] = NULL_TILE;
		updateTile(x+1, y);
		updateTile(x-1, y);
		updateTile(x, y+1);
		updateTile(x, y-1);
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
		if(r) if(t) if(l) if(b)	return 1;
                             else		return 6;
                       else if(b)		return 8;
                       else			return 7;
                  else if(l) if(b)		return 2;
                             else		return 10;
                  else if(b)			return 9;
                  else				return 12;
		else if(t) if(l) if(b)		return 4;
                            else		return 5;
                      else if(b)		return 13;
		           else			return 15;
		     else if(l) if(b)		return 3;
		     else				return 11;
		else if(b)				return 14;
		else					return 16;
	}
	
	void updateTile(const int x, const int y)
	{
		if(!isTileAt(x, y)) return;
		
		batch.setTexture(@TILE_TEXTURES[getTileAt(x, y)]);
		TextureRegion @region = grassAnim.getKeyFrame(getTileFrame(getTileState(x, y)));
		int i = (y*width + x) * 4;
		for(int j = 0; j < 4; j++) {
			Vertex vertex = batch.getVertex(i+j);
			switch(j) {
				case 0: vertex.texCoord.set(region.uv0.x, region.uv1.y); break;
				case 1: vertex.texCoord.set(region.uv1.x, region.uv1.y); break;
				case 2: vertex.texCoord.set(region.uv1.x, region.uv0.y); break;
				case 3: vertex.texCoord.set(region.uv0.x, region.uv0.y); break;
			}
			batch.modifyVertex(i+j, vertex);
		}
	}
	
	void draw()
	{
		batch.setTexture(@TILE_TEXTURES[GRASS_TILE]);
		batch.draw();
	}
}