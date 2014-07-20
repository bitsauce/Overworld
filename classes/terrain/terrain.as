bool isValidTile(Tile tile)
{
	return tile != SCENE_TILES && tile != BACKGROUND_TILES &&
			tile != FOREGROUND_TILES && tile != MAX_TILES;
}

class Terrain : GameObject
{
	grid<b2Fixture@> fixtures;
	b2Body @body;
	
	array<TileGrid@> layers(TERRAIN_LAYERS_MAX);
	
	private int width;
	private int height;
		
	TerrainGen gen();
	
	// Shader uniform
	float radius = 3.0f; // px
	float falloff = 3.0f;
	int shadowDownsampleLevel = 16;
	
	Shader @shadowShader = @Shader(":/shaders/terrainshadows.vert", ":/shaders/terrainshadows.frag");
	Batch @shadowBatch = @Batch();
	Texture @shadowTexture;
	
	Texture @terrainTexture;
	
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
	
	Terrain(const int width, const int height)
	{
		// Update texture object
		windowResized();
		
		// Set shader uniforms
		shadowShader.setUniform1f("radius", radius);
		shadowShader.setUniform1f("falloff", falloff);
		
		// Set size
		this.width = width;
		this.height = height;
		
		// Load tile textures
		array<Texture@> tileTextures(MAX_TILES);
		@tileTextures[GRASS_TILE]	=	@Texture(":/sprites/tiles/grass_tile_test.png");
		@tileTextures[STONE_TILE]	=	@Texture(":/sprites/tiles/stone_tile_test.png");
		//@tileTextures[LEAF_TILE]	=	@Texture(":/sprites/tiles/leaf_tile.png");
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
		
		// Generate a terrain
		Console.log("Generating world...");
		gen.generate(@this);
		
		for(int i = 0; i < TERRAIN_LAYERS_MAX; i++)
			layers[i].setInitialized(true);
		
		// Set global terrain handle
		@global::terrain = @this;
		
		// NOTE TO SELF: The vertex count can be redused to 424320
		// on-screen vertices by using texture atlases. This
		// equates to 15.28 MB of VRAM. Formulae: num_tiles * quads_per_tile * verts_per_quad * floats_per_vert * float_to_bytes / size_of_megabyte
		Console.log("Vertex count: " + width*height*13*4 + " (" + (width*height*13*4*8*4.0f/1048576.0f) + " MB)");
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
			b2Fixture @fixture = @body.createFixture(Rect(x * TILE_SIZE - TILE_SIZE * 0.5f, y * TILE_SIZE - TILE_SIZE * 0.5f, TILE_SIZE*2, TILE_SIZE*2), 0.0f);
			fixture.setFriction(0.5f);
			@fixtures[x, y] = @fixture;
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
	void draw(TerrainLayer layer)
	{
		Matrix4 mat;
		mat.translate(-global::camera.position.x + padding/(2.0f * global::camera.zoom), -global::camera.position.y + padding/(2.0f * global::camera.zoom), 0.0f);
		mat.scale(global::camera.zoom);
		layers[layer].draw(@terrainTexture, mat);
	}
	
	void drawShadows()
	{
		shadowTexture.clear();
		shadowBatch.renderToTexture(@shadowTexture);
		
		Shape @screen = @Shape(Rect(Vector2(-padding/2.0f), Vector2(Window.getSize()) + Vector2(padding)));
		screen.setFillTexture(@shadowTexture);
		screen.draw(@global::batches[FOREGROUND]);
	}
}