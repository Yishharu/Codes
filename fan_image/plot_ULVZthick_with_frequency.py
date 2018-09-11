#!/usr/bin python3

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
matplotlib.rcParams.update({'font.size':20}) # Sets fontsize in figure


# Set phase to plot
phase = 'Sdiff'
# Set component to plot
component = 'BAT'
# Set distance
distance = 106
# Set filename for figure
filename = 'Plots/Sdiff_T_B1.png'
# Set models to plot
events=['OUT_REF_1s_mtp500kmPICKLES','OUT_UL,'OUT_ULVZ5km_1s_mtp500kmPICKLES']
# Set model titles
titles = ['a. No ULVZ','b. 20 km ULVZ',  'c. 5 km ULVZ']
# Set center frequencies for the Fan
centerfreq=np.linspace(2,25,200)

plt.figure(figsize=(11,7))


for i in range(len(events)):
       # Initialize plot for each model
       if i ==0:
              ax0=plt.subplot(1,3,i+1)
       else:
              plt.subplot(1,3,i+1)
       event=events[i]
       
       for s in [distance]: 
          #try:
              print(s)
              # Load file
              seisfile = '/raid3/zl382/Data/Synthetics/' +  event + '/SYN_' + str(s) + '.PICKLE'
              seis= read(seisfile,format='PICKLE')
              seis.resample(10)# Resampling makes things quicker
       
              Sdifftime=seis[0].stats['traveltimes'][phase] # find time of phase

              # Cut window around phase on selected component
              tr=seis.select(channel=component)[0]
              w0=np.argmin(np.abs(tr.times()-Sdifftime+100))
              w1 = np.argmin(np.abs(tr.times()-Sdifftime-190))

              # Copy trace
              tr1=tr.copy()
              tr1=tr1.filter('bandpass', freqmin=1/40.,freqmax=1/10.)
              # Plot reference phase with wide filter
              plt.plot(tr.times()[w0:w1]-Sdifftime,tr1.data[w0:w1]/np.max(np.abs(tr1.data[w0:w1])),'k')

              # Loop through centerfrequencies
              for ft in range(len(centerfreq)):
                     print(ft)
                     f=centerfreq[ft]
                     trf= tr.copy()
                     # Filter copied trace around center frequency
                     trf=trf.filter('bandpass', freqmin=1/(f*1.2),freqmax=1/(f*0.8))
                     # Add normalized filtered arrival to the Frequency Fan
                     norm=np.max(np.abs(trf.data[w0:w1]))/4.
                     if ft ==0:
                            toplot = trf.data[w0:w1]/norm
                     else:

                            toplot = np.vstack((toplot, trf.data[w0:w1]/norm))

       # Plot frequency fan
       plt.pcolor(trf.times()[w0:w1]-Sdifftime,centerfreq,toplot,cmap='Greys')
       plt.ylim([-1,max(centerfreq)])
       plt.xlim([-10,90])
       #if i == 2 or i==3:
       plt.xlabel('time around ' +phase + ' (s)', fontsize=18)
       if i ==0:
              plt.ylabel(r'(centre frequency)$^{-1}$ (s)',fontsize=18)

       plt.title(titles[i],fontsize=20)
       plt.plot([0, 0],[min(centerfreq), max(centerfreq)],'--k')
       plt.gca().tick_params(labelsize=16)


# plt.savefig(filename)     
plt.show()

