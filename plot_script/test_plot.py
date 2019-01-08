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

event = '20161225'

syn = False # Plot synthetics
real = True # Plot real data
color = False # color by measured travel times
switch_yaxis = False
per_norm = False

## Frequencies for filter
fmin = 1/30. #Hz
fmax = 1/10.  #Hzseis

dist_range_1 = 100
dist_range_2 = 110
dist_range_3 = 120
dist_range_4 = 130

azim_min = 310
azim_max = 340

time_min = -20
time_max = 80

norm_constant = 2

real_component = 'BCT'
syn_component = 'BCT'

# dir =  '/raid3/zl382/Data/' + event + '/'
dir = '/raid2/sc845/Lowermost/EastPacific/Data/20161225/CSEM/ULVZ63/' # '/raid2/sc845/Lowermost/EastPacific/Data/20161225/'
# '/raid2/sc845/Lowermost/EastPacific/Data/20161225/CSEM/ULVZ47/' 
# [x1,y1] = [20,312]
# [x2,y2] = [35,325]
# [x3,y3] = [51,337]

# cut_x3 = np.linspace(x1,x2, num=10, endpoint=False)    # First Line
# cut_y3 = np.linspace(y1,y2, num=10, endpoint=False)

[x1,y1] = [35,312]
[x2,y2] = [50,325]
[x3,y3] = [53,337]

cut_x4 = np.linspace(x1,x2, num=10, endpoint=False)    # First Line
cut_y4 = np.linspace(y1,y2, num=10, endpoint=False)
cut_x4 = np.append(cut_x4,np.linspace(x2,x3, num = 11))
cut_y4 = np.append(cut_y4,np.linspace(y2,y3, num=11))




#################### Edit Before This Line ###################################
seislist = glob.glob(dir + '*PICKLE')
azis=[]
strange_trace = []

