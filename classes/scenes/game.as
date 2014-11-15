class GameScene : Scene
{
	void show()
	{
		Console.log("Scene: GameScene");
	}
	
	void hide()
	{
		// Save and clear
		World.save();
		World.clear();
	}
	
	void update()
	{
		::update();
	}
	
	void draw()
	{
		::draw();
	}
	
	void resized(int width, int height)
	{
	}
}