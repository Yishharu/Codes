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

event = '20170509'
syn = False # Plot synthetics
real = True # Plot real data
color = False # color by measured travel times
switch_yaxis = True

## Frequencies for filter
fmin = 1/30 #Hz
fmax = 1/10 #Hzseis

dist_range_1 = 90
dist_range_2 = 100
dist_range_3 = 110
dist_range_4 = 120

azim_min = 40
azim_max = 70

dist_min=100
dist_max=110

time_min = -40
time_max = 120

select_time_min = -40
select_time_max = -20

select_az_min =  azim_min
select_az_max = azim_max

norm_constant = 10

threshold_max = 1
threshold_min = 0.1

per_norm = False

dir = '/raid3/zl382/Data/' + event + '/'
dirdump = dir + 'Dump/'
if not os.path.exists(dirdump):
    os.makedirs(dirdump) 
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
plt.subplot(1,1,1)

# Loop through seismograms
count = 0
for s in range(0,len(seislist),1):
   #try:
    seis = read(seislist[s],format='PICKLE') # read seismogram
    azis.append(seis[0].stats['az']) # list all azimuths
   # print(seis[0].stats['az'],seis[0].stats['dist'])
    seistoplot= seis.select(channel='BHT')[0]
    s_name = os.path.splitext(os.path.split(seislist[s])[1])[0]

    if seis[0].stats['az']<azim_min or seis[0].stats['az']>azim_max \
    or seis[0].stats['dist']<dist_min or seis[0].stats['dist']>dist_max:
        continue
    print(s_name +' '+ str(s)+' / '+str(len(seislist)) + ' of '+event)
       # plot synthetics
    if syn:
        seissyn= seis.select(channel ='BXT')[0]
    if per_norm:
        norm = np.max(seistoplot.data) / norm_constant
    elif count == 0:
        norm = np.max(seistoplot.data) / norm_constant
    count = count+1   
       # Split seismograms by distance range (this needs to be adapted per event to produce a reasonable plot.
       
    plt.text(121,np.round(seis[0].stats['az']),s_name, fontsize = 8)
       # Filter data
      # if seis[0].stats.traveltimes['Sdiff']!=None:
    seistoplot.filter('highpass',freq=fmin,corners=2,zerophase=True)
    seistoplot.filter('lowpass',freq=fmax,corners=2,zerophase=True)
    if syn:
        seissyn.filter('highpass',freq=fmin,corners=2,zerophase=True)
        seissyn.filter('lowpass',freq=fmax,corners=2,zerophase=True)
          # Time shift to shift data to reference time
        #  tshift=UTCDateTime(seis[0].stats['starttime']) - UTCDateTime(seis[0].stats['eventtime']) #UTCDateTime('2016-08-31T03:11:40.700')#seis[0].stats['endtime']
    phase_time = seis[0].stats.traveltimes['Sdiff'] or seis[0].stats.traveltimes['S']   
    if real:
        plt.plot(seistoplot.timesarray-phase_time,seistoplot.data/norm+np.round(seis[0].stats['az']),'k')
    if syn:      
        print(np.max(seistoplot.data), np.max(seissyn.data))
        plt.plot(seissyn.timesarray-phase_time,seissyn.data/norm+np.round(seis[0].stats['az']),'b')
    plt.xlim([time_min,time_max])
          # Plot travel time predictions
    for k in seis[0].stats.traveltimes.keys():
        if seis[0].stats.traveltimes[k]!=None and k =='Sdiff':
            plt.plot(seis[0].stats.traveltimes[k]-phase_time,np.round(seis[0].stats['az']),'g',marker='o',markersize=4)
                     # plt.text(seis[0].stats.traveltimes[k]-seis[0].stats.traveltimes[phase],np.round(seis[0].stats['az'])-0.5, k)
            
    timewindow = 3*20    
