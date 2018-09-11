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

event = '20170110ALL'#sys.argv[1]

syn = False # Plot synthetics
real = True # Plot real data
color = False # color by measured travel times
switch_yaxis = True

## Frequencies for filter
fmin = 1/30 #Hz
fmax = 1/10  #Hzseis

dist_range_1 = 80
dist_range_2 = 100
dist_range_3 = 120
dist_range_4 = 140

azim_min = 300
azim_max = 360

norm_constant = 3
per_norm = False

dir = '/raid3/zl382/Data/' + event + '/'
seislist = glob.glob(dir + '*PICKLE')
azis=[]
strange_trace = []

# PLot measured differential travel times by coloring the lines
if color:
   dtsta=[]
   dtnw=[]
   dtdt=[]
   rd=open('traveltimes_xcorr_12_30s_20130715.dat','r')
   for line in rd.readlines():
    val=line.split()
    dtsta.append(val[0])
    dtnw.append(val[1])
    dtdt.append(float(val[4]))
    cNorm=colors.Normalize(vmin=-10,vmax=10)
    scalarMap=cm.ScalarMappable(norm=cNorm,cmap=plt.get_cmap('jet'))

count = 0
# Loop through seismograms
for s in range(0,len(seislist),1):
    seis = read(seislist[s],format='PICKLE') # read seismogram
    azis.append(seis[0].stats['az']) # list all azimuths
    print(seis[0].stats['az'],seis[0].stats['dist'])
    seistoplot= seis.select(channel='BX90T')[0]
    s_name = os.path.splitext(os.path.split(seislist[s])[1])[0]
    print(s_name +'  ' +str(s)+' / '+str(len(seislist)) + ' of '+event)
    #seistoplot.timesarray = seistoplot.times(reftime = seistoplot.stats['starttime'])    

    # plot synthetics
    if syn:
        seissyn= seis.select(channel ='BXT')[0]
    if per_norm:
        norm = np.max(seistoplot.data) / norm_constant
    elif count == 0:
        norm = np.max(seistoplot.data) / norm_constant
    count = count+1
    if np.max(seistoplot.data/norm)>30 or np.max(seistoplot.data/norm)<0.01:
        strange_trace.append([s,s_name])    
       # Split seismograms by distance range (this needs to be adapted per event to produce a reasonable plot.
       
     #  print(seis[0].stats.traveltimes['Sdiff90'])
    phase = 'S90'
    if seis[0].stats['dist'] < dist_range_1:
        plt.subplot(1,4,1)
    elif seis[0].stats['dist'] < dist_range_2:
        plt.subplot(1,4,2)
    elif seis[0].stats['dist'] < dist_range_3:
        plt.subplot(1,4,3)
    elif seis[0].stats['dist'] < dist_range_4:
        plt.subplot(1,4,4)
    plt.text(110,seis[0].stats['az'],s_name, fontsize = 8)
               

       # Filter data
      # if seis[0].stats.traveltimes['Sdiff']!=None:
    seistoplot.filter('highpass',freq=fmin,corners=2,zerophase=True)
    seistoplot.filter('lowpass',freq=fmax,corners=2,zerophase=True)
    if syn:
        seissyn.filter('highpass',freq=fmin,corners=2,zerophase=True)
        seissyn.filter('lowpass',freq=fmax,corners=2,zerophase=True)

          # Time shift to shift data to reference time
  #  tshift=UTCDateTime(seis[0].stats['starttime']) - UTCDateTime(seis[0].stats['eventtime']) #UTCDateTime('2016-08-31T03:11:40.700')#seis[0].stats['endtime']
  
    if real:
        plt.plot(seistoplot.timesarray-seis[0].stats.traveltimes[phase],seistoplot.data/norm+np.round(seis[0].stats['az']),'k')
    if syn:      
        print(np.max(seistoplot.data), np.max(seissyn.data))
        plt.plot(seissyn.timesarray-seis[0].stats.traveltimes[phase],seissyn.data/norm+np.round(seis[0].stats['az']),'b')
    plt.xlim([-50,100])

          # Plot travel time predictions
    for k in seis[0].stats.traveltimes.keys():
        if seis[0].stats.traveltimes[k]!=None and k =='S90':
            plt.plot(seis[0].stats.traveltimes[k]-seis[0].stats.traveltimes[phase],np.round(seis[0].stats['az']),'g',marker='o',markersize=4)
                 # plt.text(seis[0].stats.traveltimes[k]-seis[0].stats.traveltimes[phase],np.round(seis[0].stats['az'])-0.5, k)
    Sdifftime = seis[0].stats.traveltimes[phase]               
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
            
    w0_ref = np.argmin(np.abs(seistoplot.timesarray-seis[0].stats['traveltimes']['S90']+timewindow/3))        # arg of ref, adapative time window     
    w1_ref = np.argmin(np.abs(seistoplot.timesarray-seis[0].stats['traveltimes']['S90']-timewindow*2/3))   
    A0 = np.max(np.abs(hilbert(seistoplot.data[w0_ref:w1_ref])))/norm                

    gca().add_patch(patches.Rectangle((seistoplot.timesarray[w0_ref]-Sdifftime,np.round(seis[0].stats['az'])-A0),seistoplot.timesarray[w1_ref]-seistoplot.timesarray[w0_ref],2*A0,alpha = 0.4, color = 'red'))
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

plt.suptitle('Synthetic Waveform with Azimuth\n Event %s at distance = 90' % event)

   
# Save file and show plot
#plt.savefig('/home/zl382/Pictures/waveform/'+event+'data_with_azimuth.pdf')
plt.show()
 

