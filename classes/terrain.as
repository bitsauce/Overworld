const int TILE_SIZE = 16;

enum Direction
{
	NORTH		= 1,
	SOUTH		= 2,
	EAST		= 4,
	WEST		= 8
}

enum Tile
{
	NULL_TILE = 0,
	GRASS_TILE,
	STONE_TILE,
	MAX_TILES
}

namespace global {
	Terrain @terrain;
}

class Terrain //: GameObject
{
	grid<Tile> tiles;
	grid<b2Fixture@> fixtures;
	b2Body @body;
	
	array<Animation@> tileAnims(MAX_TILES);
	array<SpriteBatch@> batches(MAX_TILES);
	private int width = 0;
	private int height = 0;
	
	Terrain(const int width, const int height)
	{
		@TILE_TEXTURES[GRASS_TILE] = @Texture(":/sprites/tiles/grass_tile.png");
		@TILE_TEXTURES[STONE_TILE] = @Texture(":/sprites/tiles/stone_tile.png");
		
		// Load tile animations
		for(int i = NULL_TILE + 1; i < MAX_TILES; i++) {
			@tileAnims[i] = @Animation(@TILE_TEXTURES[i], 1, 21);
			@batches[i] = @SpriteBatch();
		}
		
		@global::terrain = @this;
		
		tiles.resize(width, height);
		fixtures.resize(width, height);
		
		// Initialize terrain buffers
		for(int y = 0; y < height; y++) {
			for(int x = 0; x < width; x++) {
				for(int i = NULL_TILE + 1; i < MAX_TILES; i++) {
					Sprite @tile = @Sprite(tileAnims[i].getKeyFrame(0));
					tile.setPosition(Vector2(x * TILE_SIZE, y * TILE_SIZE));
					batches[i].add(@tile);
				}
				tiles[x, y] = NULL_TILE;
			}
		}
		
		for(int i = NULL_TILE + 1; i < MAX_TILES; i++) {
			batches[i].makeStatic();
		}
		
		this.width = width;
		this.height = height;
		
		b2BodyDef def;
		def.type = b2_staticBody;
		def.position.set(0.0f, 0.0f);
		def.allowSleep = true;
		@body = b2Body(def);
		
		for(int x = 0; x < width; x++) {
			float h = 25;//(Math.sin(x*0.05f)) * 20;
			for(int y = height - 1; y >= 0 && y > h; y--) {
				addTile(x, y, GRASS_TILE);
			}
		}
	}
	
	bool isValid(const int x, const int y)
	{
		return x >= 0 && x < width && y >= 0 && y < height;
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
	
	void addTile(const int x, const int y, Tile tile)
	{
		// Make sure we can add a tile here
		if(!isValid(x, y) || isTileAt(x, y)) // Last check probably optional
			return;
		
		// Show this tile
		int i = (y*width + x);
		batches[tile].get(i).setColor(Vector4(1.0f, 1.0f, 1.0f, 1.0f));
		
		// Set this tile
		tiles[x, y] = tile;
		@fixtures[x, y] = @body.createFixture(Rect(x * TILE_SIZE, y * TILE_SIZE, TILE_SIZE, TILE_SIZE), 32.0f);
		updateTile(x, y);
		updateTile(x+1, y);
		updateTile(x-1, y);
		updateTile(x, y+1);
		updateTile(x, y-1);
	}
	
	void removeTile(const int x, const int y)
	{
		// Make sure there is a tile to remove
		if(!isValid(x, y) || !isTileAt(x, y))
			return;
		
		// Hide this tile (by setting its vertices alpha channels to 0)
		int i = (y*width + x);
		batches[getTileAt(x, y)].get(i).setColor(Vector4(1.0f, 1.0f, 1.0f, 0.0f));
		
		// Mark as a null tile
		tiles[x, y] = NULL_TILE;
		body.removeFixture(@fixtures[x, y]);
		@fixtures[x, y] = null;
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
		Tile tile = getTileAt(x, y);
		int i = (y*width + x);
		TextureRegion @region = tileAnims[tile].getKeyFrame(getTileFrame(getTileState(x, y)));
		batches[tile].get(i).setRegion(@region);
	}
	
	void draw()
	{
		Matrix4 mat;
		mat.translate(-camera.x, -camera.y, 0.0f);
		for(int i = NULL_TILE + 1; i < MAX_TILES; i++) {
			batches[i].setProjectionMatrix(mat);
			batches[i].draw();
		}
	}
}