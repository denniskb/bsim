/* This header file is writen by qp09
 * usually just for fun
 * Thu October 22 2015
 */
#ifndef NEURONBASE_H
#define NEURONBASE_H

#include "../base/constant.h"
#include "../base/Base.h"

class SynapseBase;

class NeuronBase : public Base {
public:
	NeuronBase();
	virtual ~NeuronBase() = 0;

	virtual void monitorOn();

	virtual bool isFired();

	virtual int fire();
	virtual int recv(real I) = 0;

	virtual SynapseBase *addSynapse(real weight, real delay, SpikeType type, real tau, NeuronBase *dst);
protected:
	bool fired;
	bool monitored;
};

#endif /* NEURONBASE_H */
