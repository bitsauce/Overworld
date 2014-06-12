class Player : GameObject
{
	Vector2 position;
	Vector2 velocity;
	float moveSpeed = 7.0f;
	
	Player()
	{
	}
	
	void update()
	{
		velocity.y += 9.18f;
		
		if(global::terrain.isTileAt(position.x/TILE_SIZE, (position.y+52.0f)/TILE_SIZE)) {
			velocity.y = 0.0f;
		}
		
		if(Input.getKeyState(KEY_A))
			velocity.x -= moveSpeed;
		if(Input.getKeyState(KEY_D))
			velocity.x += moveSpeed;
		if(Input.getKeyState(KEY_SPACE))
			velocity.y -= 15.0f;
		
		velocity.x *= 0.98f;
		
		position += velocity * Graphics.dt;
		camera = position - Vector2(Window.getSize())/2.0f;
	}
	
	void draw()
	{
		Shape @shape = Shape(Rect(position, Vector2(24.0f, 52.0f)));
		shape.setFillColor(Vector4(1.0f, 0.0f, 0.0f, 1.0f));
		shape.draw(global::batches[global::FOREGROUND_LAYER]);
	}
}