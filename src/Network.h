/* This header file is writen by qp09
 * usually just for fun
 * Sat October 24 2015
 */
#ifndef NETWORK_H
#define NETWORK_H

#include <vector>
#include <map>
#include <algorithm>
#include "Neuron.h"
#include "Synapse.h"
#include "Population.h"

using std::map;
using std::pair;
using std::find;
using std::vector;

struct PlainNetwork {
	void *pNeurons;
	void *pSynapses;
	//void *pPopulations;
	//size_t neuronSize;
	//size_t synapseSize;
	//size_t populationSize;
	unsigned int neuronNum;
	unsigned int synapseNum;
	unsigned int MAX_DELAY;
};

class Network {
public:
	Network();
	~Network();

	template<class Neuron>
	Neuron* create(Neuron n1);
	template<class Neuron>
	Population<Neuron>* createPopulation(Neuron n1, unsigned int num);
	template<class Neuron>
	int connect(Population<Neuron> *pSrc, Population<Neuron> *pDst, real *weight, real *delay, SpikeType *type, int size);
	
	int connect(NeuronBase *pSrc, NeuronBase *pDst, real weight, real delay, SpikeType type, bool store = true);
	PlainNetwork* buildNetwrok();

//protected:
	vector<PopulationBase*> pPopulations;
	vector<NeuronBase*> pNeurons;
	vector<SynapseBase*> pSynapses;
	map<ID, vector<ID> > n2sNetwork;
	map<ID, ID > s2nNetwork;
	real maxDelay;
	real maxFireRate;
	unsigned int populationNum;
	unsigned int neuronNum;
	unsigned int synapseNum;
};

template<class Neuron>
Neuron* Network::create(Neuron n1)
{
	Neuron *pn1 = new Neuron(n1);
	if (find(pNeurons.begin(), pNeurons.end(), pn1) == pNeurons.end()) {
		pNeurons.push_back(pn1);
		neuronNum++;
	}

	return pn1;
}

template<class Neuron>
Population<Neuron>* Network::createPopulation(Neuron n1, unsigned int num)
{
	Population<Neuron> * pp1 = new Population<Neuron>(n1, num);
	if (find(pPopulations.begin(), pPopulations.end(), pp1) == pPopulations.end()) {
		pPopulations.push_back(pp1);
		populationNum++;
		neuronNum += pp1->getNum();
	}

	return pp1;
}

template<class Neuron>
int Network::connect(Population<Neuron> *pSrc, Population<Neuron> *pDst, real *weight, real *delay, SpikeType *type, int size) {
	int srcSize = pSrc->getSize();
	int dstSize = pDst->getSize();
	if (size != srcSize * dstSize) {
		return -1;
	}	
	if (find(pPopulations.begin(), pPopulations.end(), pSrc) == pPopulations.end()) {
		pPopulations.push_back(pSrc);
		populationNum++;
		neuronNum += pSrc->getNum();
	}
	if (find(pPopulations.begin(), pPopulations.end(), pDst) == pPopulations.end()) {
		pNeurons.push_back(pDst);
		populationNum++;
		neuronNum += pDst->getNum();
	}

	int count = 0;
	for (int i=0; i<size; i++) {
		int iSrc = i/dstSize;
		int iDst = i%dstSize;
		connect(pSrc->getNeuron(iSrc), pDst->getNeuron(iDst), weight[i], delay[i], type[i], false);
		count++;
	}

	return count;
}

#endif /* NETWORK_H */

