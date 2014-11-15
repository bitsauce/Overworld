class GameObject
{
	GameObject()
	{
		World.addGameObject(@this);
	}
	
	void remove()
	{
		World.removeGameObject(@this);
	}
	
	void draw() {}
	void update() {}
}