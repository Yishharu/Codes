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
plt.rcParams.update({'font.size': 20}) 
############### Edit After This Line ###################
Location = 'Hawaii'
Event = '20180910'#sys.argv[1]

syn = False# Plot synthetics
real = True # Plot real data
color = False # color by measured travel times
switch_yaxis = False
per_norm = False

## Frequencies for filter
fmin = 1/20. #Hz
fmax = 1/10.  #Hzseis

azi_range_1_min, azi_range_1_max = 6, 8
azi_range_2_min, azi_range_2_max= 8, 10
azi_range_3_min, azi_range_3_max= 10, 12
azi_range_4_min, azi_range_4_max= 12, 15


dist_min = 90
dist_max = 140

time_min = -20
time_max = 100

norm_constant = 1.5

real_component = 'BHT'
syn_component = 'BXT'

dir = '/raid1/zl382/Data/' +Location+'/'+ Event + '/'
print('Reaing data from ', dir)

# 10-20s post cursor
[x1,y1] = [29,5]     # time , azi, better azi from small to large
[x2,y2] = [25,9]
[x3,y3] = [33,13]
timewindow = 15
# 1-5s post cursor
# [x1,y1] = [68.5,6]     # time , azi, better azi from small to large
# [x2,y2] = [67,8]
# [x3,y3] = [74,13]
# timewindow = 10

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
location_dict = np.load(dir+'STALOCATION.npy').item()
for s, (s_name, (dist,azi,stla,stlo,sbaz)) in enumerate(location_dict.items()):
    print('%s %d / %d of %s' %(s_name, s, len(location_dict), Event))

    if dist<dist_min or dist>dist_max:
        continue
    full_path = dir+s_name+'.PICKLE'
    if not os.path.exists(full_path):
        continue
    seis = read(dir+s_name+'.PICKLE',format='PICKLE') # read seismogram
    seis.differentiate()
    seistoplot= seis.select(channel=real_component)[0]

    phase_time = seis[0].stats.traveltimes['Sdiff'] or seis[0].stats.traveltimes['S']

    # Split seismograms by azimuth range (this needs to be adapted per event to produce a reasonable plot.
    if azi < azi_range_1_max and azi > azi_range_1_min:
        plt.subplot(1,4,1)
    elif azi < azi_range_2_max and azi > azi_range_2_min:
        plt.subplot(1,4,2)
    elif azi < azi_range_3_max and azi > azi_range_3_min:
        plt.subplot(1,4,3)
    elif azi < azi_range_4_max and azi > azi_range_4_min:
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

    dist = np.round(dist)
    if real:        #seistoplot.timesarray
       plt.plot(seistoplot.times(reftime=seistoplot.stats['eventtime'])-align_time, seistoplot.data / norm + np.round(seis[0].stats['dist']),'k')
    if syn:
        plt.plot(seissyn.timesarray-align_time,seissyn.data / norm + np.round(seis[0].stats['dist']),'r')

    azis.append(seis[0].stats['az']) # list all azimuths
    dists.append(seis[0].stats['dist'])

          # Plot travel time predictions
    for k in seis[0].stats.traveltimes.keys():
        if seis[0].stats.traveltimes[k]!=None: #and k!='S90' and k!='P90' and seis[0].stats.traveltimes[k]-align_time<time_max and seis[0].stats.traveltimes[k]-align_time>time_min:
            if k == 'Sdiff' or k == 'S':
                plt.plot(seis[0].stats.traveltimes[k]-align_time, dist,'g',marker='o',markersize=4)
                print('Sdiff: ' + str(seis[0].stats.traveltimes[k]-align_time))
            elif k == 'pSdiff':
                plt.plot(seis[0].stats.traveltimes[k]-align_time, dist,'r',marker='o',markersize=4)
                print('pSdiff: ' + str(seis[0].stats.traveltimes[k]-align_time))
            elif k == 'sSdiff':
                plt.plot(seis[0].stats.traveltimes[k]-align_time, dist,'orange',marker='o',markersize=4)
                print('sSdiff: ' + str(seis[0].stats.traveltimes[k]-align_time))
           # plt.text(seis[0].stats.traveltimes[k]-align_time, azi,k, fontsize = 8)
                     # plt.text(seis[0].stats.traveltimes[k]-seis[0].stats.traveltimes[phase],azi-0.5, k)

    if azi <cut_y.min() or azi>cut_y.max() or dist <94:
        continue

    start_patch = np.interp(azi, cut_y, cut_x) 
    print('Patch draw at azi %d, time %f' %(azi, start_patch))
    print('NORM VALUE: ' + str(norm))   
    # plot patches
    w0_ref = np.argmin(np.abs(seistoplot.timesarray-phase_time-start_patch))        # arg of ref, adapative time window     
    w1_ref = np.argmin(np.abs(seistoplot.timesarray-phase_time-start_patch-timewindow))   
    A0 = np.max(np.abs(hilbert(seistoplot.data[w0_ref:w1_ref])))/norm                
    gca().add_patch(patches.Rectangle((seistoplot.timesarray[w0_ref]-phase_time,dist-A0),seistoplot.timesarray[w1_ref]-seistoplot.timesarray[w0_ref],2*A0,alpha = 0.15, color = 'y'))


