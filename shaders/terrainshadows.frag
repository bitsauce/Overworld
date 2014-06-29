varying vec2 texcoord;

uniform sampler2D texture;
uniform int radius;
uniform int steps;
uniform float falloff;
uniform vec2 texsize;

void main()
{
	// Setup loop vars
	float vx = float(steps)/texsize.x;
	float vy = float(steps)/texsize.y;
	
	float acc = 0.0;
	float i = 0.0;
	
	// Calculate shadow strength
	for(int y = -radius; y <= radius; y++)
	{
		for(int x = -radius; x <= radius; x++)
		{
			float dist = sqrt(float(x*x)+float(y*y));
			if(dist < float(radius))
			{
				acc += texture2D(texture, vec2(texcoord.x+(float(x)*vx), texcoord.y+(float(y)*vy))).a;
				i += 1.0;
			}
		}
	}
	
	// Calculate mean alpha
	float a = pow(acc/i, falloff);
	
	// Set frag color
	gl_FragColor = vec4(vec3(0.0), a);
}