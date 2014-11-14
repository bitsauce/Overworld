class SpawnManager
{
	float timer = 0.0f;
	int maxMobCount = 5;
	int mobCount = 0;
	bool peacefull = true;
	
	void update()
	{
		if(peacefull) return;
		
		if(TimeOfDay.isNight() && timer <= 0.0f && mobCount < maxMobCount)
		{
			Zombie z();
			z.body.setPosition(Vector2(Camera.position.x, Terrain.generator.getGroundHeight(Camera.position.x/TILE_PX)*TILE_PX));
			timer = 10.0f;
			mobCount++;
		}
		timer -= Graphics.dt;
		
		Debug.setVariable("Mob Count", ""+mobCount);
	}
}