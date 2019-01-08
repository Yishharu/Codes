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
from shutil import copy2
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

event = '20100320'#sys.argv[1]

syn = False# Plot synthetics
real = True # Plot real data
color = False # color by measured travel times
switch_yaxis = True
per_norm = False

## Frequencies for filter
fmin = 1/5. #Hz
fmax = 1/2.  #Hzseis

dist_range_1 = 94
dist_range_2 = 100
dist_range_3 = 110
dist_range_4 = 120

time_min = -20
time_max = 80

norm_constant = 1

real_component = 'BHT'
syn_component = 'BXT'

dir = '/raid3/zl382/Data/' + event + '/'# '/raid2/sc845/Lowermost/EastPacific/Data/20161225/'

[x1,y1] = [25,63]
[x2,y2] = [30,52]
[x3,y3] = [50,40]

cut_x = np.linspace(x1,x2, num=10, endpoint=False)    # First Line
cut_y = np.linspace(y1,y2, num=10, endpoint=False)
cut_x = np.append(cut_x,np.linspace(x2,x3, num = 11))
cut_y = np.append(cut_y,np.linspace(y2,y3, num=11))

###################### Edit Before This Line ######################################

seislist = glob.glob(dir + '*PICKLE')
azis=[]
dists=[]
strange_trace = []

# Loop through seismograms
count = 0
for s in range(0,len(seislist),1):
    seis = read(seislist[s],format='PICKLE') # read seismogram
    seistoplot= seis.select(channel=real_component)[0]
    s_name = os.path.splitext(os.path.split(seislist[s])[1])[0]
    print('####'+ s_name +' '+ str(s)+' / '+str(len(seislist)) + ' of '+event+'########')
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
    phase_time = seis[0].stats.traveltimes['Sdiff'] or seis[0].stats.traveltimes['S']
    noise_time = seis[0].stats.traveltimes['P'] or seis[0].stats.traveltimes['Pdiff']-300
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

    if real:        #seistoplot.timesarray          
       plt.plot(seistoplot.times(reftime=seistoplot.stats['eventtime'])-phase_time, seistoplot.data / norm + np.round(seis[0].stats['az']),'k')
    if syn:
        plt.plot(seissyn.timesarray-phase_time,seissyn.data / norm + np.round(seis[0].stats['az']),'r')        

    azis.append(seis[0].stats['az']) # list all azimuths
    dists.append(seis[0].stats['dist'])    
               
    plt.xlim([time_min,time_max])
          # Plot travel time predictions
    for k in seis[0].stats.traveltimes.keys():
        if seis[0].stats.traveltimes[k]!=None: #and k!='S90' and k!='P90' and seis[0].stats.traveltimes[k]-phase_time<time_max and seis[0].stats.traveltimes[k]-phase_time>time_min:
            if k == 'Sdiff' or k == 'S':
                plt.plot(seis[0].stats.traveltimes[k]-phase_time, np.round(seis[0].stats['az']),'g',marker='o',markersize=4)
                print('Sdiff: ' + str(seis[0].stats.traveltimes[k]-phase_time))
            elif k == 'pSdiff':
                plt.plot(seis[0].stats.traveltimes[k]-phase_time, np.round(seis[0].stats['az']),'r',marker='o',markersize=4)
                print('pSdiff: ' + str(seis[0].stats.traveltimes[k]-phase_time))
            elif k == 'sSdiff':
                plt.plot(seis[0].stats.traveltimes[k]-phase_time, np.round(seis[0].stats['az']),'orange',marker='o',markersize=4)
                print('sSdiff: ' + str(seis[0].stats.traveltimes[k]-phase_time))
           # plt.text(seis[0].stats.traveltimes[k]-phase_time, np.round(seis[0].stats['az']),k, fontsize = 8)
                     # plt.text(seis[0].stats.traveltimes[k]-seis[0].stats.traveltimes[phase],np.round(seis[0].stats['az'])-0.5, k)              
    timewindow = 3*(1/fmin)   
    print('NORM VALUE: ' + str(norm))     
    w0 = np.argmin(np.abs(seistoplot.times(reftime=seistoplot.stats['eventtime'])-phase_time+timewindow/3))            
    w1 = np.argmin(np.abs(seistoplot.times(reftime=seistoplot.stats['eventtime'])-phase_time-timewindow*2/3))
    window_wid = seistoplot.times(reftime=seistoplot.stats['eventtime'])[w1] - seistoplot.times(reftime=seistoplot.stats['eventtime'])[w0]
    window_hei = np.max(np.abs(hilbert(seistoplot.data[w0:w1])))/norm
    # plot the picked window
    gca().add_patch(patches.Rectangle((seistoplot.times(reftime=seistoplot.stats['eventtime'])[w0]-phase_time,np.round(seis[0].stats['az'])-window_hei),window_wid,2*window_hei,alpha = 0.2, color = 'red'))  # width height
    A0_phase = np.abs(hilbert(seistoplot.data[w0:w1])).max()/norm


    w0_noise1 = np.argmin(np.abs(seistoplot.times(reftime=seistoplot.stats['eventtime'])-noise_time+timewindow/3))        # arg of ref, adapative time window     
    w1_noise1 = np.argmin(np.abs(seistoplot.times(reftime=seistoplot.stats['eventtime'])-noise_time-timewindow*2/3))   
    A0_noise1 = np.abs(hilbert(seistoplot.data[w0_noise1:w1_noise1])).max()/norm                
    #gca().add_patch(patches.Rectangle((seistoplot.timesarray[w0_ref]-phase_time,np.round(seis[0].stats['az'])-A0),seistoplot.timesarray[w1_ref]-seistoplot.timesarray[w0_ref],2*A0,alpha = 0.4, color = 'red'))
    w0_noise2 = np.argmin(np.abs(seistoplot.times(reftime=seistoplot.stats['eventtime'])-noise_time+timewindow/3-100))        # arg of ref, adapative time window     
    w1_noise2 = np.argmin(np.abs(seistoplot.times(reftime=seistoplot.stats['eventtime'])-noise_time-timewindow*2/3-100))   
    A0_noise2 = np.abs(hilbert(seistoplot.data[w0_noise2:w1_noise2])).max()/norm   

    w0_noise3 = np.argmin(np.abs(seistoplot.times(reftime=seistoplot.stats['eventtime'])-noise_time+timewindow/3-200))        # arg of ref, adapative time window     
    w1_noise3 = np.argmin(np.abs(seistoplot.times(reftime=seistoplot.stats['eventtime'])-noise_time-timewindow*2/3-200))   
    A0_noise3 = np.abs(hilbert(seistoplot.data[w0_noise3:w1_noise3])).max()/norm           

    print('A0_phase: ' +str(A0_phase)+' A0_noise: ' +str(A0_noise1)+ ' SNR: ' +str(A0_phase/A0_noise1))
    print('A0_phase: ' +str(A0_phase)+' A0_noise: ' +str(A0_noise2)+ ' SNR: ' +str(A0_phase/A0_noise2))
    print('A0_phase: ' +str(A0_phase)+' A0_noise: ' +str(A0_noise3)+ ' SNR: ' +str(A0_phase/A0_noise3))

    threshold = A0_phase #np.max(seistoplot.data/norm)
    
    print('threshold: '+str(threshold))
    if ((threshold>5 or threshold<0.05)):# and seis[0].stats['dist']>100) or (threshold<0.1 and seis[0].stats['dist']<100):
        strange_trace.append([s,seis[0].stats['az'],s_name,threshold])   
        
    plt.text(71,np.round(seis[0].stats['az'])+A0_phase/5,s_name+' #'+str(s), fontsize = 8)
