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

Location = 'Hawaii'
Event = '20100320'

syn = False# Plot synthetics
real = True # Plot real data
color = False # color by measured travel times
switch_yaxis = True
per_norm = False

## Frequencies for filter
fmin, fmax = 1/20, 1/10 #Hz
fmin2, fmax2 = 1/20, 1/10 #Hz

dist_range_1 = 90
dist_range_2 = 100
dist_range_3 = 110
dist_range_4 = 120

time_min = -20
time_max = 100

azim_min = 37
azim_max = 66

dist_min = 101
dist_max = 110

norm_constant1 = 2
norm_constant2 = 2

real_component = 'BHT'
syn_component = 'BCT'

dir = '/raid1/zl382/Data/'+Location+'/'+Event + '/'# '/raid2/sc845/Lowermost/EastPacific/Data/20161225/'
# dir2 = '/raid1/zl382/Data/Hawaii/20180910/CSEM/ULVZ_20180910/'
dir2 = '/raid1/zl382/Data/Hawaii/20100320/CSEM/ULVZ_20100320/'


plt.rcParams.update({'font.size': 30})   
###################### Edit Before This Line ######################################

seislist = glob.glob(dir + '*PICKLE')
azis=[]
dists=[]
strange_trace = []
plt.subplots(figsize=(20, 8))
# Loop through seismograms
count = 0
location_dict = np.load(dir+'STALOCATION.npy').item()

plt.subplot(1,2,1)
norm_constant = norm_constant1
# 10-20s post cursor
[x1,y1] = [55,35]
[x2,y2] = [35,50]
[x3,y3] = [15,65]

cut_x = np.linspace(x1,x2, num=10, endpoint=False)    # First Line
cut_y = np.linspace(y1,y2, num=10, endpoint=False)
cut_x = np.append(cut_x,np.linspace(x2,x3, num = 11))
cut_y = np.append(cut_y,np.linspace(y2,y3, num=11))

i_Sdiff = 0
for s, (s_name, (dist,azi,stla,stlo,sbaz)) in enumerate(location_dict.items()):
    print('%s %d / %d of %s' %(s_name, s, len(location_dict), Event))
    if azi<azim_min or azi>azim_max \
    or dist<dist_min or dist>dist_max:
        continue
    full_path = dir+s_name+'.PICKLE'
    if not os.path.exists(full_path):
        continue
    seis = read(dir+s_name+'.PICKLE',format='PICKLE') # read seismogram
    seis.differentiate()
    seistoplot= seis.select(channel=real_component)[0]

   # print(s_name +' '+ str(s)+' / '+str(len(seislist)) + ' of '+Event)
    # print('dist: '+ str(seis[0].stats['dist'])+ 'az: '+str(seis[0].stats['az']))

    phase_time = seis[0].stats.traveltimes['Sdiff'] or seis[0].stats.traveltimes['S']
    noise_time = seis[0].stats.traveltimes['P'] or seis[0].stats.traveltimes['Pdiff']-300

    align_time = seis[0].stats.traveltimes['Sdiff'] or seis[0].stats.traveltimes['S']

       # Filter data
    seistoplot.filter('bandpass', freqmin=fmin,freqmax=fmax, zerophase=True)  
    if syn:
        seissyn= seis.select(channel = syn_component)[0]
    if per_norm:
        norm = np.max(seistoplot.data) / norm_constant
    elif count == 0:
        norm = np.max(seistoplot.data) / norm_constant
    count = count+1            


 #   [wt, period, coi] = eng.cwt(seistoplot.data,delta,wname,'VoicesPerOctave', Nv,nargout=3)
    # data_filter = eng.icwt(wt, period, wname, [seconds(10) seconds(30)],'SignalMean', 0);
  
    plt.plot(seistoplot.times(reftime=seistoplot.stats['eventtime'])-align_time, seistoplot.data / norm + np.round(seis[0].stats['az']),'k')
     

    azis.append(seis[0].stats['az']) # list all azimuths
    dists.append(seis[0].stats['dist'])    
               
    plt.xlim([time_min,time_max])
          # Plot travel time predictions
    for k in seis[0].stats.traveltimes.keys():
        if seis[0].stats.traveltimes[k]!=None: #and k!='S90' and k!='P90' and seis[0].stats.traveltimes[k]-align_time<time_max and seis[0].stats.traveltimes[k]-align_time>time_min:
            if k == 'Sdiff' or k == 'S':
                plt.scatter(seis[0].stats.traveltimes[k]-align_time, azi,c='g',marker='o',s=20, label='Sdiff & S' if i_Sdiff==0 else '')
                # print('Sdiff: ' + str(seis[0].stats.traveltimes[k]-align_time))
                i_Sdiff += 1
            # elif k == 'pSdiff':
            #     plt.plot(seis[0].stats.traveltimes[k]-align_time, np.round(seis[0].stats['az']),'r',marker='o',markersize=4)
            #     print('pSdiff: ' + str(seis[0].stats.traveltimes[k]-align_time))
            # elif k == 'sSdiff':
            #     plt.plot(seis[0].stats.traveltimes[k]-align_time, np.round(seis[0].stats['az']),'orange',marker='o',markersize=4)
            #     print('sSdiff: ' + str(seis[0].stats.traveltimes[k]-align_time))
            # elif k == 'pSKKS':
            #     plt.plot(seis[0].stats.traveltimes[k]-align_time, np.round(seis[0].stats['az']),'yellow',marker='o',markersize=4)
            #     print('pSKKS: ' + str(seis[0].stats.traveltimes[k]-align_time))
            # elif k == 'SP':
            #     plt.plot(seis[0].stats.traveltimes[k]-align_time, np.round(seis[0].stats['az']),'blue',marker='o',markersize=4)
            #     print('SP: ' + str(seis[0].stats.traveltimes[k]-align_time))
 
           # plt.text(seis[0].stats.traveltimes[k]-align_time, np.round(seis[0].stats['az']),k, fontsize = 8)
                     # plt.text(seis[0].stats.traveltimes[k]-seis[0].stats.traveltimes[phase],np.round(seis[0].stats['az'])-0.5, k)              

    if azi <45:
        continue



    timewindow = 30
    start_patch = np.interp(azi, cut_y, cut_x) 
    print('Patch draw at azi %d, time %f' %(azi, start_patch))
    print('NORM VALUE: ' + str(norm))   
    # plot patches
    w0_ref = np.argmin(np.abs(seistoplot.timesarray-phase_time-start_patch))        # arg of ref, adapative time window     
    w1_ref = np.argmin(np.abs(seistoplot.timesarray-phase_time-start_patch-timewindow))   
    A0 = np.max(np.abs(hilbert(seistoplot.data[w0_ref:w1_ref])))/norm                
    gca().add_patch(patches.Rectangle((seistoplot.timesarray[w0_ref]-phase_time,np.round(seis[0].stats['az'])-A0),seistoplot.timesarray[w1_ref]-seistoplot.timesarray[w0_ref],2*A0,alpha = 0.05, color = 'y'))

    print('NORM VALUE: ' + str(norm))     

