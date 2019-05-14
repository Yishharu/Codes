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
############### Edit After This Line ###################
event = '20100320'#sys.argv[1]

syn = False# Plot synthetics
real = True # Plot real data
color = False # color by measured travel times
switch_yaxis = True
per_norm = False

## Frequencies for filter

fmin1, fmax1 = 1/5, 1/1
fmin2, fmax2 = 1/10, 1/5
fmin3, fmax3 = 1/20, 1/10
fmin4, fmax4 = 1/30, 1/20

dist_min = 100
dist_max = 110

azim_min = 38
azim_max = 65

time_min = -20
time_max = 120

norm_constant = 1

real_component = 'BHT'
syn_component = 'BXT'

dir = '/raid3/zl382/Data/' + event + '/'
#dir = '/raid2/sc845/Lowermost/EastPacific/Data/20161225/CSEM/ULVZB7'
#dir = '/raid3/zl382/Data/20180910/'
# [x1,y1] = [20,312]
# [x2,y2] = [25,325]
# [x3,y3] = [51,337]
plot_cut = False

if plot_cut:
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
    seistoplot = seis.select(channel=real_component)[0]
    s_name = os.path.splitext(os.path.split(seislist[s])[1])[0]
    print('%s %d / %d of %s' %(s_name, s, len(seislist), event))
   # print(s_name +' '+ str(s)+' / '+str(len(seislist)) + ' of '+event)
    # print('dist: '+ str(seis[0].stats['dist'])+ 'az: '+str(seis[0].stats['az']))

    if seis[0].stats['az']<azim_min or seis[0].stats['az']>azim_max \
        or  seis[0].stats['dist']<dist_min or seis[0].stats['dist']>dist_max:
        continue

    align_time = seis[0].stats.traveltimes['Sdiff'] or seis[0].stats.traveltimes['S']

    if syn:
        seissyn= seis.select(channel = syn_component)[0]
    if per_norm:
        norm = np.max(seistoplot.data) / norm_constant
    elif count == 0:
        norm = np.max(seistoplot.data) / norm_constant

    azis.append(seis[0].stats['az']) # list all azimuths
    dists.append(seis[0].stats['dist'])

    ## Filter data 1
    plt.subplot(1,4,1)
    seis_filter = seistoplot.copy()
    seis_filter.filter('bandpass', freqmin=fmin1,freqmax=fmax1, zerophase=True)

    if per_norm:
        norm1 = np.max(seis_filter.data) / norm_constant
    elif count == 0:
        norm1 = np.max(seis_filter.data) / norm_constant
    if np.max(seis_filter.data / norm1) > 3:
        print('Warning: ', s_name,' amplitude too large!!')
        continue        
    if real:        #seistoplot.timesarray
       plt.plot(seis_filter.times(reftime=seis_filter.stats['eventtime'])-align_time, seis_filter.data / norm1 + np.round(seis[0].stats['az']),'k')
    print('Norm1 Value:', norm1)
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

    ## Filter data 2
    plt.subplot(1,4,2)
    seis_filter = seistoplot.copy()
    seis_filter.filter('bandpass', freqmin=fmin2,freqmax=fmax2, zerophase=True)
    if per_norm:
        norm2 = np.max(seis_filter.data) / norm_constant
    elif count == 0:
        norm2 = np.max(seis_filter.data) / norm_constant
    if np.max(seis_filter.data / norm2) > 3:
        print('Warning: ', s_name,' amplitude too large!!')
        continue
    if real:        #seistoplot.timesarray
       plt.plot(seis_filter.times(reftime=seis_filter.stats['eventtime'])-align_time, seis_filter.data / norm2 + np.round(seis[0].stats['az']),'k')
    print('Norm2 Value:', norm2)
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

    ## Filter data 3
    plt.subplot(1,4,3)
    seis_filter = seistoplot.copy()
    seis_filter.filter('bandpass', freqmin=fmin3,freqmax=fmax3, zerophase=True)
    if per_norm:
        norm3 = np.max(seis_filter.data) / norm_constant
    elif count == 0:
        norm3 = np.max(seis_filter.data) / norm_constant
    if real:        #seistoplot.timesarray
       plt.plot(seis_filter.times(reftime=seis_filter.stats['eventtime'])-align_time, seis_filter.data / norm3 + np.round(seis[0].stats['az']),'k')
    print('Norm3 Value:', norm3)
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

    ## Filter data 4
    plt.subplot(1,4,4)
    seis_filter = seistoplot.copy()
    seis_filter.filter('bandpass', freqmin=fmin4,freqmax=fmax4, zerophase=True)
    if per_norm:
        norm4 = np.max(seis_filter.data) / norm_constant
    elif count == 0:
        norm4 = np.max(seis_filter.data) / norm_constant
    print('Norm4 Value:', norm4)
    if real:        #seistoplot.timesarray
       plt.plot(seis_filter.times(reftime=seis_filter.stats['eventtime'])-align_time, seis_filter.data / norm4 + np.round(seis[0].stats['az']),'k')

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
    count = count+1

azis = np.array(azis)
dists = np.array(dists)

y_axis_adaptive = False

plt.subplot(1,4,1)
plt.title('filter %.0f - %.0f s' %(1/fmax1,1/fmin1))
if y_axis_adaptive:
    plt.ylim(azis.min()-1,azis.max()+1)
else:
    plt.ylim(azim_min,azim_max)
plt.xlabel('time around predicted arrival (s)')
plt.ylabel('azimuth (dg)')
if switch_yaxis:
   plt.gca().invert_yaxis()

plt.subplot(1,4,2)
plt.title('filter %.0f - %.0f s' %(1/fmax2,1/fmin2))
if y_axis_adaptive:
    plt.ylim(azis.min()-1,azis.max()+1)
else:
    plt.ylim(azim_min,azim_max)
plt.xlabel('time around predicted arrival (s)')
if switch_yaxis:
   plt.gca().invert_yaxis()

plt.subplot(1,4,3)
plt.title('filter %.0f - %.0f s' %(1/fmax3,1/fmin3))
if y_axis_adaptive:
    plt.ylim(azis.min()-1,azis.max()+1)
else:
    plt.ylim(azim_min,azim_max)
plt.xlabel('time around predicted arrival (s)')
if switch_yaxis:
   plt.gca().invert_yaxis()
if plot_cut:
    plt.plot(cut_x,cut_y, '--', color='blue')

plt.subplot(1,4,4)
plt.title('filter %.0f - %.0f s' %(1/fmax4,1/fmin4))
if y_axis_adaptive:
    plt.ylim(azis.min()-1,azis.max()+1)
else:
    plt.ylim(azim_min,azim_max)
plt.xlabel('time around predicted arrival (s)')
if switch_yaxis:
   plt.gca().invert_yaxis()
if plot_cut:
    plt.plot(cut_x,cut_y, '--', color='blue')

model = os.path.split(os.path.split(dir)[0])[1]
plt.suptitle('Waveform with freq ranges \n Event %s    Real data: %s , \n dist %s - %s deg' % (model, real_component, dist_min, dist_min))

# Save file and show plot
#plt.savefig('/home/zl382/Pictures/Syn+Real/'+event+'data_with_azimuth.png')
plt.show()