# Put labels on graphs
print('!!!!!!!!!!!!!!!!!!!Stange Traces:----------------------->>>>>>')
print(strange_trace)
azis = np.array(azis)
dists = np.array(dists)

plt.subplot(1,4,1)
plt.title(' Sdiff dist < %d' % dist_range_1)
plt.ylim(azis.min()-1,azis.max()+1)
plt.xlabel('time around predicted arrival (s)')
plt.ylabel('azimuth (dg)')
if switch_yaxis:
   plt.gca().invert_yaxis()
   
plt.subplot(1,4,2)
plt.title(' Sdiff dist < %d' % dist_range_2)
plt.ylim(azis.min()-1,azis.max()+1)
plt.xlabel('time around predicted arrival (s)')
if switch_yaxis:
   plt.gca().invert_yaxis()
   
plt.subplot(1,4,3)
plt.title(' Sdiff dist < %d' % dist_range_3)
plt.ylim(azis.min()-1,azis.max()+1)
plt.xlabel('time around predicted arrival (s)')
if switch_yaxis:
   plt.gca().invert_yaxis()
plt.plot(cut_x,cut_y, '--', color='blue')

plt.subplot(1,4,4)
plt.title(' Sdiff dist < %d' % dist_range_4)
plt.ylim(azis.min()-1,azis.max()+1)
plt.xlabel('time around predicted arrival (s)')
if switch_yaxis:
   plt.gca().invert_yaxis()

plt.plot(cut_x,cut_y, '--', color='blue')


plt.suptitle('Waveform with Azimuth\n Event %s    Real data: %s , Syn Data: %s \n freq: %s s - %s s' % (event, real_component, syn_component, str(1/fmax), str(1/fmin)))

# Save file and show plot
#plt.savefig('/home/zl382/Pictures/Syn+Real/'+event+'data_with_azimuth.png')
plt.show()
