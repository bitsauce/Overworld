const int TILE_SIZE = 16;

enum Tile
{
	NULL_TILE = 0,
	
	// SCENE_TILES BEGIN
	GRASS_TILE,
	STONE_TILE,
	// SCENE_TILES END
	
	SCENE_TILES,
	
	// BACKGROUND_TILES BEGIN
	TREE_TILE,
	// BACKGROUND_TILES END
	
	BACKGROUND_TILES,
	
	// FOREGROUND_TILES BEGIN
	LEAF_TILE,
	// FOREGROUND_TILES END
	
	FOREGROUND_TILES,
	
	MAX_TILES
}

bool isValidTile(Tile tile)
{
	return tile != SCENE_TILES && tile != BACKGROUND_TILES &&
			tile != FOREGROUND_TILES && tile != MAX_TILES;
}

enum TerrainLayer
{
	TERRAIN_BACKGROUND,
	TERRAIN_SCENE,
	TERRAIN_FOREGROUND,
	TERRAIN_LAYERS_MAX
}

class Terrain : GameObject
{
	grid<b2Fixture@> fixtures;
	b2Body @body;
	
	array<TileGrid@> layers(TERRAIN_LAYERS_MAX);
	
	private int width;
	private int height;
		
	TerrainGen gen();
	
	Terrain(const int width, const int height)
	{
		// Set size
		this.width = width;
		this.height = height;
		
		// Load tile textures
		array<Texture@> tileTextures(MAX_TILES);
		@tileTextures[GRASS_TILE]	=	@Texture(":/sprites/tiles/grass_tile.png");
		@tileTextures[STONE_TILE]	=	@Texture(":/sprites/tiles/stone_tile.png");
		@tileTextures[LEAF_TILE]	=	@Texture(":/sprites/tiles/leaf_tile.png");
		@tileTextures[TREE_TILE]	=	@Texture(":/sprites/tiles/tree_tile.png");
		
		// Create terrain layers
		for(int i = 0; i < TERRAIN_LAYERS_MAX; i++)
		{
			int start = 0;
			int end = 0;
			switch(i) {
			case TERRAIN_SCENE: start = NULL_TILE + 1; end = SCENE_TILES; break;
			case TERRAIN_BACKGROUND: start = SCENE_TILES + 1; end = BACKGROUND_TILES; break;
			case TERRAIN_FOREGROUND: start = BACKGROUND_TILES + 1; end = FOREGROUND_TILES; break;
			}
			
			array<Texture@> textures;
			for(; start < end; start++) {
				textures.insertLast(@tileTextures[start]);
			}
			
			@layers[i] = @TileGrid(width, height, textures);
		}
		
		// Resize fixture grid
		fixtures.resize(width, height);
		
		// Setup b2Body
		b2BodyDef def;
		def.type = b2_staticBody;
		def.position.set(0.0f, 0.0f);
		def.allowSleep = true;
		@body = b2Body(def);
		
		// Generate a terrain
		Console.log("Generating world...");
		gen.generate(@this);
		
		// Set global terrain handle
		@global::terrain = @this;
	}
	
	// Getters/setters/validators
	int getWidth()
	{
		return width;
	}
	
	int getHeight()
	{
		return height;
	}
	
	bool isValid(const int x, const int y)
	{
		return x >= 0 && x < width && y >= 0 && y < height;
	}
	
	Tile getTileAt(const int x, const int y, TerrainLayer layer = TERRAIN_SCENE)
	{
		if(!isValid(x, y))
			return NULL_TILE;
		return getTileValue(layer, layers[layer].getTileAt(x, y));
	}
	
	bool isTileAt(const int x, const int y, TerrainLayer layer = TERRAIN_SCENE)
	{
		return getTileAt(x, y, layer) != NULL_TILE;
	}
	
	// Layer helper functions
	TerrainLayer getLayerByTile(Tile tile)
	{
		if(tile < SCENE_TILES) return TERRAIN_SCENE;
		if(tile < BACKGROUND_TILES) return TERRAIN_BACKGROUND;
		return TERRAIN_FOREGROUND;
	}
	
	int getTileIndex(TerrainLayer layer, Tile tile)
	{
		switch(layer)
		{
		case TERRAIN_SCENE: return tile - NULL_TILE; break;
		case TERRAIN_BACKGROUND: return tile - SCENE_TILES; break;
		case TERRAIN_FOREGROUND: return tile - BACKGROUND_TILES; break;
		}
		return -1;
	}
	
	Tile getTileValue(TerrainLayer layer, int tile)
	{
		if(tile == 0) return NULL_TILE;
		switch(layer)
		{
		case TERRAIN_SCENE: return Tile(tile + NULL_TILE); break;
		case TERRAIN_BACKGROUND: return Tile(tile + SCENE_TILES); break;
		case TERRAIN_FOREGROUND: return Tile(tile + BACKGROUND_TILES); break;
		}
		return NULL_TILE;
	}
	
	// Terrain modification
	void addTile(const int x, const int y, Tile tile)
	{
		// Get terrain layer
		TerrainLayer layer = getLayerByTile(tile);
		
		// Create a fixture
		if(layer == TERRAIN_SCENE && layers[layer].isValid(x, y) && @fixtures[x, y] == null) {
			@fixtures[x, y] = @body.createFixture(Rect(x * TILE_SIZE, y * TILE_SIZE, TILE_SIZE, TILE_SIZE), 32.0f);
		}
		
		// Add tile to tile grid
		layers[layer].addTile(x, y, getTileIndex(layer, tile));
	}
	
	void removeTile(const int x, const int y, TerrainLayer layer = TERRAIN_SCENE)
	{
		// Remove the fixture
		if(layer == TERRAIN_SCENE && layers[layer].isValid(x, y) && @fixtures[x, y] != null) {
			body.removeFixture(@fixtures[x, y]);
			@fixtures[x, y] = null;
		}
		
		// Remove tile from tile grid
		layers[layer].removeTile(x, y);
	}
	
	// Drawing
	void draw(TerrainLayer layer, Matrix4 mat)
	{
		layers[layer].draw(mat);
	}
}