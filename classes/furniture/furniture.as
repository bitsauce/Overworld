class Furniture : GameObject
{
	private Sprite @sprite;
	private int width;
	private int height;
	private Shader @outlineShader = @Shader(":/shaders/outline.vert", ":/shaders/outline.frag");
	
	Furniture(int width, int height, Sprite @sprite)
	{
		@this.sprite = @sprite;
		this.width = width;
		this.height = height;
		
		// Setup outline shader
		outlineShader.setUniform1f("radius", 1.5f);
		outlineShader.setUniform1f("step", 0.1f);
		outlineShader.setUniform3f("color", 0.0f, 0.0f, 0.0f);
		
		game::furnitures.insertLast(@this);
	}
	
	bool place(int x, int y)
	{
		// Validate placement
		for(int j = 0; j < height; j++)
		{
			for(int i = 0; i < width; i++)
			{
				if(game::terrain.isTileAt(x+i, y+j)) {
					return false;
				}
			}
		}
		
		// Place here
		for(int j = 0; j < height; j++)
		{
			for(int i = 0; i < width; i++)
			{
				//game::terrain.addTile(x+i, y+j, RESERVED_TILE);
			}
		}
		
		// Update sprite position
		sprite.setPosition(Vector2(x*TILE_SIZE, y*TILE_SIZE));
		
		return true;
	}
	
	void remove()
	{
		
		GameObject::remove();
	}
	
	Vector2 getPosition()
	{
		return sprite.getPosition();
	}
	
	bool isHovered() const
	{
		Vector2 cursor = Input.position + game::camera.position;
		return Rect(sprite.getPosition(), sprite.getSize()).contains(cursor);
	}
	
	void interact(Player @player) { /* virtual */ }
	
	void draw(Batch @batch)
	{
		/*if(isHovered())
		{
			batch.setShader(outlineShader);
			outlineShader.setUniform2f("resolution", texture.getWidth(), texture.getHeight());
			outlineShader.setSampler2D("texture", @texture);
		}*/
		
		sprite.draw(@batch);
		//batch.setShader(null);
	}
}