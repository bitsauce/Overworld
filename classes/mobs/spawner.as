class Spawner
{
	float timer = 0.0f;
	
	void update()
	{
		if(global::timeOfDay.isNight() && timer <= 0.0f)
		{
			Zombie z();
			z.setPosition(Vector2(camera.x, global::terrain.gen.getGroundHeight(camera.x/TILE_SIZE)*TILE_SIZE));
			timer = 10.0f;
		}
		timer -= Graphics.dt;
	}
}