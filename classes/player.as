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
		ItemDrop @item;
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
			body.applyImpulse(Vector2(-1000.0f, 0.0f), position + size/2.0f);
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
			// Use selected item
			Item @item = inventory.getSelectedItem();
			if(@item != null && (!item.singleShot || !pressed)) {
				item.use(@this);
			}
			
			pressed = true;
		}else{
			pressed = false;
		}
		
		// Temporary solution until i've found some other way to avoid tiling seams
		// for example through shaders or texture arrays
		camera = Vector2(Vector2i(getCenter() - Vector2(Window.getSize())/2.0f));
	}
	
	bool pressed = false;
	
	void draw()
	{
		Shape @shape = Shape(Rect(body.getPosition(), size));
		shape.setFillColor(Vector4(1.0f, 0.0f, 0.0f, 1.0f));
		shape.draw(global::batches[global::FOREGROUND]);
	}
}