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

f_min = 1.0/10.0
f_max = 1.0

# Set phase to plot
phase = 'Sdiff'
# Set component to plot
component = 'BAT'



event = 'ULVZ20kmPICKLES' # 'ULVZ10km_wavefieldPICKLES' #ULVZ20kmPICKLES' #'REF_modelPICKLES'
s = 105.0
           
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


scalogram = cwt(tr1.data[w0:w1], 0.1, 8, f_min, f_max)


x, y = np.meshgrid(
    tr.times()[w0:w1]-Sdifftime,
    np.logspace(np.log10(f_min), np.log10(f_max), scalogram.shape[0]))

fig, ax = plt.subplots(figsize=(9, 9))
ax.pcolormesh(x, y, np.abs(scalogram), cmap=obspy_sequential)
plt.xlabel('time around ' +phase + ' (s)', fontsize=18)

plt.xlim([-50, 120])
plt.yticks([1/10, 1/5, 1/3,1/2,  1], ['10', '5', '3','2', '1'])

           
plt.show()