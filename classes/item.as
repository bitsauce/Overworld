Texture @itemTexture = Texture(":/sprites/items/stick.png");
const float ITEM_PICKUP_RADIUS = 200.0f;
const float ITEM_SPEED = 1.0f;
class Item : GameObject, Body
{
	Vector2 velocity;
	Vector2 size = Vector2(16.0f, 16.0f);
	float moveSpeed = 7.0f;
	b2Body @body;
	b2Fixture @fix;
	
	bool jumping = false;
	
	Item()
	{
		b2BodyDef def;
		def.type = b2_dynamicBody;
		def.fixedRotation = true;
		@body = @b2Body(def);
		//body.setObject(@this);
		@fix = @body.createFixture(Rect(0, 0, size.x, size.y), 32.0f);
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
		for(int i = 0; i < global::players.size; i++)
		{
			Vector2 dt = global::players[i].getCenter() - getCenter();
			if(dt.length() <= ITEM_PICKUP_RADIUS)
			{
				setPosition(getPosition() + dt.normalized() * ITEM_SPEED);
			}
		}
	}
	
	void draw()
	{
		Shape @shape = @Shape(Rect(body.getPosition(), size));
		shape.setFillTexture(@itemTexture);
		shape.draw(global::batches[global::FOREGROUND_LAYER]);
	}
}