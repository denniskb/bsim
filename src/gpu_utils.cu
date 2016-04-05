
#include "./utils/cuda/helper_cuda.h"
#include "gpu_func.h"
#include "gpu_utils.h"

GNetwork* copyDataToGPU(GNetwork *pCpuNet)
{
	GNetwork *tmpNet = (GNetwork*)malloc(sizeof(GNetwork));
	memcpy(tmpNet, pCpuNet, sizeof(GNetwork));

	int nTypeNum = pCpuNet->nTypeNum;
	int sTypeNum = pCpuNet->sTypeNum;

	Type *nTypes, *sTypes;
	checkCudaErrors(cudaMalloc((void**)&(nTypes), sizeof(Type)*nTypeNum));
	checkCudaErrors(cudaMemcpy(nTypes, pCpuNet->nTypes, sizeof(Type)*nTypeNum, cudaMemcpyHostToDevice));
	checkCudaErrors(cudaMalloc((void**)&(sTypes), sizeof(Type)*sTypeNum));
	checkCudaErrors(cudaMemcpy(sTypes, pCpuNet->sTypes, sizeof(Type)*sTypeNum, cudaMemcpyHostToDevice));

	int *neuronNums, *synapseNums;
	checkCudaErrors(cudaMalloc((void**)&(neuronNums), sizeof(int)*(nTypeNum+1)));
	checkCudaErrors(cudaMemcpy(neuronNums, pCpuNet->neuronNums, sizeof(int)*(nTypeNum+1), cudaMemcpyHostToDevice));
	checkCudaErrors(cudaMalloc((void**)&(synapseNums), sizeof(int)*(sTypeNum+1)));
	checkCudaErrors(cudaMemcpy(synapseNums, pCpuNet->synapseNums, sizeof(int)*(sTypeNum+1), cudaMemcpyHostToDevice));

	int *gNeuronNums, *gSynapseNums;
	checkCudaErrors(cudaMalloc((void**)&(gNeuronNums), sizeof(int)*(nTypeNum)));
	checkCudaErrors(cudaMemcpy(gNeuronNums, pCpuNet->gNeuronNums, sizeof(int)*(nTypeNum), cudaMemcpyHostToDevice));
	checkCudaErrors(cudaMalloc((void**)&(gSynapseNums), sizeof(int)*(sTypeNum)));
	checkCudaErrors(cudaMemcpy(gSynapseNums, pCpuNet->gSynapseNums, sizeof(int)*(sTypeNum), cudaMemcpyHostToDevice));

	int *nOffsets, *sOffsets;
	checkCudaErrors(cudaMalloc((void**)&(nOffsets), sizeof(int)*(nTypeNum)));
	checkCudaErrors(cudaMemcpy(nOffsets, pCpuNet->nOffsets, sizeof(int)*(nTypeNum), cudaMemcpyHostToDevice));
	checkCudaErrors(cudaMalloc((void**)&(sOffsets), sizeof(int)*(sTypeNum)));
	checkCudaErrors(cudaMemcpy(sOffsets, pCpuNet->sOffsets, sizeof(int)*(sTypeNum), cudaMemcpyHostToDevice));

	//TODO support multitype N and S
	void **pNs = (void**)malloc(sizeof(void*)*nTypeNum);
	void **pSs = (void**)malloc(sizeof(void*)*sTypeNum);

	for (int i=0; i<nTypeNum; i++) {
		void *pNTmp = createType[pCpuNet->nTypes[i]]();
		memcpy(pNTmp, pCpuNet->pNeurons[i], getSize[pCpuNet->nTypes[i]]());
		cudaAllocType[pCpuNet->nTypes[i]](pCpuNet->pNeurons[i], pNTmp);
		void *pNGpu;
		checkCudaErrors(cudaMalloc((void**)&(pNGpu), getSize[pCpuNet->nTypes[i]]()));
		checkCudaErrors(cudaMemcpy(pNGpu, pNTmp, getSize[pCpuNet->nTypes[i]](), cudaMemcpyHostToDevice));
		free(pNTmp);
		pNs[i] = pNGpu;
	}

	for (int i=0; i<sTypeNum; i++) {
		void *pSTmp = createType[pCpuNet->sTypes[i]]();
		memcpy(pSTmp, pCpuNet->pSynapses[i], getSize[pCpuNet->sTypes[i]]());
		cudaAllocType[pCpuNet->sTypes[i]](pCpuNet->pSynapses[i], pSTmp);
		void *pSGpu;
		checkCudaErrors(cudaMalloc((void**)&(pSGpu), getSize[pCpuNet->sTypes[i]]()));
		checkCudaErrors(cudaMemcpy(pSGpu, pSTmp, getSize[pCpuNet->sTypes[i]](), cudaMemcpyHostToDevice));
		free(pSTmp);
		pSs[i] = pSGpu;

	}

	//GLIFNeurons *pNTmp = (GLIFNeurons*)malloc(sizeof(GLIFNeurons));
	//memcpy(pNTmp, pN, sizeof(GLIFNeurons));
	//GExpSynapses *pSTmp = (GExpSynapses*)malloc(sizeof(GExpSynapses));
	//memcpy(pSTmp, pS, sizeof(GExpSynapses));

	//GLIFNeurons *pNGpu;
	//GExpSynapses *pSGpu;

	//pN->allocGNeurons((GLIFNeurons*)pNTmp);
	//pS->allocGSynapses((GExpSynapses*)pSTmp);
	
	//checkCudaErrors(cudaMalloc((void**)&(pNGpu), sizeof(GLIFNeurons)));
	//checkCudaErrors(cudaMemcpy(pNGpu, pNTmp, sizeof(GLIFNeurons), cudaMemcpyHostToDevice));
	//checkCudaErrors(cudaMalloc((void**)&(pSGpu), sizeof(GExpSynapses)));
	//checkCudaErrors(cudaMemcpy(pSGpu, pSTmp, sizeof(GExpSynapses), cudaMemcpyHostToDevice));
	//free(pNTmp);
	//free(pSTmp);

	void **pNeurons, **pSynapses;
	checkCudaErrors(cudaMalloc((void**)&(pNeurons), sizeof(void*)*nTypeNum));
	checkCudaErrors(cudaMemcpy(pNeurons, pNs, sizeof(void*)*nTypeNum, cudaMemcpyHostToDevice));
	checkCudaErrors(cudaMalloc((void**)&(pSynapses), sizeof(void*)*sTypeNum));
	checkCudaErrors(cudaMemcpy(pSynapses, pSs, sizeof(void*)*sTypeNum, cudaMemcpyHostToDevice));
	free(pNs);
	free(pSs);

	tmpNet->pNeurons = pNeurons;
	tmpNet->pSynapses = pSynapses;
	tmpNet->nOffsets = nOffsets;
	tmpNet->sOffsets = sOffsets;
	tmpNet->neuronNums = neuronNums;
	tmpNet->synapseNums = synapseNums;

	tmpNet->nTypes = nTypes;
	tmpNet->sTypes = sTypes;
	tmpNet->gNeuronNums = gNeuronNums;
	tmpNet->gSynapseNums = gSynapseNums;

	return tmpNet;

	//GNetwork *pGpuNet;
	//checkCudaErrors(cudaMalloc((void**)&(pGpuNet), sizeof(GNetwork)));
	//checkCudaErrors(cudaMemcpy(pGpuNet, tmpNet, sizeof(GNetwork), cudaMemcpyHostToDevice));
	//free(tmpNet);

	//return pGpuNet;
}


