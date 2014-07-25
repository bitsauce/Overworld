class Menu
{
	void show() {}
	void draw(Batch @batch) {}
}

array<Menu@> menuStack;


void pushMenu(Menu @menu)
{
	menuStack.insertLast(@menu);
	menu.show();
}

void popMenu()
{
	menuStack.removeLast();
}

enum MouseState
{
	MOUSE_PRESSED = 1,
	MOUSE_HOVERED = 2
}

funcdef void ButtonCallback();
funcdef void ButtonCallbackThis(Button@);

class Button : GameObject
{
	private string text;
	private ButtonCallback @callback;
	private ButtonCallbackThis @callbackThis;
	private int state = 0;
	private Vector2 size;
	Vector2 position;
	bool pressed = false;
	string userData;
	
	Button(string text, ButtonCallback @callback)
	{
		this.text = text;
		@this.callback = @callback;
		size.set(global::arial12.getStringWidth(text), 16);
	}
	
	Button(string text, ButtonCallbackThis @callbackThis)
	{
		this.text = text;
		@this.callbackThis = @callbackThis;
		size.set(global::arial12.getStringWidth(text), 16);
	}
	
	void update()
	{
		position.x = Window.getSize().x/2.0f - global::arial12.getStringWidth(text)/2.0f;
		
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
		Shape @shape = @Shape(Rect(position, size));
		shape.setFillColor(Vector4(0.7f, 0.7f, 0.7f, 1.0f));
		shape.draw(@batch);
		
		if(state & MOUSE_PRESSED != 0 && state & MOUSE_HOVERED != 0)
			global::arial12.setColor(Vector4(1.0f, 1.0f, 0.0f, 1.0f));
		else if(state & MOUSE_PRESSED != 0)
			global::arial12.setColor(Vector4(0.5f, 0.5f, 0.0f, 1.0f));
		else if(state & MOUSE_HOVERED != 0)
			global::arial12.setColor(Vector4(0.9f, 0.9f, 0.2f, 1.0f));
		else
			global::arial12.setColor(Vector4(1.0f));
		global::arial12.draw(@global::batches[UITEXT], position + Vector2(4.0f, 0.0f), text);
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

void exit()
{
	Engine.exit();
}

class MainMenu : Menu
{
	Button @singlePlayerButton;
	Button @multiPlayerButton;
	Button @optionButton;
	Button @quitButton;
	
	MainMenu()
	{
		@singlePlayerButton = @Button("Singleplayer", @ButtonCallback(@showSinglePlayer));
		@multiPlayerButton = @Button("Multiplayer", @exit);
		@optionButton = @Button("Options", @exit);
		@quitButton = @Button("Quit", @exit);
		singlePlayerButton.position = Vector2(0, 200);
		multiPlayerButton.position = Vector2(0, 300);
		optionButton.position = Vector2(0, 400);
		quitButton.position = Vector2(0, 500);
	}
	
	void showSinglePlayer()
	{
		pushMenu(@global::worldSelectMenu);
	}
	
	void draw(Batch @batch)
	{
		Shape @shape = @Shape(Rect(Vector2(0.0f), Vector2(Window.getSize())));
		shape.setFillColor(Vector4(0.5f, 0.5f, 0.8f, 1.0f));
		shape.draw(@batch);
		
		singlePlayerButton.draw(@batch);
		multiPlayerButton.draw(@batch);
		optionButton.draw(@batch);
		quitButton.draw(@batch);
	}
}