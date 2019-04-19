#include <stdlib.h>
#include <string.h>

#include "GLIFNeurons.h"

void *mallocLIF()
{
	GLIFNeurons * p = (GLIFNeurons*)malloc(sizeof(GLIFNeurons)*1);
	memset(p, 0, sizeof(GLIFNeurons)*1);
	return (void*)p;
}

void *allocLIF(int num)
{
	void *p = mallocLIF();
	allocLIFPara(p, num);
	return p;
}

int freeLIF(void *pCPU, int num)
{
	GLIFNeurons *p = (GLIFNeurons*)pCPU;

	free(p->pRefracStep);
	free(p->pRefracTime);

	free(p->pVm);
	free(p->pCi);
	free(p->pCe);
	free(p->pC_i);
	free(p->pC_e);
	free(p->pV_tmp);
	free(p->pV_i);
	free(p->pV_e);
	free(p->pV_thresh);
	free(p->pV_reset);
	free(p->pV_m);

	free(p);
	return 0;
}

int allocLIFPara(void *pCPU, int num)
{
	GLIFNeurons *p = (GLIFNeurons*)pCPU;

	p->pRefracStep = (int*)malloc(n*sizeof(int));
	p->pRefracTime = (int*)malloc(n*sizeof(int));

	p->pVm = (real*)malloc(n*sizeof(real));
	p->pCi = (real*)malloc(n*sizeof(real));
	p->pCe = (real*)malloc(n*sizeof(real));
	p->pC_i = (real*)malloc(n*sizeof(real));
	p->pC_e = (real*)malloc(n*sizeof(real));
	p->pV_tmp = (real*)malloc(n*sizeof(real));
	p->pV_i = (real*)malloc(n*sizeof(real));
	p->pV_e = (real*)malloc(n*sizeof(real));
	p->pV_thresh = (real*)malloc(n*sizeof(real));
	p->pV_reset = (real*)malloc(n*sizeof(real));
	p->pV_m = (real*)malloc(n*sizeof(real));

	return 0;
}

int freeLIFPara(void *pCPU, int num)
{
	GLIFNeurons *p = (GLIFNeurons*)pCPU;

	free(p->pRefracStep);
	free(p->pRefracTime);

	free(p->pVm);
	free(p->pCi);
	free(p->pCe);
	free(p->pC_i);
	free(p->pC_e);
	free(p->pV_tmp);
	free(p->pV_i);
	free(p->pV_e);
	free(p->pV_thresh);
	free(p->pV_reset);
	free(p->pV_m);

	return 0;
}

int saveLIF(void *pCPU, int num, FILE *f)
{

	GLIFNeurons *p = (GLIFNeurons*)pCPU;
	fwrite(p->pRefracStep, sizeof(int), num, f);
	fwrite(p->pRefracTime, sizeof(int), num, f);

	fwrite(p->pVm, sizeof(real), num, f);
	fwrite(p->pCi, sizeof(real), num, f);
	fwrite(p->pCe, sizeof(real), num, f);
	fwrite(p->pC_i, sizeof(real), num, f);
	fwrite(p->pC_e, sizeof(real), num, f);
	fwrite(p->pV_tmp, sizeof(real), num, f);
	fwrite(p->pV_i, sizeof(real), num, f);
	fwrite(p->pV_e, sizeof(real), num, f);
	fwrite(p->pV_thresh, sizeof(real), num, f);
	fwrite(p->pV_reset, sizeof(real), num, f);
	fwrite(p->pV_m, sizeof(real), num, f);

	return 0;
}

int loadLIF(int num, FILE *f)
{
	GLIFNeurons *p = (GLIFNeurons*)malloc(sizeof(GLIFNeurons));

	fread(p->pRefracStep, sizeof(int), num, f);
	fread(p->pRefracTime, sizeof(int), num, f);

	fread(p->pVm, sizeof(real), num, f);
	fread(p->pCi, sizeof(real), num, f);
	fread(p->pCe, sizeof(real), num, f);
	fread(p->pC_i, sizeof(real), num, f);
	fread(p->pC_e, sizeof(real), num, f);
	fread(p->pV_tmp, sizeof(real), num, f);
	fread(p->pV_i, sizeof(real), num, f);
	fread(p->pV_e, sizeof(real), num, f);
	fread(p->pV_thresh, sizeof(real), num, f);
	fread(p->pV_reset, sizeof(real), num, f);
	fread(p->pV_m, sizeof(real), num, f);

	return p;
}

