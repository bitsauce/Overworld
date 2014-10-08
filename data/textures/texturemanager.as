class TextureManager
{
	private array<Texture@> textures(MAX_TEXTURES);
	private bool initialized = false;
		
	void init()
	{
		// Make sure the manager is not initialized already
		if(initialized) {
			return;
		}
		
		// Load textures
		load(MENU_BUTTON_TEXTURE, @Texture(":/sprites/gui/menu_button.png"));
		load(BERRY_BUSH_TEXTURE, @Texture(":/sprites/plants/berry_bush.png"));
		load(STICK_TEXTURE, @Texture(":/sprites/items/stick2.png"));
		
		// Mark as initialized
		initialized = true;
	}
	
	private void load(TextureID id, Texture @texture)
	{
		// Make sure the manager is not initialized
		if(initialized) {
			return;
		}
		
		// Set texture
		@textures[id] = @texture;
	}
	
	Texture @opIndex(int idx)
	{
		return (initialized && idx >= 0 && idx < MAX_TEXTURES) ? @textures[idx] : null;
	}
}