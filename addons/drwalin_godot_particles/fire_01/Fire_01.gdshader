shader_type spatial;

render_mode unshaded;
render_mode cull_disabled;
render_mode shadows_disabled;
render_mode ambient_light_disabled;
render_mode fog_disabled;
render_mode blend_add;

#include "res://addons/drwalin_godot_particles/ShaderUtils.gdshaderinc"

uniform sampler3D noise3d : filter_linear_mipmap;
uniform vec3 lowColor : source_color = vec3(1, 0.6, 0.1);
uniform vec3 hiColor : source_color = vec3(1, 0.2, 0.05);
uniform float timeScale = 1;

varying flat vec4 particleInstanceCustom;
#define LIFE_TIME particleInstanceCustom.y

varying vec3 instancePos;
varying vec3 _X;
varying vec3 _Y;
varying vec3 _Z;
varying float alphaLifeTime;

void vertex()
{
	particleInstanceCustom = INSTANCE_CUSTOM;
	const int v_id = INSTANCE_ID;
	
	instancePos = (MODEL_MATRIX * vec4(0,0,0,1)).xyz;
	uint of = uint(1001);
	
	do {
		_X = normalize(RandV(v_id, of+=uint(3)));
		_Y = normalize(RandV(v_id, of+=uint(3)));
	} while(abs(dot(_X, _Y)) > 0.95);
	_Z = normalize(cross(_X, _Y));
	_Y = cross(_X, _Z);
	
	vec2 uv = UV - 0.5;
	float c = RandF(v_id, 112)*2.0 - 1.0;
	float s = sqrt(1.0 - c*c);
	UV = (mat2(vec2(c, -s), vec2(s, c)) * uv) + vec2(0.5,0.5);
	
	float l = LIFE_TIME;
	float l2 = (log2(l) * l + 0.54) * (1.0/0.54);
	alphaLifeTime = l2;
}

float GetTex3d(sampler3D tex, float posScale, float tScale, vec2 uv)
{
	vec3 p = (instancePos + (_X*uv.x) + (_Y*uv.y) + (_Z*(LIFE_TIME*tScale))) * posScale;
	return texture(tex, p).x;
}

void fragment()
{
	float al = GetTex3d(noise3d, 2.0, timeScale*0.15, UV);
	
	vec2 g = (vec2(0.5,0.5)-UV)*2.0;
	float m = dot(g, g);
	float centric = - m*m;
	
	float alpha = clamp(centric + al - alphaLifeTime, 0, 1);
	ALPHA = alpha;
	ALBEDO = mix(hiColor, lowColor, alpha);
	EMISSION = hiColor * 0.1;
}
