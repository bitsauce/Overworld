const float ITEM_PICKUP_RADIUS = 125.0f;
const float ITEM_SPEED = 1000.0f;
class ItemDrop : GameObject, Serializable
{
	Vector2 velocity;
	Vector2 size;
	b2Body @body;
	b2Fixture @fix;
	
	ItemData @data;
	int amount;
	
	float cooldown = 2.0f;
	bool jumping = false;
	
	ItemDrop(ItemData @data, int amount = 1)
	{
		init(@data, amount);
	}
	private void init(ItemData @data, int amount)
	{
		@this.data = @data;
		this.amount = amount;
		size = Vector2(16.0f, 16.0f);
	
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
	void serialize(StringStream &ss)
	{
		ss.write(int(data.getID()));
		ss.write(amount);
		ss.write(body.getPosition());
	}
	void deserialize(StringStream &ss)
	{
		int id;
		ss.read(id);
		int amount;
		ss.read(amount);
		init(@Items[id], amount);
		Vector2 pos;
		ss.read(pos);
		body.setPosition(pos);
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
		body.setPosition(body.getPosition());
		if(cooldown > 0.0f)
		{
			cooldown -= Graphics.dt;
			return;
		}
		
		float dist;
		Player @player = World.getClosestPlayer(body.getCenter(), dist);
		if(dist <= ITEM_PICKUP_RADIUS)
		{
			Vector2 impulse = (player.body.getCenter() - body.getCenter()).normalized() * ITEM_SPEED;
			body.applyImpulse(impulse, body.getCenter());
		}
	}
	
	void draw()
	{
		Sprite @sprite = @data.icon;
		sprite.setPosition(body.getPosition() - size/2.0f);
		sprite.draw(@Layers[LAYER_SCENE]);
	}
}