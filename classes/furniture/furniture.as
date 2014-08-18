class Furniture : GameObject
{
	private Sprite @sprite;
	private int x, y; // Tile position
	private int width, height; // Tile size
	private Shader @outlineShader = @Shader(":/shaders/outline.vert", ":/shaders/outline.frag");
	
	Furniture(int width, int height)
	{
		this.width = width;
		this.height = height;
		
		// Setup outline shader
		outlineShader.setUniform1f("radius", 1.5f);
		outlineShader.setUniform1f("step", 0.1f);
		outlineShader.setUniform3f("color", 0.0f, 0.0f, 0.0f);
		
		scene::game.addFurniture(@this);
	}
	
	void remove()
	{
		// Remove invisible tiles
		Terrain @terrain = @scene::game.getTerrain();
		for(int j = 0; j < height; j++) {
			for(int i = 0; i < width; i++) {
				terrain.removeTile(x+i, y+j);
			}
		}
		
		// Remove from list
		scene::game.removeFurniture(@this);
		GameObject::remove();
	}
	
	void serialize(StringStream &ss)
	{
		ss.write(x);
		ss.write(y);
		ss.write(width);
		ss.write(height);
	}
	
	void deserialize(StringStream &ss)
	{
		int x, y;
		ss.read(x);
		ss.read(y);
		ss.read(width);
		ss.read(height);
		place(x, y);
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
		Terrain @terrain = @scene::game.getTerrain();
		for(int j = 0; j < height; j++) {
			for(int i = 0; i < width; i++) {
				terrain.addTile(x+i, y+j, RESERVED_TILE);
			}
		}
		
		// Update sprite position
		this.x = x; this.y = y;
		sprite.setPosition(Vector2(x*TILE_SIZE, y*TILE_SIZE));
		
		return true;
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