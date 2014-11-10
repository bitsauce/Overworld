class CameraManager
{
	Vector2 position = Vector2(0.0f, 0.0f);
	float zoom = 1.0f;
	
	Vector2 getCenter()
	{
		return position + Vector2(Window.getSize())/2.0f;
	}
	
	void lookAt(Vector2 point)
	{
		Vector2 windowSize = Vector2(Window.getSize());
		point -= windowSize/(2.0f*zoom);
		position = point;
	}
	
	Matrix4 getProjectionMatrix()
	{
		Matrix4 mat;
		mat.translate(-position.x, -position.y, 0.0f);
		mat.scale(zoom);
		return mat;
	}
}