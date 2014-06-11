const int TILE_SIZE = 16;

enum Direction
{
	NORTH		= 2,
	SOUTH		= 4,
	EAST		= 16,
	WEST		= 32
}

class Terrain
{
	
	grid<int> m;
	
	
	
	Texture @texture = @Texture(":/sprites/tiles/grass_tile.png");
	Animation @anim = @Animation(@texture, 1, 16);
	Batch @batch = Batch();
	private int width = 0;
	private int height = 0;
	
	Terrain(const int width, const int height)
	{
		Sprite @grassTile = Sprite(anim.getKeyFrame(0));
		for(int y = 0; y < height; y++) {
			for(int x = 0; x < width; x++) {
				grassTile.setRegion(anim.getKeyFrame(0));
				grassTile.setPosition(Vector2(x * TILE_SIZE, y * TILE_SIZE));
				grassTile.draw(@batch);
			}
		}
		batch.setTexture(@texture);
		batch.makeStatic();
		
		this.width = width;
		this.height = height;
	}
	
	bool isValid(const int x, const int y)
	{
		return x >= 0 && x < width && y >= 0 && y < height;
	}
	
	void addTile(const int x, const int y)
	{
		if(!isValid(x, y)) return;
		
		int i = (y*width + x) * 4;
		for(int j = 0; j < 4; j++) {
			Vertex vertex = batch.getVertex(i+j);
			vertex.color.set(1.0f, 1.0f, 1.0f, 1.0f);
			batch.modifyVertex(i+j, vertex);
		}
		
		updateTile(x, y);
		updateTile(x+1, y);
		updateTile(x-1, y);
		updateTile(x, y+1);
		updateTile(x, y-1);
	}
	
	void removeTile(const int x, const int y)
	{
		if(!isValid(x, y)) return;
		
		int i = (y*width + x) * 4;
		for(int j = 0; j < 4; j++) {
			Vertex vertex = batch.getVertex(i+j);
			vertex.color.set(1.0f, 1.0f, 1.0f, 0.0f);
			batch.modifyVertex(i+j, vertex);
		}
		
		updateTile(x+1, y);
		updateTile(x-1, y);
		updateTile(x, y+1);
		updateTile(x, y-1);
	}
	
	bool isTileAt(const int x, const int y)
	{
		int i = (y*width + x) * 4;
		Vertex vertex = batch.getVertex(i);
		return vertex.color.a > 0.5f;
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
		
		if(r) if(t) if(l) if(b)	return 0;
                             else		return 5;
                       else if(b)		return 7;
                       else			return 6;
                  else if(l) if(b)		return 1;
                             else		return 9;
                  else if(b)			return 8;
                  else				return 11;
		else if(t) if(l) if(b)		return 3;
                            else		return 4;
                      else if(b)		return 12;
		           else			return 14;
		     else if(l) if(b)		return 2;
		     else				return 10;
		else if(b)				return 13;
		else					return 15;
	}
	
	void updateTile(const int x, const int y)
	{
		TextureRegion @region = anim.getKeyFrame(getTileFrame(getTileState(x, y)));
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
		batch.setTexture(@texture);
		batch.draw();
	}
}