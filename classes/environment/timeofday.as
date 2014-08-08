class TimeOfDay : GameObject
{
	private float time = 13.0f*60.0f;
		
	TimeOfDay()
	{
		//@game::timeOfDay = @this;
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
	
	bool isDay()
	{
		int hour = getHour();
		return hour >= 6 && hour < 18;
	}
	
	bool isNight()
	{
		return !isDay();
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
		game::debug.addVariable("Time", formatInt(getHour(), "0", 2) + ":" + formatInt(getMinute(), "0", 2));
	}
}