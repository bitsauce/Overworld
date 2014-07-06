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
	float moveSpeed = 7.0f;
	b2Body @body;
	b2Fixture @fix;
	
	Inventory @inventory;
	
	bool jumping = false;
	bool pressed = false;
	
	Texture @playerTexture = @Texture(":/sprites/characters/full/character_ver3.png");
	
	spSkeleton @skeleton = @spSkeleton(":/sprites/characters/spineboy/spineboy.json", ":/sprites/characters/spineboy/spineboy.atlas", 0.125f);
	spAnimationState @animation;
	spAnimation @currentAnim;
	
	int health = 100;
	
	Player()
	{
		@inventory = @Inventory(@this);
		inventory.addItem(@global::items[PICKAXE_IRON]);
		
		b2BodyDef def;
		def.type = b2_dynamicBody;
		def.fixedRotation = true;
		def.position.set(200, 0);
		@body = @b2Body(def);
		@fix = @body.createFixture(Rect(0, 0, size.x, size.y), 32.0f);
		
		body.setObject(@this);
		body.setPreSolveCallback(ContactFunc(@preSolve));
		
		spAnimationStateData @data = @spAnimationStateData(@skeleton);
		data.setMix("idle", "walk", 0.2f);
		data.setMix("walk", "idle", 0.5f);
		
		@animation = @spAnimationState(@data);
		animation.looping = true;
		animation.setAnimation("idle");
		
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
		}
	}
	
	void changeAnimation(string name)
	{
		spAnimation @anim = @skeleton.findAnimation(name);
		if(@currentAnim != @anim) {
			Console.log("change anim to: "+name);
			animation.setAnimation(@anim);
			@currentAnim = @anim;
		}
	}
	
	float timer = 0.0f;
	
	void update()
	{
		Vector2 position = body.getPosition();
		
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
		
		if(body.getLinearVelocity().x >= 0.01f)
		{
			changeAnimation("walk");
			skeleton.setFlipX(false);
		}else if(body.getLinearVelocity().x <= -0.01f){
			changeAnimation("walk");
			skeleton.setFlipX(true);
		}else{
			changeAnimation("idle");
			Vector2 vel = body.getLinearVelocity();
			vel.x = 0.0f;
			body.setLinearVelocity(vel);
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
		
		skeleton.setPosition(position + Vector2(size.x/2, size.y));
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
	}
}