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

class Bush : Interactable
{
	float berryTimer = 0.0f;
	
	Bush()
	{
		@sprite = @Sprite(@global::textures[BERRY_BUSH_TEXTURE]);
	}
	
	void interact(Player @player)
	{
		if(berryTimer <= 0.0f)
		{
			// Set sprite region to bush without berries
			sprite.setRegion(@TextureRegion(@global::textures[BERRY_BUSH_TEXTURE], 0.0f, 0.0f, 1.0f, 0.5f));
			
			// Give player berries
			//player.inventory.addItem(BERRY_ITEM, 5);
			
			berryTimer = 5.0f; // Respawn in 5 seconds
		}
	}
	
	void update()
	{
		berryTimer -= Graphics.dt;
		if(berryTimer <= 0.0f) {
			sprite.setRegion(@TextureRegion(@global::textures[BERRY_BUSH_TEXTURE], 0.0f, 0.5f, 1.0f, 1.0f));
		}
	}
	
	void draw()
	{
		sprite.draw(@global::batches[SCENE]);
	}
}