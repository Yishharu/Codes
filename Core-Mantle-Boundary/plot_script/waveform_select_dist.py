#!/usr/bin/env python3

import obspy, obspy.signal, os.path, time, glob, shutil, scipy, subprocess, sys
from obspy import read, UTCDateTime
from obspy.core import Stream, Trace, event
from obspy.taup.taup import getTravelTimes

import obspy.signal
import matplotlib.pyplot as plt
import numpy as np
from obspy.io.xseed import Parser
from obspy.clients.arclink import Client as ARCLINKClient
from obspy.clients.fdsn import Client as IRISClient
from subprocess import call
from obspy.taup.taup import getTravelTimes
import matplotlib.colors as colors
import matplotlib.cm as cm
import shutil
import os
import os.path


#event = sys.argv[1]
event='20100320'

## Plot synthetics
synthetics = ''
while (synthetics != 'y' and synthetics != 'n'):
    synthetics = input('Do you want to plot synthetics (y/n)?')
    if (synthetics == 'y'):
        syn = True
    if (synthetics == 'n'):
        syn = False

real = True  # plot real data
color = False # color by measured travel times
switch_yaxis = True


## Frequencies for filter
fmin = 0.05  #Hz
fmax = 0.1   #Hz

dir = '/raid3/zl382/Data/' + event + '/'
dirdump = dir + 'Dump'
if not os.path.exists(dirdump):
    os.makedirs(dirdump)
    
seislist = sorted(glob.glob(dir + '*PICKLE'))
norm = None
azis = []
dists = []


# Loop through seismograms
for s in range(0,len(seislist),1):

    print(s, '/', len(seislist))
    seis = read(seislist[s],format='PICKLE') # Read seismogram
    dists.append(seis[0].stats['dist'])   # List all distances
    azis.append(seis[0].stats['az'])      # List all azimuths
    print('Azimuth: ', seis[0].stats['az'],'Distance: ',seis[0].stats['dist'])
    seistoplot = seis.select(channel = 'BHT')[0]

    # plot synthetics
    if syn:
        seissyn = seis.select(channel = 'BXT')[0]

    # Plot seismograms
    print(seis[0].stats.traveltimes['Sdiff'])

    Phase = ['Sdiff', 'S']
    for x in range (0,2):
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
    tshift = seis[0].stats['starttime'] - seis[0].stats['eventtime']

    print('max',np.max(seistoplot.times()))

    if real:
        norm = None
        if norm == None:
            norm = 1.* np.max(abs(seistoplot.data)) / 2.7
        

    # Plot with real distances
#    plt.plot(seistoplot.times() + tshift - seis[0].stats.traveltimes[phase], seistoplot.data / norm+ (seis[0].stats['dist']),'k')
    # Plot with round distances
    plt.plot(seistoplot.times() + tshift - seis[0].stats.traveltimes[phase], seistoplot.data / norm + np.round(seis[0].stats['dist']),'k')

    if syn:
        if norm == None:
            norm = 20.*np.max(seissyn.data)
        plt.plot(seissyn.times() - seis[0].stats.traveltimes[phase],seissyn.data/norm + np.round(seis[0].stats['dist']),'b')
        plt.xlim([-20,200])

    # Plot travel time predictions
    for k in seis[0].stats.traveltimes.keys():
        if seis[0].stats.traveltimes[k] != None:
            plt.plot(seis[0].stats.traveltimes[k] - seis[0].stats.traveltimes[phase], np.round(seis[0].stats['dist']),'g', marker ='o', markersize=4)

    # Plot the station name
    s_name = os.path.splitext(os.path.split(seislist[s])[1])[0]
    plt.text(200,seis[0].stats['dist'],s_name, fontsize = 8)


ax = plt.subplot(1,1,1)
plt.title('Waveform with distance')
plt.ylabel('Distance (deg)')
plt.xlabel('Time around predicted arrival (s)')
plt.xlim([-20, 200])
plt.ylim([126, 80])
if switch_yaxis:
    plt.gca().invert_yaxis()

# Hightlight the selected waveform
for s in range(400,len(seislist),1):
    s_name = os.path.splitext(os.path.split(seislist[s])[1])[0]
    print(s_name, 'Trace#', s, '/', len(seislist))
    seis = read(seislist[s],format='PICKLE') # Read seismogram
    dists.append(seis[0].stats['dist'])   # List all distances
    azis.append(seis[0].stats['az'])      # List all azimuths
    print('Azimuth: ', seis[0].stats['az'],'Distance: ',seis[0].stats['dist'])
    seistoplot = seis.select(channel = 'BHT')[0]




    # Plot seismograms
    print('Predicted Sdiff time: ', seis[0].stats.traveltimes['Sdiff'])
    print('Predicted S time: ', seis[0].stats.traveltimes['S'])

    Phase = ['Sdiff', 'S']
    for x in range (0,2):
        if  seis[0].stats.traveltimes[Phase[x]]!=None:
            phase = Phase[x]

    # Filter data
    seistoplot.filter('highpass',freq=fmin,corners=2,zerophase=True)
    seistoplot.filter('lowpass',freq=fmax,corners=2,zerophase=True)


    # Time shift to shift data to reference time
    tshift = seis[0].stats['starttime'] - seis[0].stats['eventtime']

    print('max',np.max(seistoplot.times()))

    # Plot with real distances
#    [tr] = ax.plot(seistoplot.times() + tshift - seis[0].stats.traveltimes[phase], seistoplot.data / norm + (seis[0].stats['dist']),'r')
    # Plot with round distances

    if real:
        norm = None
        if norm == None:
            norm = 1.* np.max(abs(seistoplot.data)) / 2.7
            
    [tr] = ax.plot(seistoplot.times() + tshift - seis[0].stats.traveltimes[phase], seistoplot.data / norm + np.round(seis[0].stats['dist']),'r')

    plt.show(block=False)


    likeness = ''
    while (likeness != 'y' and likeness != 'n'):
        likeness = input('Do you like the waveform (y/n)?')
        if (likeness == 'y'):
            like = True
            if (s >= len(seislist)):
                print('This is the last waveform')
        if (likeness == 'n'):
            like = False
            shutil.move(seislist[s],dirdump)
            if (s >= len(seislist)):
                print('This is the last waveform')
                
    tr.set_visible(False)
    plt.draw()
