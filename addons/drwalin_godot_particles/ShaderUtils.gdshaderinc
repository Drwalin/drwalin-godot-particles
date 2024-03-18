
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
