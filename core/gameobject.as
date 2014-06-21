class GameObject
{
	GameObject() {
		global::gameObjects.insertLast(@this);
	}
	
	void remove()
	{
		int idx = global::gameObjects.findByRef(@this);
		if(idx >= 0) {
			global::gameObjects.removeAt(idx);
		}
	}
	
	void draw() {}
	void update() {}
}