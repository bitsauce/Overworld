class Zombie : Humanoid, Serializable
{
	// Ray for collision checking
	RayCast ray;
	
	Zombie()
	{
		init();
	}
	
	private void init()
	{
		@ray.plotTest = @TerrainPlotTest;
		
		size = Vector2(28.0f, 44.0f);
		mass = 18.0f;
		
		Humanoid::init();
		
		health = 5;
	}
	
	void serialize(StringStream &ss)
	{
		Console.log("Saving Zombie");
		
	}
	
	void deserialize(StringStream &ss)
	{
		Console.log("Loading Zombie");
		
		init();
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
		if(contact.bodyB.getObject(@player))
		{
			contact.setEnabled(false);
			player.health--;
			if(player.health <= 0) {
				player.remove();
			}
		}else if(contact.bodyB.getObject(@proj))
		{
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
		
		Humanoid::preSolve(@contact);
	}
	
	void update()
	{
		// Check for daytime
		if(TimeOfDay.isDay())
		{
			Spawner.mobCount--;
			remove();
			return;
		}
		
		// Find target player
		Player @target = @scene::game.getClosestPlayer(body.getCenter());
		
		// Get the direction to the target
		Vector2 dt = target.body.getPosition() - body.getCenter();
		
		// Move towards target
		if(dt.x < 0.0f)
		{
			moveLeft();
		}
		else if(dt.x > 0.0f)
		{
			moveRight();
		}
		
		// Jump if necessary
		if(ray.test(getFeetPosition()/TILE_SIZE, (getFeetPosition() + Vector2(24.0f, 0.0f))/TILE_SIZE) ||
			ray.test(getFeetPosition()/TILE_SIZE, (getFeetPosition() - Vector2(24.0f, 0.0f))/TILE_SIZE))
		{
			jump();
		}
		
		Vector2 vel = body.getLinearVelocity();
		if(vel.x >= maxRunSpeed)
		{
			vel.x = maxRunSpeed;
		}else if(vel.x <= -maxRunSpeed)
		{
			vel.x = -maxRunSpeed;
		}
		body.setLinearVelocity(vel);
		
		updateAnimations();
	}
	
	void draw()
	{
		Humanoid::draw();
	}
}