funcdef void ButtonCallback();
funcdef void ButtonCallbackThis(Button@);

class Button : UiObject
{
	private string text;
	private ButtonCallback @callback;
	private ButtonCallbackThis @callbackThis;
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
	
	void draw(Batch @batch)
	{
		Vector2 position = getPosition(true)*Vector2(Window.getSize());
		Vector2 size = getSize(true)*Vector2(Window.getSize());
		
		Shape @textShape = @Shape(Rect(position + size/2.0f - Vector2(textTexture.getSize())/2.0f, Vector2(textTexture.getSize())));
		textShape.setFillTexture(@textTexture);
		
		if(isPressed() && isHovered())
			textShape.setFillColor(Vector4(1.0f, 1.0f, 0.0f, 1.0f));
		else if(isPressed())
			textShape.setFillColor(Vector4(0.5f, 0.5f, 0.0f, 1.0f));
		else if(isHovered())
			textShape.setFillColor(Vector4(0.9f, 0.9f, 0.2f, 1.0f));
		else
			textShape.setFillColor(Vector4(1.0f));
		
		textShape.draw(@batch);
		
		Shape @shape = @Shape(Rect(position, size));
		shape.setFillColor(Vector4(0.7f, 0.7f, 0.7f, 1.0f));
		shape.draw(@batch);
	}
	
	void click()
	{
		if(@callback != null) {
			callback();
		}
		if(@callbackThis != null) {
			callbackThis(@this);
		}
	}
}