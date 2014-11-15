// Include "includes.as"-files
#include "core/includes.as"
#include "classes/includes.as"
#include "data/includes.as"

void main()
{
	// Set some key binds
	Input.bind(KEY_ESCAPE, @ToggleFullscreen);
	Input.bind(KEY_I, @ZoomIn);
	Input.bind(KEY_O, @ZoomOut);
	Input.bind(KEY_C, @DebugCreate);
	//Input.bind(KEY_BACKSPACE, @back);
	
	// Set b2d world scale
	Box2D.gravity = Vector2(0.0f, 40.0f);
	Box2D.scale = TILE_PX;
	
	Textures.init();
	Items.init();
	Tiles.init();
	Recipes.init();
	Layers.init();
	
	// Go fullscreen
	//toggleFullscreen();
	
	Window.setSize(Vector2i(1280, 720));
	
	Engine.pushScene(@scene::main);
}

void draw()
{
	// Create translation matrix
	Matrix4 projmat = Camera.getProjectionMatrix();
	Layers[LAYER_SCENE].setProjectionMatrix(projmat);
	
	// Draw the background
	Background.draw(@Layers[LAYER_BACKGROUND]);
	//Water.draw();
	
	// Draw world content
	World.draw();
	
	// Render background
	Layers[LAYER_BACKGROUND].draw();
	
	// Draw terrain
	Terrain.draw(TERRAIN_BACKGROUND, @Layers[LAYER_BACKGROUND]);
	
	// Draw shadows
	Shadows.setProjectionMatrix(Camera.getProjectionMatrix());
	if(!(Input.getKeyState(KEY_Z) && Input.getKeyState(KEY_X))) // debug
		Shadows.draw();
	Shadows.clear();
	
	// Render scene
	Layers[LAYER_SCENE].draw();
	
	// Draw debug info
	if(Input.getKeyState(KEY_Z))
	{
		Debug.draw();
		if(Input.getKeyState(KEY_W))
			Graphics.enableWireframe();
		else
			Graphics.disableWireframe();
		if(Input.getKeyState(KEY_B))
			Box2D.draw(@Layers[LAYER_SCENE]);
	
		// Set FPS debug variable
		Debug.setVariable("FPS", ""+Graphics.FPS);
	}
	
	// Draw remaining layers
	for(uint i = LAYER_FOREGROUND; i < LAYER_COUNT; ++i) {
		Layers[i].draw();
	}
	
	// Clear layers
	for(uint i = 0; i < LAYER_COUNT; ++i) {
		Layers[i].clear();
	}
}

void update()
{
	// Step Box2D
	Box2D.step(Graphics.dt);
	
	// Update all managers
	Terrain.update();
	TimeOfDay.update();
	Background.update();
	Spawner.update();
	//Water.update();
	World.update();
}

void windowResized(int width, int height)
{
	Console.log("Window resized: " + width + ", " + height);
	scene::game.resized(width, height);
}