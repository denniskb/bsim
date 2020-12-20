#include "../../include/BSim.h"
#include "../../src/utils/random.h"


using namespace std;
using namespace spice::util;


static ulong_ seed = 1337;


void connect(Network & net,
             int const src_pop,
			 int const dst_pop,
			 int const src_sz,
			 int const dst_sz,
			 float const p,
			 float const w,
			 float const d)
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
	const int N = 20000;
	Network c;
	auto P = c.createPopulation(N*5/10, CompositeNeuron<PoissonNeuron, StaticSynapse>(PoissonNeuron(20, 0), 1, 1));
	auto E = c.createPopulation(N*4/10, CompositeNeuron<LIFEBNeuron, StaticSynapse>(LIFEBNeuron(0.0, 0.0, 0.0, 1.0e-1, 50.0e-3, 0.0, 1.0, 1.0, 15.0e-3, 100.0e-1), 1, 1));
	auto I = c.createPopulation(N*1/10, CompositeNeuron<LIFEBNeuron, StaticSynapse>(LIFEBNeuron(0.0, 0.0, 0.0, 1.0e-1, 50.0e-3, 0.0, 1.0, 1.0, 15.0e-3, 100.0e-1), 1, 1));

	connect(c, 0, 1, P->getNum(), E->getNum(), 0.1f, 0.0001f, 0.0015f); // P->E
	connect(c, 0, 2, P->getNum(), I->getNum(), 0.1f, 0.0001f, 0.0015f); // P->I

	connect(c, 1, 1, E->getNum(), E->getNum(), 0.1f, 0.0001f, 0.0015f); // E->E
	connect(c, 1, 2, E->getNum(), I->getNum(), 0.1f, 0.0001f, 0.0015f); // E->I

	connect(c, 2, 1, I->getNum(), E->getNum(), 0.1f, -0.0005f, 0.0015f); // I->E
	connect(c, 2, 2, I->getNum(), I->getNum(), 0.1f, -0.0005f, 0.0015f); // I->I

	MGSim sg(&c, 0.0001f);
	sg.run(0.1f);

	return 0;
} 
