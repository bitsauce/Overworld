Player @getClosestPlayer(Vector2 position)
{
	Player @closestPlayer = null;
	float minDist = -1.0f;
	for(int i = 0; i < global::players.size; i++)
	{
		float dist = (global::players[i].body.getPosition() - position).length();
		if(dist <= minDist || minDist < 0.0f)
		{
			@closestPlayer = @global::players[i];
			minDist = dist;
		}
	}
	return closestPlayer;
}

class Zombie : GameObject
{
	Vector2 size = Vector2(24.0f, 42.0f);
	float moveSpeed = 7.0f;
	float maxMovementSpeed = 50.0f;
	b2Body @body;
	b2Fixture @fix;
	int health = 5;
	
	Zombie()
	{
		b2BodyDef def;
		def.type = b2_dynamicBody;
		def.fixedRotation = true;
		def.position.set(200, 0);
		@body = @b2Body(def);
		@fix = @body.createFixture(Rect(0, 0, size.x, size.y), 32.0f);
		
		body.setObject(@this);
		body.setPreSolveCallback(b2ContactCallback(@preSolve));
	}
	
	void remove()
	{
		body.destroy();
		GameObject::remove();
	}
	
	void preSolve(b2Contact @contact)
	{
		Player @player;
		Projectile @proj;
		if(contact.bodyB.getObject(@player)) {
			contact.setEnabled(false);
			player.health--;
			if(player.health <= 0) {
				player.remove();
			}
		}else if(contact.bodyB.getObject(@proj)) {
			float speed = contact.bodyB.getLinearVelocity().length();
			if(speed >= 100.0f)
			{
				health--;
				if(health <= 0)
				{
					remove();
				}
			}else{
				contact.setEnabled(false);
			}
		}
	}
	
	void update()
	{
		Player @target = @getClosestPlayer(body.getCenter());
		Vector2 dt = target.body.getPosition() - body.getCenter();
		
		if(dt.x < 0.0f)
			body.applyImpulse(Vector2(-1000.0f, 0.0f), body.getCenter());
		if(dt.x > 0.0f)
			body.applyImpulse(Vector2(1000.0f, 0.0f), body.getCenter());
		
		Vector2i tile = Vector2i((body.getPosition()+Vector2(-8.0f, size.y))/TILE_SIZE);
		if(global::terrain.isTileAt(tile.x, tile.y))
			body.applyImpulse(Vector2(0.0f, -1000.0f), body.getCenter());
		tile = Vector2i((body.getPosition()+Vector2(size.x+8.0f, size.y))/TILE_SIZE);
		if(global::terrain.isTileAt(tile.x, tile.y))
			body.applyImpulse(Vector2(0.0f, -1000.0f), body.getCenter());
		
		Vector2 vel = body.getLinearVelocity();
		if(vel.x >= maxMovementSpeed) {
			vel.x = maxMovementSpeed;
		}else if(vel.x <= -maxMovementSpeed) {
			vel.x = -maxMovementSpeed;
		}
		body.setLinearVelocity(vel);
	}
	
	void draw()
	{
		Shape @shape = Shape(Rect(body.getPosition(), size));
		shape.setFillColor(Vector4(0.0f, 1.0f, 0.0f, 1.0f));
		shape.draw(global::batches[global::SCENE]);
	}
}