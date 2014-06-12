#include "classes/terrain.as"
#include "classes/background.as"
#include "classes/gameobject.as"
#include "classes/player.as"

array<Texture@> TILE_TEXTURES(MAX_TILES);
Font @arial = @Font("Arial Bold", 12);

namespace global {
	enum Layer {
		BACKGROUND_LAYER,
		FOREGROUND_LAYER,
		NUM_LAYERS
	}
	array<Batch@> batches(NUM_LAYERS);
}

void main()
{
	Terrain(50, 50);
	Background();
	Player();
	
	// Create batches
	for(int i = 0; i < global::batches.size; i++) {
		@global::batches[i] = Batch();
	}
}

void draw()
{
	// Clear batches
	for(int i = 0; i < global::batches.size; i++) {
		global::batches[i].clear();
	}
	
	for(int i = 0; i < global::gameObjects.size; i++) {
		global::gameObjects[i].draw();
	}
	
	arial.setColor(Vector4(0.0f, 0.0f, 0.0f, 1.0f));
	arial.draw(@global::batches[global::BACKGROUND_LAYER], Vector2(12.0f, 12.0f), "FPS: " + Graphics.FPS);
	
	for(int i = 0; i < global::batches.size; i++) {
		global::batches[i].draw();
	}
	
	global::terrain.draw();
}

Vector2 camera;
float cameraSpeed = 16.0f;

bool profilerToggled = false;

void update()
{
	if(Input.getKeyState(KEY_LMB))
		global::terrain.removeTile((Input.position.x+camera.x)/TILE_SIZE, (Input.position.y+camera.y)/TILE_SIZE);
	else if(Input.getKeyState(KEY_RMB))
		global::terrain.addTile((Input.position.x+camera.x)/TILE_SIZE, (Input.position.y+camera.y)/TILE_SIZE, GRASS_TILE);
	
	for(int i = 0; i < global::gameObjects.size; i++) {
		global::gameObjects[i].update();
	}
	
	if(Input.getKeyState(KEY_P)) {
		if(!profilerToggled) Engine.toggleProfiler();
		profilerToggled = true;
	}else{
		profilerToggled = false;
	}
}