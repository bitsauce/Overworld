class Projectile : GameObject
{
	Vector2 size = Vector2(20, 6);
	Sprite @sprite = @Sprite(@Texture(":/sprites/items/stick2.png"));
	b2Body @body;
	bool collided = false;
	float lifeTile = 10.0f; // 10s
	
	Projectile()
	{	
		b2BodyDef def;
		def.type = b2_dynamicBody;
		def.fixedRotation = false;
		@body = @b2Body(def);
		body.setObject(@this);
		body.createFixture(Rect(0, 0, size.x, size.y), 32.0f);
		body.setBeginContactCallback(@b2ContactCallback(@beginContact));
	}
	
	void remove()
	{
		body.destroy();
		GameObject::remove();
	}
	
	void beginContact(b2Contact @contact)
	{
		Player @player;
		Terrain @terrain;
		if(!contact.bodyB.getObject(@player))
		{
			collided = true; // Not a player
			// TODO: Connect projectile to whatever it hit using a b2WeldJoint
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
			lifeTile -= Graphics.dt;
			if(lifeTile <= 0.0f)
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