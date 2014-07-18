class Spawner : GameObject
{
	float timer = 0.0f;
	
	void update()
	{
		if(global::timeOfDay.isNight() && timer <= 0.0f)
		{
			Zombie z();
			z.body.setPosition(Vector2(global::camera.position.x, global::terrain.gen.getGroundHeight(global::camera.position.x/TILE_SIZE)*TILE_SIZE));
			timer = 10.0f;
		}
		timer -= Graphics.dt;
	}
}