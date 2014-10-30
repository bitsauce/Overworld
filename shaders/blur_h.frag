varying vec2 texCoord;

uniform sampler2D u_texture;
uniform int u_radius;
uniform int u_width;

void main()
{
	gl_FragColor.rgba = vec4(0.0);
	for(float i = -float(u_radius); i <= float(u_radius); ++i)
	{
		gl_FragColor.a += texture2D(u_texture, vec2(texCoord.x + i/float(u_width), texCoord.y)).a;
	}
	gl_FragColor.a /= float(u_radius)*2.0;
}