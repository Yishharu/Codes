# -*- coding: utf-8 -*-
"""
Created on Wed Dec  6 11:56:01 2017

@author: zl382
"""

#!/usr/bin python3

import obspy
from obspy import read
from obspy.core import Stream
from obspy.core import Trace
from obspy.core import event
from obspy import UTCDateTime
from obspy.imaging.cm import obspy_sequential
from obspy.signal.tf_misfit import cwt

import pywt
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

f_min = 1.0/50.0
f_max = 1.0

# Set phase to plot
phase = 'Sdiff'
# Set component to plot
component = 'BAT'
# Set distance
distance = 106
# Set filename for figure
filename = 'Plots/Sdiff_T_B1.png'
# Set models to plot
events=['OUT_REF_1s_mtp500kmPICKLES','OUT_ULVZ20km_1s_mtp500kmPICKLES','OUT_ULVZ5km_1s_mtp500kmPICKLES']
# Set model titles
titles = ['a. No ULVZ','b. 20 km ULVZ',  'c. 5 km ULVZ']
# Set center frequencies for the Fan
centerfreq = np.linspace(2,50,20)


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
           seis.resample(10)   # Resampling makes things quicker

           Sdifftime = seis[0].stats['traveltimes'][phase] # find time of phase

           tr = seis.select(channel=component)[0]
           w0 = np.argmin(np.abs(tr.times()-Sdifftime+100))
           w1 = np.argmin(np.abs(tr.times()-Sdifftime-190))

           # Copy trace
           tr1 = tr.copy()
           #tr1 = tr1.filter('bandpass', freqmin=1/40.,freqmax=1/10.)
           # Plot reference phase with wide filter
           # plt.plot(tr.times()[w0:w1]-Sdifftime,tr1.data[w0:w1]/np.max(np.abs(tr1.data[w0:w1])),'k')


           scalogram = cwt(tr1.data[w0:w1], tr.stats.delta, 8, f_min, f_max)
           

           x, y = np.meshgrid(
               tr.times()[w0:w1]-Sdifftime,
               np.logspace(np.log10(f_min), np.log10(f_max), scalogram.shape[0]))

           ax.pcolormesh(x, y, np.abs(scalogram), cmap=obspy_sequential)
           plt.xlabel('time around ' +phase + ' (s)', fontsize=18)
           if i ==0:
               plt.ylabel(r'(centre frequency)$^{-1}$ (s)',fontsize=18)
           ax.set_yscale('log')
           ax.set_ylim(f_min, f_max)
           plt.xlim([-40, 180])
           plt.yticks([1/50, 1/20, 1/10, 1/5, 1/3, 1], ['50', '20', '10', '5', '3', '1'])
           plt.title(titles[i],fontsize=20)

           
plt.show()