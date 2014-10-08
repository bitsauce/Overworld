enum Anchor
{
	TOP		= 1,
	LEFT	= 2,
	BOTTOM	= 4,
	RIGHT	= 8,
	
	HORIZONTAL = 16,
	VERTICAL = 32,
	
	CENTER = HORIZONTAL | VERTICAL,
	
	TOP_LEFT = TOP | LEFT,
	TOP_RIGHT = TOP | RIGHT,
	BOTTOM_LEFT = BOTTOM | LEFT,
	BOTTOM_RIGHT = BOTTOM | RIGHT,
	
	TOP_CENTER = TOP | VERTICAL,
	LEFT_CENTER = LEFT | HORIZONTAL,
	RIGHT_CENTER = RIGHT | VERTICAL,
	BOTTOM_CENTER = BOTTOM | HORIZONTAL
}

enum UiState
{
	UI_PRESSED = 1,
	UI_HOVERED = 2,
	UI_ACTIVE = 4
}

class UiObject
{
	// Rect in screen relative coordinates
	private Rect rect;
	private UiObject @parent;
	private uint state;
	uint anchor;
		
	UiObject(UiObject @parent)
	{
		if(@parent == null && @uiRoot != null) {
			@parent = @uiRoot;
		}
		@this.parent = @parent;
		this.anchor = TOP_LEFT;
		this.state = 0;
	}
	
	void press()
	{
		state |= UI_PRESSED;
	}
	
	void release()
	{
		state &= ~UI_PRESSED;
	}
	
	bool isPressed()
	{
		return state & UI_PRESSED != 0;
	}
	
	void hover()
	{
		state |= UI_HOVERED;
	}
	
	void unhover()
	{
		state &= ~UI_HOVERED;
	}
	
	bool isHovered()
	{
		return state & UI_HOVERED != 0;
	}
	
	void activate()
	{
		state |= UI_ACTIVE;
	}
	
	void deactivate()
	{
		state &= ~UI_ACTIVE;
	}
	
	bool isActive()
	{
		return state & UI_ACTIVE != 0;
	}
	
	void click()
	{
	}
	
	void update()
	{
		Vector2 position = getPosition(true);
		Vector2 size = getSize(true);
		
		if(Rect(position, size).contains(Input.position))
		{
			hover();
		}
		else
		{
			unhover();
		}
		
		if(!isPressed())
		{
			if(isHovered() && Input.getKeyState(KEY_LMB))
			{
				press();
			}
		}else
		{
			if(!Input.getKeyState(KEY_LMB))
			{
				if(isHovered())
				{
					click();
					activate();
				}else{
					deactivate();
				}
				release();
			}
		}
	}
		
	void draw(Batch @batch)
	{
	}
	
	Rect getRect(const bool recursive)
	{
		return Rect(getPosition(recursive), getSize(recursive));
	}
		
	Vector2 getPosition(const bool recursive/*drawPosition*/)
	{
		if(recursive)
		{
			Vector2 parentPos = parent.getPosition(recursive);
			Vector2 parentSize = parent.getSize(recursive);
			Vector2 pos = getPosition(false);
			Vector2 size = getSize(false);
			
			if(anchor & BOTTOM != 0)
			{
				parentPos.y += parentSize.y;
				pos.y -= size.y;
			}
			else if(anchor & VERTICAL != 0)
			{
				parentPos.y += parentSize.y/2.0f;
				pos.y -= size.y/2.0f;
			}
			
			if(anchor & RIGHT != 0)
			{
				parentPos.x += parentSize.x;
				pos.x -= size.x;
			}
			else if(anchor & HORIZONTAL != 0)
			{
				parentPos.x += parentSize.x/2.0f;
				pos.x -= size.x/2.0f;
			}
			
			return parentPos + pos * parentSize;
		}
		return rect.position;
	}
	
	void setPosition(const Vector2 position)
	{
		rect.position = position;
	}
	
	Vector2 getSize(const bool recursive)
	{
		if(recursive)
		{
			return parent.getSize(recursive) * rect.size;
		}
		return rect.size;
	}
	
	void setSize(const Vector2 size)
	{
		rect.size = size;
	}
}

class UiRoot : UiObject
{
	UiRoot()
	{
		super(@null);
		if(@uiRoot == null)
		{
			@uiRoot = @this;
			rect.set(0.0f, 0.0f, 1.0f, 1.0f);
		}
	}
	
	Vector2 getPosition(const bool)
	{
		return rect.position * Vector2(Window.getSize());
	}
	
	Vector2 getSize(const bool)
	{
		return rect.size * Vector2(Window.getSize());
	}
}

UiRoot @uiRoot = @UiRoot();