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
from obspy import UTCDateTime

save_path = '/raid3/zl382/Data/MATLAB/' #'raid3/zl382/Data/MATLAB/' # '/home/zl382/Documents/MATLAB/'
# Set phase to plot
phases = ['Sdiff','Sdiff','Pdiff']
# Set component to plot
components = ['BHT','BHR','BHZ']
# Set models to plot
events=['SHdiff','SVdiff','Pdiff']

#ref_phase = ['SKS','SKKS','SKKKS','SKKKKS']
ref_phase = ['SKKS','SKS']

EQ = '20170110'
# station = '/TA.732A'
dir = '/raid3/zl382/Data/' + EQ + '/'
seislist = glob.glob(dir + '*PICKLE')
count = 0

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
    
#    if (os.path.exists('/raid3/zl382/Data/MATLAB/' + s_name + '_'+'BHT'+'.mat')):
#        continue   
    
    print(str(s)+'/' + str(len(seislist)))
    seisfile = seislist[s]
    seis = read(seisfile, format='PICKLE')         # Read the three component data
    try:
        seis.resample(10)            # resample seems to be important, for the length of data and processing speed~
    except:
        count = count + 1
        print(str(s)+' resample break down!!!!!!!')
        continue
    # Time shift to shift data to reference time   # Important for REAL DATA
    tshift=UTCDateTime(seis[0].stats['starttime']) - UTCDateTime(seis[0].stats['eventtime'])
    
 #   print(s_name)   
    for i in range(len(components)):
        event = events[i]
        phase = phases[i]
        component = components[i]         
        #seisfile = '/raid3/zl382/Data/' + EQ + station + '.PICKLE'
        Sdifftime = seis[0].stats['traveltimes'][phase]    
        if (Sdifftime == None) and (phase == 'Sdiff'):
            phase = 'S'
            Sdifftime = seis[0].stats['traveltimes'][phase]      
        if (Sdifftime == None) and (phase == 'Pdiff'):
            phase = 'P'
            Sdifftime = seis[0].stats['traveltimes'][phase] 
        # print(Sdifftime)
        if (Sdifftime == None):          
            break
#        seis.resample(10)            # resample seems to be important, for the length of data and processing speed~
        tr = seis.select(channel=component)[0]
        
#        w0 = np.argmin(np.abs(tr.times()+tshift-Sdifftime+100))
        for x in range (0,len(ref_phase)):
            if  seis[0].stats.traveltimes[ref_phase[x]]!=None:
                ref_phase_time = seis[0].stats.traveltimes[ref_phase[x]]
                
        if (ref_phase_time == None) or (phase == 'Pdiff'):
            w0 = np.argmin(np.abs(tr.times()+tshift-Sdifftime+80))
        else:
            w0 = np.argmin(np.abs(tr.times()+tshift-ref_phase_time+20))
            
        w1 = np.argmin(np.abs(tr.times()+tshift-Sdifftime-60))
        
        if (w0>w1):
            Sdifftime = None
            break
        
        sio.savemat(save_path + s_name + '_' + component + '.mat', {'data': tr.data[w0:w1], 'times': tr.times()[w0:w1], 'phase': phase})
        #print('w0:w1: ',w0, ':', w1 )        
        stations_components.append(s_name + '_' + component)
        print(s_name + '_' + component + '.mat')
    if (Sdifftime != None):
        sname.append(s_name)
        
sio.savemat(save_path + 'pickle_mat_interface.mat', {'phases': phases, 'components': components, 'stations_components': stations_components, 'sname': sname, 'events':events})
print(str(count)+' resample break')