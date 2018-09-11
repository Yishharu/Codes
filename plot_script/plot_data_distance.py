#!/usr/bin/env python3

import obspy, obspy.signal, os.path, time, glob, shutil, scipy, subprocess, sys
from obspy import read, UTCDateTime
from obspy.core import Stream, Trace, event
#from obspy.taup.taup import getTravelTimes

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

event = sys.argv[1]
# Plot Parameter
real = True  # plot real data
syn = True
color = False # color by measured travel times
per_norm = False
norm_constant = 2

time_min = -160
time_max = 200

dist_min = 60
dist_max = 130

## Frequencies for filter
fmin = 1/30  #Hz
fmax = 1/10   #Hz

dir = '/raid3/zl382/Data/' + event + '/'
#dir = '/raid2/sc845/ULVZ/Synthetics/OUT_ULVZ10km_1s_mtp500kmPICKLES/'
#dirdump = dir + 'Dump'
#if not os.path.exists(dirdump):
#    os.makedirs(dirdump)
    
seislist = sorted(glob.glob(dir + '*PICKLE'))
norm = None
azis = []
dists = []

count = 0
# Loop through seismograms
for s in range(0,len(seislist),5):

    print(s, '/', len(seislist))
    seis = read(seislist[s],format='PICKLE') # Read seismogram
    dists.append(seis[0].stats['dist'])# List all distances
#    azis.append(seis[0].stats['az'])      # List all azimuths
#    print('Azimuth: ', seis[0].stats['az'],'Distance: ',seis[0].stats['dist'])
    seistoplot = seis.select(channel = 'BHT')[0]
    # plot synthetics
    if syn:
        seissyn = seis.select(channel = 'BXT')[0]
    # Plot seismograms
    plt.subplot(1,1,1)
    
    if seis[0].stats.traveltimes['Sdiff']!=None:
        phase = 'Sdiff'
    else:
        phase = 'S'
    align_time = seis[0].stats.traveltimes[phase]
                    
    # Filter data
    seistoplot.filter('bandpass', freqmin=fmin,freqmax=fmax, zerophase=True)
    if syn:
        seissyn.filter('bandpass', freqmin=fmin,freqmax=fmax, zerophase=True)

    # Time shift to shift data to reference time
    tshift =  seis[0].stats['starttime'] - UTCDateTime(seis[0].stats['eventtime'])
    
    if per_norm:
        norm = np.max(seistoplot.data) / norm_constant
    elif count == 0:
        norm = np.max(seistoplot.data) / norm_constant
    count = count+1


    # Plot with real distances
#    plt.plot(seistoplot.times() + tshift - seis[0].stats.traveltimes[phase], seistoplot.data / norm+ (seis[0].stats['dist']),'k')
    # Plot with round distances
    if real:
        plt.plot(seistoplot.timesarray-align_time, seistoplot.data / norm + np.round(seis[0].stats['dist']),'k')

    if syn:
        plt.plot(seissyn.timesarray-align_time,seissyn.data/norm + np.round(seis[0].stats['dist']),'r')

    # Plot travel time predictions
    for k in seis[0].stats.traveltimes.keys():
        if seis[0].stats.traveltimes[k] != None and k !='S90' and k !='P90':
            plt.plot(seis[0].stats.traveltimes[k]-align_time, np.round(seis[0].stats['dist']),'g', marker ='o', markersize=4)
            plt.text(seis[0].stats.traveltimes[k]-align_time, np.round(seis[0].stats['dist']),k, fontsize = 8)



ax = plt.subplot(1,1,1)
plt.title('Waveform with distance\n Event %s' % event)
plt.ylabel('Distance (deg)')
plt.xlabel('Time around predicted arrival (s)')
plt.xlim([time_min, time_max])
plt.ylim([dist_min, dist_max])

plt.show()
