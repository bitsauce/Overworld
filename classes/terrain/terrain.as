bool isValidTile(TileID tile)
{
	return tile != SCENE_TILES && tile != BACKGROUND_TILES &&
			tile != FOREGROUND_TILES && tile != MAX_TILES;
}

class Terrain : GameObject, Serializable
{
	// Box2D body
	b2Body @body;
	
	// Box2D tile fixtures
	private grid<b2Fixture@> fixtures;
	
	// Terrain layers (as TileGrids)
	private array<TileGrid@> layers(TERRAIN_LAYERS_MAX);
	
	// Terrain size
	private int width;
	private int height;
		
	// Terrain initialized flag
	bool initialized;
		
	// Terrain generator
	TerrainGen gen();
	
	// Shadow shader
	Shader @shadowShader = @Shader(":/shaders/terrainshadows.vert", ":/shaders/terrainshadows.frag");
	
	// Shadow batch and texture (fbo)
	Batch @shadowBatch = @Batch();
	Texture @shadowTexture;
	
	// Shadow shader uniforms
	float radius = 3.0f;
	float falloff = 3.0f;
	int shadowDownsampleLevel = 16; // must be power of two
	
	// Pre-rendered terrain texture
	Texture @terrainTexture;
	
	Terrain()
	{
		// Update texture object
		windowResized();
		
		// Set shader uniforms
		shadowShader.setUniform1f("radius", radius);
		shadowShader.setUniform1f("falloff", falloff);
	}
	
	~Terrain()
	{
		//save();
	}
	
	int get_padding() const
	{
		return radius*shadowDownsampleLevel*2;
	}
	
	void windowResized()
	{
		Vector2i size = Window.getSize();
		@terrainTexture = @Texture(size.x + padding, size.y + padding);
		terrainTexture.setFiltering(LINEAR);
		
		Vector2i resolution = size/shadowDownsampleLevel;
		@shadowTexture = @Texture(resolution.x, resolution.y);
		shadowTexture.setFiltering(LINEAR);
		
		shadowBatch.clear();
		shadowBatch.setShader(@shadowShader);
		Shape @downsampledRect = @Shape(Rect(0.0f, 0.0f, resolution.x, resolution.y));
		downsampledRect.draw(@shadowBatch);
		
		shadowShader.setUniform2f("resolution", resolution.x, resolution.y);
		shadowShader.setSampler2D("texture", @terrainTexture);
	}
	
	private void init(int width, int height)
	{
		// Set size
		this.width = width;
		this.height = height;
		
		Console.log("Init terrain of size: " + width + ", " + height);
		
		// Load tile textures
		array<Texture@> tileTextures(MAX_TILES);
		@tileTextures[GRASS_TILE]	=	@Texture(":/sprites/tiles/grass_tile.png");
		@tileTextures[STONE_TILE]	=	@Texture(":/sprites/tiles/stone_tile.png");
		@tileTextures[LEAF_TILE]	=	@Texture(":/sprites/tiles/leaf_tile.png");
		//@tileTextures[TREE_TILE]	=	@Texture(":/sprites/tiles/tree_tile.png");
		
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
		body.setObject(@this);
		
		// NOTE TO SELF: The vertex count can be redused to 424320
		// on-screen vertices by using texture atlases. This
		// equates to 15.28 MB of VRAM. Formulae: num_tiles * quads_per_tile * verts_per_quad * floats_per_vert * float_to_bytes / size_of_megabyte
		Console.log("Terrain vertex count: " + width*height*13*4 + " (" + (width*height*13*4*8*4.0f/1048576.0f) + " MB)");
	}
	
	void save(IniFile @worldFile)
	{
		if(@worldFile == null) return;
		Console.log("Saving terrain...");
		for(int i = 0; i < TERRAIN_LAYERS_MAX; i++)
		{
			string tileString;
			for(int y = 0; y < height; y++)
			{
				for(int x = 0; x < width; x++)
				{
					tileString += formatInt(getTileAt(x, y, TerrainLayer(i)), "0", 3);
				}
			}
			if(i == TERRAIN_BACKGROUND) worldFile.setValue("terrain", "background", tileString);
			else if(i == TERRAIN_SCENE) worldFile.setValue("terrain", "scene", tileString);
			else if(i == TERRAIN_FOREGROUND) worldFile.setValue("terrain", "foreground", tileString);
		}
		Console.log("Terrain saved");
		worldFile.save();
	}
	
