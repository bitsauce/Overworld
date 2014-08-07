funcdef void ButtonCallback();
funcdef void ButtonCallbackThis(Button@);

class Button : UiObject
{
	private string text;
	private ButtonCallback @callback;
	private ButtonCallbackThis @callbackThis;
	any userData;
	
	Shader @outlineShader = @Shader(":/shaders/outline.vert", ":/shaders/outline.frag");
	
	private Texture @textTexture;
	
	Button(string text, ButtonCallback @callback, UiObject @parent)
	{
		super(@parent);
		
		setText(text);
		@this.callback = @callback;
		setupShader();
	}
	
	Button(string text, ButtonCallbackThis @callbackThis, UiObject @parent)
	{
		super(@parent);
		
		setText(text);
		@this.callbackThis = @callbackThis;
		setupShader();
	}
	
	void setupShader()
	{
		outlineShader.setUniform1f("radius", 1.5f);
		outlineShader.setUniform1f("step", 0.1f);
		outlineShader.setUniform3f("color", 0.0f, 0.0f, 0.0f);
		outlineShader.setUniform2f("resolution", textTexture.getWidth(), textTexture.getHeight());
		outlineShader.setSampler2D("texture", @textTexture);
	}
	
	void setText(string text)
	{
		this.text = text;
		@textTexture = @renderTextToTexture(@global::largeFont, text, 6.0f);
	}
	
	void draw(Batch @batch)
	{
		Vector2 position = getPosition(true)*Vector2(Window.getSize());
		Vector2 size = getSize(true)*Vector2(Window.getSize());
		
		if(isPressed() && isHovered())
			outlineShader.setUniform3f("color", 1.0f, 1.0f, 0.0f);
		else if(isPressed())
			outlineShader.setUniform3f("color", 0.5f, 0.5f, 0.0f);
		else if(isHovered())
			outlineShader.setUniform3f("color", 0.9f, 0.9f, 0.2f);
		else
			outlineShader.setUniform3f("color", 0.0f, 0.0f, 0.0f);
		
		Vector2 textSize = Vector2(Math.min(textTexture.getWidth(), size.x), Math.min(textTexture.getHeight(), size.y));
		
		batch.setShader(@outlineShader);
		Shape(Rect(position - (textSize-size)*0.5f, textSize)).draw(@batch);
		batch.setShader(null);
		
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