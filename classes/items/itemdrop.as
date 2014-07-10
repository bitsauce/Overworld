const float ITEM_PICKUP_RADIUS = 125.0f;
const float ITEM_SPEED = 1000.0f;
class ItemDrop : GameObject, Body
{
	Vector2 velocity;
	Vector2 size = Vector2(16.0f, 16.0f);
	float moveSpeed = 7.0f;
	b2Body @body;
	b2Fixture @fix;
	
	Item @data;
	int amount;
	
	float cooldown = 2.0f;
	
	bool jumping = false;
	
	ItemDrop(Item @data, int amount = 1)
	{
		@this.data = @data;
		this.amount = amount;
		
		b2BodyDef def;
		def.type = b2_dynamicBody;
		def.fixedRotation = true;
		@body = @b2Body(def);
		body.setObject(@this);
		body.setPreSolveCallback(ContactFunc(@preSolve));
		@fix = @body.createFixture(Rect(0, 0, size.x, size.y), 32.0f);
	}
	
	void remove()
	{
		body.destroy();
		GameObject::remove();
	}
	
	bool canPickup()
	{
		return cooldown <= 0.0f;
	}
	
	void preSolve(b2Contact @contact)
	{
		ItemDrop @item;
		if(contact.bodyB.getObject(@item)) {
			contact.setEnabled(false);
		}
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
	
	void update()
	{
		if(cooldown > 0.0f)
		{
			cooldown -= Graphics.dt;
			return;
		}
		
		for(int i = 0; i < global::players.size; i++)
		{
			Vector2 dt = global::players[i].getCenter() - getCenter();
			if(dt.length() <= ITEM_PICKUP_RADIUS)
			{
				Vector2 impulse = dt.normalized() * ITEM_SPEED;
				body.applyImpulse(impulse, getCenter());
			}
		}
	}
	
	void draw()
	{
		Sprite @sprite = @data.icon;
		sprite.setPosition(getPosition());
		sprite.draw(global::batches[SCENE]);
	}
}