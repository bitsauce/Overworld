class Background
{
	void draw()
	{
		Shape @shape = Shape(Rect(0, 0, Window.getSize().x, Window.getSize().y));
		shape.setFillColor(Vector4(0.0f, 0.0f, 1.0f, 1.0f));
		shape.draw(@backgroundBatch);
	}
}