	void load(IniFile @worldFile)
	{	
		// Initialize terrain
		init(parseInt(worldFile.getValue("world", "width")), parseInt(worldFile.getValue("world", "height")));
		
		// Load tiles from file
		for(int i = 0; i < TERRAIN_LAYERS_MAX; i++)
		{
			string tileString;
			if(i == TERRAIN_BACKGROUND) tileString = worldFile.getValue("terrain", "background");
			else if(i == TERRAIN_SCENE) tileString = worldFile.getValue("terrain", "scene");
			else if(i == TERRAIN_FOREGROUND) tileString = worldFile.getValue("terrain", "foreground");
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
		for(int i = 0; i < TERRAIN_LAYERS_MAX; i++) {
			layers[i].setInitialized(true);
		}
		setInitialized(true);
	}
	
	void generate(int width, int height, IniFile @worldFile)
	{
		// Set world size
		worldFile.setValue("world", "width", formatInt(width, ""));
		worldFile.setValue("world", "height", formatInt(height, ""));
		
		// Initialize terrain
		init(width, height);
		
		// Generate a terrain
		Console.log("Generating world...");
		gen.generate(@this);
		save(@worldFile);
		
		// Set layers as initialized
		for(int i = 0; i < TERRAIN_LAYERS_MAX; i++) {
			layers[i].setInitialized(true);
		}
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
	
	TileID getTileAt(const int x, const int y, TerrainLayer layer = TERRAIN_SCENE)
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
	TerrainLayer getLayerByTile(TileID tile)
	{
		if(tile < SCENE_TILES) return TERRAIN_SCENE;
		if(tile < BACKGROUND_TILES) return TERRAIN_BACKGROUND;
		return TERRAIN_FOREGROUND;
	}
	
	int getTileIndex(TerrainLayer layer, TileID tile)
	{
		switch(layer)
		{
		case TERRAIN_SCENE: return tile - NULL_TILE; break;
		case TERRAIN_BACKGROUND: return tile - SCENE_TILES; break;
		case TERRAIN_FOREGROUND: return tile - BACKGROUND_TILES; break;
		}
		return -1;
	}
	
	TileID getTileValue(TerrainLayer layer, int tile)
	{
		if(tile == 0) return NULL_TILE;
		switch(layer)
		{
		case TERRAIN_SCENE: return TileID(tile + NULL_TILE); break;
		case TERRAIN_BACKGROUND: return TileID(tile + SCENE_TILES); break;
		case TERRAIN_FOREGROUND: return TileID(tile + BACKGROUND_TILES); break;
		}
		return NULL_TILE;
	}
	
	private bool isValidPosition(int x, int y) const
	{
		return x >= 0 && x < width && y >= 0 && y < height;
	}
	
	private void createFixture(int x, int y)
	{
		if(!isValidPosition(x, y))
			return;
		b2Fixture @fixture = @body.createFixture(Rect(x * TILE_SIZE - TILE_SIZE * 0.5f, y * TILE_SIZE - TILE_SIZE * 0.5f, TILE_SIZE*2, TILE_SIZE*2), 0.0f);
		game::tiles[getTileAt(x, y)].setupFixture(@fixture);
		@fixtures[x, y] = @fixture;
	}
	
	private void removeFixture(int x, int y)
	{
		if(!isValidPosition(x, y))
			return;
		body.removeFixture(@fixtures[x, y]);
		@fixtures[x, y] = null;
	}
	
	private bool isFixtureAt(int x, int y)
	{
		if(!isValidPosition(x, y))
			return false;
		return @fixtures[x, y] != null;
	}
	
	private void updateFixture(int x, int y)
	{
		// Find out if this tile should contain a fixture
		TileGrid @scene = @layers[TERRAIN_SCENE];
		bool shouldContainFixture = scene.isTileAt(x, y) && (scene.getTileState(x, y) & NESW != NESW);
		
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
		layers[layer].addTile(x, y, getTileIndex(layer, tile));
		
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
	
	void setInitialized(bool initialized)
	{
		if(this.initialized == false && initialized == true)
		{
			TileGrid @scene = @layers[TERRAIN_SCENE];
			for(int x = 0; x < width; x++)
			{
				for(int y = 0; y < height; y++)
				{
					updateFixture(x, y);
				}
			}
		}
		this.initialized = initialized;
	}
	
	// Drawing
	void draw(TerrainLayer layer)
	{
		Matrix4 mat;
		mat.translate(-game::camera.position.x + padding/(2.0f * game::camera.zoom), -game::camera.position.y + padding/(2.0f * game::camera.zoom), 0.0f);
		mat.scale(game::camera.zoom);
		layers[layer].draw(@terrainTexture, mat);
	}
	
	void drawShadows()
	{
		shadowTexture.clear();
		shadowBatch.renderToTexture(@shadowTexture);
		
		Shape @screen = @Shape(Rect(Vector2(-padding*0.5f), Vector2(Window.getSize()) + Vector2(padding)));
		screen.setFillTexture(@shadowTexture);
		screen.draw(@game::batches[FOREGROUND]);
	}
}