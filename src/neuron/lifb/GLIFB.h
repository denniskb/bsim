
#include "GLIFEBNeurons.h"

__global__ void find_lifeb_neuron(GLIFEBNeurons *d_neurons, int num, int start_id);
__global__ void update_lifeb_neuron(GLIFEBNeurons *d_neurons, int num, int start_id);
__global__ void update_all_lifeb_neuron(GLIFEBNeurons *d_neurons, int num, int start_id);
__global__ void update_dense_lifeb_neuron(GLIFEBNeurons *d_neurons, int num, int start_id);

