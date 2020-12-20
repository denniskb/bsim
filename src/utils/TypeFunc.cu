/* This file is generated by scripts automatively.
 * do not change it by hand.
 */

#include "../gpu_utils/gpu_func.h"

#include "../../include/GNeuron.h"
#include "../../include/GSynapse.h"
#include "../utils/TypeFunc.h"

int (*cudaAllocType[])(void *, void *, int) = { cudaAllocConstant, cudaAllocPoisson, cudaAllocArray, cudaAllocDecide, cudaAllocFFT, cudaAllocMem, cudaAllocMax, cudaAllocLIFE, cudaAllocTJ, cudaAllocStatic, cudaAllocLIFEB};

int (*cudaFreeType[])(void *) = { cudaFreeConstant, cudaFreePoisson, cudaFreeArray, cudaFreeDecide, cudaFreeFFT, cudaFreeMem, cudaFreeMax, cudaFreeLIFE, cudaFreeTJ, cudaFreeStatic, cudaFreeLIFEB};

int (*cudaUpdateType[])(void *, int, int, BlockSize*) = { cudaUpdateConstant, cudaUpdatePoisson, cudaUpdateArray, cudaUpdateDecide, cudaUpdateFFT, cudaUpdateMem, cudaUpdateMax, cudaUpdateLIFE, cudaUpdateTJ, cudaUpdateStatic, cudaUpdateLIFEB};

