funcdef void ButtonCallback();
funcdef void ButtonCallbackThis(Button@);

class Button : UiObject
{
	private string text;
	private ButtonCallback @callback;
	private ButtonCallbackThis @callbackThis;
	private int state = 0;
	bool pressed = false;
	any userData;
	
	private Texture @textTexture;
	
	Button(string text, ButtonCallback @callback, UiObject @parent)
	{
		super(@parent);
		
		setText(text);
		@this.callback = @callback;
	}
	
	Button(string text, ButtonCallbackThis @callbackThis, UiObject @parent)
	{
		super(@parent);
		
		setText(text);
		@this.callbackThis = @callbackThis;
	}
	
	void setText(string text)
	{
		this.text = text;
		
		@textTexture = @Texture(global::arial12.getStringWidth(text), global::arial12.getStringHeight(text));
		textTexture.setFiltering(LINEAR);
		
		Batch @batch = @Batch();
		global::arial12.setColor(Vector4(1.0f));
		global::arial12.draw(@batch, Vector2(0.0f), text);
		batch.renderToTexture(@textTexture);
	}
	
	void update()
	{
		Vector2 position = getPosition(true)*Vector2(Window.getSize());
		Vector2 size = getSize(true)*Vector2(Window.getSize());
		
		if(Rect(position, size).contains(Input.position)) {
			state |= MOUSE_HOVERED;
		}else{
			state &= ~MOUSE_HOVERED;
		}
		
		if(state & MOUSE_PRESSED == 0)
		{
			if(state & MOUSE_HOVERED != 0 && Input.getKeyState(KEY_LMB))
			{
				state |= MOUSE_PRESSED;
			}
		}else
		{
			if(!Input.getKeyState(KEY_LMB))
			{
				if(state & MOUSE_HOVERED != 0) {
					clicked();
				}
				state &= ~MOUSE_PRESSED;
			}
		}
	}
	
	void draw(Batch @batch)
	{
		Vector2 position = getPosition(true)*Vector2(Window.getSize());
		Vector2 size = getSize(true)*Vector2(Window.getSize());
		
		Shape @textShape = @Shape(Rect(position + size/2.0f - Vector2(textTexture.getSize())/2.0f, Vector2(textTexture.getSize())));
		textShape.setFillTexture(@textTexture);
		
		if(state & MOUSE_PRESSED != 0 && state & MOUSE_HOVERED != 0)
			textShape.setFillColor(Vector4(1.0f, 1.0f, 0.0f, 1.0f));
		else if(state & MOUSE_PRESSED != 0)
			textShape.setFillColor(Vector4(0.5f, 0.5f, 0.0f, 1.0f));
		else if(state & MOUSE_HOVERED != 0)
			textShape.setFillColor(Vector4(0.9f, 0.9f, 0.2f, 1.0f));
		else
			textShape.setFillColor(Vector4(1.0f));
		
		textShape.draw(@batch);
		
		Shape @shape = @Shape(Rect(position, size));
		shape.setFillColor(Vector4(0.7f, 0.7f, 0.7f, 1.0f));
		shape.draw(@batch);
	}
	
	void clicked()
	{
		if(@callback != null) {
			callback();
		}
		if(@callbackThis != null) {
			callbackThis(@this);
		}
	}
}