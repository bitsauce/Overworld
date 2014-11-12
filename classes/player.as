class Player : Humanoid, Serializable
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
		Camera.lookAt(Vector2(x, y));

		// Load inventory
		string itemString, amountString;
		ss.read(itemString);
		ss.read(amountString);
		for(int y = 0; y < INV_HEIGHT; y++)
		{
			for(int x = 0; x < INV_WIDTH; x++)
			{
				int j = (x + y*INV_WIDTH) * 3;
				inventory.slots[x, y].set(@Items[ItemID(parseInt(itemString.substr(j, 3)))], parseInt(amountString.substr(j, 3)));
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
			if(!inventory.isHovered())
			{
				Item @item = inventory.getSelectedItem();
				if(@item != null && (!item.singleShot || !lmbPressed))
				{
					item.use(@this);
				}
			}
			
			lmbPressed = true;
		}
		else
		{
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
		
		updateAnimations();
		
		// Update camera
		Camera.lookAt(position);
		Debug.setVariable("Camera", Camera.position.x + ", " + Camera.position.y);
		Debug.setVariable("Chunk", Math.floor(body.getPosition().x/CHUNK_SIZE/TILE_SIZE)+", "+Math.floor(body.getPosition().y/CHUNK_SIZE/TILE_SIZE));
		
		// Update audio listener
		Audio.position = position;
		
		//
		inventory.update();
		
		@handItem = @inventory.getSelectedItem();
	}
	
	void draw()
	{
		Humanoid::draw();
		inventory.draw();
	}
}