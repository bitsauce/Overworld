const float ITEM_PICKUP_RADIUS = 125.0f;
const float ITEM_SPEED = 1000.0f;
class ItemDrop : GameObject
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
		body.setPreSolveCallback(b2ContactCallback(@preSolve));
		@fix = @body.createFixture(Vector2(0.0f), size.x/2.0f, 32.0f);
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
	
	void update()
	{
		if(cooldown > 0.0f)
		{
			cooldown -= Graphics.dt;
			return;
		}
		
		for(int i = 0; i < global::players.size; i++)
		{
			Vector2 dt = global::players[i].body.getPosition() - body.getCenter();
			if(dt.length() <= ITEM_PICKUP_RADIUS)
			{
				Vector2 impulse = dt.normalized() * ITEM_SPEED;
				body.applyImpulse(impulse, body.getCenter());
			}
		}
	}
	
	void draw()
	{
		Sprite @sprite = @data.icon;
		sprite.setPosition(body.getPosition() - size/2.0f);
		sprite.draw(global::batches[SCENE]);
	}
}