class Bush : Furniture
{
	float berryTimer = 0.0f;
	
	Bush()
	{
		super(4, 2);
		init();
	}
	
	private void init()
	{
		@sprite = @Sprite(TextureRegion(@game::textures[BERRY_BUSH_TEXTURE], 0.0f, 0.5f, 1.0f, 1.0f));
	}
	
	void serialize(StringStream &ss)
	{
		ss.write(berryTimer);
		Furniture::serialize(ss);
	}
	
	void deserialize(StringStream &ss)
	{
		init();
		
		ss.read(berryTimer);
		Furniture::deserialize(ss);
	}
	
	void interact(Player @player)
	{
		if(berryTimer <= 0.0f)
		{
			// Set sprite region to bush without berries
			sprite.setRegion(TextureRegion(@game::textures[BERRY_BUSH_TEXTURE], 0.0f, 0.0f, 1.0f, 0.5f));
			
			// Give player berries
			player.inventory.addItem(@game::items[BERRIES], 5);
			
			berryTimer = 5.0f; // Respawn in 5 seconds
		}
	}
	
	void update()
	{
		berryTimer -= Graphics.dt;
		if(berryTimer <= 0.0f) {
			sprite.setRegion(TextureRegion(@game::textures[BERRY_BUSH_TEXTURE], 0.0f, 0.5f, 1.0f, 1.0f));
		}
	}
	
	void draw()
	{
		Furniture::draw(@scene::game.getBatch(SCENE));
	}
}