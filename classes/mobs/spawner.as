class Spawner
{
	float timer = 0.0f;
	
	void update()
	{
		if(game::timeOfDay.isNight() && timer <= 0.0f)
		{
			Zombie z();
			z.body.setPosition(Vector2(game::camera.position.x, game::terrain.generator.getGroundHeight(game::camera.position.x/TILE_SIZE)*TILE_SIZE));
			timer = 10.0f;
		}
		timer -= Graphics.dt;
	}
	
	void draw()
	{
	}
}