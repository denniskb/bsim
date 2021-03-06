/* This program is writen by qp09.
 * usually just for fun.
 * Fri October 30 2015
 */

#include "../../include/BSim.h"

using namespace std;

int main()
{
	Network c;
	Population<LIF_brian> *pn1 = c.createPopulation(0, 1, LIF_brian(LIFENeuron(0.0, 0.0, 0.0, 1.0e-1, 10.0e-3, 0.0, 1.0, 1.0, 15.0e-3, 2.0e-1), 1.0, 1.0));
	Population<LIF_brian> *pn2 = c.createPopulation(1, 1, LIF_brian(LIFENeuron(0.0, 0.0, 0.0, 1.0e-1, 10.0e-3, 0.0, 1.0, 1.0, 15.0e-3, 0), 1.0, 1.0));

	c.connect(pn1, pn2, 5.0e-4, 1.0e-3, Excitatory);
	STSim s(&c, 1.0e-3);
	s.run(0.1);

	return 0;
} 



