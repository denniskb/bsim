
#include "../../gpu_utils/runtime.h"

#include "GPoisson.h"


__global__ void update_poisson_neuron(GPoissonNeurons *d_neurons, int const num, int const start_id)
{
	for (int idx = blockIdx.x * blockDim.x + threadIdx.x; idx < num; idx += blockDim.x * gridDim.x) {
		if (curand_uniform(&d_neurons->p_state[idx]) < d_neurons->p_rate[idx]) {
			gFireCount[start_id + idx]++;
			gFiredTable[gFiredTableCap*gCurrentIdx + atomicAdd(&(gFiredTableSizes[gCurrentIdx]), 1)] = start_id + idx;
		}
	}
}
