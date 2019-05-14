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
Event = '20100320'#sys.argv[1]

syn = False# Plot synthetics
real = not syn # Plot real data
color = False # color by measured travel times
switch_yaxis = True
per_norm = False

## Frequencies for filter
fmin = 1/20. #Hz
fmax = 1/10.  #Hzseis

dist_range_0 = 94
dist_range_1 = 100
dist_range_2 = 110


azi_min = 38
azi_max = 65

time_min = -20
time_max = 80

norm_constant = 2.5

real_component = 'BHT'
syn_component = 'BCT'

dir = '/raid1/zl382/Data/'+Location+'/'+Event+'/'
# dir = '/raid1/zl382/Data/Hawaii/20180910/CSEM/ULVZ_20180910/'
print('Reading Data at' , dir)
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

plt.rcParams.update({'font.size': 25})  
###################### Edit Before This Line ######################################

seislist = glob.glob(dir + '*PICKLE')
azis=[]
dists=[]
strange_trace = []

# Loop through seismograms
count = 0
location_dict = np.load('/raid1/zl382/Data/Hawaii/20100320/STALOCATION.npy').item()
for s, (s_name, (dist,azi,stla,stlo,sazi)) in enumerate(location_dict.items()):
    print('%s %d / %d of %s' %(s_name, s, len(location_dict), Event))
    if azi<azi_min or azi>azi_max :
        continue
   #try:
    full_path = dir+s_name+'.PICKLE'
    if not os.path.exists(full_path):
        continue
    seis = read(dir+s_name+'.PICKLE',format='PICKLE') # read seismogram
    # Split seismograms by distance range (this needs to be adapted per event to produce a reasonable plot.
    if dist < dist_range_1 and dist > dist_range_0:
        plt.subplot(1,2,1)
    elif dist < dist_range_2 and dist > dist_range_1:
        plt.subplot(1,2,2)

    else:
        continue
    align_time = seis[0].stats.traveltimes['Sdiff'] or seis[0].stats.traveltimes['S']

    if syn:
        seissyn= seis.select(channel = syn_component)[0]
        seissyn.filter('bandpass', freqmin=fmin,freqmax=fmax, zerophase=True)
        if per_norm:
            norm = np.max(seissyn.data) / norm_constant
        elif count == 0:
            norm = np.max(seissyn.data) / norm_constant

        plt.plot(seissyn.time-align_time,seissyn.data / norm + np.round(seis[0].stats['az']),'r')
    elif real:
        seistoplot= seis.select(channel = real_component)[0]
        seistoplot.differentiate()
        seistoplot.filter('bandpass', freqmin=fmin,freqmax=fmax, zerophase=True)
        if per_norm:
            norm = np.max(seistoplot.data) / norm_constant
        elif count == 0:
            norm = np.max(seistoplot.data) / norm_constant
        plt.plot(seistoplot.times(reftime=seistoplot.stats['eventtime'])-align_time, seistoplot.data / norm + np.round(seis[0].stats['az']),'k')

    count = count+1
    azis.append(seis[0].stats['az']) # list all azimuths
    dists.append(seis[0].stats['dist'])

    plt.xlim([time_min,time_max])
          # Plot travel time predictions
    for k in seis[0].stats.traveltimes.keys():
        if seis[0].stats.traveltimes[k]!=None: #and k!='S90' and k!='P90' and seis[0].stats.traveltimes[k]-align_time<time_max and seis[0].stats.traveltimes[k]-align_time>time_min:
            if k == 'Sdiff' or k == 'S':
                plt.plot(seis[0].stats.traveltimes[k]-align_time, np.round(seis[0].stats['az']),'g',marker='o',markersize=4)
                print('Sdiff: ' + str(seis[0].stats.traveltimes[k]-align_time))
            # elif k == 'pSdiff':
            #     plt.plot(seis[0].stats.traveltimes[k]-align_time, np.round(seis[0].stats['az']),'r',marker='o',markersize=4)
            #     print('pSdiff: ' + str(seis[0].stats.traveltimes[k]-align_time))
            # elif k == 'sSdiff':
            #     plt.plot(seis[0].stats.traveltimes[k]-align_time, np.round(seis[0].stats['az']),'orange',marker='o',markersize=4)
            #     print('sSdiff: ' + str(seis[0].stats.traveltimes[k]-align_time))
           # plt.text(seis[0].stats.traveltimes[k]-align_time, np.round(seis[0].stats['az']),k, fontsize = 8)
                     # plt.text(seis[0].stats.traveltimes[k]-seis[0].stats.traveltimes[phase],np.round(seis[0].stats['az'])-0.5, k)
    
    # timewindow = 3*20
#          w0 = np.argmin(np.abs(seistoplot.times-Sdifftime+timewindow/3))
#          w1 = np.argmin(np.abs(seistoplot.times-Sdifftime-timewindow*2/3))
#          window_wid = seistoplot.times[w1] - seistoplot.times[w0]
#          window_hei = np.max(np.abs(hilbert(seistoplot.data[w0:w1])))/norm
#        #                test_w0 = np.argmin(np.abs(seistoplot.times()-Sdifftime+(-1)))
#        #                test_w1 = np.argmin(np.abs(seistoplot.times()-Sdifftime-149))
#        #                test_window_hei = np.max(np.abs(hilbert(seistoplot.data[test_w0:test_w1])))/norm
#        #                print('Window difference: '+str( (test_window_hei-window_hei)/window_hei))
#          gca().add_patch(patches.Rectangle((seistoplot.times[w0]-Sdifftime,np.round(seis[0].stats['az'])-window_hei),window_wid,2*window_hei,alpha = 0.2, color = 'red'))  # width height

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

plt.subplot(1,2,1)
# plt.title(' Distance from %d to %d' % (dist_range_0, dist_range_1))
plt.ylim(azis.min()-2,azis.max()+2)
plt.xlabel('Time around Predicted Sdiff Arrival (s)')
plt.ylabel('Azimuth (deg)')
if switch_yaxis:
   plt.gca().invert_yaxis()

plt.subplot(1,2,2)
# plt.title(' Distance from %d to %d' % (dist_range_1, dist_range_2))
plt.ylim(azis.min()-2,azis.max()+2)
plt.xlabel('Time around Predicted Sdiff Arrival (s)')
if switch_yaxis:
   plt.gca().invert_yaxis()


model = os.path.split(os.path.split(dir)[0])[1]
# plt.suptitle('Waveform with Azimuth\n Event %s    Real data: %s , Syn Data: %s \n freq: %s s - %s s' % (model, real_component, syn_component, str(1/fmax), str(1/fmin)))

# Save file and show plot
#plt.savefig('/home/zl382/Pictures/Syn+Real/'+event+'data_with_azimuth.png')
plt.show()
