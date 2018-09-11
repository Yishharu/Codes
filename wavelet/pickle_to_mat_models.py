# -*- coding: utf-8 -*-
"""
Created on Wed Dec  6 17:05:19 2017

@author: zl382
"""

import scipy.io as sio
import numpy as np
from obspy import read 
import matplotlib.pyplot as plt


save_path = '/home/zl382/Documents/MATLAB/'
# Set phase to plot
phases = ['Sdiff','Sdiff','Pdiff']
# Set component to plot
components = ['BAT','BAR','BAZ']
# Set distance
distance = 106.0
# Set filename for figure
filename = 'Plots/Sdiff_T_B1.png'
# Set models to plot
#events=['REF_modelPICKLES','ULVZ2kmPICKLES','ULVZ5kmPICKLES']
events=['REF_modelPICKLES','ULVZ2kmPICKLES','ULVZ5kmPICKLES','ULVZ10km_wavefieldPICKLES','ULVZ20kmPICKLES']
# Set model titles
titles = ['SHdiff','SVdiff','Pdiff']

ref_phase = ['SKKS']
# Set center frequencies fo the Fan
# centerfreq = np.linspace(1,25,200)

#centerfreq = 1 + np.log2(np.linspace(1,25,100))*5.168

#centerfreq = np.log(np.linspace(np.power(1.25,1),np.power(1.25,25),500))*5

s = 106.0

time_min = -120
time_max = 180

sio.savemat(save_path + 'pickle_mat_interface.mat', {'phases': phases, 'components': components, 'events': events})

for j in range(len(events)):
    event = events[j]
    
    seisfile = '/raid3/zl382/Data/Synthetics/' +  event + '/SYN_' + str(s) + '.PICKLE'
    seis = read(seisfile, format='PICKLE')
    
    for i in range(len(components)):
        phase = phases[i]
        component = components[i]
        seis.resample(10)
        Sdifftime = seis[0].stats['traveltimes'][phase]
        tr = seis.select(channel=component)[0]
        
        for x in range (0,len(ref_phase)):
            if  seis[0].stats.traveltimes[ref_phase[x]]!=None:
                ref_phase_time = seis[0].stats.traveltimes[ref_phase[x]]
                
#        if (ref_phase_time == None) or (phase == 'Pdiff'):
#            w0 = np.argmin(np.abs(tr.times()-Sdifftime+100))
#        else:
        w0 = np.argmin(np.abs(tr.times()-Sdifftime-time_min))
            
        w1 = np.argmin(np.abs(tr.times()-Sdifftime-time_max))
        
        if (w0>w1):
            Sdifftime = None
            break
    
        sio.savemat(save_path + event +'_'+ component + '.mat', {'data': tr.data[w0:w1], 'times': tr.times()[w0:w1], 'phase': phase, 'event': event})
print('PICKLES processed to mat Done! in ' + save_path)