uint MulFNV_1a(uint v)
{
	return v * uint(16777619);
}

uint FNV_1a(int v)
{
	return MulFNV_1a(uint(v) ^ uint(2166136261));
}

uint RandUI(int _id, uint _var)
{
	uint a = MulFNV_1a(uint(_id) ^ uint(2166136261));
	return MulFNV_1a(a ^ _var);
}

float RandF(int _id, uint _var)
{
	return float(RandUI(_id, _var) % uint(16777619)) / float(6777618);
}

vec3 RandV(int _id, uint _var)
{
	return vec3(RandF(_id, _var), RandF(_id, _var+uint(1)), RandF(_id, _var+uint(2)));
}
