#!/usr/bin/env python3

import obspy, obspy.signal, os.path, time, glob, shutil, scipy, subprocess, sys
from obspy import read, UTCDateTime
from obspy.core import Stream, Trace

import obspy.signal
import matplotlib.pyplot as plt
import numpy as np
from obspy.io.xseed import Parser
from subprocess import call
import matplotlib.colors as colors
import matplotlib.cm as cm
import shutil
import os
import os.path
from pylab import *
import matplotlib.patches as patches
from scipy.signal import hilbert

event = 'REF_modelPICKLES' #'ULVZ5kmPICKLES' #'REF_modelPICKLES' #'ULVZ20kmPICKLES' #['ULVZ10km_wavefieldPICKLES']
dir = '/raid3/zl382/Data/Synthetics/' + event + '/'
print('Loading data from %s'%(dir))

syn = False
real = True  # plot real data
color = False # color by measured travel times
switch_yaxis = False
per_norm = False
components = ['BAT','BAR','BAZ']
norm_constant = 10
fmin = 1/20
fmax = 1/10
Phase = ['S','Sdiff']

time_min = -20
time_max = 120

azim_min = 40
azim_max = 60

dist_min = 110
dist_max = 120

count = 0
for i,component in enumerate(components):
    plt.subplot(1,3,i+1)    
    seislist = sorted(glob.glob(dir + '*PICKLE'))
    azis = []
    dists = []    
    
    # Loop through seismograms
    for s in range(60,140,1):            
        print('distance %s of %s' %(s, event))
        seis = read(dir+'SYN_'+'%.1f' %(s)+'.PICKLE',format='PICKLE') # Read seismogram
        dists.append(seis[0].stats['dist'])# List all distances
        #    azis.append(seis[0].stats['az'])      # List all azimuths
        #    print('Azimuth: ', seis[0].stats['az'],'Distance: ',seis[0].stats['dist'])
        seistoplot = seis.select(channel = component)[0]           
        # plot synthetics
        if syn:
            seissyn = seis.select(channel = component)[0]           
        # Plot seismograms
        #print(seis[0].stats.traveltimes['Sdiff'])            
        
        # Filter data        
        seistoplot.filter('bandpass', freqmin=fmin,freqmax=fmax, zerophase=True) 
        
        if per_norm:
            norm = np.max(seistoplot.data) / norm_constant
        elif count == 0:
            norm = np.max(seistoplot.data) / norm_constant
        count = count+1
        
        align_time = seis[0].stats.traveltimes['Sdiff'] or seis[0].stats.traveltimes['S']
        plt.plot(seistoplot.times() - align_time, seistoplot.data / norm + seis[0].stats['dist'],'k')
        print('Norm Value: %e' %(norm))

        # Plot travel time predictions
        for k in seis[0].stats.traveltimes.keys():
            if seis[0].stats.traveltimes[k] != None:
                plt.plot(seis[0].stats.traveltimes[k] - align_time, np.round(seis[0].stats['dist']),'g', marker ='o', markersize=4)            
        # Plot the station name
        #  s_name = os.path.splitext(os.path.split(seislist[s])[1])[0]
        #plt.text(200,seis[0].stats['dist'],s_name, fontsize = 8)    

    if i == 0:
        plt.ylabel('Distance (deg)')

    dists = np.array(dists)    
    plt.title(component,fontsize=10)
    plt.xlabel('Time around ' +'S/Sdiff' + ' (s)', fontsize=10)
    plt.xlim([time_min,time_max])
    plt.ylim(dists.min()-4,dists.max()+4)

    plt.gca().tick_params(labelsize=10)
    if switch_yaxis:
        plt.gca().invert_yaxis()
plt.suptitle('Model ' + event + ' ', fontsize = 16)  
# plt.savefig('/home/zl382/Pictures/waveform/Synthetic/'+component+'_'+event+'.png')
plt.show()
