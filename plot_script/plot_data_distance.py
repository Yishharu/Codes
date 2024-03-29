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
Location = 'Hawaii'
event = '20100320'#sys.argv[1]

syn = False# Plot synthetics
real = True # Plot real data
color = False # color by measured travel times
switch_yaxis = False
per_norm = False

## Frequencies for filter
fmin = 1/20. #Hz
fmax = 1/10.  #Hzseis

azi_range_0 = 45
azi_range_1 = 50
azi_range_2 = 55
azi_range_3 = 60
azi_range_4 = 65

dist_min = 90
dist_max = 140

time_min = -20
time_max = 80

norm_constant = 4

real_component = 'BHT'
syn_component = 'BXT'

dir = '/raid1/zl382/Data/' +Location+'/'+ event + '/'
print('Reaing data from ', dir)
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
    seistoplot= seis.select(channel=real_component)[0]
    s_name = os.path.splitext(os.path.split(seislist[s])[1])[0]
    print('%s %d / %d of %s' %(s_name, s, len(seislist), event))
   # print(s_name +' '+ str(s)+' / '+str(len(seislist)) + ' of '+event)
    # print('dist: '+ str(seis[0].stats['dist'])+ 'az: '+str(seis[0].stats['az']))

    if seis[0].stats['dist']<dist_min or seis[0].stats['dist']>dist_max:
        continue

    # Split seismograms by azimuth range (this needs to be adapted per event to produce a reasonable plot.
    if seis[0].stats['az'] < azi_range_1 and seis[0].stats['az'] > azi_range_0:
        plt.subplot(1,4,1)
    elif seis[0].stats['az'] < azi_range_2 and seis[0].stats['az'] > azi_range_1:
        plt.subplot(1,4,2)
    elif seis[0].stats['az'] < azi_range_3 and seis[0].stats['az'] > azi_range_2:
        plt.subplot(1,4,3)
    elif seis[0].stats['az'] < azi_range_4 and seis[0].stats['az'] > azi_range_3:
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
    
#          timewindow = 3*20
#          w0 = np.argmin(np.abs(seistoplot.times-Sdifftime+timewindow/3))
#          w1 = np.argmin(np.abs(seistoplot.times-Sdifftime-timewindow*2/3))
#          window_wid = seistoplot.times[w1] - seistoplot.times[w0]
#          window_hei = np.max(np.abs(hilbert(seistoplot.data[w0:w1])))/norm
#        #                test_w0 = np.argmin(np.abs(seistoplot.times()-Sdifftime+(-1)))
#        #                test_w1 = np.argmin(np.abs(seistoplot.times()-Sdifftime-149))
#        #                test_window_hei = np.max(np.abs(hilbert(seistoplot.data[test_w0:test_w1])))/norm
#        #                print('Window difference: '+str( (test_window_hei-window_hei)/window_hei))
#          gca().add_patch(patches.Rectangle((seistoplot.times[w0]-Sdifftime,np.round(seis[0].stats['az'])-window_hei),window_wid,2*window_hei,alpha = 0.2, color = 'red'))  # width height

#     # Find out the strange trace
#     w0_ref = np.argmin(np.abs(seistoplot.times(reftime=seistoplot.stats['eventtime'])-align_time+10))        # arg of ref, adapative time window
#     w1_ref = np.argmin(np.abs(seistoplot.times(reftime=seistoplot.stats['eventtime'])-align_time-20))
#     A0 = np.max(np.abs(seistoplot.data[w0_ref:w1_ref]))/norm
#     #gca().add_patch(patches.Rectangle((seistoplot.timesarray[w0_ref]-align_time,np.round(seis[0].stats['az'])-A0),seistoplot.timesarray[w1_ref]-seistoplot.timesarray[w0_ref],2*A0,alpha = 0.4, color = 'red'))
#     threshold = A0 #np.max(seistoplot.data/norm)

#     print('NORM VALUE: %f ; threshold = %.5f' %(norm, threshold))
#     if ((threshold>5 or threshold<0.05)):# and seis[0].stats['dist']>100) or (threshold<0.1 and seis[0].stats['dist']<100):
#         strange_trace.append([s,seis[0].stats['az'],s_name,threshold])

#     # plt.text(81,np.round(seis[0].stats['az'])+A0/5,s_name+' #'+str(s), fontsize = 8)
# # Put labels on graphs
# print('!!!!!!!!!!!!!!!!!!!Stange Traces:----------------------->>>>>>')
# print(strange_trace)

azis = np.array(azis)
dists = np.array(dists)

plt.subplot(1,4,1)
plt.title(' Sdiff az < %d' % azi_range_1)
plt.xlim([time_min,time_max])
plt.ylim(dists.min()-1,dists.max()+1)
plt.xlabel('time around predicted arrival (s)')
plt.ylabel('azimuth (dg)')
if switch_yaxis:
   plt.gca().invert_yaxis()

plt.subplot(1,4,2)
plt.title(' Sdiff az < %d' % azi_range_2)
plt.xlim([time_min,time_max])
plt.ylim(dists.min()-1,dists.max()+1)
plt.xlabel('time around predicted arrival (s)')
if switch_yaxis:
   plt.gca().invert_yaxis()

plt.subplot(1,4,3)
plt.title(' Sdiff az < %d' % azi_range_3)
plt.xlim([time_min,time_max])
plt.ylim(dists.min()-1,dists.max()+1)
plt.xlabel('time around predicted arrival (s)')
if switch_yaxis:
   plt.gca().invert_yaxis()
if plot_cut:
    plt.plot(cut_x,cut_y, '--', color='blue')

plt.subplot(1,4,4)
plt.title(' Sdiff az < %d' % azi_range_4)
plt.xlim([time_min,time_max])
plt.ylim(dists.min()-1,dists.max()+1)
plt.xlabel('time around predicted arrival (s)')
if switch_yaxis:
   plt.gca().invert_yaxis()
if plot_cut:
    plt.plot(cut_x,cut_y, '--', color='blue')

model = os.path.split(os.path.split(dir)[0])[1]
plt.suptitle('Waveform with Distance\n Event %s    Real data: %s , Syn Data: %s \n freq: %s s - %s s' % (model, real_component, syn_component, str(1/fmax), str(1/fmin)))

# Save file and show plot
#plt.savefig('/home/zl382/Pictures/Syn+Real/'+event+'data_with_azimuth.png')
plt.show()
