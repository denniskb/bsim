#pragma once

#include <chrono>

using namespace std::chrono;

class timer
{
	time_point<high_resolution_clock> s;

public:
	timer() { s = high_resolution_clock::now(); }
	double stop()
	{
		return duration_cast<microseconds>( high_resolution_clock::now() - s ).count() * 1e-6;
	}
};