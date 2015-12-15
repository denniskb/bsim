/* This program is writen by qp09.
 * usually just for fun.
 * Sat October 24 2015
 */

#include "Network.h"
#include "utils.h"

Network::Network()
{
}

Network::~Network()
{
	if (!pPopulations.empty()) {
		vector<PopulationBase*>::iterator iter;
		for (iter = pPopulations.begin(); iter != pPopulations.end(); iter++) {
			PopulationBase * t = *iter;
			delete t;
		}
	}

	if (!pNeurons.empty()) {
		vector<NeuronBase*>::iterator iter;
		for (iter = pNeurons.begin(); iter != pNeurons.end(); iter++) {
			NeuronBase * t = *iter;
			delete t;
		}
	}

	if (!pSynapses.empty()) {
		vector<SynapseBase*>::iterator iter;
		for (iter = pSynapses.begin(); iter != pSynapses.end(); iter++) {
			SynapseBase * t = *iter;
			delete t;
		}
	}

	pPopulations.clear();
	pNeurons.clear();
	pSynapses.clear();
}

int Network::connect(NeuronBase *pn1, NeuronBase *pn2, real weight, real delay, SpikeType type, bool store)
{
	if (store) {
		if (find(pNeurons.begin(), pNeurons.end(), pn1) == pNeurons.end()) {
			pNeurons.push_back(pn1);
		}
		if (find(pNeurons.begin(), pNeurons.end(), pn2) == pNeurons.end()) {
			pNeurons.push_back(pn2);
		}
	}

	SynapseBase * p = pn1->addSynapse(weight, delay, type, pn2);

	pSynapses.push_back(p);
	synapseNum++;
	s2nNetwork[p->getID()] = pn2->getID(); 
	n2sNetwork[pn1->getID()].push_back(p->getID());

	if (delay > maxDelay) {
		maxDelay = delay;
	}
	
	return 1;
}


PlainNetwork* Network::buildNetwrok()
{
	//size_t populationSize = 0;
	//size_t neuronSize = 0;
	//size_t synapseSize = 0;
	vector<PopulationBase*>::iterator piter;
	vector<NeuronBase*>::iterator niter;
	vector<SynapseBase*>::iterator siter;

	//for (piter = pPopulations.begin(); piter != pPopulations.end();  piter++) {
	//	PopulationBase * p = *piter;
	//	populationSize += p->getSize();
	//	neuronNum += p->getNum();
	//}
	//for (niter = pNeurons.begin(); niter != pNeurons.end();  niter++) {
	//	NeuronBase * p = *niter;
	//	neuronSize += p->getSize();
	//	neuronNum++;
	//}
	//for (siter = pSynapses.begin(); siter != pSynapses.end();  siter++) {
	//	SynapseBase * p = *siter;
	//	synapseSize += p->getSize();
	//	synapseNum++;
	//}

	//ret->populationSize = populationSize;
	//ret->neuronSize = neuronSize;
	//ret->synapseSize = synapseSize;
	
	GLIFNeurons *pGLIF = (GLIFNeurons*)malloc(sizeof(GLIFNeurons));
	GExpSynapses *pGExp = (GExpSynapses*)malloc(sizeof(GExpSynapses));
	pGLIF->allocNeurons(neuronNum);
	pGLIF->allocConnects(synapseNum);

	unsigned int idx = 0;
	for (piter = pPopulations.begin(); piter != pPopulations.end();  piter++) {
		PopulationBase * p = *piter;
		size_t copied = p->hardCopy(pGLIF, idx);
		idx += copied;
	}
	for (niter = pNeurons.begin(); niter != pNeurons.end();  niter++) {
		NeuronBase * p = *niter;
		size_t copied = p->hardCopy(pGLIF, idx);
		idx += copied;
	}
	idx = 0;
	for (siter = pSynapses.begin(); siter != pSynapses.end();  siter++) {
		SynapseBase * p = *siter;
		int copied = p->hardCopy(pGExp, idx);
		idx += copied;
	}

	map<ID, vector<ID>>::iterator n2sIter;
	map<ID, ID>::iterator s2nIter;
	unsigned int loc = 0;
	for (n2sIter = n2sNetwork.begin(); n2sIter != n2sNetwork.end(); n2sIter++) {
		unsigned int idx = id2idx(pGLIF->pID, neuronNum, n2sIter->first);
		pGLIF->pSynapsesNum[idx] = n2sIter->second.size();
		pGLIF->pSynapsesLoc[idx] = loc;
		for (unsigned int i = 0; i<pGLIF->pSynapsesNum[idx]; i++) {
			unsigned int idx2 = id2idx(pGExp->pID, synapseNum, n2sIter->second.at(i)); 
			pGLIF->pSynapsesIdx[loc] = idx2;
			loc++;
			pGExp->pSrc[idx2] = idx;
		}	
	}

	for (s2nIter = s2nNetwork.begin(); s2nIter != s2nNetwork.end(); s2nIter++) {
		unsigned int idx = id2idx(pGExp->pID, synapseNum, s2nIter->first);
		pGExp->pDst[idx] = id2idx(pGLIF->pID, neuronNum, s2nIter->second);
	}

	PlainNetwork * ret = (PlainNetwork*)malloc(sizeof(PlainNetwork));
	if (ret == NULL) {
		printf("Malloc PlainNetwork failed/n");
		return NULL;
	}

	ret->neuronNum = neuronNum;
	ret->synapseNum = synapseNum;
	ret->pNeurons = pGLIF;
	ret->pSynapses = pGExp;
	ret->MAX_DELAY = maxDelay;

	return ret;
}