#          w0 = np.argmin(np.abs(seistoplot.times-phase_time+timewindow/3))            
#          w1 = np.argmin(np.abs(seistoplot.times-phase_time-timewindow*2/3))
#          window_wid = seistoplot.times[w1] - seistoplot.times[w0]
#          window_hei = np.max(np.abs(hilbert(seistoplot.data[w0:w1])))/norm
#        #                test_w0 = np.argmin(np.abs(seistoplot.times()-phase_time+(-1)))            
#        #                test_w1 = np.argmin(np.abs(seistoplot.times()-phase_time-149))     
#        #                test_window_hei = np.max(np.abs(hilbert(seistoplot.data[test_w0:test_w1])))/norm
#        #                print('Window difference: '+str( (test_window_hei-window_hei)/window_hei))
#          gca().add_patch(patches.Rectangle((seistoplot.times[w0]-phase_time,np.round(seis[0].stats['az'])-window_hei),window_wid,2*window_hei,alpha = 0.2, color = 'red'))  # width height            
    w0_ref = np.argmin(np.abs(seistoplot.timesarray-phase_time-select_time_min))        # arg of ref, adapative time window     
    w1_ref = np.argmin(np.abs(seistoplot.timesarray-phase_time-select_time_max))   
    A0 = np.max(np.abs(hilbert(seistoplot.data[w0_ref:w1_ref])))/norm                
    gca().add_patch(patches.Rectangle((seistoplot.timesarray[w0_ref]-phase_time,np.round(seis[0].stats['az'])-A0),seistoplot.timesarray[w1_ref]-seistoplot.timesarray[w0_ref],2*A0,alpha = 0.05, color = 'y'))
    threshold = A0 #np.max(seistoplot.data/norm)
    print('NORM VALUE: ' + str(norm)+ ' ; ' + 'threshold = ' + str(threshold))    
    if ((threshold>threshold_max or threshold<threshold_min)):  #(threshold>5 or threshold<0.02):
        strange_trace.append([s,s_name,seis[0].stats['az'],seis[0].stats['dist'],threshold])   
# Put labels on graphs
print('!!!!!!!!!!!!!!!!!!!Stange Traces:----------------------->>>>>>')
print(strange_trace)

plt.ylim(azim_min,azim_max)
plt.xlabel('time around predicted arrival (s)')
plt.ylabel('azimuth (dg)')
if switch_yaxis:
   plt.gca().invert_yaxis()

plt.suptitle('Waveform with Azimuth\n Event %s' % event)

# Hightlight the selected waveform 

for trace in strange_trace:
    s = trace[0]
    s_name = trace[1]
    azimuth = trace[2]
    dist = trace[3]
    threshold = trace[4]    
    print(s_name, 'Trace#', s, '/', len(seislist))
    seis = read(seislist[s],format='PICKLE') # read seismogram
    if real:
        seistoplot = seis.select(channel='BHT')[0]
       # plot synthetics
    if syn:
        seissyn= seis.select(channel ='BXT')[0]       
    # Split seismograms by distance range (this needs to be adapted per event to produce a reasonable plot.
    if seis[0].stats['az']<select_az_min or seis[0].stats['az']>select_az_max:
        continue
       # Filter data
      # if seis[0].stats.traveltimes['Sdiff']!=None:
    seistoplot.filter('highpass',freq=fmin,corners=2,zerophase=True)
    seistoplot.filter('lowpass',freq=fmax,corners=2,zerophase=True)
          # Time shift to shift data to reference time
      # tshift=seis[0].stats['starttime']-seis[0].stats['eventtime']  
   # print('max',np.max(seistoplot.timesarray))
    phase_time = seis[0].stats.traveltimes['Sdiff'] or seis[0].stats.traveltimes['S']   
    [tr] = plt.plot(seistoplot.timesarray-phase_time,seistoplot.data/norm+np.round(seis[0].stats['az']),'r')
        
    print('azi ='+ str(azimuth) + ' ; '+'dist ='+ str(dist)+' ; '+ 'threshold = ' + str(threshold))

    plt.show(block=False)

    likeness = ''
    while (likeness != 'y' and likeness != 'n' and likeness != 'r'):
        likeness = input('Do you like the waveform (y/n/r)?')
        if (likeness == 'y'):
            like = True
            if (s >= len(seislist)):
                print('This is the last waveform')
        elif (likeness == 'n'):
            like = False
            shutil.move(seislist[s],dirdump)
            print('# ' + str(s)+' '+s_name+' successfully moved to dump!!')
            if (s >= len(seislist)):
               print('This is the last waveform')  
        elif (likeness == 'r'):
            seis[0].data = - seis[0].data
            seis.write(seislist[s],format='PICKLE')
            print('# ' + str(s)+' '+s_name+' successfully reversed!!')
            if (s >= len(seislist)):
               print('This is the last waveform')   

    tr.set_visible(False)
    plt.draw()
 
plt.show()
