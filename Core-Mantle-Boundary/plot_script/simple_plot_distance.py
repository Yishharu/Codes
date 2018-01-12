#!/usr/bin/env python3

import obspy, obspy.signal, os.path, time, glob, shutil, scipy, subprocess, sys
from obspy import read, UTCDateTime
from obspy.core import Stream, Trace, event
from obspy.taup.taup import getTravelTimes

import obspy.signal
import matplotlib.pyplot as plt
import numpy as np
from obspy.io.xseed import Parser
from subprocess import call
from obspy.taup.taup import getTravelTimes
import matplotlib.colors as colors
import matplotlib.cm as cm
import shutil
import os
import os.path


# event = sys.argv[1]

syn = False

real = True  # plot real data
color = False # color by measured travel times
switch_yaxis = True


## Frequencies for filter
fmin = 0.03  #Hz
fmax = 1   #Hz

#dir = '/raid3/zl382/Data/' + event + '/'
dir = '/raid3/zl382/Data/Synthetics/OUT_ULVZ20km_1s_mtp500kmPICKLES/'

    
seislist = sorted(glob.glob(dir + '*PICKLE'))
norm = None
azis = []
dists = []


# Loop through seismograms
for s in range(0,len(seislist),1):

    print(s, '/', len(seislist))
    seis = read(seislist[s],format='PICKLE') # Read seismogram
    dists.append(seis[0].stats['dist'])   # List all distances
#    azis.append(seis[0].stats['az'])      # List all azimuths
#    print('Azimuth: ', seis[0].stats['az'],'Distance: ',seis[0].stats['dist'])
    seistoplot = seis.select(channel = 'BAT')[0]

    # Plot seismograms


    Phase = ['SKKS','S','Sdiff']
    for x in range(len(Phase)):
        if  seis[0].stats.traveltimes[Phase[x]]!=None:
            phase = Phase[x]
    plt.subplot(1,1,1)

    # Filter data
    seistoplot.filter('highpass',freq=fmin,corners=2,zerophase=True)
    seistoplot.filter('lowpass',freq=fmax,corners=2,zerophase=True)
    if syn:
        seissyn.filter('highpass', freq=fmin,corners=2,zerophase=True)
        seissyn.filter('lowpass',freq=fmax,corners=2,zerophase=True)

    # Time shift to shift data to reference time
    tshift = seis[0].stats.traveltimes[phase]

    print('max',np.max(seistoplot.times()))

    if real:
        norm = None
        if norm == None:
            norm = 1.* np.max(abs(seistoplot.data)) / 10.0
        

    # Plot with real distances
    plt.plot(seistoplot.times() - tshift, seistoplot.data / norm+ (seis[0].stats['dist']),'k')
    # Plot with round distances
   # plt.plot(seistoplot.times() + tshift, seistoplot.data / norm + np.round(seis[0].stats['dist']),'k')



    # Plot travel time predictions
    for k in seis[0].stats.traveltimes.keys():
        if seis[0].stats.traveltimes[k] != None:
            if k == 'S':
                d1, = plt.plot(seis[0].stats.traveltimes[k] - tshift, seis[0].stats['dist'],'r', marker ='o', markersize=4, label = 'S')
            elif k == 'Sdiff':
                d2, = plt.plot(seis[0].stats.traveltimes[k] - tshift, seis[0].stats['dist'],'m', marker ='o', markersize=4, label = 'Sdiff')
            elif k == 'P':
                d3, = plt.plot(seis[0].stats.traveltimes[k] - tshift, seis[0].stats['dist'],'b', marker ='o', markersize=4, label = 'P')
            elif k == 'Pdiff':
                d4, = plt.plot(seis[0].stats.traveltimes[k] - tshift, seis[0].stats['dist'],'c', marker ='o', markersize=4, label = 'Pdiff')
            elif k == 'SKS' or 'SKKS' or 'SKKKS':
                d5, = plt.plot(seis[0].stats.traveltimes[k] - tshift, seis[0].stats['dist'],'y', marker ='o', markersize=4, label = 'SKS and SKKS and SKKKS')


    # Plot the station name
    s_name = os.path.splitext(os.path.split(seislist[s])[1])[0]
    plt.text(620,seis[0].stats['dist'], s_name, fontsize = 8)


ax = plt.subplot(1,1,1)
plt.legend(handles = [d1, d2, d3, d4, d5], labels = ['S', 'Sdiff', 'P', 'Pdiff', 'SKS and SKKS and SKKKS'], loc = 'upper left', fontsize = 'x-small')
plt.title('Waveform with distance\n Event %s' % dir)
plt.ylabel('Distance (deg)')
plt.xlabel('Time around predicted arrival (s)')
plt.xlim([-400, 600])
plt.ylim([150, 79])
if switch_yaxis:
    plt.gca().invert_yaxis()


plt.show()
