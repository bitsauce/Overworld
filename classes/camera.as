class Camera
{
	Vector2 position = Vector2(0.0f, 0.0f);
	float zoom = 1.0f;
	
	Matrix4 getProjectionMatrix()
	{
		Matrix4 mat;
		mat.translate(-position.x, -position.y, 0.0f);
		mat.scale(zoom);
		return mat;
	}
}