

class TextureManager
{
	private array<Texture@> textures(MAX_TEXTURES);
		
	TextureManager()
	{
		@textures[BERRY_BUSH_TEXTURE] = @Texture(":/sprites/plants/berry_bush.png");
	}
	
	Texture @opIndex(int idx)
	{
		return idx >= 0 && idx < MAX_TEXTURES ? @textures[idx] : null;
	}
}