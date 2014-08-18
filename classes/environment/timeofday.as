class TimeOfDay
{
	private float time = 13*60; // one o' clock
	
	void serialize(StringStream &ss)
	{
		ss.write(time);
	}
	
	void deserialize(StringStream &ss)
	{
		ss.read(time);
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
		// Apply time
		time += Graphics.dt;
		
		// Debug: Time speedup (0 forwards, 9 backwards)
		if(Input.getKeyState(KEY_0)) {
			time += 10.0f;
		}else if(Input.getKeyState(KEY_9)) {
			time -= 10.0f;
		}
		
		// Make sure time loops around to 00:00
		if(time >= 1440.0f) {
			time = 0.0f;
		}
		
		// Make sure time loops back to 24:59
		if(time < 0.0f) {
			time = 1440.0f;
		}
	}
	
	void draw()
	{
		// Debug: Draw time
		game::debug.setVariable("Time", formatInt(getHour(), "0", 2) + ":" + formatInt(getMinute(), "0", 2));
	}
}