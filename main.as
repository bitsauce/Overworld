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
	Box2D.scale = TILE_SIZE;
	
	Textures.init();
	Tiles.init();
	Items.init();
	
	// Go fullscreen
	//toggleFullscreen();
	
	Window.setSize(Vector2i(1280, 720));
	
	//Graphics.enableWireframe();
	
	Engine.pushScene(@scene::main);
}

void update()
{
	Exit();
}

void windowResized(int width, int height)
{
	Console.log("Window resized: " + width + ", " + height);
	scene::game.resized(width, height);
}