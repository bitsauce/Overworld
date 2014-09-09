//  Algorithm from: http://en.wikipedia.org/wiki/Bresenham's_line_algorithm
funcdef bool RayCastTest(int, int);

class RayCast
{
	// The rasterized points
	array<Vector2i> points;
	
	// A func call for plot testing
	RayCastTest @plotTest;
	
	// The raycast range
	float range = 0.0f;
	
	// This function casts a ray from p0 to p1
	bool test(const Vector2i p0, const Vector2i p1, Vector2i &out end = void)
	{
		// Clear previous points
		points.clear();
		
		// Get integer points
		int x0 = p0.x;
		int y0 = p0.y;
		int x1 = p1.x;
		int y1 = p1.y;
		
		// Get deltas
		int dx = Math.abs(x1-x0);
		int dy = Math.abs(y1-y0);
		
		// Get line dir
		int sx = x0 < x1 ? 1 : -1;
		int sy = y0 < y1 ? 1 : -1;
		
		// Get ???
		int a = dx-dy;
		
		// Perform line plotting
		bool col = false;
		while(true)
		{
			// Plot the current pos
			if(!plot(x0, y0))
			{
				// Plot test failed, break
				col = true;
				break;
			}
			
			// Check if we have reached the end
			if((x0 == x1 && y0 == y1) || (range > 0.0f && (Vector2(x0, y0) - Vector2(p0)).length() > range))
				break;
			
			
			// Apply y traversal
			int a2 = a*2;
			if(a2 > -dy)
			{
				a -= dy;
				x0 += sx;
			}
			
			// Apply x traversal
			if(a2 < dx)
			{
				a += dx;
				y0 += sy;
			}
		}
		
		// Set out arguments
		end = Vector2i(x0, y0);
		
		// Return result
		return col;
	}
	
	bool test(const Vector2 p0, const Vector2 p1, Vector2i &out end = void)
	{
		return test(Vector2i(Math.floor(p0.x), Math.floor(p0.y)), Vector2i(Math.floor(p1.x), Math.floor(p1.y)), end);
	}
	
	bool plot(const int x, const int y)
	{
		// Test plot
		if(@plotTest != null && !plotTest(x, y)) {
			return false;
		}
		
		// Plot the point
		points.insertLast(Vector2i(x, y));
		return true;
	}
}