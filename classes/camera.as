class Camera
{
	Vector2 position = Vector2(0.0f, 0.0f);
	float zoom = 1.0f;
	
	void lookAt(Vector2 point)
	{
		Vector2 windowSize = Vector2(Window.getSize());
		point -= windowSize/(2.0f*zoom);
		position = point;
		//position.x = Math.min(Math.max(0, point.x), game::terrain.getWidth() * TILE_SIZE - windowSize.x);
		//position.y = Math.min(Math.max(0, point.y), game::terrain.getHeight() * TILE_SIZE - windowSize.y);
	}
	
	Matrix4 getProjectionMatrix()
	{
		Matrix4 mat;
		mat.translate(-position.x, -position.y, 0.0f);
		mat.scale(zoom);
		return mat;
	}
}