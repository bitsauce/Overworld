varying vec2 texcoord;

uniform sampler2D texture;
uniform float radius;
uniform float falloff;
uniform vec2 resolution;

void main()
{
	// Setup loop vars
	vec2 dtvec = 1.0f/resolution;
	float acc = 0.0;
	float i = 0.0;
	
	// Calculate shadow strength
	for(float y = -radius; y <= radius; y += 1.0f)
	{
		for(float x = -radius; x <= radius; x += 1.0f)
		{
			float dist = sqrt(x*x+y*y);
			if(dist < radius)
			{
				acc += texture2D(texture, texcoord + dtvec*vec2(x, y)).a;
				i += 1.0;
			}
		}
	}
	
	// Calculate mean alpha
	float a = pow(acc/i, falloff);
	
	// Set frag color
	gl_FragColor = vec4(vec3(0.0), a);
}