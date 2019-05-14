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
if_round = True

## Frequencies for filter
fmin = 1/20. #Hz
fmax = 1/10.  #Hzseis

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

norm_constant = 1.5

real_component = 'BHT'
syn_component = 'BXT'

dir = '/raid1/zl382/Data/'+Location+'/'+Event + '/'# '/raid2/sc845/Lowermost/EastPacific/Data/20161225/'

# 10-20s post cursor
[x1,y1] = [15,65]
[x2,y2] = [35,50]
[x3,y3] = [55,35]

# # 1-5s post cursor
# [x1,y1] = [40,65]   #  time , azimuth
# [x2,y2] = [60,50]
# [x3,y3] = [90,35]

cut_x = np.linspace(x1,x2, num=10, endpoint=False)    # First Line
cut_y = np.linspace(y1,y2, num=10, endpoint=False)
cut_x = np.append(cut_x,np.linspace(x2,x3, num = 11))
cut_y = np.append(cut_y,np.linspace(y2,y3, num=11))

cut_x = cut_x[::-1]
cut_y = cut_y[::-1]
plt.rcParams.update({'font.size': 30})   
###################### Edit Before This Line ######################################
def set_size(w,h, ax=None):
    """ w, h: width, height in inches """
    if not ax: ax=plt.gca()
    l = ax.figure.subplotpars.left
    r = ax.figure.subplotpars.right
    t = ax.figure.subplotpars.top
    b = ax.figure.subplotpars.bottom
    figw = float(w)/(r-l)
    figh = float(h)/(t-b)
    ax.figure.set_size_inches(figw, figh)

seislist = glob.glob(dir + '*PICKLE')
azis=[]
dists=[]
strange_trace = []

# Loop through seismograms
count = 0
location_dict = np.load(dir+'STALOCATION.npy').item()


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
    seistoplot.filter('bandpass', freqmin=fmin,freqmax=fmax, zerophase=True)    
    if syn:
        seissyn.filter('bandpass', freqmin=fmin,freqmax=fmax, zerophase=True)  
    if syn:
        seissyn= seis.select(channel = syn_component)[0]
    if per_norm:
        norm = np.max(seistoplot.data) / norm_constant
    elif count == 0:
        norm = np.max(seistoplot.data) / norm_constant
    count = count+1          
       # Filter data
 
    if if_round:
        azi = np.round(azi)
 #   [wt, period, coi] = eng.cwt(seistoplot.data,delta,wname,'VoicesPerOctave', Nv,nargout=3)
    # data_filter = eng.icwt(wt, period, wname, [seconds(10) seconds(30)],'SignalMean', 0);

         
    plt.plot(seistoplot.times(reftime=seistoplot.stats['eventtime'])-align_time, seistoplot.data / norm + azi,'k')   
    print('NORM VALUE: ' + str(norm))
    azis.append(seis[0].stats['az']) # list all azimuths
    dists.append(seis[0].stats['dist'])    
               
    plt.xlim([time_min,time_max])
          # Plot travel time predictions
    for k in seis[0].stats.traveltimes.keys():
        if seis[0].stats.traveltimes[k]!=None: #and k!='S90' and k!='P90' and seis[0].stats.traveltimes[k]-align_time<time_max and seis[0].stats.traveltimes[k]-align_time>time_min:
            if k == 'Sdiff' or k == 'S':
                plt.plot(seis[0].stats.traveltimes[k]-align_time, azi,'g',marker='o',markersize=4)
                print('Sdiff: ' + str(seis[0].stats.traveltimes[k]-align_time))
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
    if azi <50:
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
  
    #     continue     
   
plt.subplot(1,1,1)

plt.xlabel('Time around Predicted Sdiff (s)')
plt.ylabel('Azimuth (deg)')


# Save file and show plot
#plt.savefig('/home/zl382/Pictures/Syn+Real/'+event+'data_with_azimuth.png')
plt.ylim(36,66)

plt.gca().invert_yaxis()
plt.show()
