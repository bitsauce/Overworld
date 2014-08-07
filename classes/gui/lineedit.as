class LineEdit : UiObject, KeyboardListener
{
	private string text;
	private int cursorPos = 0;
	private float cursorTime = 0.0f;
	
	LineEdit(UiObject @parent)
	{
		super(@parent);
		Input.addKeyboardListener(@this);
	}
	
	void setText(const string text)
	{
		this.text = text;
	}
	
	string getText() const
	{
		return text;
	}
	
	private void insertAt(const int at, const string str)
	{
		// Check valid index
		if(at < 0 || at > text.length)
			return;
		
		// Insert string at index
		string endStr = text.substr(at);
		text = text.substr(0, at);
		text += str + endStr;
	}
	
	private void removeAt(const int at)
	{
		// Check valid index
		if(at < 0 || at > text.length)
			return;
		
		// Remove char at index
		string endStr = text.substr(at);
		text = text.substr(0, at-1);
		text += endStr;
	}
	
	void charEvent(uint code)
	{
		// Only add text if active
		//if(!isActive())
		//	return;
		
		if(code == KEY_BACKSPACE) // Backspace counts as a char
		{
			// Remove char behind
			if(cursorPos != 0) {
				removeAt(cursorPos);
				cursorPos--;
			}
		}else{
			// Add text
			insertAt(cursorPos, formatUtf8(code));
			cursorPos++;
		}
	}
	
	void keyPressed(VirtualKey key)
	{
		switch(key)
		{
			// Delete
			case KEY_DELETE:
			{
				// Remove char in front
				if(cursorPos + 1 <= text.length) {
					removeAt(cursorPos + 1);
				}
			}
			break;
			
			// Left cursor key
			case KEY_LEFT:
			{
				// Decrease cursor position
				if(--cursorPos < 0) {
					cursorPos = 0;
				}
			}
			break;
			
			// Right cursor key
			case KEY_RIGHT:
			{
				if(++cursorPos >= text.length) {
					cursorPos = text.length;
				}
			}
			break;
		}
	}
	
	void keyReleased(VirtualKey key)
	{
	}
	
	void update()
	{
		cursorTime -= Graphics.dt;
		if(cursorTime <= 0.0f)
			cursorTime = 1.0f;
	}
	
	void draw(Batch @batch)
	{
		Vector2 position = getPosition(true)*Vector2(Window.getSize());
		Vector2 size = getSize(true)*Vector2(Window.getSize());
		
		global::largeFont.setColor(Vector4(1.0f));
		global::largeFont.draw(@batch, position, text);
		
		if(cursorTime >= 0.5f)
		{
			Shape @shape = @Shape(Rect(position.x + global::largeFont.getStringWidth(text.substr(0, cursorPos)), position.y, 2, global::largeFont.getStringHeight("")));
			shape.setFillColor(Vector4(0.0f, 0.0f, 0.0f, 1.0f));
			shape.draw(@batch);
		}
	}
}