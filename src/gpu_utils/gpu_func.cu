/* This program is writen by qp09.
 * usually just for fun.
 * Sat March 12 2016
 */

#include "../../include/GNeuron.h"
#include "../utils/utils.h"
#include "gpu_kernel.h"
#include "gpu_func.h"


int cudaUpdateConstant(void *data, int num, int start_id, BlockSize *pSize)
{
	update_constant_neuron<<<pSize->gridSize, pSize->blockSize>>>((GConstantNeurons*)data, num, start_id);

	return 0;
}

int cudaUpdatePoisson(void *data, int num, int start_id, BlockSize *pSize)
{
	update_poisson_neuron<<<pSize->gridSize, pSize->blockSize>>>((GPoissonNeurons*)data, num, start_id);

	return 0;
}

int cudaUpdateArray(void *data, int num, int start_id, BlockSize *pSize)
{
	update_array_neuron<<<pSize->gridSize, pSize->blockSize>>>((GArrayNeurons*)data, num, start_id);

	return 0;
}

int cudaUpdateLIFE(void *data, int num, int start_id, BlockSize *pSize)
{
	find_life_neuron<<<pSize->gridSize, pSize->blockSize>>>((GLIFENeurons*)data, num, start_id);
	update_life_neuron<<<pSize->gridSize, pSize->blockSize>>>((GLIFENeurons*)data, num, start_id);
	//update_dense_life_neuron<<<pSize->gridSize, pSize->blockSize>>>((GLIFENeurons*)data, num, start_id);

	return 0;
}

int cudaUpdateTJ(void *data, int num, int start_id, BlockSize *pSize)
{
	update_tj_neuron<<<pSize->gridSize, pSize->blockSize>>>((GTJNeurons*)data, num, start_id);

	return 0;
}

int cudaUpdateMax(void *data, int num, int start_id, BlockSize *pSize)
{
	update_max_neuron<<<pSize->gridSize, pSize->blockSize>>>((GMaxNeurons*)data, num, start_id);

	return 0;
}

int cudaUpdateStatic(void *data, int num, int start_id, BlockSize *pSize)
{
	//update_static_hit<<<pSize->gridSize, pSize->blockSize>>>((GStaticSynapses*)data, num, start_id);
	//reset_active_synapse<<<1, 1>>>();
	update_dense_static_hit<<<pSize->gridSize, pSize->blockSize>>>((GStaticSynapses*)data, num, start_id);

	return 0;
}

int addCrossNeurons(int *ids, int num)
{
	add_cross_neuron<<<(num+MAXBLOCKSIZE-1)/MAXBLOCKSIZE, MAXBLOCKSIZE>>>(ids, num);
	return 0;
}


int cudaDeliverNeurons(int *idx2index, int *crossnode_index2idx, int *global_cross_data, int *fired_n_num, int node_num, int neuron_num)
{
	deliver_neurons<<<(neuron_num + MAXBLOCKSIZE-1)/MAXBLOCKSIZE, MAXBLOCKSIZE>>>(idx2index, crossnode_index2idx, global_cross_data, fired_n_num, node_num);

	return 0;
}

BlockSize * getBlockSize(int nSize, int sSize)
{
	BlockSize *ret = (BlockSize*)malloc(sizeof(BlockSize)*TYPESIZE);
	cudaOccupancyMaxPotentialBlockSize(&(ret[Constant].minGridSize), &(ret[Constant].blockSize), update_constant_neuron, 0, nSize); 
	ret[Constant].gridSize = (upzero_else_set_one(nSize) + (ret[Constant].blockSize) - 1) / (ret[Constant].blockSize);

	cudaOccupancyMaxPotentialBlockSize(&(ret[Poisson].minGridSize), &(ret[Poisson].blockSize), update_poisson_neuron, 0, nSize); 
	ret[Poisson].gridSize = (upzero_else_set_one(nSize) + (ret[Poisson].blockSize) - 1) / (ret[Poisson].blockSize);

	cudaOccupancyMaxPotentialBlockSize(&(ret[Array].minGridSize), &(ret[Array].blockSize), update_poisson_neuron, 0, nSize); 
	ret[Array].gridSize = (upzero_else_set_one(nSize) + (ret[Array].blockSize) - 1) / (ret[Array].blockSize);

	cudaOccupancyMaxPotentialBlockSize(&(ret[LIFE].minGridSize), &(ret[LIFE].blockSize), update_life_neuron, 0, nSize); 
	ret[LIFE].gridSize = (upzero_else_set_one(nSize) + (ret[LIFE].blockSize) - 1) / (ret[LIFE].blockSize);

	cudaOccupancyMaxPotentialBlockSize(&(ret[TJ].minGridSize), &(ret[TJ].blockSize), update_life_neuron, 0, nSize); 
	ret[TJ].gridSize = (upzero_else_set_one(nSize) + (ret[TJ].blockSize) - 1) / (ret[TJ].blockSize);

	cudaOccupancyMaxPotentialBlockSize(&(ret[Max].minGridSize), &(ret[Max].blockSize), update_tj_neuron, 0, nSize); 
	ret[Max].gridSize = (upzero_else_set_one(nSize) + (ret[Max].blockSize) - 1) / (ret[Max].blockSize);

	//cudaOccupancyMaxPotentialBlockSize(&(ret[Static].minGridSize), &(ret[Static].blockSize), update_static_hit, 0, sSize); 
	ret[Static].blockSize = 128;
	ret[Static].gridSize = (upzero_else_set_one(nSize) + (ret[Static].blockSize) - 1) / (ret[Static].blockSize);

	return ret;
}
