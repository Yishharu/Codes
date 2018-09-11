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
#events = os.listdir('/raid3/zl382/Data/Synthetics/*10km*')
events = ['20170110ALL']# ['ULVZ20kmPICKLES'] #['ULVZ10km_wavefieldPICKLES']
component = 'BHT'
norm_constant = 3
## Plot synthetics

syn = False
real = True  # plot real data
color = False # color by measured travel times
switch_yaxis = True
fmin = [0,1/30,1/20,1/10,1/5,1/2]
fmax = [0,1/20,1/10,1/5,1/2,1]
fmin[0]=1/30 
fmax[0]=1/10
plot_row = 2
plot_column = 3  
dist_min = 30
dist_max = 60

per_norm = False

for event in events:
    plt.figure(figsize=(11.69,8.27))
    dir = '/raid3/zl382/Data/' + event + '/'
    print(dir)
    seislist = glob.glob(dir + '*PICKLE')
    azis = []
    dists = []     
    
    plt.figure(figsize=(11.69,8.27))
    for i in range(plot_row*plot_column):
        if i == 0:
            ax0=plt.subplot(plot_row, plot_column, i+1)
        else:
            plt.subplot(plot_row, plot_column, i+1)
        print('i=',i)       
        # Loop through seismograms
        count = 0
        for s in [920,39,123,171]:#range(0,len(seislist),10):    
            #print(s, '/', len(seislist))          
            seis = read(seislist[s],format='PICKLE') # read seismogram
            s_name = os.path.splitext(os.path.split(seislist[s])[1])[0]
            dists.append(seis[0].stats['dist'])# List all distances
            #    azis.append(seis[0].stats['az'])      # List all azimuths
            #    print('Azimuth: ', seis[0].stats['az'],'Distance: ',seis[0].stats['dist'])
            seistoplot = seis.select(channel = component)[0]           
            # plot synthetics             
            if syn:
                seissyn = seis.select(channel = component)[0]           
            # Plot seismograms
            #print(seis[0].stats.traveltimes['Sdiff'])            
            Phase = ['S','Sdiff']
            for x in range (0,2):
                if  seis[0].stats.traveltimes[Phase[x]]!=None:
                    phase = Phase[x]
            # Filter data    
            seistoplot.filter('bandpass', freqmin=fmin[i],freqmax=fmax[i], zerophase=True)   
            if syn:
                seissyn.filter('highpass', freq=fmin[i],corners=2,zerophase=True)
                seissyn.filter('lowpass',freq=fmax[i],corners=2,zerophase=True)   
                
            if per_norm:
                norm = np.max(seistoplot.data) / norm_constant
            elif count == 0:
                norm = np.max(seistoplot.data) / norm_constant
            count = count+1                 
            plt.plot(seistoplot.timesarray- seis[0].stats.traveltimes[phase], seistoplot.data / norm + np.round(seis[0].stats['dist']),'k')
            plt.text(60,seis[0].stats['dist'],s_name, fontsize = 8)
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
          #  s_name = os.path.splitext(os.path.split(seislist[s])[1])[0]
            #plt.text(200,seis[0].stats['dist'],s_name, fontsize = 8)    
            if i != 10:
                Sdifftime = seis[0].stats.traveltimes[phase]                
                timewindow = 3*1/fmin[i] #    timewindow = 3*2/(fmin[i]+fmax[i]) 
                w0 = np.argmin(np.abs(seistoplot.timesarray-Sdifftime+timewindow/3))            
                w1 = np.argmin(np.abs(seistoplot.timesarray-Sdifftime-timewindow*2/3))
                window_wid = seistoplot.timesarray[w1] - seistoplot.timesarray[w0]
                window_hei = np.max(np.abs(hilbert(seistoplot.data))[w0:w1])/norm
                gca().add_patch(patches.Rectangle((seistoplot.timesarray[w0]-Sdifftime,np.round(seis[0].stats['dist'])-window_hei),window_wid,2*window_hei,alpha = 0.4, color = 'red'))  # width height
                print('window hei: '+ str(window_hei))
        if i == 0:
            plt.ylabel('Distance (deg)')
            
        plt.title('frequency band [%.1f s - %.1f s] ' % (1/fmax[i], 1/fmin[i]),fontsize=10)
        plt.xlabel('Time around ' +phase + ' (s)', fontsize=10)
        plt.xlim([-20, 60])
        plt.ylim([dist_min,dist_max])
        plt.gca().tick_params(labelsize=10)
        if switch_yaxis:
            plt.gca().invert_yaxis()
    plt.suptitle('Event ' + event + ' ' + component, fontsize = 16)  
   # plt.savefig('/home/zl382/Pictures/waveform/Synthetic/'+component+'_'+event+'.png')
    plt.show()
    plt.close('all')