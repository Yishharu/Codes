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


#events = os.listdir('/raid3/zl382/Data/Synthetics/')
events = ['REF_modelPICKLES',
          'ULVZ20km_5%vsPICKLES',
          'ULVZ20km_10%vsPICKLES',
          'ULVZ20kmPICKLES']
          
labels = ['REF_model',
          'ULVZ20km_5%vs',
          'ULVZ20km_10%vs',
          'ULVZ20km_20%vs']        
          
colors = ['black',
          'yellow',
          'pink',
          'red']

component = 'BAT'
norm_constant = 5


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

plt.figure(figsize=(11.69,8.27))
for j in range(len(events)):
    dir = '/raid3/zl382/Data/Synthetics/' + events[j] + '/'
    print(dir)
    
    seis = read(dir+'SYN_90.PICKLE',format='PICKLE')
    seistoplot = seis.select(channel = component)[0]
    
    norm = np.max(seistoplot.data)/norm_constant
    
    fmin = [1/30, 1/20, 1/10, 1/5]  
    fmax = [1/10, 1/5, 1, 1]
    
    plot_row = 1
    plot_column = 4
    
    for i in range(plot_column):
        plt.subplot(plot_row, plot_column, i+1)
        print('i=',i)     
            # Loop through seismograms
        for s in range(90,140,3):

            seis = read(dir+'SYN_'+str(s)+'.PICKLE',format='PICKLE') # Read seismogram
            seistoplot = seis.select(channel = component)[0]
            
            Phase = ['S','Sdiff']
            for x in range (0,2):
                if  seis[0].stats.traveltimes[Phase[x]]!=None:
                    phase = Phase[x]          
            # Filter data          
            seistoplot.filter('highpass',freq=fmin[i],corners=2,zerophase=True)
            seistoplot.filter('lowpass',freq=fmax[i],corners=2,zerophase=True)

            plt.xlim([-20, 60])
            plt.ylim([135, 90])
            plt.gca().tick_params(labelsize=10)
            plt.title('frequency band [%i s - %i s]' % (1/fmax[i], 1/fmin[i]),fontsize=10)
            plt.xlabel('Time around ' +phase + ' (s)', fontsize=10)
            if switch_yaxis:
                plt.gca().invert_yaxis() 

            try:
                if s==90:
                    plt.plot(seistoplot.times() - seis[0].stats.traveltimes[phase], seistoplot.data / norm + np.round(seis[0].stats['dist']),color = colors[j],label=labels[j])
                else:
                    plt.plot(seistoplot.times() - seis[0].stats.traveltimes[phase], seistoplot.data / norm + np.round(seis[0].stats['dist']),color = colors[j])              
            except:
                continue
          
            # Plot travel time predictions
            for k in seis[0].stats.traveltimes.keys():
                if seis[0].stats.traveltimes[k] != None:
                    plt.plot(seis[0].stats.traveltimes[k] - seis[0].stats.traveltimes[phase], np.round(seis[0].stats['dist']),'g', marker ='o', markersize=2)
    
    if j==0:
        if i==0:
            plt.ylabel('Distance (deg)')
            
leg = plt.legend(shadow=True,fontsize=8,fancybox=True,framealpha=0.5)
plt.suptitle('Models Together  ' + component, fontsize = 16)  
plt.savefig('/home/zl382/Pictures/waveform/Synthetic/models_together'+component+'velocityreduction.png')
#plt.show()
plt.close('all')