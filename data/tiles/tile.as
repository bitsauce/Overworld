array<uint> TILE_INDICES = {
	0, 3, 2, 0, 2, 1,       // q1
	4, 7, 6, 4, 6, 5,       // q2
	8, 11, 10, 8, 10, 9,    // q3
	12, 15, 14, 12, 14, 13, // q4
	16, 19, 18, 16, 18, 17, // q5
	20, 23, 22, 20, 22, 21, // q6
	24, 27, 26, 24, 26, 25, // q7
	28, 31, 30, 28, 30, 29, // q8
	32, 35, 34, 32, 34, 33  // q9
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
		itemDrop.body.setPosition(Vector2(x, y) * TILE_PX + itemDrop.size/2.0f);
	}
	
	void setupFixture(b2Fixture @fixture)
	{
		fixture.setFriction(0.5f);
	}
	
	array<Vertex> getVertices(const int x, const int y, const uint state) const
	{
		array<Vertex> vertices = Terrain.getVertexFormat().createVertices(4*9);
		TextureAtlas @atlas = @Tiles.getAtlas();
		for(int i = 0; i < 9; ++i)
		{
			if(i >= 0 && i <= 2 && state & NORTH != 0) continue;
			else if(i >= 2 && i <= 4 && state & EAST != 0) continue;
			else if(i >= 4 && i <= 6 && state & SOUTH != 0) continue;
			else if((i >= 6 && i <= 7 || i == 0) && state & WEST != 0) continue;
			
			vertices[i*4+0].set4f(VERTEX_POSITION, x * TILE_PX + (TILE_TEXTURE_COORDS[0, i] * FULL_TILE_PXF - BORDER_PXF), y * TILE_PX + (TILE_TEXTURE_COORDS[1, i] * FULL_TILE_PXF - BORDER_PXF));
			vertices[i*4+1].set4f(VERTEX_POSITION, x * TILE_PX + (TILE_TEXTURE_COORDS[2, i] * FULL_TILE_PXF - BORDER_PXF), y * TILE_PX + (TILE_TEXTURE_COORDS[1, i] * FULL_TILE_PXF - BORDER_PXF));
			vertices[i*4+2].set4f(VERTEX_POSITION, x * TILE_PX + (TILE_TEXTURE_COORDS[2, i] * FULL_TILE_PXF - BORDER_PXF), y * TILE_PX + (TILE_TEXTURE_COORDS[3, i] * FULL_TILE_PXF - BORDER_PXF));
			vertices[i*4+3].set4f(VERTEX_POSITION, x * TILE_PX + (TILE_TEXTURE_COORDS[0, i] * FULL_TILE_PXF - BORDER_PXF), y * TILE_PX + (TILE_TEXTURE_COORDS[3, i] * FULL_TILE_PXF - BORDER_PXF));
			
			TextureRegion region = atlas.get(id, TILE_TEXTURE_COORDS[0, i], 1-TILE_TEXTURE_COORDS[3, i], TILE_TEXTURE_COORDS[2, i], 1-TILE_TEXTURE_COORDS[1, i]);
			vertices[i*4+0].set4f(VERTEX_TEX_COORD, region.uv0.x, region.uv1.y);
			vertices[i*4+1].set4f(VERTEX_TEX_COORD, region.uv1.x, region.uv1.y);
			vertices[i*4+2].set4f(VERTEX_TEX_COORD, region.uv1.x, region.uv0.y);
			vertices[i*4+3].set4f(VERTEX_TEX_COORD, region.uv0.x, region.uv0.y);
		}
		
		// Centeral part
		/*vertices[0].set4f(VERTEX_POSITION,  x    * TILE_PX,  y    * TILE_PX);
		vertices[1].set4f(VERTEX_POSITION, (x+1) * TILE_PX,  y    * TILE_PX);
		vertices[2].set4f(VERTEX_POSITION, (x+1) * TILE_PX, (y+1) * TILE_PX);
		vertices[3].set4f(VERTEX_POSITION,  x    * TILE_PX, (y+1) * TILE_PX);
		
		TextureAtlas @atlas = @Tiles.getAtlas();
		TextureRegion region = atlas.get(id, BORDER_PXF/FULL_TILE_PXF, BORDER_PXF/FULL_TILE_PXF, 1.0f - (BORDER_PXF/FULL_TILE_PXF), 1.0f - (BORDER_PXF/FULL_TILE_PXF));
		vertices[0].set4f(VERTEX_TEX_COORD, region.uv0.x, region.uv1.y);
		vertices[1].set4f(VERTEX_TEX_COORD, region.uv1.x, region.uv1.y);
		vertices[2].set4f(VERTEX_TEX_COORD, region.uv1.x, region.uv0.y);
		vertices[3].set4f(VERTEX_TEX_COORD, region.uv0.x, region.uv0.y);*/
		
		/*for(int i = 0; i < 13; ++i)
		{
			if(TILE_DRAW_SECTION[i, state])
			{
				vertices[0].set4f(VERTEX_POSITION, x * TILE_PX + TILE_DRAW_POSITION[i, ],              y * TILE_PX - BORDER_PX);
				vertices[1].set4f(VERTEX_POSITION, x * TILE_PX + TILE_DRAW_POSITION[i, ],  y * TILE_PX - BORDER_PX);
				vertices[2].set4f(VERTEX_POSITION, x * TILE_PX + BORDER_PX, (y+0.5f) * TILE_PX);
				vertices[3].set4f(VERTEX_POSITION, x * TILE_PX,             (y+0.5f) * TILE_PX);
			}
		}
		
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
		vertices[15].set4f(VERTEX_TEX_COORD, region.uv0.x, region.uv0.y);*/

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