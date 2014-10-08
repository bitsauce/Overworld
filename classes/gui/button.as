funcdef void ButtonCallback();
funcdef void ButtonCallbackThis(Button@);

class Button : UiObject
{
	// Button text
	private string text;
		
	// Button callback
	private ButtonCallback @callback;
	private ButtonCallbackThis @callbackThis;
		
	// User data
	any userData;
	
	// Text texture
	private Texture @textTexture;
		
	// Button sprite
	private Sprite @buttonSprite = @Sprite(@game::textures[MENU_BUTTON_TEXTURE]);
	
	
	// Constructors
	Button(string text, ButtonCallback @callback, UiObject @parent)
	{
		// Call parent constructor
		super(@parent);
		
		// Set callback
		@this.callback = @callback;
		
		// Set text
		setText(text);
	}
	
	Button(string text, ButtonCallbackThis @callbackThis, UiObject @parent)
	{
		// Call parent constructor
		super(@parent);
		
		// Set callback
		@this.callbackThis = @callbackThis;
		
		// Set text
		setText(text);
	}
	
	void setText(string text)
	{
		// Set text
		this.text = text;
		
		// Store text render texture
		@textTexture = @renderTextToTexture(@font::large, text, 6.0f);
	}
	
	Vector2 getSize(const bool recursive)
	{
		Vector2 size = Vector2(282.0f/Window.getSize().x, 55.0f/Window.getSize().y);
		if(recursive)
		{
			size = parent.getSize(recursive) * size;
			size.x = Math.max(size.x, 282.0f);
			size.y = size.x * 55.0f/282.0f;
		}
		return size;
	}
	
	void draw(Batch @batch)
	{
		// Get size and position
		Vector2 position = getPosition(true);
		Vector2 size = getSize(true);
		
		// Draw button sprite
		buttonSprite.setSize(size);
		buttonSprite.setPosition(position);
		buttonSprite.draw(@batch);
		
		// Draw text
		/*Shape textShape(Rect(position - (textSize-size)*0.5f, textSize));
		textShape.setFillTexture(@textTexture);
		textShape.draw(@batch);*/
		font::large.setColor(Vector4(1.0f));
		font::large.draw(@batch, position - (Vector2(font::large.getStringWidth(text), font::large.getStringHeight(text))-size)*0.5f, text);
	}
	
	void click()
	{
		// Call click callbacks
		if(@callback != null) {
			callback();
		}
		
		if(@callbackThis != null) {
			callbackThis(@this);
		}
	}
}