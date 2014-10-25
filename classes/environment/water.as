Vector4 waterColor = Vector4(0.5f, 0.5f, 0.8f, 0.9f);

class WaterTile
{
	int x, y;
	float height = 0.0f;
	
	WaterTile(int x, int y)
	{
		this.x = x;
		this.y = y;
		
		init();
	}
	
	private void init()
	{
	}
	
	void serialize(StringStream &ss)
	{
		ss.write(x);
		ss.write(y);
		ss.write(height);
	}
	
	void deserialize(StringStream &ss)
	{
		ss.read(x);
		ss.read(y);
		ss.read(height);
		
		init();
	}
	
	void draw()
	{
		Batch @batch = scene::game.getBatch(SCENE);
		
		array<Vertex> vertices(4);
		
		vertices[0].color = vertices[1].color = vertices[2].color = vertices[3].color = waterColor;
		
		// Trapezoid
		Water @water = @scene::game.getWater();
		float h = water.isWaterAt(x+1, y) ? water.getWaterAt(x+1, y).height : height;
		vertices[0].position.set(x * TILE_SIZE, (y+1-height) * TILE_SIZE);
		vertices[1].position.set((x+1) * TILE_SIZE, (y+1-h) * TILE_SIZE);
		vertices[2].position.set((x+1) * TILE_SIZE, (y+1) * TILE_SIZE);
		vertices[3].position.set(x * TILE_SIZE, (y+1) * TILE_SIZE);
		
		batch.addVertices(vertices, QUAD_INDICES);
	}
}

class WaterParticle : GameObject
{
	b2Body @body;
	float size;
	
	WaterParticle(float size)
	{
		init(size);
	}
	
	void remove()
	{
		body.destroy();
		GameObject::remove();
	}
	
	private void init(float size)
	{
		this.size = size;
		
		// Create body def
		b2BodyDef def;
		def.type = b2_dynamicBody;
		def.fixedRotation = false;
		
		// Create body
		@body = @b2Body(def);
		body.setObject(@this);
		body.setBeginContactCallback(b2ContactCallback(@beginContact));
		body.createFixture(Vector2(0.0f), size*8.0f, 32.0f);
	}
	
	void beginContact(b2Contact @contact)
	{
		Terrain @terrain;
		if(contact.bodyB.getObject(@terrain))
		{
			scene::game.getWater().addWater(body.getPosition().x/TILE_SIZE, body.getPosition().y/TILE_SIZE, size);
			remove();
		}
	}
	
	void update()
	{
	}
	
	void draw()
	{
		Shape @shape = @Shape(body.getPosition(), size*8.0f, 8);
		shape.setFillColor(waterColor);
		shape.draw(scene::game.getBatch(SCENE));
	}
}

class Water
{
	private grid<WaterTile@> waterGrid;
	private array<WaterTile@> waterList;
	private int width = 250, height = 50;
		
	Water()
	{
		waterGrid.resize(250, 50);
	}
		
	WaterTile @getWaterAt(const int x, const int y)
	{
		return waterGrid[x, y];
	}
	
	bool isWaterAt(const int x, const int y)
	{
		return @waterGrid[x, y] != null;
	}
	
	void addWater(const int x, const int y, const float amount)
	{
		if(scene::game.getTerrain().isTileAt(x, y)) {
			return;
		}
		
		WaterTile @tile = isWaterAt(x, y) ? @waterGrid[x, y] : @WaterTile(x, y);
		tile.height += amount;
		
		@waterGrid[x, y] = @tile;
		waterList.insertLast(@tile);
	}
	
	void addParticle(Vector2 position, float size = 1.0f)
	{
		WaterParticle particle(size);
		particle.body.setPosition(position);
	}
	
	void update()
	{
		Terrain @terrain = @scene::game.getTerrain();
		for(int i = 0; i < waterList.size; ++i)
		{
			WaterTile @water = @waterList[i];
			
			float w = water.height*0.25f;
			
			if(!terrain.isTileAt(water.x-1, water.y))
			{
				water.height *= 0.5f;
				if(water.height <= 0.1f)
				{
					@waterGrid[water.x, water.y] = null;
					waterList.removeAt(i);
					i--;
					continue;
				}else
				{
					addParticle(Vector2(water.x*TILE_SIZE - 1.0f, (water.y+0.5f)*TILE_SIZE), w);
				}
			}
			
			if(!terrain.isTileAt(water.x+1, water.y))
			{
				water.height *= 0.5f;
				if(water.height <= 0.1f)
				{
					@waterGrid[water.x, water.y] = null;
					waterList.removeAt(i);
					i--;
					continue;
				}else
				{
					addParticle(Vector2((water.x+1)*TILE_SIZE + 1.0f, (water.y+0.5f)*TILE_SIZE), w);
				}
			}
		}
	}
	
	void draw()
	{
		for(int i = 0; i < waterList.size; ++i) {
			waterList[i].draw();
		}
	}
}