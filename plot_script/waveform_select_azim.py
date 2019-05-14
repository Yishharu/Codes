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

Location = 'Hawaii'
Event = '20180910'
syn = False # Plot synthetics
real = True # Plot real data
color = False # color by measured travel times
switch_yaxis = True
per_norm = False

## Frequencies for filter
fmin, fmax = 1/20, 1/10   # Hz

dist_range_1, dist_range_2, dist_range_3, dist_range_4 = 94, 96, 100, 110

azim_min, azim_max = 0, 20
dist_min, dist_max = 100, 110
select_az_min, select_az_max = 0,20

time_min, time_max = -40, 120
select_time_min, select_time_max = -30, -20

norm_constant = 0.3

threshold_max = 0.3
threshold_min = 0.005

component = 'BHT'
###################################### Edit Before This Line ##################################
dir = '/raid1/zl382/Data/'+Location+'/' + Event + '/'
dirdump = dir + 'Dump/'
if not os.path.exists(dirdump):
    os.makedirs(dirdump) 
azis=[]
strange_trace = []

# Loop through seismograms
count = 0
location_dict = np.load(dir+'STALOCATION.npy').item()
for s, (s_name, (dist,azi,stla,stlo,sazi)) in enumerate(location_dict.items()):
    print('%s %d / %d of %s' %(s_name, s, len(location_dict), Event))
    if azi<select_az_min or azi>select_az_max \
    or dist<dist_min or dist>dist_max:
        continue
   #try:
    full_path = dir+s_name+'.PICKLE'
    if not os.path.exists(full_path):
        continue
    seis = read(dir+s_name+'.PICKLE',format='PICKLE') # read seismogram
    azis.append(seis[0].stats['az']) # list all azimuths
   # print(seis[0].stats['az'],seis[0].stats['dist'])
    seistoplot= seis.select(channel=component)[0]
    seistoplot.differentiate()

       # plot synthetics
    if syn:
        seissyn= seis.select(channel ='BXT')[0] 
       # Split seismograms by distance range (this needs to be adapted per Event to produce a reasonable plot.
       
    plt.text(121,np.round(seis[0].stats['az']),s_name, fontsize = 8)
       # Filter data
      # if seis[0].stats.traveltimes['Sdiff']!=None:
    seistoplot.filter('bandpass', freqmin=fmin,freqmax=fmax, zerophase=True)
    if per_norm:
        norm = np.max(seistoplot.data) / norm_constant
    elif count == 0:
        norm = np.max(seistoplot.data) / norm_constant
    count = count+1  

    phase_time = seis[0].stats.traveltimes['Sdiff'] or seis[0].stats.traveltimes['S']   
    if real:
        plt.plot(seistoplot.timesarray-phase_time,seistoplot.data/norm+np.round(seis[0].stats['az']),'k')
    if syn:      
        print(np.max(seistoplot.data), np.max(seissyn.data))
        plt.plot(seissyn.timesarray-phase_time,seissyn.data/norm+np.round(seis[0].stats['az']),'b')
    plt.xlim([time_min,time_max])
    plt.title('Sdiff dist %.0f - %.0f' %(dist_min, dist_max))
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

plt.suptitle('Waveform with Azimuth\n Event %s' % Event)

# Hightlight the selected waveform 

for trace in strange_trace:
    s = trace[0]
    s_name = trace[1]
    azimuth = trace[2]
    dist = trace[3]
    threshold = trace[4]    
    print(s_name, 'Trace#', s, '/', len(location_dict))
    full_path = dir+s_name+'.PICKLE'
    seis = read(full_path,format='PICKLE') # read seismogram
    
    if real:
        seistoplot = seis.select(channel=component)[0]
        seistoplot.differentiate()
       # plot synthetics
    if syn:
        seissyn= seis.select(channel ='BXT')[0]       
    # Split seismograms by distance range (this needs to be adapted per event to produce a reasonable plot.
    if seis[0].stats['az']<select_az_min or seis[0].stats['az']>select_az_max:
        continue
       # Filter data
    seistoplot.filter('bandpass', freqmin=fmin,freqmax=fmax, zerophase=True)

    if per_norm:
        norm = np.max(seistoplot.data) / norm_constant
    phase_time = seis[0].stats.traveltimes['Sdiff'] or seis[0].stats.traveltimes['S']   

    [tr] = plt.plot(seistoplot.timesarray-phase_time,seistoplot.data/norm+np.round(seis[0].stats['az']),'r')
        
    print('azi ='+ str(azimuth) + ' ; '+'dist ='+ str(dist)+' ; '+ 'threshold = ' + str(threshold))

    plt.show(block=False)

    likeness = ''
    while (likeness != 'y' and likeness != 'n' and likeness != 'r'):
        likeness = input('Do you like the waveform (y/n/r)?')
        if (likeness == 'y'):
            like = True
            if (s >= strange_trace[-1][0]):
                print('This is the last waveform')
        elif (likeness == 'n'):
            like = False
            shutil.move(full_path,dirdump)
            print('# ' + str(s)+' '+s_name+' successfully moved to dump!!')
            if (s >= strange_trace[-1][0]):
               print('This is the last waveform')  
        elif (likeness == 'r'):
            for trace in seis.select(channel=component):
                trace.data = -trace.data
            seis.write(full_path,format='PICKLE')
            print('# ' + str(s)+' '+s_name+' successfully reversed!!')
            if (s >= strange_trace[-1][0]):
               print('This is the last waveform')   

    tr.set_visible(False)
    plt.draw()
 
plt.show()