#######################################################################################################################################################################################

###################################################################################################################################################################################################

count = 0
plt.subplot(1,2,2) 
norm_constant = norm_constant2

i_Sdiff = 0

dir = dir2
real_component = syn_component
for s, (s_name, (dist,azi,stla,stlo,sbaz)) in enumerate(location_dict.items()):
    print('%s %d / %d of %s' %(s_name, s, len(location_dict), Event))
    if azi<azim_min or azi>azim_max \
    or dist<dist_min or dist>dist_max:
        continue
    full_path = dir+s_name+'.PICKLE'
    if not os.path.exists(full_path):
        continue
    seis = read(dir+s_name+'.PICKLE',format='PICKLE') # read seismogram
    seis.differentiate()
    seistoplot= seis.select(channel=real_component)[0]
   # print(s_name +' '+ str(s)+' / '+str(len(seislist)) + ' of '+Event)
    # print('dist: '+ str(seis[0].stats['dist'])+ 'az: '+str(seis[0].stats['az']))

    phase_time = seis[0].stats.traveltimes['Sdiff'] or seis[0].stats.traveltimes['S']
    noise_time = seis[0].stats.traveltimes['P'] or seis[0].stats.traveltimes['Pdiff']-300

    align_time = seis[0].stats.traveltimes['Sdiff'] or seis[0].stats.traveltimes['S']
        
       # Filter data
    seistoplot.filter('bandpass', freqmin=fmin2,freqmax=fmax2, zerophase=True)     
    if syn:
        seissyn= seis.select(channel = syn_component)[0]
    if per_norm:
        norm = np.max(seistoplot.data) / norm_constant
    elif count == 0:
        norm = np.max(seistoplot.data) / norm_constant
    count = count+1  

 #   [wt, period, coi] = eng.cwt(seistoplot.data,delta,wname,'VoicesPerOctave', Nv,nargout=3)
    # data_filter = eng.icwt(wt, period, wname, [seconds(10) seconds(30)],'SignalMean', 0);
  
    plt.plot(seistoplot.time-align_time, seistoplot.data / norm + np.round(seis[0].stats['az']),'r')
     

    azis.append(seis[0].stats['az']) # list all azimuths
    dists.append(seis[0].stats['dist'])    
               
    plt.xlim([time_min,time_max])
          # Plot travel time predictions
    for k in seis[0].stats.traveltimes.keys():
        if seis[0].stats.traveltimes[k]!=None: #and k!='S90' and k!='P90' and seis[0].stats.traveltimes[k]-align_time<time_max and seis[0].stats.traveltimes[k]-align_time>time_min:
            if k == 'Sdiff' or k == 'S':
                plt.scatter(seis[0].stats.traveltimes[k]-align_time, azi,c='g',marker='o',s=20, zorder=10, label='Sdiff & S' if i_Sdiff==0 else '')
                # print('Sdiff: ' + str(seis[0].stats.traveltimes[k]-align_time))
                i_Sdiff += 1
            # elif k == 'pSdiff':
            #     plt.plot(seis[0].stats.traveltimes[k]-align_time, np.round(seis[0].stats['az']),'r',marker='o',markersize=4)
            #     print('pSdiff: ' + str(seis[0].stats.traveltimes[k]-align_time))
            # elif k == 'sSdiff':
            #     plt.plot(seis[0].stats.traveltimes[k]-align_time, np.round(seis[0].stats['az']),'orange',marker='o',markersize=4)
            #     print('sSdiff: ' + str(seis[0].stats.traveltimes[k]-align_time))
            # elif k == 'pSKKS':
            #     plt.plot(seis[0].stats.traveltimes[k]-align_time, np.round(seis[0].stats['az']),'yellow',marker='o',markersize=4)
            #     print('pSKKS: ' + str(seis[0].stats.traveltimes[k]-align_time))
            # elif k == 'SP':
            #     plt.plot(seis[0].stats.traveltimes[k]-align_time, np.round(seis[0].stats['az']),'blue',marker='o',markersize=4)
            #     print('SP: ' + str(seis[0].stats.traveltimes[k]-align_time))
 
           # plt.text(seis[0].stats.traveltimes[k]-align_time, np.round(seis[0].stats['az']),k, fontsize = 8)
                     # plt.text(seis[0].stats.traveltimes[k]-seis[0].stats.traveltimes[phase],np.round(seis[0].stats['az'])-0.5, k)              


    print('NORM VALUE: ' + str(norm))    

    if azi <45:
        continue
    timewindow = 20
    start_patch = np.interp(azi, cut_y, cut_x) 
    print('Patch draw at azi %d, time %f' %(azi, start_patch))
    print('NORM VALUE: ' + str(norm))   
    # plot patches
    w0_ref = np.argmin(np.abs(seistoplot.time-phase_time-start_patch))        # arg of ref, adapative time window     
    w1_ref = np.argmin(np.abs(seistoplot.time-phase_time-start_patch-timewindow))   
    A0 = np.max(np.abs(hilbert(seistoplot.data[w0_ref:w1_ref])))/norm                
    gca().add_patch(patches.Rectangle((seistoplot.time[w0_ref]-phase_time,np.round(seis[0].stats['az'])-A0),seistoplot.time[w1_ref]-seistoplot.time[w0_ref],2*A0,alpha = 0.05, color = 'y'))

   # plt.text(81,np.round(seis[0].stats['az'])+A0/5,s_name+' #'+str(s), fontsize = 8)
# Put labels on graphs

azis = np.array(azis)
dists = np.array(dists)
   
ax = plt.subplot(1,2,1)
#plt.title('100 < Sdiff distance < 110')
# plt.ylim([])
plt.ylim(azis.min()-3,azis.max()+3)
#plt.ylim(0,31)
plt.xlabel('Time around predicted arrival (s)')
plt.ylabel('Azimuth (deg)')
if switch_yaxis:
   plt.gca().invert_yaxis()
ax.xaxis.set_major_locator(plt.MultipleLocator(20))   
ax.xaxis.set_minor_locator(plt.MultipleLocator(5)) 
plt.legend(loc=4,prop={'size':12})

ax = plt.subplot(1,2,2)
#plt.title('100 < Sdiff distance < 110')
# plt.ylim([])
plt.ylim(azis.min()-3,azis.max()+3)
#plt.ylim(0,31)
plt.xlabel('Time around predicted arrival (s)')
# plt.ylabel('Azimuth (deg)')
if switch_yaxis:
   plt.gca().invert_yaxis()
ax.xaxis.set_major_locator(plt.MultipleLocator(20))   
ax.xaxis.set_minor_locator(plt.MultipleLocator(5)) 
plt.legend(loc=4,prop={'size':12})
plt.show()
