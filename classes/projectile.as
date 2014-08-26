class Projectile : GameObject
{
	Vector2 size;
	Sprite @sprite;
	b2Body @body;
	b2WeldJoint @joint;
	bool collided;
	float lifeTime;
	
	Projectile()
	{
		// Setup vars
		collided = false;
		lifeTime = 10.0f; // 10s
		
		// Init the rest
		init();
	}
	
	private void init()
	{
		// Load spirte
		size = Vector2(20, 6);
		@sprite = @Sprite(@game::textures[STICK_TEXTURE]);
		
		// Create body def
		b2BodyDef def;
		def.type = b2_dynamicBody;
		def.fixedRotation = false;
		
		// Create body
		@body = @b2Body(def);
		body.setObject(@this);
		body.createFixture(Rect(0, 0, size.x, size.y), 32.0f);
		body.setPreSolveCallback(@b2ContactCallback(@preSolve));
	}
	
	void remove()
	{
		body.destroy();
		GameObject::remove();
	}
	
	void serialize(StringStream &ss)
	{
		ss.write(body.getPosition());
		ss.write(body.getLinearVelocity());
		
		ss.write(collided);
		ss.write(lifeTime);
	}
	
	void deserialize(StringStream &ss)
	{
		init();
		
		Vector2 pos, vel;
		ss.read(pos); body.setPosition(pos);
		ss.read(vel); body.setLinearVelocity(vel);
		
		ss.read(collided);
		ss.read(lifeTime);
	}
	
	b2Contact @contact;
	
	void preSolve(b2Contact @contact)
	{
		Player @player;
		Projectile @proj;
		if(contact.bodyB.getObject(@proj) || contact.bodyB.getObject(@player))
		{
			// Disable collision for projectiles and players
			contact.setEnabled(false);
		}else
		{
			collided = true;
			@this.contact = @contact;
		}
	}
	
	void update()
	{
		if(!collided)
		{
			// Set angle of projectile
			body.setAngle(Math.atan2(body.getLinearVelocity().y, body.getLinearVelocity().x));
		}else
		{
			if(@joint == null && @contact != null)
			{
				b2WeldJointDef def;
				def.initialize(@contact.bodyB, @contact.bodyA, body.getPosition());
				@joint = @b2WeldJoint(def);
				@contact = null;
			}
			
			lifeTime -= Graphics.dt;
			if(lifeTime <= 0.0f)
			{
				remove();
			}
		}
	}
	
	void draw()
	{
		sprite.setRotation(body.getAngle()*(180/Math.PI));
		sprite.setPosition(body.getPosition());
		sprite.draw(@scene::game.getBatch(SCENE));
	}
}