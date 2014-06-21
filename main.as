// Include "includes.as"-files
#include "core/includes.as"
#include "classes/includes.as"
#include "scripts/includes.as"

void main()
{
	Box2D.scale = TILE_SIZE;
	
	TimeOfDay();
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
	
	arial.setColor(Vector4(0.0f, 0.0f, 0.0f, 1.0f));
	arial.draw(@global::batches[global::UITEXT], Vector2(730.0f, 12.0f), "FPS: " + Graphics.FPS);
	
	for(int i = 0; i < global::batches.size; i++) {
		global::batches[i].draw();
	}
	
	global::terrain.draw();
	
	Box2D.draw();
}

Vector2 camera;
float cameraSpeed = 16.0f;

bool profilerToggled = false;

void update()
{
	if(Input.getKeyState(KEY_LMB)) {
		global::terrain.removeTile((Input.position.x+camera.x)/TILE_SIZE, (Input.position.y+camera.y)/TILE_SIZE);
	}else if(Input.getKeyState(KEY_RMB)){
		global::terrain.addTile((Input.position.x+camera.x)/TILE_SIZE, (Input.position.y+camera.y)/TILE_SIZE, GRASS_TILE);
	}
	
	if(Input.getKeyState(KEY_I))
	{
		Item i();
		i.body.setTransform(Input.position+camera, 0.0f);
	}
	
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