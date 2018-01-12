#!/usr/bin python3

import scipy.io as sio
from scipy import signal
import obspy
from obspy import read
from obspy.core import Stream
from obspy.core import Trace
from obspy.core import event
from obspy import UTCDateTime
import obspy.signal
import matplotlib.pyplot as plt
import os.path
import time
import glob
import shutil
import numpy as np
import sys
import matplotlib.colors as colors
import matplotlib.cm as cm
import matplotlib
#matplotlib.rcParams.update({'font.size':20}) # Sets fontsize in figure


## Norm
normlization = ''
while (normlization != 'y' and normlization != 'n'):
    normlization = input('Do you want to norm (y/n)?')
    if (normlization == 'y'):
        if_norm = True
    if (normlization == 'n'):
        if_norm = False

sig_freq = [12.0, 18.0, 5.0]     # Second, Hz^-1   
# Set phase to plot
phase = 'Sdiff'
# Set component to plot
component = 'BAT'
# Set distance
distance = 106
# Set models to plot
events=['OUT_REF_1s_mtp500kmPICKLES','OUT_ULVZ20km_1s_mtp500kmPICKLES','OUT_ULVZ5km_1s_mtp500kmPICKLES']
centerfreq = np.linspace(2,300,200, endpoint = False)

save_path = '/home/zl382/Documents/MATLAB/'

s = distance
# Load file
seisfile = '/raid3/zl382/Data/Synthetics/' +  events[0] + '/SYN_' + str(s) + '.PICKLE'
seis = read(seisfile,format='PICKLE')
seis.resample(10)   # Resampling makes things quicker

Sdifftime = seis[0].stats['traveltimes'][phase] # find time of phase

waveform = sio.loadmat(save_path + 'dispersion.mat')['waveform']
# toplot = np.reshape(sio.loadmat(save_path + 'dispersion.mat')['toplot'],(-1,1))

# Cut window around phase on selected component
tr = seis.select(channel=component)[0]
tr.data[:] = 0


w_start = np.argmin(np.abs(tr.times() - Sdifftime + 1300))
w_end = np.argmin(np.abs(tr.times() - Sdifftime - 2800 + 1300))


w0 = np.argmin(np.abs(tr.times() - Sdifftime + 100 + 1300))
w1 = np.argmin(np.abs(tr.times() - Sdifftime - 2800 + 1300))

tr.data[w_start:w_end] = waveform[0:w_end-w_start]

# Copy trace and create signal
tr1 = tr.copy()
tr1 = tr1.filter('bandpass', freqmin=1/40.,freqmax=1/10.)

# Plot reference phase with wide filter
fig = plt.figure()
ax1 = plt.subplot(121)
plt.plot(tr1.times()[w0:w1]-Sdifftime,tr1.data[w0:w1]/np.max(np.abs(tr1.data[w0:w1])),'k')
# Raw Waveform plot normalized with maximum amplitude, Necessary!

# Loop through centerfrequencies
for ft in range(len(centerfreq)):
    print(ft)
    f = centerfreq[ft]
    trf = tr.copy()
    # Filter copied trace around center frequency
    trf = trf.filter('bandpass', freqmin=1/(f*1.2),freqmax=1/(f*0.8))
    # Add normalized filtered arrival to the Frequency Fan
    if if_norm:
        norm = np.max(np.abs(trf.data[w0:w1]))/4. #  Norm for fan
    else:
        norm = 1.0
        
    if ft == 0:
        toplot = trf.data[w0:w1]/norm
    else:    
        toplot = np.vstack((toplot, trf.data[w0:w1]/norm))   # Stack array vertically

    plt.plot(trf.times()[w0:w1]-Sdifftime, f + trf.data[w0:w1]/norm, 'k') # Filtered Waveform plot in certain range normalized with maximum amplitude, not that Necessary!
    
# Plot frequency fan
ax2 = plt.subplot(122)
plt.pcolor(trf.times()[w0:w1]-Sdifftime,centerfreq,toplot,cmap='Greys')
# Plot reference phase with wide filter
plt.plot(tr1.times()[w0:w1]-Sdifftime,tr1.data[w0:w1]/np.max(np.abs(tr1.data[w0:w1])),'k')

ax1.set_xlabel('time (s)')
ax1.set_ylim([-1, max(centerfreq)])
ax1.set_xlim([-1400, 1500])
ax1.set_ylabel(r'(centre frequency)$^{-1}$ (s)',fontsize=18)

ax2.set_xlabel('time (s)')
ax2.set_ylim([-1, max(centerfreq)])
ax2.set_xlim([-1400, 1500])
plt.suptitle('Dispersion Test with frequency' + ' Norm = ' + str(if_norm))
plt.show()
