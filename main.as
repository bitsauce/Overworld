// Include "includes.as"-files
#include "core/includes.as"
#include "classes/includes.as"
#include "scripts/includes.as"

void main()
{
	// Set some key binds
	Input.bind(KEY_ESCAPE, @toggleFullscreen);
	Input.bind(KEY_P, @toggleProfiler);
	Input.bind(KEY_I, @zoomIn);
	Input.bind(KEY_O, @zoomOut);
	//Input.bind(KEY_BACKSPACE, @back);
	
	// Go fullscreen
	//toggleFullscreen();
	
	// Set b2d world scale
	Box2D.gravity = Vector2(0.0f, 40.0f);
	Box2D.scale = TILE_SIZE;
	
	// Create layer batches
	for(int i = 0; i < global::batches.size; i++) {
		@global::batches[i] = Batch();
	}
	
	Engine.pushScene(@global::mainMenu);
}

void draw()
{
}

void update()
{
	exit();
}

void windowResized(int width, int height)
{
	Console.log("Window resized: " + width + ", " + height);
	
	// Call resize event on all game objects
	for(int i = 0; i < global::gameObjects.size; i++) {
		global::gameObjects[i].windowResized();
	}
}