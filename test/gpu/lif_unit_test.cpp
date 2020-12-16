/* This program is writen by qp09.
 * usually just for fun.
 * Tue December 15 2015
 */

#include "../../include/BSim.h"

#include <random>

using namespace std;

int main(int argc, char **argv)
{
	const int N = 100;
	Network c;
	auto pn0 = c.createPopulation(N, PoissonNeuron(10, 0));
	//(real v_init, real v_rest, real v_reset, real cm, real tau_m, real tau_refrac, real tau_syn_E, real tau_syn_I, real v_thresh, real i_offset);
	auto pn1 = c.createPopulation(N, LIF_brian(LIFENeuron(0.0, 0.0, 0.0, 0.9, 50.0e-3, 0.0, 1.0, 1.0, 0.5, 100.0e-1), 1, 1));

	mt19937 gen;
	gen.seed(1337);
	uniform_real_distribution<> iif;
	for (int src = 0; src < N; src++)
		for (int dst = 0; dst < N; dst++)
			if (iif(gen) < 0.05)
				c.connect(0, src, 1, dst, 0.1, 0.01);

	//c.connect(pn0, pn1, 0.01, 0.01, Excitatory);

	SGSim sg(&c, 0.01);
	sg.run(10);

	return 0;
} 
