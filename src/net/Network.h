/* This header file is writen by qp09
 * usually just for fun
 * Sat October 24 2015
 */
#ifndef NETWORK_H
#define NETWORK_H

#include <vector>
#include <map>
#include <algorithm>

#include "../base/SimInfo.h"
#include "../neuron/NeuronBase.h"
#include "../synapse/SynapseBase.h"
#include "../base/Population.h"
#include "GNetwork.h"

using std::pair;
using std::find;
using std::vector;
using std::map;

class Network {
public:
	Network();
	~Network();

	template<class Neuron>
	Neuron* create(Neuron n1);
	template<class Neuron>
	Population<Neuron>* createPopulation(ID id, int num, Neuron templ, bool empty = false);
	template<class Neuron1, class Neuron2>
	int connect(Population<Neuron1> *pSrc, Population<Neuron2> *pDst, real *weight, real *delay, SpikeType *type, int size);
	
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

public:
	vector<NeuronBase*> pOutputs;

//protected:
	vector<PopulationBase*> pPopulations;
	vector<NeuronBase*> pNeurons;
	vector<SynapseBase*> pSynapses;
	map<ID, vector<ID> > n2sNetwork;
	map<ID, ID> s2nNetwork;
	map<ID, NeuronBase*> id2neuron;
	map<ID, SynapseBase*> id2synapse;
	map<ID, int> nid2idx;
	map<ID, int> sid2idx;
	map<int, ID> idx2nid;
	map<int, ID> idx2sid;
	real maxDelay;
	int maxDelaySteps;
	real maxFireRate;
	vector<Type> nTypes;
	vector<Type> sTypes;
	int populationNum;
	vector<int> neuronNums;
	vector<int> connectNums;
	vector<int> synapseNums;
	int totalNeuronNum;
	int totalSynapseNum;
};

template<class Neuron>
Neuron* Network::create(Neuron n1)
{
	Neuron *pn1 = new Neuron(n1);
	if (find(pNeurons.begin(), pNeurons.end(), pn1) == pNeurons.end()) {
		pNeurons.push_back(pn1);
		addNeuronNum(pn1->getType(), 1);
	}

	return pn1;
}

template<class Neuron>
Population<Neuron>* Network::createPopulation(ID id, int num, Neuron templ, bool empty)
{
	
	Population<Neuron> * pp1 = NULL;
	if (empty) {
		pp1 = new Population<Neuron>(id, num);
	} else {
		pp1 = new Population<Neuron>(id, num, templ);
	}

	if (find(pPopulations.begin(), pPopulations.end(), pp1) == pPopulations.end()) {
		pPopulations.push_back(pp1);
		populationNum++;
		addNeuronNum(pp1->getType(), pp1->getNum());
	}

	return pp1;
}

template<class Neuron1, class Neuron2>
int Network::connect(Population<Neuron1> *pSrc, Population<Neuron2> *pDst, real *weight, real *delay, SpikeType *type, int size) {
	int srcSize = pSrc->getNum();
	int dstSize = pDst->getNum();
	if (size != srcSize * dstSize) {
		printf("ERROR: size not match!");
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
		        //connect(NeuronBase *pn1, NeuronBase *pn2, real weight, real delay, SpikeType type, real tau, bool store)
		if (type == NULL) {
			connect(pSrc->getNeuron(iSrc), pDst->getNeuron(iDst), weight[i], delay[i], Excitatory, 0.0, false);
		} else {
			connect(pSrc->getNeuron(iSrc), pDst->getNeuron(iDst), weight[i], delay[i], type[i], 0.0, false);
		}
		count++;
	}

	return count;
}

#endif /* NETWORK_H */
