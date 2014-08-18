class DebugTextDrawer
{
	private dictionary variables;
	
	void setVariable(string name, string value)
	{
		variables[name] = value;
	}
	
	void draw()
	{
		font::large.setColor(Vector4(0.0f, 0.0f, 0.0f, 1.0f));
		array<string> @keys = variables.getKeys();
		for(int i = 0; i < keys.size; i++) {
			string str;
			variables.get(keys[i], str);
			font::large.draw(@scene::game.getBatch(UITEXT), Vector2(20.0f, 12.0f + i*12), str);
		}
	}
}