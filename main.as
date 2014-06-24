// Include "includes.as"-files
#include "core/includes.as"
#include "classes/includes.as"
#include "scripts/includes.as"

void main()
{
	Console.log("Loading game...");
	
	Box2D.scale = TILE_SIZE;
	
	TimeOfDay();
	Console.log("Creating terrain...");
	Terrain(250, 250);
	Background();
	Console.log("Setting up player...");
	Player();
	
	// Create batches
	for(int i = 0; i < global::batches.size; i++) {
		@global::batches[i] = Batch();
	}
}

void draw()
{
	Matrix4 mat;
	mat.translate(-camera.x, -camera.y, 0.0f);
	global::batches[global::FOREGROUND].setProjectionMatrix(mat);
		
	// Clear batches
	for(int i = 0; i < global::batches.size; i++) {
		global::batches[i].clear();
	}
	
	for(int i = 0; i < global::gameObjects.size; i++) {
		global::gameObjects[i].draw();
	}
	
	global::arial12.setColor(Vector4(0.0f, 0.0f, 0.0f, 1.0f));
	global::arial12.draw(@global::batches[global::UITEXT], Vector2(730.0f, 12.0f), "FPS: " + Graphics.FPS);
	//global::arial12.draw(@global::batches[global::UITEXT], Vector2(12.0f, 150.0f), "Camera: (" + camera.x + ", " +camera.y+")");
	
	global::batches[global::BACKGROUND].draw();
	
	global::terrain.draw(TERRAIN_BACKGROUND, mat);
	global::terrain.draw(TERRAIN_SCENE, mat);
	
	global::batches[global::FOREGROUND].draw();
	
	global::terrain.draw(TERRAIN_FOREGROUND, mat);
	
	for(int i = global::FOREGROUND + 1; i < global::batches.size; i++) {
		global::batches[i].draw();
	}
	
	//Box2D.draw();
}

Vector2 camera;
float cameraSpeed = 16.0f;

bool profilerToggled = false;

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