array<uint> TILE_INDICES = {
	0, 3, 2, 0, 2, 1,      // q1
	4, 7, 6, 4, 6, 5,      // q2
	8, 11, 10, 8, 10, 9,   // q3
	12, 15, 14, 12, 14, 13 // q4
};

class Tile
{
	private TileID id;
	private Texture @texture;
	private ItemID item;
	private float opacity;
	
	Tile(TileID id)
	{
		this.id = id;
		@this.texture = @TILE_TEXTURES[id];
		this.item = TILE_ITEMS[id];
		this.opacity = TILE_OPACITIES[id];
	}
	
	void createItemDrop(int x, int y)
	{
		ItemDrop itemDrop(@Items[item]);
		itemDrop.body.setPosition(Vector2(x, y) * TILE_SIZE + itemDrop.size/2.0f);
	}
	
	void setupFixture(b2Fixture @fixture)
	{
		fixture.setFriction(0.5f);
	}
	
	array<Vertex> getVertices(const int x, const int y, const uint state) const
	{
		array<Vertex> vertices = Terrain.getVertexFormat().createVertices(16);
				
		vertices[0].set4f(VERTEX_POSITION, x     * TILE_SIZE + TILE_SIZE * 0.5f, y     * TILE_SIZE - TILE_SIZE * 0.5f);
		vertices[1].set4f(VERTEX_POSITION, (x+1) * TILE_SIZE + TILE_SIZE * 0.5f, y     * TILE_SIZE - TILE_SIZE * 0.5f);
		vertices[2].set4f(VERTEX_POSITION, (x+1) * TILE_SIZE + TILE_SIZE * 0.5f, (y+1) * TILE_SIZE - TILE_SIZE * 0.5f);
		vertices[3].set4f(VERTEX_POSITION, x     * TILE_SIZE + TILE_SIZE * 0.5f, (y+1) * TILE_SIZE - TILE_SIZE * 0.5f);
		
		vertices[4].set4f(VERTEX_POSITION, x     * TILE_SIZE + TILE_SIZE * 0.5f, y     * TILE_SIZE + TILE_SIZE * 0.5f);
		vertices[5].set4f(VERTEX_POSITION, (x+1) * TILE_SIZE + TILE_SIZE * 0.5f, y     * TILE_SIZE + TILE_SIZE * 0.5f);
		vertices[6].set4f(VERTEX_POSITION, (x+1) * TILE_SIZE + TILE_SIZE * 0.5f, (y+1) * TILE_SIZE + TILE_SIZE * 0.5f);
		vertices[7].set4f(VERTEX_POSITION, x     * TILE_SIZE + TILE_SIZE * 0.5f, (y+1) * TILE_SIZE + TILE_SIZE * 0.5f);
		
		vertices[8].set4f(VERTEX_POSITION, x     * TILE_SIZE - TILE_SIZE * 0.5f, y     * TILE_SIZE + TILE_SIZE * 0.5f);
		vertices[9].set4f(VERTEX_POSITION, (x+1) * TILE_SIZE - TILE_SIZE * 0.5f, y     * TILE_SIZE + TILE_SIZE * 0.5f);
		vertices[10].set4f(VERTEX_POSITION, (x+1) * TILE_SIZE - TILE_SIZE * 0.5f, (y+1) * TILE_SIZE + TILE_SIZE * 0.5f);
		vertices[11].set4f(VERTEX_POSITION, x     * TILE_SIZE - TILE_SIZE * 0.5f, (y+1) * TILE_SIZE + TILE_SIZE * 0.5f);
		
		vertices[12].set4f(VERTEX_POSITION, x     * TILE_SIZE - TILE_SIZE * 0.5f, y     * TILE_SIZE - TILE_SIZE * 0.5f);
		vertices[13].set4f(VERTEX_POSITION, (x+1) * TILE_SIZE - TILE_SIZE * 0.5f, y     * TILE_SIZE - TILE_SIZE * 0.5f);
		vertices[14].set4f(VERTEX_POSITION, (x+1) * TILE_SIZE - TILE_SIZE * 0.5f, (y+1) * TILE_SIZE - TILE_SIZE * 0.5f);
		vertices[15].set4f(VERTEX_POSITION, x     * TILE_SIZE - TILE_SIZE * 0.5f, (y+1) * TILE_SIZE - TILE_SIZE * 0.5f);
		
		uint8 q1 = ((state >> 0) & 0x7) + 0x0;
		uint8 q2 = ((state >> 2) & 0x7) + 0x8;
		uint8 q3 = ((state >> 4) & 0x7) + 0x10;
		uint8 q4 = (((state >> 6) & 0x7) | ((state << 2) & 0x7)) + 0x18;
		
		TextureRegion region;
		TextureAtlas @atlas = @Tiles.getAtlas();
		region = atlas.get(id, q1/32.0f, 0.0f, (q1+1)/32.0f, 1.0f);
		vertices[0].set4f(VERTEX_TEX_COORD, region.uv0.x, region.uv1.y);
		vertices[1].set4f(VERTEX_TEX_COORD, region.uv1.x, region.uv1.y);
		vertices[2].set4f(VERTEX_TEX_COORD, region.uv1.x, region.uv0.y);
		vertices[3].set4f(VERTEX_TEX_COORD, region.uv0.x, region.uv0.y);
		
		region = atlas.get(id, q2/32.0f, 0.0f, (q2+1)/32.0f, 1.0f);
		vertices[4].set4f(VERTEX_TEX_COORD, region.uv0.x, region.uv1.y);
		vertices[5].set4f(VERTEX_TEX_COORD, region.uv1.x, region.uv1.y);
		vertices[6].set4f(VERTEX_TEX_COORD, region.uv1.x, region.uv0.y);
		vertices[7].set4f(VERTEX_TEX_COORD, region.uv0.x, region.uv0.y);
		
		region = atlas.get(id, q3/32.0f, 0.0f, (q3+1)/32.0f, 1.0f);
		vertices[8].set4f(VERTEX_TEX_COORD, region.uv0.x, region.uv1.y);
		vertices[9].set4f(VERTEX_TEX_COORD, region.uv1.x, region.uv1.y);
		vertices[10].set4f(VERTEX_TEX_COORD, region.uv1.x, region.uv0.y);
		vertices[11].set4f(VERTEX_TEX_COORD, region.uv0.x, region.uv0.y);
		
		region = atlas.get(id, q4/32.0f, 0.0f, (q4+1)/32.0f, 1.0f);
		vertices[12].set4f(VERTEX_TEX_COORD, region.uv0.x, region.uv1.y);
		vertices[13].set4f(VERTEX_TEX_COORD, region.uv1.x, region.uv1.y);
		vertices[14].set4f(VERTEX_TEX_COORD, region.uv1.x, region.uv0.y);
		vertices[15].set4f(VERTEX_TEX_COORD, region.uv0.x, region.uv0.y);

		return vertices;
	}
	
	array<uint> getIndices(/*const uint state*/) const
	{
		return TILE_INDICES;
	}
	
	TileID getID() const
	{
		return id;
	}
	
	Texture @getTexture() const
	{
		return @texture;
	}
	ItemID getItemID() const
	{
		return item;
	}
	float getOpacity() const
	{
		return opacity;
	}
}