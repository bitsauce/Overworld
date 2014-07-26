class GameScene : Scene
{
	void show()
	{
		Console.log("Show game");
	}
	
	void hide()
	{
		// Do clean up here
		Console.log("Leaving game");
		global::terrain.save();
		global::gameObjects.clear();
		global::interactables.clear();
		global::players.clear();
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
	
	void draw()
	{
		// Clear batches
		for(int i = 0; i < global::batches.size; i++) {
			global::batches[i].clear();
		}
	
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
}