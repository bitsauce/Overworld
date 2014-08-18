class GameObject
{
	GameObject()
	{
		scene::game.addGameObject(@this);
	}
	
	void remove()
	{
		scene::game.removeGameObject(@this);
	}
	
	void draw() {}
	void update() {}
}