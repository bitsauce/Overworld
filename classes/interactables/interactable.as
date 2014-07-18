class Interactable : GameObject
{
	Sprite @sprite;
	
	Interactable()
	{
		global::interactables.insertLast(@this);
	}
	
	bool isHovered() const
	{
		Vector2 cursor = Input.position + global::camera.position;
		return Rect(sprite.getPosition(), sprite.getSize()).contains(cursor);
	}
	
	void interact(Player @player) { /* virtual */ }
}