azis = np.array(azis)
dists = np.array(dists)

ax = plt.subplot(1,4,1)
plt.title(' azi %d - %d' % (azi_range_1_min , azi_range_1_max))
plt.xlim([time_min,time_max])
plt.ylim(dists.min()-1,dists.max()+1)
plt.xlabel('Time around Sdiff (s)')
plt.ylabel('Distance (deg)')
ax.xaxis.set_major_locator(plt.MultipleLocator(20))   
ax.xaxis.set_minor_locator(plt.MultipleLocator(5)) 
if switch_yaxis:
   plt.gca().invert_yaxis()

ax = plt.subplot(1,4,2)
plt.title(' azi %d - %d' % (azi_range_2_min , azi_range_2_max))
plt.xlim([time_min,time_max])
plt.ylim(dists.min()-1,dists.max()+1)
plt.xlabel('Time around Sdiff (s)')
ax.xaxis.set_major_locator(plt.MultipleLocator(20))   
ax.xaxis.set_minor_locator(plt.MultipleLocator(5)) 
if switch_yaxis:
   plt.gca().invert_yaxis()

ax = plt.subplot(1,4,3)
plt.title(' azi %d - %d' % (azi_range_3_min , azi_range_3_max))
plt.xlim([time_min,time_max])
plt.ylim(dists.min()-1,dists.max()+1)
plt.xlabel('Time around Sdiff (s)')
ax.xaxis.set_major_locator(plt.MultipleLocator(20))   
ax.xaxis.set_minor_locator(plt.MultipleLocator(5)) 
if switch_yaxis:
   plt.gca().invert_yaxis()


ax = plt.subplot(1,4,4)
plt.title(' azi %d - %d' % (azi_range_4_min , azi_range_4_max))
plt.xlim([time_min,time_max])
plt.ylim(dists.min()-1,dists.max()+1)
plt.xlabel('Time around Sdiff (s)')
ax.xaxis.set_major_locator(plt.MultipleLocator(20))   
ax.xaxis.set_minor_locator(plt.MultipleLocator(5)) 
if switch_yaxis:
   plt.gca().invert_yaxis()

model = os.path.split(os.path.split(dir)[0])[1]
# plt.suptitle('Waveform with Distance\n Event %s    Real data: %s , Syn Data: %s \n freq: %s s - %s s' % (model, real_component, syn_component, str(1/fmax), str(1/fmin)))

# Save file and show plot
#plt.savefig('/home/zl382/Pictures/Syn+Real/'+event+'data_with_azimuth.png')
plt.show()
