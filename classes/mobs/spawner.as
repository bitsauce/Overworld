class Spawner
{
	float timer = 0.0f;
	int maxMobCount = 5;
	int mobCount = 0;
	
	void update()
	{
		if(game::timeOfDay.isNight() && timer <= 0.0f && mobCount < maxMobCount)
		{
			Zombie z();
			z.body.setPosition(Vector2(game::camera.position.x, game::terrain.generator.getGroundHeight(game::camera.position.x/TILE_SIZE)*TILE_SIZE));
			timer = 10.0f;
			mobCount++;
		}
		timer -= Graphics.dt;
	}
	
	void draw()
	{
		scene::game.getDebug().setVariable("Mob Count", ""+mobCount);
	}
}