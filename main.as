// Include "includes.as"-files
#include "core/includes.as"
#include "classes/includes.as"
#include "scripts/includes.as"

void main()
{
	Console.log("Loading game...");
	
	// Set b2d world scale
	Box2D.scale = TILE_SIZE;
	
	// Create batches
	for(int i = 0; i < global::batches.size; i++) {
		@global::batches[i] = Batch();
	}
	
	// Create time manager
	TimeOfDay();
	
	// Create background
	Background();
	
	// Create terrain
	Console.log("Creating terrain...");
	Terrain(250, 250);
	
	// Create player
	Console.log("Setting up player...");
	Player();
}

Texture @terrainTexture = @Texture(800, 600);

void draw()
{
	// Create translation matrix
	Matrix4 mat;
	mat.translate(-camera.x, -camera.y, 0.0f);
	global::batches[global::SCENE].setProjectionMatrix(mat);
		
	// Clear batches
	for(int i = 0; i < global::batches.size; i++) {
		global::batches[i].clear();
	}
	
	// Draw game object into batches
	for(int i = 0; i < global::gameObjects.size; i++) {
		global::gameObjects[i].draw();
	}
	
	// Render scene terrain-layer to texture
	terrainTexture.clear();
	global::terrain.draw(@terrainTexture, TERRAIN_BACKGROUND);
	
	Shape @screen = @Shape(Rect(Vector2(0.0f), Vector2(Window.getSize())));
	screen.setFillTexture(@terrainTexture);
	screen.draw(@global::batches[global::BACKGROUND]);
	
	global::batches[global::BACKGROUND].draw();
	
	// Draw scene content
	global::batches[global::SCENE].draw();
	
	// Draw terrain scene and foreground layer to texture
	terrainTexture.clear();
	global::terrain.draw(@terrainTexture, TERRAIN_SCENE);
	global::terrain.draw(@terrainTexture, TERRAIN_FOREGROUND);
	
	screen.setFillTexture(@terrainTexture);
	screen.draw(@global::batches[global::FOREGROUND]);
	
	global::terrain.drawShadows();
	
	global::batches[global::FOREGROUND].draw();
	
	screen.setFillTexture(@terrainTexture);
	screen.draw(@global::batches[global::FOREGROUND]);
	
	// Draw debug text to screen
	global::arial12.setColor(Vector4(0.0f, 0.0f, 0.0f, 1.0f));
	global::arial12.draw(@global::batches[global::UITEXT], Vector2(730.0f, 12.0f), "FPS: " + Graphics.FPS);
	//global::arial12.draw(@global::batches[global::UITEXT], Vector2(12.0f, 150.0f), "Camera: (" + camera.x + ", " +camera.y+")");
	
	// Draw remaining batches
	for(int i = global::FOREGROUND + 1; i < global::batches.size; i++) {
		global::batches[i].draw();
	}
	
	//Box2D.draw();
}

Vector2 camera;
float cameraSpeed = 16.0f;

bool profilerToggled = false;
bool itoggled = false;

void update()
{
	for(int i = 0; i < global::gameObjects.size; i++) {
		global::gameObjects[i].update();
	}
	
	if(Input.getKeyState(KEY_P)) {
		if(!profilerToggled) Engine.toggleProfiler();
		profilerToggled = true;
	}else{
		profilerToggled = false;
	}
	
	Box2D.step(Graphics.dt);
}