# Loop through seismograms
count = 0
for s in range(0,len(seislist),1):
    seis = read(seislist[s],format='PICKLE') # read seismogram
    azis.append(seis[0].stats['az']) # list all azimuths
    # print(seis[0].stats['az'],seis[0].stats['dist'])
    seistoplot= seis.select(channel=real_component)[0]
    s_name = os.path.splitext(os.path.split(seislist[s])[1])[0]
    print(s_name +' '+ str(s)+' / '+str(len(seislist)) + ' of '+event)
    # print('dist: '+ str(seis[0].stats['dist'])+ 'az: '+str(seis[0].stats['az']))

    # Split seismograms by distance range (this needs to be adapted per event to produce a reasonable plot.
    if seis[0].stats['dist'] < dist_range_1 and seis[0].stats['dist'] > 94:
        plt.subplot(1,4,1)
    elif seis[0].stats['dist'] < dist_range_2 and seis[0].stats['dist'] > dist_range_1:
        plt.subplot(1,4,2)
    elif seis[0].stats['dist'] < dist_range_3 and seis[0].stats['dist'] > dist_range_2:
        plt.subplot(1,4,3)
    elif seis[0].stats['dist'] < dist_range_4 and seis[0].stats['dist'] > dist_range_3:
        plt.subplot(1,4,4)
    else:
        continue
    align_time = seis[0].stats.traveltimes['Sdiff'] or seis[0].stats.traveltimes['S']

    if syn:
        seissyn= seis.select(channel = syn_component)[0]
    if per_norm:
        norm = np.max(seistoplot.data) / norm_constant
    elif count == 0:
        norm = np.max(seistoplot.data) / norm_constant
    count = count+1          
       # Filter data
    seistoplot.filter('bandpass', freqmin=fmin,freqmax=fmax, zerophase=True)    
    if syn:
        seissyn.filter('bandpass', freqmin=fmin,freqmax=fmax, zerophase=True)   

    if real:        #seistoplot.timesarray      seistoplot.stats['starttime']-align_time-seistoplot.stats['eventtime']+seistoplot.times()+855.1    
        # plt.plot(seistoplot.stats['starttime']-seistoplot.stats['eventtime']+seistoplot.times()-746.6995-align_time, seistoplot.data / norm + np.round(seis[0].stats['az']),'k')
        stime = seistoplot.stats['eventtime'] + align_time + time_min+746.6995
        etime = seistoplot.stats['eventtime'] + align_time + time_max +746.6995
        spoint = int((stime-seistoplot.stats.starttime)*
                        seistoplot.stats.sampling_rate+.5)
        epoint = int((etime-seistoplot.stats.starttime)*
                        seistoplot.stats.sampling_rate+.5)  
        plt.plot(np.linspace(time_min,time_max,num=len(seistoplot.data[spoint:epoint])), seistoplot.data[spoint:epoint] / norm + np.round(seis[0].stats['az']),'k')
    if syn:
        plt.plot(seissyn.timesarray-align_time,seissyn.data / norm + np.round(seis[0].stats['az']),'r')        
        
               
    plt.xlim([time_min,time_max])
          # Plot travel time predictions
    for k in seis[0].stats.traveltimes.keys():
        if seis[0].stats.traveltimes[k]!=None: #and k!='S90' and k!='P90' and seis[0].stats.traveltimes[k]-align_time<time_max and seis[0].stats.traveltimes[k]-align_time>time_min:
            if k == 'Sdiff' or k == 'S':
                plt.plot(seis[0].stats.traveltimes[k]-align_time, np.round(seis[0].stats['az']),'g',marker='o',markersize=4)
                print('Sdiff: ' + str(seis[0].stats.traveltimes[k]-align_time))
            elif k == 'pSdiff':
                plt.plot(seis[0].stats.traveltimes[k]-align_time, np.round(seis[0].stats['az']),'r',marker='o',markersize=4)
                print('pSdiff: ' + str(seis[0].stats.traveltimes[k]-align_time))
            elif k == 'sSdiff':
                plt.plot(seis[0].stats.traveltimes[k]-align_time, np.round(seis[0].stats['az']),'orange',marker='o',markersize=4)
                print('sSdiff: ' + str(seis[0].stats.traveltimes[k]-align_time))
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
            
    w0_ref = np.argmin(np.abs(seistoplot.times()-align_time+10))        # arg of ref, adapative time window     
    w1_ref = np.argmin(np.abs(seistoplot.times()-align_time-20))   
    A0 = np.max(np.abs(seistoplot.data[w0_ref:w1_ref]))/norm                
    #gca().add_patch(patches.Rectangle((seistoplot.timesarray[w0_ref]-align_time,np.round(seis[0].stats['az'])-A0),seistoplot.timesarray[w1_ref]-seistoplot.timesarray[w0_ref],2*A0,alpha = 0.4, color = 'red'))
    threshold = A0 #np.max(seistoplot.data/norm)
    
    print('threshold: '+str(threshold))
    if ((threshold>5 or threshold<0.05)):# and seis[0].stats['dist']>100) or (threshold<0.1 and seis[0].stats['dist']<100):
        strange_trace.append([s,seis[0].stats['az'],s_name,threshold])   
        
    plt.text(81,np.round(seis[0].stats['az'])+A0/5,s_name+' #'+str(s), fontsize = 8)
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
#plt.plot(cut_x4,cut_y4, '--', color='blue')

plt.subplot(1,4,4)
plt.title(' Sdiff dist < %d' % dist_range_4)
plt.ylim(azim_min,azim_max)
plt.xlabel('time around predicted arrival (s)')
plt.plot(cut_x4,cut_y4, '--', color='blue')
if switch_yaxis:
   plt.gca().invert_yaxis()
#plt.plot(cut_x4,cut_y4, '--', color='blue')


plt.suptitle('Waveform with Azimuth\n Event %s    Real data: %s , Syn Data: %s \n freq: %s s - %s s \n Data Path: %s' % (event, real_component, syn_component, str(1/fmax), str(1/fmin), dir))
 
# Save file and show plot
#plt.savefig('/home/zl382/Pictures/Syn+Real/'+event+'data_with_azimuth.png')
plt.show()
