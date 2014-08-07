class DebugTextDrawer : GameObject
{
	//private dict<string> strings;
	
	void addVariable(string name, string value)
	{
		//strings[name] = value;
	}
	
	void draw()
	{
		if(Input.getKeyState(KEY_Z))
		{
			global::largeFont.setColor(Vector4(0.0f, 0.0f, 0.0f, 1.0f));
			//for(int i = 0; i < strings.size; i++) {
			//	global::largeFont.draw(@global::batches[UITEXT], Vector2(20.0f, 12.0f + i*12), strings[i]);
			//}
			//strings.clear();
		}
	}
}