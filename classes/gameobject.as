class GameObject
{
	GameObject() {
		global::gameObjects.insertLast(@this);
	}
	
	void draw() {}
	void update() {}
}

namespace global {
	array<GameObject@> gameObjects;
}