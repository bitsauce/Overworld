class Bush : Furniture, Serializable
{
	float berryTimer = 0.0f;
	
	Bush()
	{
		super(4, 2, @Sprite(TextureRegion(@game::textures[BERRY_BUSH_TEXTURE], 0.0f, 0.5f, 1.0f, 1.0f)));
	}
	
	void save(IniFile @worldFile)
	{
	}
	
	void load(IniFile @worldFile)
	{
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
		Furniture::draw(@game::batches[SCENE]);
	}
}