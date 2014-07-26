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

class UiObject
{
	// Rect in screen relative coordinates
	private Rect rect;
	private UiObject @parent;
	uint anchor;
		
	UiObject(UiObject @parent)
	{
		if(@parent == null && @uiRoot != null) {
			@parent = @uiRoot;
		}
		@this.parent = @parent;
		this.anchor = TOP_LEFT;
	}
	
	void update() {}
	void draw(Batch @batch) {}
	
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
			Vector2 pos = rect.position;
			Vector2 size = rect.size;
			
			if(anchor & BOTTOM != 0)
			{
				parentPos.y += parentSize.y;
				pos.y -= size.y;
			}else if(anchor & VERTICAL != 0)
			{
				parentPos.y += parentSize.y/2.0f;
				pos.y -= size.y/2.0f;
			}
			
			if(anchor & RIGHT != 0)
			{
				parentPos.x += parentSize.x;
				pos.x -= size.x;
			}else if(anchor & HORIZONTAL != 0)
			{
				parentPos.x += parentSize.x/2.0f;
				pos.x -= size.x/2.0f;
			}
			
			return parentPos + pos * parentSize;
		}else{
			return rect.position;
		}
	}
	
	void setPosition(Vector2 position)
	{
		rect.position = position;
	}
		
	Vector2 getSize(const bool recursive)
	{
		if(recursive)
		{
			return parent.getSize(recursive) * rect.size;
		}else{
			return rect.size;
		}
	}
	
	void setSize(Vector2 size)
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
		return rect.position;
	}
	
	Vector2 getSize(const bool)
	{
		return rect.size;
	}
}

UiRoot @uiRoot = @UiRoot();