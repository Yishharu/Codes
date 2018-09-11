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
events =['20100320ALL'] #['ULVZ20kmPICKLES'] #['ULVZ10km_wavefieldPICKLES']
component = 'BHT'
norm_constant = 2   #amplfy factor
## Plot synthetics
synthetics = ''
#while (synthetics != 'y' and synthetics != 'n'):
#    synthetics = input('Do you want to plot synthetics (y/n)?')
#    if (synthetics == 'y'):
#        syn = True
#    if (synthetics == 'n'):
#        syn = False
syn = False
real = True  # plot real data
color = False # color by measured travel times
switch_yaxis = True
for event in events:
    plt.figure(figsize=(11.69,8.27))
    dir = '/raid3/zl382/Data/' + event + '/'
    print(dir)
    #dir = '/raid2/sc845/ULVZ/Synthetics/OUT_ULVZ10km_1s_mtp500kmPICKLES/'
    #dirdump = dir + 'Dump'
    #if not os.path.exists(dirdump):
    #    os.makedirs(dirdump)      
    seislist = sorted(glob.glob(dir + '*PICKLE'))
    azis = []
    dists = []    
    seis = read(dir+'IW.FLWY.PICKLE',format='PICKLE')
    seistoplot = seis.select(channel = component)[0]    
    norm = np.max(seistoplot.data)/norm_constant    
    fmin = [1/100, 1/100, 1/50, 1/(2.7*1.2)]  
    fmax = [1/1, 1/1, 1/1, 1/(2.7*0.8)]    
    plot_row = 1
    plot_column = 4   
    plt.figure(figsize=(11.69,8.27))
    for i in range(plot_column):
        if i == 0:
            ax0=plt.subplot(plot_row, plot_column, i+1)
        else:
            plt.subplot(plot_row, plot_column, i+1)
        print('i=',i)       
            # Loop through seismograms  
        for s in range(0,len(seislist),5):   
            #print(s, '/', len(seislist))
            seis = read(seislist[s],format='PICKLE') # read seismogram            
            dists.append(seis[0].stats['dist'])# List all distances
            azis.append(seis[0].stats['az'])      # List all azimuths
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
            tshift = 0#seis[0].stats['starttime'] - UTCDateTime(seis[0].stats['eventtime'])   
            if i == 0:
                plt.plot(seistoplot.times() + tshift - seis[0].stats.traveltimes[phase], seistoplot.data/norm + seis[0].stats['az'],'k')
                continue                   
            # Filter data            
            seistoplot.filter('highpass',freq=fmin[i],corners=2,zerophase=True)
            seistoplot.filter('lowpass',freq=fmax[i],corners=2,zerophase=True)
            if syn:
                seissyn.filter('highpass', freq=fmin[i],corners=2,zerophase=True)
                seissyn.filter('lowpass',freq=fmax[i],corners=2,zerophase=True)            
            # Time shift to shift data to reference time
            tshift = seis[0].stats['starttime'] - UTCDateTime(seis[0].stats['eventtime'])           
            #print('max',np.max(seistoplot.times()))()       
            # Plot with real distances
            #    plt.plot(seistoplot.times() + tshift - seis[0].stats.traveltimes[phase], seistoplot.data / norm+ (seis[0].stats['dist']),'k')
            # Plot with round distances
            plt.plot(seistoplot.times() + tshift - seis[0].stats.traveltimes[phase], seistoplot.data/norm + seis[0].stats['az'],'k')
            if syn:
                if norm == None:
                    norm = 20.*np.max(seissyn.data)
                    plt.plot(seissyn.times() - seis[0].stats.traveltimes[phase],seissyn.data/norm + np.round(seis[0].stats['az']),'b')
                    plt.xlim([-20,200])           
            # Plot travel time predictions
            for k in seis[0].stats.traveltimes.keys():
                if seis[0].stats.traveltimes[k] != None:
                    plt.plot(seis[0].stats.traveltimes[k] - seis[0].stats.traveltimes[phase], seis[0].stats['az'],'g', marker ='o', markersize=4)            
            # Plot the station name
          #  s_name = os.path.splitext(os.path.split(seislist[s])[1])[0]
            #plt.text(200,seis[0].stats['dist'],s_name, fontsize = 8)    
            if i != 10:
                Sdifftime = seis[0].stats.traveltimes[phase]               
                timewindow = 3*(1/fmin[i])           
                w0 = np.argmin(np.abs(seistoplot.times()+tshift-Sdifftime+timewindow/3))            
                w1 = np.argmin(np.abs(seistoplot.times()+tshift-Sdifftime-timewindow*2/3))
                window_wid = seistoplot.times()[w1] - seistoplot.times()[w0]
                window_hei = np.max(np.abs(hilbert(seistoplot.data[w0:w1])))/norm
#                test_w0 = np.argmin(np.abs(seistoplot.times()-Sdifftime+(-1)))            
#                test_w1 = np.argmin(np.abs(seistoplot.times()-Sdifftime-149))     
#                test_window_hei = np.max(np.abs(hilbert(seistoplot.data[test_w0:test_w1])))/norm
#                print('Window difference: '+str( (test_window_hei-window_hei)/window_hei))
                gca().add_patch(patches.Rectangle((seistoplot.times()[w0]+tshift-Sdifftime,seis[0].stats['az']-window_hei),window_wid,2*window_hei,alpha = 0.4, color = 'red'))  # width height
        if i == 0:
            plt.ylabel('Distance (deg)')
            
        plt.title('frequency band [%i.1f s - %.1f s]' % (1/fmax[i], 1/fmin[i]),fontsize=10)
        plt.xlabel('Time around ' +phase + ' (s)', fontsize=10)
        plt.xlim([-500, 500])
        plt.ylim([0, 180])
        plt.gca().tick_params(labelsize=10)
        if switch_yaxis:
            plt.gca().invert_yaxis()
    plt.suptitle('Model ' + event + ' ' + component, fontsize = 16)  
   # plt.savefig('/home/zl382/Pictures/waveform/Synthetic/'+component+'_'+event+'.png')
    plt.show()
    plt.close('all')