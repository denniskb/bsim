/* This program is writen by qp09.
 * usually just for fun.
 * Mon December 14 2015
 */


#include "../../third_party/cuda/helper_cuda.h"
#include "GDecideNeurons.h"

int cudaAllocDecide(void *pCpu, void *pGpu, int num)
{
	GDecideNeurons *pGpuNeurons = (GDecideNeurons*)pGpu;
	GDecideNeurons *p = (GDecideNeurons*)pCpu;

	checkCudaErrors(cudaMalloc((void**)&(pGpuNeurons->p_tmp_rate), sizeof(real)*num));
	checkCudaErrors(cudaMemcpy(pGpuNeurons->p_tmp_rate, p->p_tmp_rate, sizeof(real)*num, cudaMemcpyHostToDevice));

	checkCudaErrors(cudaMalloc((void**)&(pGpuNeurons->p_fire_rate), sizeof(real)*num));
	checkCudaErrors(cudaMemcpy(pGpuNeurons->p_fire_rate, p->p_fire_rate, sizeof(real)*num, cudaMemcpyHostToDevice));

	checkCudaErrors(cudaMalloc((void**)&(pGpuNeurons->p_fire_count), sizeof(int)*num));
	checkCudaErrors(cudaMemcpy(pGpuNeurons->p_fire_count, p->p_fire_count, sizeof(int)*num, cudaMemcpyHostToDevice));

	return 0;
}

int cudaFreeDecide(void *pGpu)
{
	GDecideNeurons *pGpuNeurons = (GDecideNeurons*)pGpu;

	checkCudaErrors(cudaFree(pGpuNeurons->p_tmp_rate));
	checkCudaErrors(cudaFree(pGpuNeurons->p_fire_rate));
	checkCudaErrors(cudaFree(pGpuNeurons->p_fire_count));

	return 0;
}
