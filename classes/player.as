interface Body
{
	Vector2 getPosition();
	void setPosition(Vector2);
	Vector2 getSize();
	void setSize(Vector2);
	Vector2 getCenter();
}

class Player : GameObject, Body
{
	Vector2 velocity;
	Vector2 size = Vector2(24.0f, 42.0f);
	float moveSpeed = 7.0f;
	b2Body @body;
	b2Fixture @fix;
	
	Inventory @inventory;
	
	bool jumping = false;
	
	Player()
	{
		@inventory = @Inventory(@this);
		inventory.addItem(@global::items[PICKAXE_IRON]);
		
		b2BodyDef def;
		def.type = b2_dynamicBody;
		def.fixedRotation = true;
		def.position.set(200, 0);
		@body = @b2Body(def);
		@fix = @body.createFixture(Rect(0, 0, size.x, size.y), 32.0f);
		
		body.setObject(@this);
		body.setPreSolveCallback(ContactFunc(@collision));
		
		global::players.insertLast(@this);
	}
	
	Vector2 getPosition()
	{
		return body.getPosition();
	}
	
	void setPosition(Vector2 position)
	{
		body.setTransform(position, 0.0f);
	}
	
	Vector2 getSize()
	{
		return size;
	}
	
	void setSize(Vector2)
	{
		// NO
	}
	
	Vector2 getCenter()
	{
		return getPosition() + getSize()/2.0f;
	}
	
	void collision(b2Contact @contact)
	{
		Item @item;
		Projectile @proj;
		if(contact.other.getObject(@item)) {
			contact.setEnabled(false);
			if(item.canPickup()) {
				int result = inventory.addItem(@item.data, item.amount);
				if(result == 0) {
					item.remove();
				}else{
					item.amount = result;
				}
			}
		}else if(contact.other.getObject(@proj)) {
			contact.setEnabled(false);
		}
	}
	
	void update()
	{
		Vector2 position = body.getPosition();
		
		if(Input.getKeyState(KEY_A))
			body.applyImpulse(Vector2(-10.0f, 0.0f), position + size/2.0f);
		if(Input.getKeyState(KEY_D))
			body.applyImpulse(Vector2(1000.0f, 0.0f), position + size/2.0f);
		if(Input.getKeyState(KEY_SPACE)) {
			if(!jumping) body.applyImpulse(Vector2(0.0f, -20000.0f), position + size/2.0f);
			jumping = true;
		}else{
			jumping = false;
		}
		
		if(Input.getKeyState(KEY_LMB))
		{
			ItemID id = global::items.find(inventory.getSelectedItem());
			switch(id)
			{
			case PICKAXE_IRON:
			{
				Vector2 dt = Input.position+camera - getCenter();
				if(dt.length() <= ITEM_PICKUP_RADIUS)
				{
					Vector2i pos = Vector2i((Input.position+camera)/TILE_SIZE);
					
					Tile tile = global::terrain.getTileAt(pos.x, pos.y);
					if(tile == NULL_TILE)
					{
						tile = global::terrain.getTileAt(pos.x, pos.y, TERRAIN_BACKGROUND);
						global::terrain.removeTile(pos.x, pos.y, TERRAIN_BACKGROUND);
					}else{
						global::terrain.removeTile(pos.x, pos.y);
					}
					
					switch(tile)
					{
					case GRASS_TILE:
					{
						Item item(@global::items[GRASS_BLOCK]);
						item.setPosition(Vector2(pos)*TILE_SIZE);
					}
					break;
					case TREE_TILE:
					{
						Item item1(@global::items[STICK]);
						item1.setPosition(Vector2(pos)*TILE_SIZE);
						Item item2(@global::items[WOOD_BLOCK]);
						item2.setPosition(Vector2(pos)*TILE_SIZE);
					}
					break;
					}
				}
			}
			break;
			
			case WOOD_BLOCK:
			{
				Vector2 dt = Input.position+camera - getCenter();
				if(dt.length() <= ITEM_PICKUP_RADIUS)
				{
					Vector2i pos = Vector2i((Input.position+camera)/TILE_SIZE);
					Tile tile = global::terrain.getTileAt(pos.x, pos.y, TERRAIN_BACKGROUND);
					if(tile == NULL_TILE && inventory.removeItem(@global::items[id]))
					{
						global::terrain.addTile(pos.x, pos.y, TREE_TILE);
					}
				}
			}
			break;
			case GRASS_BLOCK:
			{
				Vector2 dt = Input.position+camera - getCenter();
				if(dt.length() <= ITEM_PICKUP_RADIUS)
				{
					Vector2i pos = Vector2i((Input.position+camera)/TILE_SIZE);
					Tile tile = global::terrain.getTileAt(pos.x, pos.y);
					if(tile == NULL_TILE && inventory.removeItem(@global::items[id]))
					{
						global::terrain.addTile(pos.x, pos.y, GRASS_TILE);
					}
				}
			}
			break;
			
			case STICK:
			{
				if(!pressed && inventory.removeItem(@global::items[id]))
				{
					Vector2 dt = Input.position+camera - getCenter();
					
					Projectile p();
					p.setPosition(getCenter());
					p.body.applyImpulse(dt.normalized() * 3000, p.getPosition());
				}
			}
			break;
			}
			
			pressed = true;
		}else{
			pressed = false;
		}
	
		camera = position - Vector2(Window.getSize())/2.0f;
	}
	
	bool pressed = false;
	
	void draw()
	{
		Shape @shape = Shape(Rect(body.getPosition(), size));
		shape.setFillColor(Vector4(1.0f, 0.0f, 0.0f, 1.0f));
		shape.draw(global::batches[global::FOREGROUND]);
	}
}