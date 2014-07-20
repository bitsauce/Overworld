// Include "includes.as"-files
#include "core/includes.as"
#include "classes/includes.as"
#include "scripts/includes.as"

void main()
{
	Console.log("Loading game...");
	
	// Set some key binds
	Input.bind(KEY_ESCAPE, @toggleFullscreen);
	Input.bind(KEY_P, @toggleProfiler);
	
	// Go fullscreen
	toggleFullscreen();
	
	// Set b2d world scale
	Box2D.gravity = Vector2(0.0f, 40.0f);
	Box2D.scale = TILE_SIZE;
	
	// Create layer batches
	for(int i = 0; i < global::batches.size; i++) {
		@global::batches[i] = Batch();
	}
	
	// Create time manager
	TimeOfDay();
	
	// Create background
	Background();
	
	// Create terrain
	Console.log("Creating terrain...");
	Terrain(250, 50);
	
	// Create player
	Console.log("Setting up player...");
	Player player();
	
	// Spawn in the middle of the world
	int x = 250/2;
	int y = global::terrain.gen.getGroundHeight(x);
	player.body.setPosition(Vector2(x*TILE_SIZE, y*TILE_SIZE));
	
	// Give loadout
	player.inventory.addItem(@global::items[PICKAXE_IRON]);
	player.inventory.addItem(@global::items[STONE_BLOCK], 50);
}

void draw()
{
	if(Input.getKeyState(KEY_I))
		global::camera.zoom += 0.1f;
	else if(Input.getKeyState(KEY_O))
		global::camera.zoom -= 0.1f;
	
	// Create translation matrix
	global::batches[SCENE].setProjectionMatrix(global::camera.getProjectionMatrix());
	
	// Clear batches
	for(int i = 0; i < global::batches.size; i++) {
		global::batches[i].clear();
	}
	
	// Draw game object into batches
	for(int i = 0; i < global::gameObjects.size; i++) {
		global::gameObjects[i].draw();
	}
	
	// Render scene terrain-layer to texture
	global::terrain.terrainTexture.clear();
	global::terrain.draw(TERRAIN_BACKGROUND);
	
	Shape @screen = @Shape(Rect(Vector2(-global::terrain.padding/2.0f), Vector2(Window.getSize()) + Vector2(global::terrain.padding)));
	screen.setFillTexture(@global::terrain.terrainTexture);
	screen.draw(@global::batches[BACKGROUND]);
	
	global::batches[BACKGROUND].draw();
	
	// Box2D debug draw
	if(Input.getKeyState(KEY_B)) {
		Box2D.draw(@global::batches[SCENE]);
	}
	
	// Draw scene content
	global::batches[SCENE].draw();
	
	// Draw terrain scene and foreground layer to texture
	global::terrain.terrainTexture.clear();
	global::terrain.draw(TERRAIN_SCENE);
	global::terrain.draw(TERRAIN_FOREGROUND);
	
	screen.setFillTexture(@global::terrain.terrainTexture);
	screen.draw(@global::batches[FOREGROUND]);
	
	global::terrain.drawShadows();
	
	global::batches[FOREGROUND].draw();
	
	// Draw debug text to screen
	global::debug.addVariable("FPS", ""+Graphics.FPS);
	
	// Draw remaining batches
	for(int i = FOREGROUND + 1; i < global::batches.size; i++) {
		global::batches[i].draw();
	}
}

void update()
{
	// Step Box2D
	Box2D.step(Graphics.dt);
	
	// Update all game objects
	for(int i = 0; i < global::gameObjects.size; i++) {
		global::gameObjects[i].update();
	}
}

void windowResized(int width, int height)
{
	Console.log("Window resized: " + width + ", " + height);
	
	// Call resize event on all game objects
	for(int i = 0; i < global::gameObjects.size; i++) {
		global::gameObjects[i].windowResized();
	}
}