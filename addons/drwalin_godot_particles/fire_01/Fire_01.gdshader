shader_type spatial;

render_mode unshaded;
render_mode cull_disabled;
render_mode blend_add;

uniform sampler3D noise3d;
uniform sampler2D mask;

uniform vec3 vel1 = vec3(1, 1, 0);
uniform vec3 vel2 = vec3(0, -1, -1);

uniform vec3 lowColor : source_color = vec3(1, 0.6, 0.1);
uniform vec3 hiColor : source_color = vec3(1, 0.2, 0.05);

uniform float timeScale = 1;

varying flat vec4 instanceCustom;
varying float initialSize;

#define ROTATION_IN_RADIANS instanceCustom.x
#define LIFE_TIME instanceCustom.y
#define ANIMATION_FRAME instanceCustom.x


uint RandUI(int _id, uint _var)
{
	uint a = (uint(_id) ^ uint(2166136261)) * uint(16777619);
	return (a ^ _var) * uint(16777619);
}

float RandF(int _id, uint _var)
{
	return float(RandUI(_id, _var) % uint(16777619)) / float(16777619-1);
}

vec3 RandV(int _id, uint _var)
{
	return vec3(RandF(_id, _var), RandF(_id, _var+uint(1)), RandF(_id, _var+uint(2)));
}

varying vec3 instancePos;
varying vec3 _X;
varying vec3 _Y;
varying vec3 _Z;
varying float alphaLifeTime;

void vertex()
{
	instanceCustom = INSTANCE_CUSTOM;
	const int v_id = INSTANCE_ID;
	
	initialSize = RandF(v_id, 10)*0.2;
	
	instancePos = (MODEL_MATRIX * vec4(0,0,0,1)).xyz;
	
	uint offset = uint(1001);
	
	do {
		_X = normalize(RandV(v_id, offset));
		_Y = normalize(RandV(v_id, offset + uint(3)));
		offset += uint(6);
	} while(abs(dot(_X, _Y)) > 0.9);
	
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
	vec3 p = (instancePos + (_X*uv.y) + (_Y*uv.x) + (_Z*(LIFE_TIME*tScale))) * posScale;
	return texture(tex, p).x;
}

void fragment()
{
	float al = GetTex3d(noise3d, 2.0, timeScale*0.15, UV);
	
	vec2 g = (vec2(0.5,0.5)-UV)*2.0;
	float m = dot(g, g);
	float centric = - m*m;
	
	ALPHA = clamp(centric + al - alphaLifeTime, 0, 1);
	
	ALBEDO = mix(hiColor, lowColor, ALPHA);
	
	EMISSION = ALBEDO * 0.1;
}
