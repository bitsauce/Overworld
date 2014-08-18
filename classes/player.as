class Player : GameObject
{
	// Player body
	b2Body @body;
	
	// Player foot sensor (for checking on-gound-ness)
	b2Fixture @footSensor;
	int numGroundContact;
	
	// Player physical size
	Vector2 size;
	
	// Player inventory
	Inventory @inventory;
	
	// For single shot items
	bool lmbPressed;
	
	// Player name
	string name;
	
	// Player skeletal animations
	spSkeleton @skeleton;
	spAnimationState @animation;
	spAnimation @currentAnim;
	
	// Movement variables
	float maxRunSpeed = 256.0f;
	float moveForce = 5000.0f;
	float jumpForce = 6800.0f;
	float accel = 0.1f; // factor
	float mass = 18.0f;
	
	// Player health
	int maxHealth = 100;
	int health = 100;
	
	// Walking sounds
	array<AudioSource@> walkDirtSounds;
	
	Player()
	{
		init();
	}
	
	private void init()
	{
		// Create an inventory for the player
		@inventory = @Inventory(@this);
		
		@skeleton = @spSkeleton(":/sprites/characters/anim/skeleton.json", ":/sprites/characters/anim/skeleton.atlas", 1.0f);
		
		size = Vector2(28.0f, 44.0f);
		name = "Bitsauce";
		
		lmbPressed = false;
			
		maxRunSpeed = 256.0f;
		moveForce = 5000.0f;
		jumpForce = 6800.0f;
		accel = 0.1f; // factor
		mass = 18.0f;
		maxHealth = 100;
		health = 100;
		
		// Create body defintion
		b2BodyDef def;
		def.type = b2_bulletBody;
		def.fixedRotation = true;
		def.allowSleep = false;
		def.linearDamping = 1.0f;
		
		// Create player body
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
		
		// Setup spine animations
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
		for(int i = 0; i < 4; i++) {
			@walkDirtSounds[i] = @AudioSource(":/sounds/player/walk_dirt_"+(i+1)+".wav");
			walkDirtSounds[i].looping = false;
		}
		
		skeleton.texture.setFiltering(LINEAR);
	}
	
	void serialize(StringStream &ss)
	{
		Console.log("Saving player '" + name + "'...");
		
		ss.write(body.getPosition().x);
		ss.write(body.getPosition().y);
		
		// Save inventory
		string itemString;
		string amountString;
		for(int y = 0; y < INV_HEIGHT; y++)
		{
			for(int x = 0; x < INV_WIDTH; x++)
			{
				ItemSlot @slot = @inventory.slots[x, y];
				if(!slot.isEmpty())
				{
					itemString += formatInt(slot.item.getID(), "0", 3);
					amountString += formatInt(slot.amount, "0", 3);
				}else{
					itemString += "000";
					amountString += "000";
				}
			}
		}
		ss.write(itemString);
		ss.write(amountString);
	}
	
	void deserialize(StringStream &ss)
	{
		init();
		
		Console.log("Loading player '" + name + "'...");
		
		float x, y;
		ss.read(x);
		ss.read(y);
		body.setPosition(Vector2(x, y));

		// Load inventory
		string itemString, amountString;
		ss.read(itemString);
		ss.read(amountString);
		for(int y = 0; y < INV_HEIGHT; y++)
		{
			for(int x = 0; x < INV_WIDTH; x++)
			{
				int j = (x + y*INV_WIDTH) * 3;
				inventory.slots[x, y].set(@game::items[ItemID(parseInt(itemString.substr(j, 3)))], parseInt(amountString.substr(j, 3)));
			}
		}
	}
	
	void remove()
	{
		body.destroy();
		GameObject::remove();
	}
	
	void beginContact(b2Contact @contact)
	{
		Terrain @terrain;
		if(contact.bodyB.getObject(@terrain)) {
			// Check for foot sensor collision
			if(@footSensor == @contact.fixtureA) {
				numGroundContact++;
			}
		}
	}
	
	void endContact(b2Contact @contact)
	{
		Terrain @terrain;
		if(contact.bodyB.getObject(@terrain)) {
			// Check for foot sensor collision
			if(@footSensor == @contact.fixtureA) {
				numGroundContact--;
			}
		}
	}
	
	void preSolve(b2Contact @contact)
	{
		ItemDrop @item;
		Projectile @proj;
		if(contact.bodyB.getObject(@item)) {
			contact.setEnabled(false);
			if(item.canPickup()) {
				int result = inventory.addItem(@item.data, item.amount);
				if(result == 0) {
					item.remove();
				}else{
					item.amount = result;
				}
			}
		}else if(contact.bodyB.getObject(@proj)) {
			contact.setEnabled(false);
		}
		
		Terrain @terrain;
		if(contact.bodyB.getObject(@terrain) && numGroundContact > 0) {
			contact.setFriction(0.9f);
		}else{
			contact.resetFriction();
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
	
	Vector2 getFeetPosition() const
	{
		return body.getPosition() + Vector2(0.0f, size.y/2.0f);
	}
	
	void animationEvent(spEvent @event)
	{
		if(event.string == "step")
		{
			// Play footstep sound
			AudioSource @stepSound = @walkDirtSounds[Math.getRandomInt(0, 3)];
			stepSound.play();
			stepSound.position = body.getPosition();
		}
	}
	
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
		
		if(Input.getKeyState(KEY_SPACE) && numGroundContact > 0) {
			body.applyImpulse(Vector2(0.0f, -jumpForce), position);
		}
		
		velocity = body.getLinearVelocity();
		
		animation.timeScale = Math.abs(velocity.x/128.0f);
		if(numGroundContact > 0)
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
			if(@item != null && (!item.singleShot || !lmbPressed)) {
				item.use(@this);
			}
			
			lmbPressed = true;
		}else{
			lmbPressed = false;
		}
		
		// Furniture interaction
		if(Input.getKeyState(KEY_RMB))
		{
			Furniture @furniture = @scene::game.getHoveredFurniture();
			if(@furniture != null && (furniture.getPosition() - position).length() <= ITEM_PICKUP_RADIUS) {
				furniture.interact(@this);
			}
		}
		
		// Clamp to world
		if(position.x < 0.0f)
		{
			position.x = 0.0f;
			body.setLinearVelocity(Vector2(0.0f, velocity.y));
			body.setPosition(position);
		}else if(position.x > game::terrain.getWidth()*TILE_SIZE)
		{
			position.x = game::terrain.getWidth()*TILE_SIZE;
			body.setLinearVelocity(Vector2(0.0f, velocity.y));
			body.setPosition(position);
		}
		
		if(position.y < 0.0f)
		{
			position.y = 0.0f;
			body.setLinearVelocity(Vector2(velocity.x, 0.0f));
			body.setPosition(position);
		}else if(position.y > game::terrain.getHeight()*TILE_SIZE)
		{
			position.y = game::terrain.getHeight()*TILE_SIZE;
			body.setLinearVelocity(Vector2(velocity.x, 0.0f));
			body.setPosition(position);
		}
		
		skeleton.position = position + Vector2(0.0f, size.y/2.0f);
		animation.update(Graphics.dt);
		
		// Update camera
		game::camera.lookAt(position);
		
		// Update audio listener
		Audio.position = position;
		
		//
		inventory.update();
	}
	
	void draw()
	{
		// Draw skeleton
		skeleton.draw(@scene::game.getBatch(SCENE));
		
		// Draw debug health bar
		float p = (health/float(maxHealth));
		Shape healthBar(Rect(body.getPosition().x-size.x/2.0f, body.getPosition().y-size.y/2.0f-24, size.x*p, 4));
		healthBar.setFillColor(Vector4(1.0f*(1-p), 1.0f*p, 0.0f, 1.0f));
		healthBar.draw(@scene::game.getBatch(SCENE));
		
		inventory.draw();
	}
}