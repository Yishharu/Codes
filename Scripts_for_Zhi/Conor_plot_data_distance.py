#!/usr/bin/env python3

import obspy, obspy.signal, os.path, glob, scipy, sys
from obspy import read
import matplotlib.pyplot as plt
import numpy as np

event = sys.argv[1]

synthetics = ''
while (synthetics != 'y' and synthetics != 'n'):
   synthetics = input('Do you want to plot synthetics (y/n)? ')
   if (synthetics == 'y'):
      syn = True
   if (synthetics == 'n'):
      syn = False

switch_yaxis = False

def findAlign(timeArray, seisArray):
    iInd = np.searchsorted(timeArray, -20)
    fInd = np.searchsorted(timeArray, 60)
    windowSeis = []
    for i in range(iInd, fInd):
        windowSeis.append(seisArray[i])

    maxInd = np.argmax(windowSeis) + iInd
    return maxInd
 
# Frequencies for filter
fmin = 0.033
fmax = 0.1

dir = 'Data/' + event + '/'
seislist = glob.glob(dir + '/*PICKLE')

### Recorrect to original norm system once the data_selector is working
norm = None
dists = []
xlim = 0.

fig = plt.figure(figsize=(4,12))


# Loop through seismograms
for s in range(len(seislist)):
    print(s + 1, len(seislist))
    seis = read(seislist[s], format='PICKLE')

    # List all distances
    dists.append(seis[0].stats['dist'])
   
    seistoplot = seis.select(channel='BHT')[0]

    if (s == 0):
       xlim = seis[0].stats.traveltimes['S']

    # Plot synthetics
    if syn:
        seissyn = seis.select(channel='BXT')[0]

    # Plot seismograms
    phase = 'S'
    plt.subplot(1,1,1)

    # Filter data
    seistoplot.filter('highpass', freq=fmin, corners=2, zerophase=True)
    seistoplot.filter('lowpass', freq=fmax, corners=2, zerophase=True)
    seistoplot.data = np.gradient(seistoplot.data, seistoplot.stats.delta)

    if syn:
        seissyn.filter('highpass', freq=fmin, corners=2, zerophase=True)
        seissyn.filter('lowpass', freq=fmax, corners=2, zerophase=True)
        seissyn.data = np.gradient(seissyn.data, seissyn.stats.delta)

    # Time shift to shift data to reference time
    tshift = seis[0].stats['starttime'] - seis[0].stats['eventtime']

    seistoplot.times = [x + tshift - seis[0].stats.traveltimes['S'] for x in seistoplot.times()]

    alignInd = findAlign(seistoplot.times, seistoplot.data)

    talign = seistoplot.times[alignInd]

    seistoplot.times = [x - talign for x in seistoplot.times]
    
    if norm == None:
        norm = 1. * np.max(abs(seistoplot.data))
    plt.plot(seistoplot.times, seistoplot.data / norm + np.round((seis[0].stats['dist'])), 'k')

    if syn:
        plt.plot(seissyn.times(), seissyn.data / norm + (seis[0].stats['dist']), 'b')
      
    # Plot travel time predictions
    #for k in seis[0].stats.traveltimes.keys():
    #    if seis[0].stats.traveltimes[k] != None:
    #        plt.plot(seis[0].stats.traveltimes[k], np.round(seis[0].stats['dist']), 'g', marker='o', markersize=5)
    #        plt.text(seis[0].stats.traveltimes[k], np.round(seis[0].stats['dist'])-0.5, k, fontsize=6)  

# Put labels on graphs
plt.subplot(1,1,1)
plt.title(' ')
plt.ylabel('Distance (dg)')
plt.xlabel('Time around predicted arrival (s)')
plt.xlim([-15, 50])
plt.ylim([78, 98])
if switch_yaxis:
    plt.gca().invert_yaxis()

# Save file and show plot
if syn ==  True:
    plt.savefig('Plots/' + event + '/' + 'distance.pdf', bbox_inches='tight')
    plt.savefig('Plots/' + event + '/' + 'distance.eps', format='eps', dpi=1000, bbox_inches='tight')
if syn == False:
    plt.savefig('Plots/' + event + '/' + 'distance_noSyn.pdf', bbox_inches='tight')
    plt.savefig('Plots/' + event + '/' + 'distance_noSyn.eps', format='eps', dpi=1000, bbox_inches='tight')

plt.show()
