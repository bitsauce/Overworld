varying vec2 texCoord;

uniform sampler2D u_texture;
uniform sampler2D u_filter;
uniform int u_radius;
uniform int u_height;

void main()
{
	if(texture2D(u_filter, texCoord).a <= 0.0)
		discard;
	
	gl_FragColor.rgba = vec4(0.0);
	for(float i = -float(u_radius); i <= float(u_radius); ++i)
	{
		gl_FragColor.a += texture2D(u_texture, vec2(texCoord.x, texCoord.y + i/float(u_height))).a;
	}
	gl_FragColor.a /= float(u_radius)*2.0;
}