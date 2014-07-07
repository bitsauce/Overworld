interface Body
{
	Vector2 getPosition();
	void setPosition(Vector2);
	Vector2 getSize();
	void setSize(Vector2);
	Vector2 getCenter();
}

class Player : GameObject, Body
{
	Vector2 size = Vector2(42.0f, 62.0f);
	b2Body @body;
	b2Fixture @fix;
	
	Inventory @inventory;
	
	bool falling = false;
	bool pressed = false;
	
	Texture @playerTexture = @Texture(":/sprites/characters/full/character_ver3.png");
	
	spSkeleton @skeleton = @spSkeleton(":/sprites/characters/anim/skeleton.json", ":/sprites/characters/anim/skeleton.atlas", 1.0f);
	spAnimationState @animation;
	spAnimation @currentAnim;
	
	// Movement
	float maxRunSpeed = 256.0f;
	float moveForce = 5000.0f;
	float jumpForce = 6800.0f;
	float accel = 0.1f; // factor
	
	int health = 100;
	
	Player()
	{
		@inventory = @Inventory(@this);
		inventory.addItem(@global::items[PICKAXE_IRON]);
		
		b2BodyDef def;
		def.type = b2_dynamicBody;
		def.fixedRotation = true;
		def.position.set(200, 0);
		def.linearDamping = 1.0f;
		@body = @b2Body(def);
		@fix = @body.createFixture(Vector2(0.0f, size.x/2.0f), size.x, 5.0f);
		fix.setFriction(0.9f);
		
		body.setObject(@this);
		body.setPreSolveCallback(ContactFunc(@preSolve));
		
		spAnimationStateData @data = @spAnimationStateData(@skeleton);
		data.setMix("idle", "walk", 0.2f);
		data.setMix("walk", "idle", 0.5f);
		data.setMix("jump", "idle", 0.1f);
		data.setMix("walk", "jump", 0.1f);
		data.setMix("jump", "idle", 0.1f);
		data.setMix("idle", "jump", 0.2f);
		
		@animation = @spAnimationState(@data);
		animation.looping = true;
		changeAnimation("idle");
		
		global::players.insertLast(@this);
	}
	
	void remove()
	{
		body.destroy();
		GameObject::remove();
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
	
	void preSolve(b2Contact @contact)
	{
		ItemDrop @item;
		Projectile @proj;
		Terrain @terrain;
		if(contact.other.getObject(@item)) {
			contact.setEnabled(false);
			if(item.canPickup()) {
				int result = inventory.addItem(@item.data, item.amount);
				if(result == 0) {
					item.remove();
				}else{
					item.amount = result;
				}
			}
		}else if(contact.other.getObject(@proj)) {
			contact.setEnabled(false);
		}else if(contact.other.getObject(@terrain)) {
			falling = false;
		}
	}
	
	void changeAnimation(string name)
	{
		spAnimation @anim = @skeleton.findAnimation(name);
		if(@currentAnim != @anim) {
			animation.setAnimation(@anim);
			@currentAnim = @anim;
		}
	}
	
	float timer = 0.0f;
	
	Vector2 getFeetPosition() const
	{
		return getPosition() + Vector2(size.x/2.0f, size.y);
	}
	
	float jumpTimer = 0.0f;
	
	void update()
	{
		Vector2 position = body.getPosition();
		Vector2 velocity = body.getLinearVelocity();
		
		if(Input.getKeyState(KEY_A)) {
			float impulse = (maxRunSpeed + velocity.x);
			if(impulse > maxRunSpeed*accel) impulse = maxRunSpeed*accel;
			body.applyImpulse(Vector2(-impulse * body.getMass(), 0.0f), getFeetPosition());
		}
		
		if(Input.getKeyState(KEY_D)) {
			float impulse = (maxRunSpeed - velocity.x);
			if(impulse > maxRunSpeed*accel) impulse = maxRunSpeed*accel;
			body.applyImpulse(Vector2(impulse * body.getMass(), 0.0f), getFeetPosition());
		}
		
		if(Input.getKeyState(KEY_SPACE) && !falling) {
			if(jumpTimer < 0.1f) {
				body.applyImpulse(Vector2(0.0f, -jumpForce), getCenter());
			}else{
				falling = true;
			}
			jumpTimer += Graphics.dt;
		}else{
			jumpTimer = 0.0f;
		}
		
		velocity = body.getLinearVelocity();
		
		animation.timeScale = Math.abs(velocity.x/128.0f);
		if(!falling)
		{
			animation.looping = true;
			if(velocity.x >= 0.01f)
			{
				changeAnimation("walk");
				skeleton.flipX = false;
			}else if(velocity.x <= -0.01f){
				changeAnimation("walk");
				skeleton.flipX = true;
			}else{
				changeAnimation("idle");
				velocity.x = 0.0f;
				body.setLinearVelocity(velocity);
				animation.timeScale = 1.0f;
			}
		}else{
			animation.looping = false;
			animation.timeScale = 1.0f;
			changeAnimation("jump");
		}
		
		if(Input.getKeyState(KEY_LMB))
		{
			// Use selected item
			Item @item = inventory.getSelectedItem();
			if(@item != null && (!item.singleShot || !pressed)) {
				item.use(@this);
			}
			
			pressed = true;
		}else{
			pressed = false;
		}
		
		if(global::timeOfDay.getHour() >= 21 && timer <= 0.0f)
		{
			Zombie z();
			z.setPosition(Vector2(camera.x, global::terrain.gen.getGroundHeight(camera.x/TILE_SIZE)*TILE_SIZE));
			timer = 10.0f;
		}
		timer -= Graphics.dt;
		
		skeleton.position = position + Vector2(0.0f, size.y);
		animation.update(Graphics.dt);
		
		// Temporary solution until i've found some other way to avoid tiling seams
		// for example through shaders or texture arrays
		camera = Vector2(Vector2i(getCenter() - Vector2(Window.getSize())/2.0f));
	}
	
	void draw()
	{
		/*Shape @shape = Shape(Rect(body.getPosition(), size));
		shape.setFillTexture(@playerTexture);
		shape.draw(global::batches[global::SCENE]);*/
		
		skeleton.draw(@global::batches[global::SCENE]);
		
		global::arial12.draw(@global::batches[global::UITEXT], Vector2(600.0f, 12.0f), "Health: "+formatInt(health, ""));
		global::arial12.draw(@global::batches[global::UITEXT], Vector2(25.0f, 100.0f), "maxRunSpeed: "+maxRunSpeed);
		global::arial12.draw(@global::batches[global::UITEXT], Vector2(25.0f, 125.0f), "jumpForce: "+jumpForce);
		global::arial12.draw(@global::batches[global::UITEXT], Vector2(25.0f, 150.0f), "accel: "+accel);
	}
}