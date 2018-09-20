#/usr/bin/python3
# Usage: python3 plot_data_azimuth.py [event]
# Example: python3 plot_data_azimuth.py 20100320
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
import scipy
from obspy.io.xseed import Parser
from subprocess import call
import subprocess
import sys
import matplotlib.colors as colors
import matplotlib.cm as cm
from scipy.signal import hilbert
from pylab import *
import matplotlib.patches as patches

event = sys.argv[1]

syn = False # Plot synthetics
real = True # Plot real data
color = False # color by measured travel times
switch_yaxis = True
per_norm = False

## Frequencies for filter
fmin = 1/30. #Hz
fmax = 1/10.  #Hzseis

dist_range_1 = 90
dist_range_2 = 100
dist_range_3 = 120
dist_range_4 = 140

azim_min = 300
azim_max = 360

time_min = -40
time_max = 100

norm_constant = 10

real_component = 'BHT'
syn_component = 'BXT'

dir = '/raid3/zl382/Data/' + event + '/'
seislist = glob.glob(dir + '*PICKLE')
azis=[]
strange_trace = []

# Loop through seismograms
count = 0
for s in range(0,len(seislist),3):
   #try:
    seis = read(seislist[s],format='PICKLE') # read seismogram
    azis.append(seis[0].stats['az']) # list all azimuths
   # print(seis[0].stats['az'],seis[0].stats['dist'])
    seistoplot= seis.select(channel=real_component)[0]
    s_name = os.path.splitext(os.path.split(seislist[s])[1])[0]
    print(s_name +' '+ str(s)+' / '+str(len(seislist)) + ' of '+event)
       # plot synthetics
    if syn:
        seissyn= seis.select(channel = syn_component)[0]
    if per_norm:
        norm = np.max(seistoplot.data) / norm_constant
    elif count == 0:
        norm = np.max(seistoplot.data) / norm_constant
    count = count+1   

       # Split seismograms by distance range (this needs to be adapted per event to produce a reasonable plot.
       
  #  print(seis[0].stats.traveltimes['Sdiff'])
    if seis[0].stats.traveltimes['Sdiff']!=None:
        phase = 'Sdiff'
    else:
        phase = 'S'
    align_time = seis[0].stats.traveltimes[phase]       

    if seis[0].stats['dist'] < dist_range_1:
        plt.subplot(1,4,1)
    elif seis[0].stats['dist'] < dist_range_2:
        plt.subplot(1,4,2)
    elif seis[0].stats['dist'] < dist_range_3:
        plt.subplot(1,4,3)
    elif seis[0].stats['dist'] < dist_range_4:
        plt.subplot(1,4,4)
    
       # Filter data
    seistoplot.filter('bandpass', freqmin=fmin,freqmax=fmax, zerophase=True)    
    if syn:
        seissyn.filter('bandpass', freqmin=fmin,freqmax=fmax, zerophase=True)   

    if real:                
       plt.plot(seistoplot.timesarray-align_time, seistoplot.data / norm + np.round(seis[0].stats['az']),'k')
    if syn:
        plt.plot(seissyn.timesarray-align_time,seissyn.data / norm + np.round(seis[0].stats['az']),'r')        
        
               
    plt.xlim([time_min,time_max])
          # Plot travel time predictions
    for k in seis[0].stats.traveltimes.keys():
        if seis[0].stats.traveltimes[k]!=None and k!='S90' and k!='P90' and seis[0].stats.traveltimes[k]-align_time<time_max and seis[0].stats.traveltimes[k]-align_time>time_min:
            plt.plot(seis[0].stats.traveltimes[k]-align_time, np.round(seis[0].stats['az']),'g',marker='o',markersize=4)
           # plt.text(seis[0].stats.traveltimes[k]-align_time, np.round(seis[0].stats['az']),k, fontsize = 8)
                     # plt.text(seis[0].stats.traveltimes[k]-seis[0].stats.traveltimes[phase],np.round(seis[0].stats['az'])-0.5, k)              
    timewindow = 3*20   
    print('NORM VALUE: ' + str(norm))     
