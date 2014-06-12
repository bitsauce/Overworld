array<uint> QUAD_INDICES = { 0,3,1, 1,3,2 };

class Background : GameObject
{
	Vector4 topColor = Vector4(1.0f, 1.0f, 1.0f, 1.0f);
	Vector4 bottomColor = Vector4(0.35f, 0.67f, 1.0f, 1.0f);
	
	void draw()
	{
		array<Vertex> vertices(4);
		
		vertices[0].position.set(0.0f, 0.0f);
		vertices[0].color = topColor;
		
		vertices[1].position.set(Window.getSize().x, 0.0f);
		vertices[1].color = topColor;
		
		vertices[2].position.set(Window.getSize().x, Window.getSize().y);
		vertices[2].color = bottomColor;
		
		vertices[3].position.set(0, Window.getSize().y);
		vertices[3].color = bottomColor;
		
		global::batches[global::BACKGROUND_LAYER].addVertices(vertices, QUAD_INDICES);
	}
}