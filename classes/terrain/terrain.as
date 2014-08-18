bool isValidTile(TileID tile)
{
	return tile != SCENE_TILES && tile != BACKGROUND_TILES &&
			tile != FOREGROUND_TILES && tile != MAX_TILES;
}

class Terrain
{
	// Box2D body
	b2Body @body;
	
	// Box2D tile fixtures
	private grid<b2Fixture@> fixtures;
	
	// Terrain layers (as TileGrids)
	private array<TileGrid@> layers;
	
	// Terrain size
	private int width;
	private int height;
		
	// Terrain initialized flag
	bool initialized;
	
	// Terrain generator
	TerrainGen generator;
	
	private void init(int width, int height)
	{
		// Set initialized flag
		this.initialized = false;
		
		// Set size
		this.width = width;
		this.height = height;
		
		Console.log("Initializing terrain of size: " + width + ", " + height);
		
		// Create terrain layers
		layers.resize(TERRAIN_LAYERS_MAX);
		for(int i = 0; i < TERRAIN_LAYERS_MAX; i++) {
			@layers[i] = @TileGrid(width, height);
		}
		
		// Resize fixture grid
		fixtures.resize(width, height);
		
		// Setup b2Body
		b2BodyDef def;
		def.type = b2_staticBody;
		def.position.set(0.0f, 0.0f);
		def.allowSleep = true;
		
		@body = b2Body(def);
		body.setObject(@this);
		
		// NOTE TO SELF: The vertex count can be redused to 424320
		// on-screen vertices by using texture atlases. This
		// equates to 15.28 MB of VRAM. Formulae: num_tiles * quads_per_tile * verts_per_quad * floats_per_vert * float_to_bytes / size_of_megabyte
		Console.log("Terrain VRAM usage: " + (width*height*13*4*8*4.0f/1048576.0f) + " MB");
	}
	
	void setInitialized(bool initialized)
	{
		// Set layers as initialized
		for(int i = 0; i < TERRAIN_LAYERS_MAX; i++) {
			layers[i].setInitialized(true);
		}
		
		// Update all fixtures
		if(this.initialized == false && initialized == true) {
			for(int x = 0; x < width; x++) {
				for(int y = 0; y < height; y++) {
					updateFixture(x, y);
				}
			}
		}
		this.initialized = initialized;
	}
	
	void serialize(StringStream &ss)
	{
		Console.log("Saving terrain...");
		
		ss.write(width);
		ss.write(height);
		
		for(int i = 0; i < TERRAIN_LAYERS_MAX; i++)
		{
			string tileString;
			for(int y = 0; y < height; y++)
			{
				for(int x = 0; x < width; x++)
				{
					TileID tile = getTileAt(x, y, TerrainLayer(i));
					if(tile <= RESERVED_TILE) tile = NULL_TILE;
					tileString += formatInt(tile, "0", 3);
				}
			}
			ss.write(tileString);
		}
	}
	
	void deserialize(StringStream &ss)
	{	
		Console.log("Loading terrain...");
		
		// Initialize terrain
		int width, height;
		ss.read(width);
		ss.read(height);
		init(width, height);
		
		// Load tiles from file
		for(int i = 0; i < TERRAIN_LAYERS_MAX; i++)
		{
			string tileString;
			ss.read(tileString);
			for(int y = 0; y < height; y++)
			{
				for(int x = 0; x < width; x++)
				{
					int j = (x + y*width) * 3;
					addTile(x, y, TileID(parseInt(tileString.substr(j, 3))));
				}
			}
		}
		
		// Set layers as initialized
		setInitialized(true);
	}
	
	void generate(int width, int height)
	{
		// Initialize terrain
		init(width, height);
		
		// Generate stuff
		generator.generate(@game::terrain);
		
		// Set terrain as initialized
		setInitialized(true);
	}
	
	// Getters/setters/validators
	int getWidth() const
	{
		return width;
	}
	
	int getHeight() const
	{
		return height;
	}
	
	bool isValid(const int x, const int y)
	{
		return x >= 0 && x < width && y >= 0 && y < height;
	}
	
	TileID getTileAt(const int x, const int y, const TerrainLayer layer = TERRAIN_SCENE)
	{
		return isValid(x, y) ? layers[layer].getTileAt(x, y) : NULL_TILE;
	}
	
	bool isTileAt(const int x, const int y, TerrainLayer layer = TERRAIN_SCENE)
	{
		return getTileAt(x, y, layer) != NULL_TILE;
	}
	
	TerrainLayer getLayerByTile(TileID tile)
	{
		if(tile < SCENE_TILES) return TERRAIN_SCENE;
		if(tile < BACKGROUND_TILES) return TERRAIN_BACKGROUND;
		return TERRAIN_FOREGROUND;
	}
	
	private void createFixture(int x, int y)
	{
		if(!isValid(x, y))
			return;
		b2Fixture @fixture = @body.createFixture(Rect(x * TILE_SIZE - TILE_SIZE * 0.5f, y * TILE_SIZE - TILE_SIZE * 0.5f, TILE_SIZE*2, TILE_SIZE*2), 0.0f);
		game::tiles[getTileAt(x, y)].setupFixture(@fixture);
		@fixtures[x, y] = @fixture;
	}
	
	private void removeFixture(int x, int y)
	{
		if(!isValid(x, y))
			return;
		body.removeFixture(@fixtures[x, y]);
		@fixtures[x, y] = null;
	}
	
	private bool isFixtureAt(int x, int y)
	{
		if(!isValid(x, y))
			return false;
		return @fixtures[x, y] != null;
	}
	
	private void updateFixture(int x, int y)
	{
		// Find out if this tile should contain a fixture
		TileGrid @scene = @layers[TERRAIN_SCENE];
		bool shouldContainFixture = scene.isTileAt(x, y, true) && (scene.getTileState(x, y, true) & NESW != NESW);
		
		// Create or remove fixture
		if(shouldContainFixture && !isFixtureAt(x, y)) {
			createFixture(x, y);
		}else if(!shouldContainFixture && isFixtureAt(x, y)) {
			removeFixture(x, y);
		}
	}
	
	// Terrain modification
	void addTile(const int x, const int y, TileID tile)
	{
		// Check for null tile
		if(tile == NULL_TILE)
			return;
		
		// Get terrain layer
		TerrainLayer layer = getLayerByTile(tile);
		
		// Add tile to tile grid
		layers[layer].addTile(x, y, tile);
		
		// If we've modified the scene layer
		if(initialized && layer == TERRAIN_SCENE)
		{
			// Update fixtures
			updateFixture(x, y);
			updateFixture(x+1, y);
			updateFixture(x-1, y);
			updateFixture(x, y+1);
			updateFixture(x, y-1);
		}
	}
	
	void removeTile(const int x, const int y, TerrainLayer layer = TERRAIN_SCENE)
	{
		// Remove tile from tile grid
		layers[layer].removeTile(x, y);
		
		// If we've modified the scene layer
		if(initialized && layer == TERRAIN_SCENE)
		{
			// Update fixtures
			updateFixture(x, y);
			updateFixture(x+1, y);
			updateFixture(x-1, y);
			updateFixture(x, y+1);
			updateFixture(x, y-1);
		}
	}
	
	// Drawing
	void draw(TerrainLayer layer, Texture @texture)
	{
		Matrix4 mat;
		mat.translate(-game::camera.position.x + scene::game.padding/(2.0f * game::camera.zoom), -game::camera.position.y + scene::game.padding/(2.0f * game::camera.zoom), 0.0f);
		mat.scale(game::camera.zoom);
		layers[layer].draw(@texture, mat);
	}
}