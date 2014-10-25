class DebugManager
{
	private dictionary variables;
	
	void setVariable(string name, string value)
	{
		variables[name] = value;
	}
	
	void draw()
	{
		font::large.setColor(Vector4(0.0f, 0.0f, 0.0f, 1.0f));
		string drawString;
		array<string> @keys = variables.getKeys();
		for(int i = 0; i < keys.size; ++i)
		{
			string str;
			variables.get(keys[i], str);
			drawString += keys[i] + ": " + str + "\n";
		}
		font::large.draw(@scene::game.getBatch(UITEXT), Vector2(5.0f, 48.0f), drawString);
	}
}