#include "../../include/BSim.h"
#include "../../src/utils/random.h"


using namespace std;
using namespace spice::util;


static ulong_ seed = 1337;


void connect(Network & net, int src_pop, int dst_pop, int src_sz, int dst_sz, float p, float w, float d)
{
	xoroshiro128p gen(seed++);
	std::vector<float> neighbors(dst_sz);

	for (int src = 0; src < src_sz; src++)
	{
		int const degree = binornd(gen, dst_sz, p);
		
		float total = exprnd(gen);
		for (int i = 0; i < degree; i++)
		{
			neighbors[i] = total;
			total += exprnd(gen);
		}

		float const scale = (dst_sz - degree) / total;
		for (int i = 0; i < degree; i++)
			net.connect(src_pop, src, dst_pop, static_cast<int>(neighbors[i] * scale) + i, w, d);
	}
}


int main(int argc, char **argv)
{
	const int N = 10000;
	Network c;
	auto pn0 = c.createPopulation(N, CompositeNeuron<PoissonNeuron, StaticSynapse>(PoissonNeuron(10, 0), 1, 1));
	auto pn1 = c.createPopulation(N, LIF_brian(LIFENeuron(0.0, 0.0, 0.0, 0.9, 50.0e-3, 0.0, 1.0, 1.0, 0.5, 100.0e-1), 1, 1));

	connect(c, 0, 1, N, N, 0.01f, 0.005f, 0.01f);

	SGSim sg(&c, 0.01);
	sg.run(1);

	return 0;
} 
