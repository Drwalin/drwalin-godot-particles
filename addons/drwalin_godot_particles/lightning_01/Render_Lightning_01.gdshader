shader_type spatial;

render_mode unshaded;
render_mode cull_disabled;
render_mode shadows_disabled;
render_mode ambient_light_disabled;
render_mode blend_add;

#include "res://addons/drwalin_godot_particles/ShaderUtils.gdshaderinc"

uniform sampler2D sparkTex : filter_linear_mipmap;
uniform vec3 color : source_color = vec3(0.6, 0.1, 0.8);
uniform sampler3D whiteNoise3d : filter_linear_mipmap;

uniform float maxAmplitude = 1.0;
uniform float maxRange = 10.0; // world units

varying float travelDistance; // distance 0 - maxRange
varying float lifeTime;

#define LIFE_TIME INSTANCE_CUSTOM.y

vec2 CalcPointAmplitude(float heightFactor, vec3 instanceRandom, int instanceId, uint seed2)
{
	float v = heightFactor*(heightFactor-1.0)*4.0 * maxAmplitude;
	float r = RandF(instanceId, seed2);
	float z = r;
	
	float split = heightFactor * 5.0;
	vec3 uv = vec3(0,0,0);
	int j=instanceId;
	ivec4 dirIds = ivec4(instanceId/(169*13), instanceId/169, instanceId/13, instanceId)%13;
	
	const vec2 dirVec = vec2(1, 0);
	vec3 dirs[5];
	dirs[0] = vec3(0,1,0);
	for (int i=0; i<4; ++i) {
		float theta = TIME * 0.001 + float(dirIds[i])*171.3211;
		float s = sin(theta);
		float c = cos(theta);
		mat2 rot = mat2(vec2(s, c), vec2(s, -c));
		vec2 dir = rot * dirVec * 0.5;
		dirs[i+1] = vec3(dir.x, 1.0, dir.y);
	}
	
	for (int i=0; i<5; ++i) {
		if (split < float(i)) {
			uv += dirs[i];
		} else if (split < float(i+1)) {
			uv += dirs[i] * fract(split);
		}
	}
	
	uv.x += TIME * 0.001;
	
	uv *= 0.2;
	
	float ss1 = texture(whiteNoise3d, uv).x*2.0 - 1.0;
	float ss2 = texture(whiteNoise3d, uv.yzx + vec3(0.3, -0.1, 0)).x*2.0 - 1.0;
	
	//return uv.xz;
	
	//float ss = texture(whiteNoise3d, vec3(heightFactor/20.0, instanceRandom.x/10.0, z)).x*2.0 - 1.0;
	return vec2(ss1, ss2) * v;
}

void vertex() {
	lifeTime = LIFE_TIME;
	int v_id = int(FNV_1a(INSTANCE_ID));
	vec3 vert = VERTEX;
	vert.y *= maxRange;
	travelDistance = vert.y;
	
	float yFactor = travelDistance/maxRange;
	
	UV.y *= maxRange*0.5;
	UV.y += RandF(v_id, 12)*17.0;
	
	float y = travelDistance/maxRange*0.8;
	y *= y;
	y *= y;
	float scaleX = (1.0 - y);
	
	//UV.y -= LIFE_TIME*maxRange*0.25;
	//vert.x *= scaleX;
	vert.xz *= scaleX;
	vert.xz += CalcPointAmplitude(yFactor, COLOR.xyz/*LIFE_TIME*/, v_id, 145527);// * scaleX;
	VERTEX = (MODEL_MATRIX * vec4(vert, 1.0)).xyz;
}

void fragment() {
	vec4 col = texture(sparkTex, UV) * vec4(color, 1.0);
	float alpha = col.w;
	if (travelDistance/maxRange > lifeTime*3.0) {
		alpha = 0.0;
	}
	ALPHA = alpha;// * (1.0-travelDistance/maxRangeOfCurrent);
	ALBEDO = col.xyz;
}
