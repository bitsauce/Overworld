class Humanoid : GameObject
{
	// Box2D body
	b2Body @body;
	
	// Foot sensor (for checking on-gound-ness)
	b2Fixture @footSensor;
	int numGroundContact;
	
	// Physical size
	Vector2 size; // = Vector2(28.0f, 44.0f);
	
	// Movement variables
	float maxRunSpeed; // = 256.0f;
	float moveForce; // = 5000.0f;
	float jumpForce; // = 6800.0f;
	float accel; // = 0.1f; // factor
	float mass; // = 18.0f;
	
	// Skeletal animations
	spSkeleton @skeleton;
	spAnimationState @animation;
	spAnimation @currentAnim;
	
	ItemData @handItem;
	
	// Health
	int maxHealth = 100;
	int health = 100;
	
	// Walking sounds
	array<AudioSource@> walkDirtSounds;
	
	Humanoid()
	{
	}
	
	private void init()
	{
		// Load skeleton
		@skeleton = @spSkeleton(":/sprites/characters/anim/skeleton.json", ":/sprites/characters/anim/skeleton.atlas", 1.0f);
		skeleton.texture.setFiltering(LINEAR);
		
		// Set default values for movement
		maxRunSpeed = 256.0f;
		moveForce = 5000.0f;
		jumpForce = 6800.0f;
		accel = 0.1f; // factor
		
		// Set default values for helath
		maxHealth = 100;
		health = 100;
		
		// Create body defintion
		b2BodyDef def;
		def.type = b2_bulletBody;
		def.fixedRotation = true;
		def.allowSleep = false;
		def.linearDamping = 1.0f;
		
		// Create body
		@body = @b2Body(def);
		body.setObject(@this);
		body.setBeginContactCallback(b2ContactCallback(@beginContact));
		body.setEndContactCallback(b2ContactCallback(@endContact));
		body.setPreSolveCallback(b2ContactCallback(@preSolve));
		
		// Create upper and lower circle fixtures
		b2Fixture @fixture = @body.createFixture(Vector2(0.0f, -size.x/4.0f), size.x/2.0f, mass);
		fixture.setFriction(0.0f);
		@fixture = @body.createFixture(Vector2(0.0f,  size.x/4.0f), size.x/2.0f, mass);
		fixture.setFriction(0.0f);
		
		// Create foot sensor
		@footSensor = @body.createFixture(Rect(-4, size.x/4.0f+12, 8, 8), 0.0f);
		footSensor.setSensor(true);
		numGroundContact = 0;
		
		// Setup spine animations // TODO: Move to global scope (as only one copy of this is strictly neseccary)
		spAnimationStateData @data = @spAnimationStateData(@skeleton);
		data.setMix("idle", "walk", 0.2f);
		data.setMix("walk", "idle", 0.5f);
		data.setMix("jump", "idle", 0.1f);
		data.setMix("walk", "jump", 0.1f);
		data.setMix("jump", "idle", 0.1f);
		data.setMix("idle", "jump", 0.2f);
		
		// Create spine animation
		@animation = @spAnimationState(@data);
		@animation.eventCallback = @spEventCallback(@animationEvent);
		animation.looping = true;
		changeAnimation("idle");
		
		walkDirtSounds.resize(4);
		for(int i = 0; i < 4; ++i) {
			@walkDirtSounds[i] = @AudioSource(":/sounds/player/walk_dirt_"+(i+1)+".wav");
			walkDirtSounds[i].looping = false;
		}
	}
	
	// PHYSICS
	void beginContact(b2Contact @contact)
	{
		// Check for foot sensor collision
		TerrainManager @terrain;
		if(contact.bodyB.getObject(@terrain))
		{
			if(@footSensor == @contact.fixtureA)
			{
				numGroundContact++;
			}
		}
	}
	
	void endContact(b2Contact @contact)
	{
		// Check for foot sensor collision
		TerrainManager @terrain;
		if(contact.bodyB.getObject(@terrain))
		{
			if(@footSensor == @contact.fixtureA)
			{
				numGroundContact--;
			}
		}
	}
	
	void preSolve(b2Contact @contact)
	{
		// This gives friction to the controller while avoiding the wall-sticking problem
		TerrainManager @terrain;
		if(contact.bodyB.getObject(@terrain) && numGroundContact > 0)
		{
			contact.setFriction(0.9f);
		}else
		{
			contact.resetFriction();
		}
	}
	
	Vector2 getFeetPosition() const
	{
		return body.getPosition() + Vector2(0.0f, size.y/2.0f);
	}
	
	// ANIMATIONS
	void changeAnimation(string name)
	{
		// Get animation by name
		spAnimation @anim = @skeleton.findAnimation(name);
		if(@anim == null)
		{
			Console.log("Humanoid::changeAnimation() - Animation '" + name + "' does not exists.");
			return;
		}
		
		// Make sure this animation isn't current
		if(@currentAnim != @anim)
		{
			animation.setAnimation(@anim);
			@currentAnim = @anim;
		}
	}
	
	void updateAnimations()
	{
		Vector2 position = body.getPosition();
		Vector2 velocity = body.getLinearVelocity();
		
		animation.timeScale = Math.abs(velocity.x/128.0f);
		if(numGroundContact > 0)
		{
			animation.looping = true;
			if(velocity.x >= 0.01f)
			{
				changeAnimation("walk");
				skeleton.flipX = false;
			}else if(velocity.x <= -0.01f)
			{
				changeAnimation("walk");
				skeleton.flipX = true;
			}else
			{
				changeAnimation("idle");
				velocity.x = 0.0f;
				body.setLinearVelocity(velocity);
				animation.timeScale = 1.0f;
			}
		}else
		{
			animation.looping = false;
			animation.timeScale = 1.0f;
			changeAnimation("jump");
		}
		
		skeleton.position = position + Vector2(0.0f, size.y/2.0f);
		animation.update(Graphics.dt);
	}
	
	void animationEvent(spEvent @event)
	{
		if(event.string == "step")
		{
			// Play footstep sound
			AudioSource @stepSound = @walkDirtSounds[Random().nextInt(3)];
			stepSound.play();
			stepSound.position = body.getPosition();
		}
	}
	
	private void updateSprite(const string name, Texture @texture)
	{
		// TODO: Implement
		// 1) Get skeleton texture atlas
		// 2) Get the texture region for the spesified part
		// 3) Erase this part of the atlas using a shader, blend mode or Texture.updateSection
		// 4) Draw the new texture to this region
	}
	
	void equipLeftHand(Sprite @item)
	{
		//@handItem = @item;
	}
	
	// MOVEMENT
	void moveLeft()
	{
		float impulse = (maxRunSpeed + body.getLinearVelocity().x);
		if(impulse > maxRunSpeed*accel) impulse = maxRunSpeed*accel;
		body.applyImpulse(Vector2(-impulse * body.getMass(), 0.0f), getFeetPosition());
	}
	
	void moveRight()
	{
		float impulse = (maxRunSpeed - body.getLinearVelocity().x);
		if(impulse > maxRunSpeed*accel) impulse = maxRunSpeed*accel;
		body.applyImpulse(Vector2(impulse * body.getMass(), 0.0f), getFeetPosition());
	}
	
	void jump()
	{
		body.applyImpulse(Vector2(0.0f, -jumpForce), getFeetPosition());
	}
	
	// DRAWING
	void draw()
	{
		
		// Draw skeleton
		skeleton.draw(@Layers[LAYER_SCENE]);
		
		// Test draw hand item
		if(@handItem != null)
		{
			float f = skeleton.findBone("rarm").worldRotation;
			if(!skeleton.flipX)
			{
				f *= -1;
				handItem.icon.setPosition(skeleton.position + skeleton.findBone("rarm").worldPosition - Vector2(0, 16) + Vector2(Math.cos(f*0.0174532925f), Math.sin(f*0.0174532925f))*10);
			}
			else
			{
				handItem.icon.setPosition(skeleton.position + skeleton.findBone("rarm").worldPosition - Vector2(0, 16) - Vector2(Math.cos(f*0.0174532925f), Math.sin(f*0.0174532925f))*10);
			}
			handItem.icon.setOrigin(Vector2(0, 16));
			handItem.icon.setRotation(f-45);
			handItem.icon.draw(@Layers[LAYER_SCENE]);
			handItem.icon.setRotation(0);
		}
		
		// Draw debug health bar
		float p = (health/float(maxHealth));
		Shape healthBar(Rect(body.getPosition().x-size.x/2.0f, body.getPosition().y-size.y/2.0f-24, size.x*p, 4));
		healthBar.setFillColor(Vector4(1.0f*(1-p), 1.0f*p, 0.0f, 1.0f));
		healthBar.draw(@Layers[LAYER_SCENE]);
	}
}