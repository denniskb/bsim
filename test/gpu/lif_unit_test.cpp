#include "../../include/BSim.h"
#include "../../src/utils/random.h"


using namespace std;
using namespace spice::util;


void connect(Network & net, int src_pop, int dst_pop, int src_sz, int dst_sz, float p)
{

}


int main(int argc, char **argv)
{
	const int N = 10000;
	Network c;
	auto pn0 = c.createPopulation(N, CompositeNeuron<PoissonNeuron, StaticSynapse>(PoissonNeuron(10, 0), 1, 1));
	auto pn1 = c.createPopulation(N, LIF_brian(LIFENeuron(0.0, 0.0, 0.0, 0.9, 50.0e-3, 0.0, 1.0, 1.0, 0.5, 100.0e-1), 1, 1));

	/*mt19937 gen;
	gen.seed(1337);
	uniform_real_distribution<> iif;
	for (int src = 0; src < N; src++)
		for (int dst = 0; dst < N; dst++)
			if (iif(gen) < 0.01)
				c.connect(0, src, 1, dst, 0.1, 0.01);*/

	//c.connect(pn0, pn1, 0.01, 0.01, Excitatory);

	c.connect(0, 2, 0, 7, 0.1, 0.01);

	SGSim sg(&c, 0.01);
	sg.run(0.1);

	return 0;
} 