#          w0 = np.argmin(np.abs(seistoplot.times-Sdifftime+timewindow/3))            
#          w1 = np.argmin(np.abs(seistoplot.times-Sdifftime-timewindow*2/3))
#          window_wid = seistoplot.times[w1] - seistoplot.times[w0]
#          window_hei = np.max(np.abs(hilbert(seistoplot.data[w0:w1])))/norm
#        #                test_w0 = np.argmin(np.abs(seistoplot.times()-Sdifftime+(-1)))            
#        #                test_w1 = np.argmin(np.abs(seistoplot.times()-Sdifftime-149))     
#        #                test_window_hei = np.max(np.abs(hilbert(seistoplot.data[test_w0:test_w1])))/norm
#        #                print('Window difference: '+str( (test_window_hei-window_hei)/window_hei))
#          gca().add_patch(patches.Rectangle((seistoplot.times[w0]-Sdifftime,np.round(seis[0].stats['az'])-window_hei),window_wid,2*window_hei,alpha = 0.2, color = 'red'))  # width height
            
    # w0_ref = np.argmin(np.abs(seistoplot.timesarray-align_time+10))        # arg of ref, adapative time window     
    # w1_ref = np.argmin(np.abs(seistoplot.timesarray-align_time-20))   
    # A0 = np.max(np.abs(seistoplot.data[w0_ref:w1_ref]))/norm                
    # #gca().add_patch(patches.Rectangle((seistoplot.timesarray[w0_ref]-align_time,np.round(seis[0].stats['az'])-A0),seistoplot.timesarray[w1_ref]-seistoplot.timesarray[w0_ref],2*A0,alpha = 0.4, color = 'red'))
    # threshold = A0 #np.max(seistoplot.data/norm)
    
    # print(threshold)
    # if ((threshold>0.5 or threshold<0.05)):# and seis[0].stats['dist']>100) or (threshold<0.1 and seis[0].stats['dist']<100):
    #     strange_trace.append([s,seis[0].stats['az'],s_name,threshold])   
        
    #plt.text(71,np.round(seis[0].stats['az'])+A0,s_name+' #'+str(s), fontsize = 8)
# Put labels on graphs
print('!!!!!!!!!!!!!!!!!!!Stange Traces:----------------------->>>>>>')
print(strange_trace)
plt.subplot(1,4,1)
plt.title(' Sdiff dist < %d' % dist_range_1)
plt.ylim(azim_min,azim_max)
plt.xlabel('time around predicted arrival (s)')
plt.ylabel('azimuth (dg)')
if switch_yaxis:
   plt.gca().invert_yaxis()
   
plt.subplot(1,4,2)
plt.title(' Sdiff dist < %d' % dist_range_2)
plt.ylim(azim_min,azim_max)
plt.xlabel('time around predicted arrival (s)')
if switch_yaxis:
   plt.gca().invert_yaxis()
   
plt.subplot(1,4,3)
plt.title(' Sdiff dist < %d' % dist_range_3)
plt.ylim(azim_min,azim_max)
plt.xlabel('time around predicted arrival (s)')
if switch_yaxis:
   plt.gca().invert_yaxis()
   
plt.subplot(1,4,4)
plt.title(' Sdiff dist < %d' % dist_range_4)
plt.ylim(azim_min,azim_max)
plt.xlabel('time around predicted arrival (s)')
if switch_yaxis:
   plt.gca().invert_yaxis()

plt.suptitle('Waveform with Azimuth\n Event %s    Real data: %s , Syn Data: %s \n freq: %s s - %s s' % (event, real_component, syn_component, str(1/fmax), str(1/fmin)))

   
# Save file and show plot
#plt.savefig('/home/zl382/Pictures/Syn+Real/'+event+'data_with_azimuth.png')
plt.show()
