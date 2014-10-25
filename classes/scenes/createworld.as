class CreateWorldMenu : Scene
{
	array<UiObject@> uiObjects;
	Batch @batch = @Batch();
	LineEdit @worldNameEdit;
	
	CreateWorldMenu()
	{
	}
	
	void show()
	{
		Console.log("CreateWorldMenu: Show");
		
		@worldNameEdit = LineEdit(null);
		worldNameEdit.anchor = CENTER;
		worldNameEdit.setPosition(Vector2(0.0f, 0.0f));
		worldNameEdit.setSize(Vector2(0.2f, 0.01f));
		@worldNameEdit.acceptFunc = AcceptCallback(@createWorld);
		
		Button @createWorldButton = @Button("Create!", ButtonCallback(@createWorld), null);
		createWorldButton.anchor = BOTTOM_CENTER;
		createWorldButton.setPosition(Vector2(0.0f, -0.1f));
		createWorldButton.setSize(Vector2(0.2f, 0.05f));
		
		uiObjects.insertLast(@createWorldButton);
		uiObjects.insertLast(@worldNameEdit);
	}
	
	void hide()
	{
		Console.log("CreateWorldMenu: Hide");
		
		uiObjects.clear();
	}
	
	void update()
	{
		Terrain.update();
		
		// Update all ui objects
		for(int i = 0; i < uiObjects.size; ++i) {
			uiObjects[i].update();
		}
	}
	
	void draw()
	{
		// Clear batch
		batch.clear();
		
		// Draw all ui objects
		for(int i = 0; i < uiObjects.size; ++i)
		{
			uiObjects[i].draw(@batch);
		}
		
		// Draw batch
		batch.draw();
	}
	
	void createWorld()
	{
		// Get world name
		string worldName = worldNameEdit.getText();
		if(worldName.length == 0)
			return;
		
		// Create world
		scene::game.createWorld(worldName);
		
		// Show game
		Engine.pushScene(@scene::game);
	}
}