class Player : GameObject
{
	Vector2 position;
	Vector2 velocity;
	Vector2 size = Vector2(24.0f, 42.0f);
	float moveSpeed = 7.0f;
	b2Body @body;
	b2Fixture @fix;
	
	bool jumping = false;
	
	Player()
	{
		b2BodyDef def;
		def.type = b2_dynamicBody;
		def.fixedRotation = true;
		def.position.set(200, 0);
		@body = @b2Body(def);
		@fix = @body.createFixture(Rect(0, 0, size.x, size.y), 32.0f);
	}
	
	~Player()
	{
		body.removeFixture(@fix);
	}
	
	void update()
	{
		position = body.getPosition();
		
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
		
		camera = position - Vector2(Window.getSize())/2.0f;
	}
	
	void draw()
	{
		Shape @shape = Shape(Rect(position, size));
		shape.setFillColor(Vector4(1.0f, 0.0f, 0.0f, 1.0f));
		shape.draw(global::batches[global::FOREGROUND_LAYER]);
	}
}