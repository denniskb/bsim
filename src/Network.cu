
#include "utils.h"
#include "gpu_utils.h"
#include "gpu_func.h"
#include "Network.h"

GNetwork* Network::buildNetwork()
{
	vector<PopulationBase*>::iterator piter;
	vector<NeuronBase*>::iterator niter;
	vector<SynapseBase*>::iterator siter;

	int neuronTypeNum = nTypes.size();
	int synapseTypeNum = sTypes.size();

	void **pAllNeurons = (void**)malloc(sizeof(void*)*neuronTypeNum);
	void **pAllSynapses = (void**)malloc(sizeof(void*)*synapseTypeNum);
	Type *pNTypes = (Type*)malloc(sizeof(Type)*neuronTypeNum);
	Type *pSTypes = (Type*)malloc(sizeof(Type)*synapseTypeNum);
	int *pNeuronsNum = (int*)malloc(sizeof(int)*(neuronTypeNum + 1));
	int *pSynapsesNum = (int*)malloc(sizeof(int)*(synapseTypeNum + 1));
	pNeuronsNum[0] = 0;
	pSynapsesNum[0] = 0;

	int *pNOffsets = (int*)malloc(sizeof(int)*(neuronTypeNum));
	int *pSOffsets = (int*)malloc(sizeof(int)*(synapseTypeNum));
	int *pNNums = (int*)malloc(sizeof(int)*(neuronTypeNum + 1));
	int *pSNums = (int*)malloc(sizeof(int)*(synapseTypeNum + 1));
	pNNums[0] = 0;
	pSNums[0] = 0;

	for (int i=0; i<neuronTypeNum; i++) {
		pNTypes[i] = nTypes[i];

		void *pN = createType[nTypes[i]]();
		allocType[nTypes[i]](pN, neuronNums[i]);

		int idx = 0;
		for (piter = pPopulations.begin(); piter != pPopulations.end();  piter++) {
			PopulationBase * p = *piter;
			if (p->getType() == nTypes[i]) {
				size_t copied = p->hardCopy(pN, idx);
				idx += copied;
			}
		}
		for (niter = pNeurons.begin(); niter != pNeurons.end();  niter++) {
			NeuronBase * p = *niter;
			if (p->getType() == nTypes[i]) {
				size_t copied = p->hardCopy(pN, idx);
				idx += copied;
			}
		}

		ID *pId = *(ID**)pN;
		for (int t=0; t<idx; t++) {
			nid2idx[pId[t]] = t + pNeuronsNum[i];
			idx2nid[t+pNeuronsNum[i]] = pId[t];
		}

		pNOffsets[i] = 0;
		pNeuronsNum[i+1] = idx + pNeuronsNum[i];
		pNNums[i+1] = pNeuronsNum[i+1];
		pAllNeurons[i] = pN;

	}

	for (int i=0; i<synapseTypeNum; i++) {
		pSTypes[i] = sTypes[i];

		void *pS = createType[sTypes[i]]();
		allocType[sTypes[i]](pS, synapseNums[i]);

		int idx = 0;
		for (siter = pSynapses.begin(); siter != pSynapses.end();  siter++) {
			SynapseBase * p = *siter;
			if (p->getType() == sTypes[i]) {
				int copied = p->hardCopy(pS, idx);
				idx += copied;
			}
		}

		ID *pId = *(ID**)pS;
		for (int t=0; t<idx; t++) {
			sid2idx[pId[t]] = t + pSynapsesNum[i];
			idx2sid[t+pSynapsesNum[i]] = pId[t];
		}

		pSOffsets[i] = 0;
		pSynapsesNum[i+1] = idx + pSynapsesNum[i];
		pSNums[i+1] = pSynapsesNum[i+1];
		pAllSynapses[i] = pS;
	}

	for (int i=0; i<neuronTypeNum; i++) {
		int *pSynapsesNum = (int*)malloc(sizeof(int)*neuronNums[i]);
	       	int *pSynapsesLoc = (int*)malloc(sizeof(int)*neuronNums[i]);
		int *pSynapsesIdx = (int*)malloc(sizeof(int)*connectNums[i]);

		map<ID, vector<ID>>::iterator n2sIter;
		int loc = 0;
		for (n2sIter = n2sNetwork.begin(); n2sIter != n2sNetwork.end(); n2sIter++) {
			map<ID, int>::iterator iter = nid2idx.find(n2sIter->first);
			if (iter == nid2idx.end()) {
				printf("Can't find ID %d_%d\n", n2sIter->first.groupId, n2sIter->first.id);
			}
			if (i != getType(pNeuronsNum, neuronTypeNum+1, iter->second)) {
				continue;
			}
			int idx = getOffset(pNeuronsNum, neuronTypeNum+1, iter->second);
			pSynapsesNum[idx] = n2sIter->second.size();
			pSynapsesLoc[idx] = loc;
			for (int i = 0; i<pSynapsesNum[idx]; i++) {
				map<ID, int>::iterator iter = sid2idx.find(n2sIter->second.at(i));
				if (iter == sid2idx.end()) {
					printf("Can't find ID %d_%d\n", n2sIter->first.groupId, n2sIter->first.id);
				}
				int idx2 = iter->second; 
				pSynapsesIdx[loc] = idx2;
				loc++;
			}	
		}

		allocConnect[nTypes[i]](pAllNeurons[i], pSynapsesNum, pSynapsesLoc, pSynapsesIdx, connectNums[i]);
	}

	for (int i=0; i<synapseTypeNum; i++) {
		int *pSynapsesDst = (int*)malloc(sizeof(int)*synapseNums[i]);
		map<ID, ID>::iterator s2nIter;
		for (s2nIter = s2nNetwork.begin(); s2nIter != s2nNetwork.end(); s2nIter++) {
			map<ID, int>::iterator iter = sid2idx.find(s2nIter->first);
			if (iter == sid2idx.end()) {
				printf("Can't find ID %d_%d\n", s2nIter->first.groupId, s2nIter->first.id);
			}
			if (i != getType(pSynapsesNum, synapseTypeNum+1, iter->second)) {
				continue;
			}
			int idx = getOffset(pSynapsesNum, synapseTypeNum+1, iter->second);
			iter = nid2idx.find(s2nIter->second);
			if (iter == nid2idx.end()) {
				printf("Can't find ID %d_%d\n", s2nIter->second.groupId, s2nIter->second.id);
			}
			pSynapsesDst[idx] = iter->second;
		}

		allocConnect[sTypes[i]](pAllSynapses[i], pSynapsesDst, NULL, NULL, synapseNums[i]);
	}

	GNetwork * ret = (GNetwork*)malloc(sizeof(GNetwork));
	if (ret == NULL) {
		printf("Malloc GNetwork failed/n");
		return NULL;
	}

	ret->pNeurons = pAllNeurons;
	ret->pSynapses = pAllSynapses;
	ret->nOffsets = pNOffsets;
	ret->sOffsets = pSOffsets;
	ret->gNeuronNums = pNNums;
	ret->gSynapseNums = pSNums;

	ret->nTypeNum = neuronTypeNum;
	ret->sTypeNum = synapseTypeNum;
	ret->nTypes = pNTypes;
	ret->sTypes = pSTypes;
	ret->neuronNums = pNeuronsNum;
	ret->synapseNums = pSynapsesNum;

	ret->MAX_DELAY = maxDelay;

	return ret;
}