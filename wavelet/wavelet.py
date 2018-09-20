#!/usr/bin python3

import obspy
import obspy.signal
from obspy import read
from obspy.core import Stream
from obspy.core import Trace
from obspy.core import event
from obspy import UTCDateTime
from obspy.imaging.cm import obspy_sequential
from obspy.signal.tf_misfit import cwt

import matplotlib.pyplot as plt
import os.path
import time
import glob
import shutil
import numpy as np
import sys
import matplotlib.colors as colors
import matplotlib.cm as cm
import matplotlib.pyplot as plt

plt.figure(figsize=(11,7))

if_norm = False

f_min = 1.0/35.0
f_max = 1.0

time_min = -120
time_max = 70

# Set phase to plot
phase = 'Sdiff'
# Set component to plot
component = 'BAT'
# Set distance
distance = 104.0
# Set filename for figure
filename = 'Plots/Sdiff_T_B1.png'
# Set models to plot
events=['REF_modelPICKLES','ULVZ2kmPICKLES','ULVZ5kmPICKLES']  #'REF_modelPICKLES','ULVZ2kmPICKLES','REF_modelPICKLES','ULVZ2kmPICKLES','ULVZ5kmPICKLES']#
# Set model titles
titles = ['No ULVZ','2 km ULVZ',  '5 km ULVZ']

for i in range(len(events)):
       # Initialize plot for each model
       if i ==0:
              ax=plt.subplot(1,3,i+1)
       else:
              ax=plt.subplot(1,3,i+1)
       event=events[i]

       for s in [distance]: 
           
           # Load file
           seisfile = '/raid3/zl382/Data/Synthetics/' +  event + '/SYN_' + str(s) + '.PICKLE'
           seis = read(seisfile,format='PICKLE')
         #  seis.resample(10)   # Resampling makes things quicker

           Sdifftime = seis[0].stats['traveltimes'][phase] # find time of phase

           tr = seis.select(channel=component)[0]
           w0 = np.argmin(np.abs(tr.times()-Sdifftime-time_min))
           w1 = np.argmin(np.abs(tr.times()-Sdifftime-time_max))

           # Copy trace
           trf = tr.copy()
           trf = trf.filter('bandpass', freqmin=1/40.,freqmax=1/10., zerophase=True)
           # Plot reference phase with wide filter
           # plt.plot(tr.times()[w0:w1]-Sdifftime,tr1.data[w0:w1]/np.max(np.abs(tr1.data[w0:w1])),'k')


           scalogram = cwt(tr.data[w0:w1], tr.stats.delta, 8, f_min, f_max)
           

           x, y = np.meshgrid(
               tr.times()[w0:w1]-Sdifftime,
               np.logspace(np.log10(f_min), np.log10(f_max), scalogram.shape[0]))
           
           if if_norm:
               norm = np.reshape(np.abs(scalogram).max(1),(-1,1))
               ax.pcolormesh(x, y, np.abs(scalogram)/norm, cmap=obspy_sequential)
           else:
               ax.pcolormesh(x, y, np.abs(scalogram), cmap=obspy_sequential)           
           
           plt.xlabel('time around ' +phase + ' (s)', fontsize=18)
           if i ==0:
               plt.ylabel('Period (s)',fontsize=18)
           ax.set_yscale('log')
           ax.set_ylim(f_min, f_max)
          # ax.set_xlim([-40, 180])
           plt.yticks([1/30, 1/20, 1/10, 1/5, 1/3, 1/2, 1], ['30', '20', '10', '5', '3', '2', '1'])
           plt.title(titles[i],fontsize=20)
           ax2 = ax.twinx()
           ax2.plot(trf.times()[w0:w1]-Sdifftime, trf.data[w0:w1]/np.max(np.abs(trf.data[w0:w1])),'k')
           ax2.set_ylim([-1,50])
           ax2.set_yticklabels([])
           plt.xlim([time_min,time_max])
           
plt.show()
