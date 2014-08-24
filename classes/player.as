class Player : Humanoid
{
	// Player inventory
	Inventory @inventory;
	
	// For single shot items
	bool lmbPressed;
	
	// Player name
	string name;
	
	Player()
	{
		init();
	}
	
	private void init()
	{
		// Create an inventory for the player
		@inventory = @Inventory(@this);
		
		size = Vector2(28.0f, 44.0f);
		name = "Bitsauce";
		mass = 18.0f;
		lmbPressed = false;
		
		Humanoid::init();
	}
	
	void serialize(StringStream &ss)
	{
		Console.log("Saving player '" + name + "'...");
		
		ss.write(body.getPosition().x);
		ss.write(body.getPosition().y);
		
		// Save inventory
		string itemString;
		string amountString;
		for(int y = 0; y < INV_HEIGHT; y++)
		{
			for(int x = 0; x < INV_WIDTH; x++)
			{
				ItemSlot @slot = @inventory.slots[x, y];
				if(!slot.isEmpty())
				{
					itemString += formatInt(slot.item.getID(), "0", 3);
					amountString += formatInt(slot.amount, "0", 3);
				}else{
					itemString += "000";
					amountString += "000";
				}
			}
		}
		ss.write(itemString);
		ss.write(amountString);
	}
	
	void deserialize(StringStream &ss)
	{
		init();
		
		Console.log("Loading player '" + name + "'...");
		
		float x, y;
		ss.read(x);
		ss.read(y);
		body.setPosition(Vector2(x, y));

		// Load inventory
		string itemString, amountString;
		ss.read(itemString);
		ss.read(amountString);
		for(int y = 0; y < INV_HEIGHT; y++)
		{
			for(int x = 0; x < INV_WIDTH; x++)
			{
				int j = (x + y*INV_WIDTH) * 3;
				inventory.slots[x, y].set(@game::items[ItemID(parseInt(itemString.substr(j, 3)))], parseInt(amountString.substr(j, 3)));
			}
		}
	}
	
	void remove()
	{
		body.destroy();
		GameObject::remove();
	}
	
	void preSolve(b2Contact @contact)
	{
		ItemDrop @item;
		Projectile @proj;
		if(contact.bodyB.getObject(@item))
		{
			// Pickup item drops
			contact.setEnabled(false);
			if(item.canPickup())
			{
				int result = inventory.addItem(@item.data, item.amount);
				if(result == 0)
				{
					item.remove();
				}else
				{
					item.amount = result;
				}
			}
		}else if(contact.bodyB.getObject(@proj))
		{
			// Disable collision for projectiles (?)
			contact.setEnabled(false);
		}
		
		Humanoid::preSolve(@contact);
	}
	
	void update()
	{
		Vector2 position = body.getPosition();
		Vector2 velocity = body.getLinearVelocity();
		
		if(Input.getKeyState(KEY_A)) {
			moveLeft();
		}
		
		if(Input.getKeyState(KEY_D)) {
			moveRight();
		}
		
		if(Input.getKeyState(KEY_SPACE) && numGroundContact > 0) {
			jump();
		}
		
		// Use selected item
		if(Input.getKeyState(KEY_LMB))
		{
			Item @item = inventory.getSelectedItem();
			if(@item != null && (!item.singleShot || !lmbPressed)) {
				item.use(@this);
			}
			
			lmbPressed = true;
		}else{
			lmbPressed = false;
		}
		
		// Furniture interaction
		if(Input.getKeyState(KEY_RMB))
		{
			Furniture @furniture = @scene::game.getHoveredFurniture();
			if(@furniture != null && (furniture.getPosition() - position).length() <= ITEM_PICKUP_RADIUS) {
				furniture.interact(@this);
			}
		}
		
		// Clamp player position to world bounds
		if(position.x < 0.0f)
		{
			position.x = 0.0f;
			body.setLinearVelocity(Vector2(0.0f, velocity.y));
			body.setPosition(position);
		}else if(position.x > game::terrain.getWidth()*TILE_SIZE)
		{
			position.x = game::terrain.getWidth()*TILE_SIZE;
			body.setLinearVelocity(Vector2(0.0f, velocity.y));
			body.setPosition(position);
		}
		
		if(position.y < 0.0f)
		{
			position.y = 0.0f;
			body.setLinearVelocity(Vector2(velocity.x, 0.0f));
			body.setPosition(position);
		}else if(position.y > game::terrain.getHeight()*TILE_SIZE)
		{
			position.y = game::terrain.getHeight()*TILE_SIZE;
			body.setLinearVelocity(Vector2(velocity.x, 0.0f));
			body.setPosition(position);
		}
		
		updateAnimations();
		
		// Update camera
		game::camera.lookAt(position);
		
		// Update audio listener
		Audio.position = position;
		
		//
		inventory.update();
	}
	
	void draw()
	{
		Humanoid::draw();
		inventory.draw();
	}
}