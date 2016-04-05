/* This header file is writen by qp09
 * usually just for fun
 * Sat October 24 2015
 */
#ifndef SIMPLENETWORK_H
#define SIMPLENETWORK_H

#include <vector>
#include <map>
#include <algorithm>

#include "SimInfo.h"
#include "Neuron.h"
#include "Synapse.h"
#include "Population.h"
#include "GNetwork.h"
//#include "GFunc.h"

using std::map;
using std::pair;
using std::find;
using std::vector;


class SimpleNetwork {
public:
	SimpleNetwork();
	~SimpleNetwork();

	template<class Neuron>
	Neuron* create(Neuron n1);
	template<class Neuron>
	Population<Neuron>* createPopulation(ID id, int num, Neuron templ);
	template<class Neuron>
	int connect(Population<Neuron> *pSrc, Population<Neuron> *pDst, real *weight, real *delay, SpikeType *type, int size);
	
	SynapseBase* connect(NeuronBase *pSrc, NeuronBase *pDst, real weight, real delay, SpikeType type = Excitatory, real tau = 0, bool store = true);
	int connect(int populationIDSrc, int neuronIDSrc, int populationIDDst, int neuronIDDst, real weight, real delay, real tau = 0);
	GNetwork* buildNetwork();

	int addNeuronNum(Type type, int num);
	int addConnectionNum(Type type, int num);
	int addSynapseNum(Type type, int num);

	int addMonitor(int populationIDSrc, int neuronIDSrc);
	int addOutput(int populationIDSrc, int neuronIDSrc);
	int addProbe(int populationIDSrc, int neuronIDSrc, double weight = 1);
	PopulationBase* findPopulation(int populationID);
	NeuronBase* findNeuron(int populationIDSrc, int neuronIDSrc);

	int reset(SimInfo &info);
	int update(SimInfo &info);
	void monitor(SimInfo &info);

//protected:
	vector<PopulationBase*> pPopulations;
	vector<NeuronBase*> pNeurons;
	vector<SynapseBase*> pSynapses;
	vector<NeuronBase*> pOutputs;
	map<ID, vector<ID> > n2sNetwork;
	map<ID, ID> s2nNetwork;
	map<ID, int> id2idx;
	map<int, ID> idx2id;
	real maxDelay;
	real maxFireRate;
	vector<Type> nTypes;
	vector<Type> sTypes;
	int populationNum;
	vector<int> neuronNums;
	vector<int> connectNums;
	vector<int> synapseNums;
};

template<class Neuron>
Neuron* SimpleNetwork::create(Neuron n1)
{
	Neuron *pn1 = new Neuron(n1);
	if (find(pNeurons.begin(), pNeurons.end(), pn1) == pNeurons.end()) {
		pNeurons.push_back(pn1);
		addNeuronNum(pn1->getType(), 1);
	}

	return pn1;
}

template<class Neuron>
Population<Neuron>* SimpleNetwork::createPopulation(ID id, int num, Neuron tmpl)
{
	Population<Neuron> * pp1 = new Population<Neuron>(id, num);
	if (find(pPopulations.begin(), pPopulations.end(), pp1) == pPopulations.end()) {
		pPopulations.push_back(pp1);
		populationNum++;
		addNeuronNum(pp1->getType(), pp1->getNum());
	}

	return pp1;
}

template<class Neuron>
int SimpleNetwork::connect(Population<Neuron> *pSrc, Population<Neuron> *pDst, real *weight, real *delay, SpikeType *type, int size) {
	int srcSize = pSrc->getSize();
	int dstSize = pDst->getSize();
	if (size != srcSize * dstSize) {
		return -1;
	}	
	if (find(pPopulations.begin(), pPopulations.end(), pSrc) == pPopulations.end()) {
		pPopulations.push_back(pSrc);
		populationNum++;
		//neuronNum += pSrc->getNum();
		addNeuronNum(pSrc->getType(), pSrc->getNum());
	}
	if (find(pPopulations.begin(), pPopulations.end(), pDst) == pPopulations.end()) {
		pPopulations.push_back(pDst);
		populationNum++;
		//neuronNum += pDst->getNum();
		addNeuronNum(pDst->getType(), pDst->getNum());
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

#endif /* SIMPLENETWORK_H */
