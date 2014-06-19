

class Inventory : GameObject
{
	void draw()
	{return;
		for(int i = 0; i < 9; i++) {
			Shape @shape = Shape(Rect(5 + 30*i, 5, 25, 25));
			shape.setFillColor(Vector4(1,0,0,1));
			shape.draw(global::batches[global::GUI]);
		}
	}
}