// Include "includes.as"-files
#include "core/includes.as"
#include "classes/includes.as"
#include "scripts/includes.as"

void main()
{
	// Set some key binds
	Input.bind(KEY_ESCAPE, @toggleFullscreen);
	Input.bind(KEY_P, @toggleProfiler);
	
	// Go fullscreen
	//toggleFullscreen();
	
	// Set b2d world scale
	Box2D.gravity = Vector2(0.0f, 40.0f);
	Box2D.scale = TILE_SIZE;
	
	// Create layer batches
	for(int i = 0; i < global::batches.size; i++) {
		@global::batches[i] = Batch();
	}
		
	pushMenu(@global::mainMenu);
}

void draw()
{
	// Clear batches
	for(int i = 0; i < global::batches.size; i++) {
		global::batches[i].clear();
	}
	
	if(menuStack.size > 0) {
		menuStack[menuStack.size-1].draw(global::batches[GUI]);
		// Draw remaining batches
		for(int i = 0; i < global::batches.size; i++) {
			global::batches[i].draw();
		}
		
	}else{
		drawGame();
	}
}

void drawGame()
{	
	// Create translation matrix
	global::batches[SCENE].setProjectionMatrix(global::camera.getProjectionMatrix());
	
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