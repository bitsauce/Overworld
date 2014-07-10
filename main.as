// Include "includes.as"-files
#include "core/includes.as"
#include "classes/includes.as"
#include "scripts/includes.as"

void main()
{
	Console.log("Loading game...");
	
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
	player.setPosition(Vector2(x*TILE_SIZE, y*TILE_SIZE));
	
	// Give loadout
	player.inventory.addItem(@global::items[PICKAXE_IRON]);
}

void draw()
{
	// Create translation matrix
	Matrix4 mat;
	mat.translate(-camera.x, -camera.y, 0.0f);
	global::batches[SCENE].setProjectionMatrix(mat);
		
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
	
	Shape @screen = @Shape(Rect(Vector2(-global::terrain.padding/2.0f), Vector2(800, 600) + Vector2(global::terrain.padding)));
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
	global::arial12.setColor(Vector4(0.0f, 0.0f, 0.0f, 1.0f));
	global::arial12.draw(@global::batches[UITEXT], Vector2(730.0f, 12.0f), "FPS: " + Graphics.FPS);
	
	// Draw remaining batches
	for(int i = FOREGROUND + 1; i < global::batches.size; i++) {
		global::batches[i].draw();
	}
}

Vector2 camera;

bool profilerToggled = false;

void update()
{
	// Update all game objects
	for(int i = 0; i < global::gameObjects.size; i++) {
		global::gameObjects[i].update();
	}
	
	// Profiler toggle
	if(Input.getKeyState(KEY_P)) {
		if(!profilerToggled) Engine.toggleProfiler();
		profilerToggled = true;
	}else{
		profilerToggled = false;
	}
	
	// Step Box2D
	Box2D.step(Graphics.dt);
}