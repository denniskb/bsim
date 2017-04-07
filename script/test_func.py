#!/usr/bin/python

import math

dt = 1e-4

w = 0.2e-9

tau_m = 10e-3
tau_E = 2e-3
tau_I = 0.6e-3

c_m = 0.2e-9

v_rest = -74e-3

i_offset = 0

rm = tau_m/c_m

C1 = math.exp(-dt/tau_m)
CE = math.exp(-dt/tau_E)
C2 = rm*(1-C1)

i_tmp = i_offset + v_rest/rm

#i_E = w * math.sqrt(CE)

#i_E *= CE


i_E = 7.80507935899e-9
i_I = -2.53944517467e-9

#print i_E * CE

i_E = i_E * math.sqrt(CE)
i_I = i_I * math.sqrt(CE)

vm = -60e-3
v = -56.3520826e-3

i_syn = ((v - C1*vm)/C2 - i_tmp)/math.sqrt(CE)
v_new = (C1*vm + C2 * (i_tmp + i_E + i_I))

print i_syn
print v_new
#print (rm*tau_E/(tau_E - tau_m))