int freeGPUData(GNetwork *pGpuNet)
{
	GNetwork *pTmpNet = pGpuNet;
	//GNetwork *pTmpNet = (GNetwork*)malloc(sizeof(GNetwork));
	//checkCudaErrors(cudaMemcpy(pTmpNet, pGpuNet, sizeof(GLIFNeurons), cudaMemcpyDeviceToHost));

	int nTypeNum = pTmpNet->nTypeNum;
	int sTypeNum = pTmpNet->sTypeNum;

	void **pTmpNs = (void**)malloc(sizeof(void*) * nTypeNum);
	checkCudaErrors(cudaMemcpy(pTmpNs, pTmpNet->pNeurons, sizeof(void*)*nTypeNum, cudaMemcpyDeviceToHost));
	void **pTmpSs = (void**)malloc(sizeof(void*) * sTypeNum);
	checkCudaErrors(cudaMemcpy(pTmpSs, pTmpNet->pSynapses, sizeof(void*)*sTypeNum, cudaMemcpyDeviceToHost));

	Type * pTmpNT = (Type*)malloc(sizeof(Type)*nTypeNum);
	checkCudaErrors(cudaMemcpy(pTmpNT, pTmpNet->nTypes, sizeof(Type)*nTypeNum, cudaMemcpyDeviceToHost));
	Type * pTmpST = (Type*)malloc(sizeof(Type)*sTypeNum);
	checkCudaErrors(cudaMemcpy(pTmpST, pTmpNet->sTypes, sizeof(Type)*sTypeNum, cudaMemcpyDeviceToHost));

	for (int i=0; i<nTypeNum; i++) {
		void *pTmpN = createType[pTmpNT[i]]();
		checkCudaErrors(cudaMemcpy(pTmpN, pTmpNs[i], getSize[pTmpNT[i]](), cudaMemcpyDeviceToHost));
		cudaFreeType[pTmpNT[i]](pTmpN);
		free(pTmpN);
	}

	for (int i=0; i<sTypeNum; i++) {
		void *pTmpS = createType[pTmpST[i]]();
		checkCudaErrors(cudaMemcpy(pTmpS, pTmpSs[i], getSize[pTmpST[i]](), cudaMemcpyDeviceToHost));
		cudaFreeType[pTmpST[i]](pTmpS);
		free(pTmpS);
	}

        //GLIFNeurons *pN = (GLIFNeurons*)pGpuNet->pNeurons;
	//GExpSynapses *pS = (GExpSynapses*)pGpuNet->pSynapses;

	//GLIFNeurons *pNTmp = (GLIFNeurons*)malloc(sizeof(GLIFNeurons));
	//GExpSynapses *pSTmp = (GExpSynapses*)malloc(sizeof(GExpSynapses));
	//checkCudaErrors(cudaMemcpy(pNTmp, pN, sizeof(GLIFNeurons), cudaMemcpyDeviceToHost));
	//checkCudaErrors(cudaMemcpy(pSTmp, pS, sizeof(GExpSynapses), cudaMemcpyDeviceToHost));

	//freeGNeurons(pNTmp);
	//freeGSynapses(pSTmp);


	checkCudaErrors(cudaFree(pTmpNet->nTypes));
	checkCudaErrors(cudaFree(pTmpNet->sTypes));
	free(pTmpNT);
	free(pTmpST);

	checkCudaErrors(cudaFree(pTmpNet->gNeuronNums));
	checkCudaErrors(cudaFree(pTmpNet->gSynapseNums));

	checkCudaErrors(cudaFree(pTmpNet->neuronNums));
	checkCudaErrors(cudaFree(pTmpNet->synapseNums));

	checkCudaErrors(cudaFree(pTmpNet->nOffsets));
	checkCudaErrors(cudaFree(pTmpNet->sOffsets));

	checkCudaErrors(cudaFree(pTmpNet->pNeurons));
	checkCudaErrors(cudaFree(pTmpNet->pSynapses));
	free(pTmpNs);
	free(pTmpSs);
	//checkCudaErrors(cudaFree(pGpuNet));
	free(pTmpNet);

	return 0;
}