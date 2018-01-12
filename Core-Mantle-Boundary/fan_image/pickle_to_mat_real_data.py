# -*- coding: utf-8 -*-
"""
Created on Wed Dec  6 17:05:19 2017

@author: zl382
"""

import scipy.io as sio
import numpy as np
from obspy import read 
import matplotlib.pyplot as plt
import glob
import os.path

save_path = '/raid3/zl382/Data/MATLAB/' #'raid3/zl382/Data/MATLAB/' # '/home/zl382/Documents/MATLAB/'
# Set phase to plot
phases = ['Sdiff','Sdiff','Pdiff']
# Set component to plot
components = ['BHT','BHR','BHZ']
# Set distance
distance = 106
# Set filename for figure
filename = 'Plots/Sdiff_T_B1.png'
# Set models to plot
events=['SHdiff','SVdiff','Pdiff']

EQ = '20100320'
# station = '/TA.732A'
dir = '/raid3/zl382/Data/' + EQ + '/'
seislist = glob.glob(dir + '*PICKLE')

#'OUT_REF_1s_mtp500kmPICKLES','OUT_ULVZ20km_1s_mtp500kmPICKLES','ULVZ10km_1sPICKLES','OUT_ULVZ5km_1s_mtp500kmPICKLES']
# Set model titles
#titles = ['a. No ULVZ','b. 20 km ULVZ','c. 10 km ULVZ','d. 5 km ULVZ']
# Set center frequencies fo the Fan
# centerfreq = np.linspace(1,25,200)

#centerfreq = 1 + np.log2(np.linspace(1,25,100))*5.168

#centerfreq = np.log(np.linspace(np.power(1.25,1),np.power(1.25,25),500))*5

stations_components = []
sname = []

for s in range(0,len(seislist),1):
    s_name = os.path.splitext(os.path.split(seislist[s])[1])[0] 
    print(str(s)+'/' + str(len(seislist)))
    Sdiff_exist = True
 #   print(s_name)   
    for i in range(len(components)):
        if (Sdiff_exist == False):
            break
        event = events[i]
        phase = phases[i]
        component = components[i]
        seisfile = seislist[s]  
        #seisfile = '/raid3/zl382/Data/' + EQ + station + '.PICKLE'
        seis = read(seisfile, format='PICKLE')        
        Sdifftime = seis[0].stats['traveltimes'][phase]
        try:        
            seis.resample(10)            # resample seems to be important, for the length of data and processing speed~
        except:
            break
        # print(Sdifftime)
        if (Sdifftime == None):
            Sdiff_exist = False
            break
        tr = seis.select(channel=component)[0]
        
        w0 = np.argmin(np.abs(tr.times()-Sdifftime+100))
        w1 = np.argmin(np.abs(tr.times()-Sdifftime-190))
        
        sio.savemat(save_path + s_name + '_' + component + '.mat', {'data': tr.data[w0:w1], 'times': tr.times()[w0:w1], 'phase': phase})
        stations_components.append(s_name+'_'+component)
        print(s_name + '_' + component + '.mat')

    if (Sdiff_exist):  
        sname.append(s_name)
sio.savemat(save_path + 'pickle_mat_interface.mat', {'phases': phases, 'components': components, 'stations_components': stations_components, 'sname': sname, 'events':events})
