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
phases = ['SKS','SKKS','Sdiff']
# Set component to plot
components = ['BAT','BAR','BAZ']
# Set distance
distance = 106
# Set filename for figure
filename = 'Plots/Sdiff_T_B1.png'
# Set models to plot

events=['REF_modelPICKLES','ULVZ2kmPICKLES','ULVZ5kmPICKLES']



# Set model titles
titles = ['SHdiff','SVdiff','Pdiff']

ref_phase = ['SKKKKS','SKKKS','SKKS','SKS']
# Set center frequencies fo the Fan
# centerfreq = np.linspace(1,25,200)

#centerfreq = 1 + np.log2(np.linspace(1,25,100))*5.168

#centerfreq = np.log(np.linspace(np.power(1.25,1),np.power(1.25,25),500))*5

s = 106

sio.savemat(save_path + 'pickle_mat_interface.mat', {'phases': phases, 'components': components, 'events': events})

for j in range(len(events)):
    event = events[j]
    
    seisfile = '/raid3/zl382/Data/Synthetics/' +  event + '/SYN_' + str(s) + '.PICKLE'
    seis = read(seisfile, format='PICKLE')
    
    for i in range(len(components)):
        phase = phases[i]
        component = components[i]
        seis.resample(10)
        Sdifftime = seis[0].stats['traveltimes']['Sdiff']
        tr = seis.select(channel=component)[0]
        

        w0 = np.argmin(np.abs(tr.times()-Sdifftime+20))
            
        w1 = np.argmin(np.abs(tr.times()-Sdifftime-30))
        
    
        sio.savemat(save_path + event +'_'+ component + '.mat', {'data': tr.data[w0:w1], 'times': tr.times()[w0:w1], 'phase': phase, 'event': event})