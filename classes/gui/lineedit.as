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
		
		global::arial12.setColor(Vector4(1.0f));
		global::arial12.draw(@batch, position, text);
		
		if(cursorTime >= 0.5f)
		{
			Shape @shape = @Shape(Rect(position.x + global::arial12.getStringWidth(text.substr(0, cursorPos)), position.y, 2, global::arial12.getStringHeight("")));
			shape.setFillColor(Vector4(0.0f, 0.0f, 0.0f, 1.0f));
			shape.draw(@batch);
		}
		
		// Get pos and size
		/*Point2 guiPos = viewPos + pos();
		Size2 size = size();
		
		// Draw box
		GFX.drawRectOutlined(Rect2(guiPos, size()), 1, Color(90, 90, 90, 90), Color(0, 0, 0, 90));
		
		// Draw text
		int stringWidth = currentFont().stringWidth(text);
		int stringHeight = currentFont().stringHeight(text);
		int textx = guiPos.x+(size.width/2)-(stringWidth/2);
		int texty = guiPos.y+(size.height/2)-(stringHeight/2);
		GFX.drawText(textx, texty, text);
		
		// Draw text cursor
		if(isActive())
		{
			if(cursorTime < 30)
			{
				int cursorWidth = currentFont().stringWidth(text.substr(0, cursorPos));
				GFX.drawLine(textx+cursorWidth, guiPos.y+(size.height/2)-(stringHeight),
							textx+cursorWidth, guiPos.y+(size.height/2)+(stringHeight),
							1, Color::black);
			}else if(cursorTime >= 60) {
				cursorTime = 0;
			}
			cursorTime++;
		}*/
	}
}