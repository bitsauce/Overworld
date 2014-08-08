class GameObject
{
	GameObject()
	{
		game::objects.insertLast(@this);
	}
	
	void remove()
	{
		int idx = game::objects.findByRef(@this);
		if(idx >= 0) {
			game::objects.removeAt(idx);
		}
	}
	
	void draw() {}
	void update() {}
	void windowResized() {}
}