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
		// Update all ui objects
		for(int i = 0; i < uiObjects.size; i++) {
			uiObjects[i].update();
		}
	}
	
	void draw()
	{
		batch.clear();
		
		Shape @shape = @Shape(Rect(Vector2(0.0f), Vector2(Window.getSize())));
		shape.setFillColor(Vector4(0.5f, 0.5f, 0.8f, 1.0f));
		shape.draw(@batch);
		
		// Draw all ui objects
		for(int i = 0; i < uiObjects.size; i++) {
			uiObjects[i].draw(@batch);
		}
		
		batch.draw();
	}
	
	void createWorld()
	{
		string worldName = worldNameEdit.getText();
		if(worldName.length == 0)
			return;
		
		IniFile @worldFile = @IniFile("saves:/Overworld/worlds/world_"+worldName+".ini");
		worldFile.setValue("world", "name", worldName);
		
		// Generate world
		Console.log("Creating world...");
		global::terrain.generate(250, 50, @worldFile);
		
		// Load game
		loadGame(@worldFile);
		
		worldFile.save();
	}
}