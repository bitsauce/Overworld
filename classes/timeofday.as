class TimeOfDay : GameObject
{
	private float time = 13.0f*60.0f;
		
	TimeOfDay()
	{
		@global::timeOfDay = @this;
	}
	
	float getTime()
	{
		return time;
	}
	
	int getHour()
	{
		return int(time/60.0f);
	}
	
	int getMinute()
	{
		return int(time-getHour()*60.0f);
	}
	
	void update()
	{
		time += Graphics.dt;
		
		if(Input.getKeyState(KEY_0))
		{
			time += 10.0f;
		}else if(Input.getKeyState(KEY_9)){
			time -= 10.0f;
		}
		
		if(time >= 1440.0f)
		{
			time = 0.0f;
		}
		
		if(time < 0.0f)
		{
			time = 1440.0f;
		}
	}
	
	void draw()
	{
		//arial.draw(@global::batches[global::GUI], Vector2(500.0f, 12.0f), formatInt(getHour(), "0", 2) + ":" + formatInt(getMinute(), "0", 2));
	}
}