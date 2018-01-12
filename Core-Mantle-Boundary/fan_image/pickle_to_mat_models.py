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
phase = 'Pdiff'
# Set component to plot
component = 'BAZ'
# Set distance
distance = 106
# Set filename for figure
filename = 'Plots/Sdiff_T_B1.png'
# Set models to plot
events=['OUT_REF_1s_mtp500kmPICKLES','OUT_ULVZ20km_1s_mtp500kmPICKLES','OUT_ULVZ10km_1s_mtp500kmPICKLES','OUT_ULVZ5km_1s_mtp500kmPICKLES']
# Set model titles
titles = ['a. No ULVZ','b. 20 km ULVZ','c. 10 km ULVZ','d. 5 km ULVZ']
# Set center frequencies fo the Fan
# centerfreq = np.linspace(1,25,200)

#centerfreq = 1 + np.log2(np.linspace(1,25,100))*5.168

#centerfreq = np.log(np.linspace(np.power(1.25,1),np.power(1.25,25),500))*5

s = 106

sio.savemat(save_path + 'pickle_mat_interface.mat', {'phase': phase, 'component': component, 'events': events})

for i in range(len(events)):
    event=events[i]
    seisfile = '/raid3/zl382/Data/Synthetics/' +  event + '/SYN_' + str(s) + '.PICKLE'
    seis = read(seisfile, format='PICKLE')
    seis.resample(10)
    Sdifftime = seis[0].stats['traveltimes'][phase]
    tr = seis.select(channel=component)[0]

    w0 = np.argmin(np.abs(tr.times()-Sdifftime+100))
    w1 = np.argmin(np.abs(tr.times()-Sdifftime-190))

    sio.savemat(save_path + event + '.mat', {'data': tr.data[w0:w1], 'times': tr.times()[w0:w1], 'phase': phase, 'events': events})