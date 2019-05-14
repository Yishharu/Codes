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
Event = '20170509'

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
time_max = 200

azim_min = 30
azim_max = 55

dist_min = 94
dist_max = 110

norm_constant = 1

real_component = 'BHT'
syn_component = 'BXT'

dir = '/raid1/zl382/Data/'+Location+'/'+Event + '/'# '/raid2/sc845/Lowermost/EastPacific/Data/20161225/'

# 10-20s post cursor
# [x1,y1] = [10,65]
# [x2,y2] = [30,50]
# [x3,y3] = [50,35]

# # 1-5s post cursor
[x1,y1] = [30,65]
[x2,y2] = [50,50]
[x3,y3] = [80,35]

cut_x = np.linspace(x1,x2, num=10, endpoint=False)    # First Line
cut_y = np.linspace(y1,y2, num=10, endpoint=False)
cut_x = np.append(cut_x,np.linspace(x2,x3, num = 11))
cut_y = np.append(cut_y,np.linspace(y2,y3, num=11))

plt.rcParams.update({'font.size': 30})   
###################### Edit Before This Line ######################################

seislist = glob.glob(dir + '*PICKLE')
azis=[]
dists=[]
strange_trace = []

i_Sdiff = 0 
i_pSdiff = 0
i_sSdiff = 0 
i_pSKKS = 0 
i_SP = 0 

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
 

 #   [wt, period, coi] = eng.cwt(seistoplot.data,delta,wname,'VoicesPerOctave', Nv,nargout=3)
    # data_filter = eng.icwt(wt, period, wname, [seconds(10) seconds(30)],'SignalMean', 0);
    
    if if_round:
        azi = np.round(azi)


    if real:        #seistoplot.timesarray   
        if if_round:       
            plt.plot(seistoplot.times(reftime=seistoplot.stats['eventtime'])-align_time, seistoplot.data / norm + azi,'k')
        else:
            plt.plot(seistoplot.times(reftime=seistoplot.stats['eventtime'])-align_time, seistoplot.data / norm + azi,'k')
   
    if syn:
        plt.plot(seissyn.timesarray-align_time,seissyn.data / norm + azi,'r')        

    azis.append(seis[0].stats['az']) # list all azimuths
    dists.append(seis[0].stats['dist'])    
               
    plt.xlim([time_min,time_max])
          # Plot travel time predictions
    for k in seis[0].stats.traveltimes.keys():
        if seis[0].stats.traveltimes[k]!=None: #and k!='S90' and k!='P90' and seis[0].stats.traveltimes[k]-align_time<time_max and seis[0].stats.traveltimes[k]-align_time>time_min:
            if k == 'Sdiff' or k == 'S':
                plt.scatter(seis[0].stats.traveltimes[k]-align_time, azi,c='g',marker='o',s=20, label='Sdiff & S' if i_Sdiff==0 else '')
                print('Sdiff: ' + str(seis[0].stats.traveltimes[k]-align_time))
                i_Sdiff += 1
            elif k == 'pSdiff':
                plt.scatter(seis[0].stats.traveltimes[k]-align_time, azi,c='r',marker='o',s=20, label='pSdiff' if i_pSdiff==0 else '')
                print('pSdiff: ' + str(seis[0].stats.traveltimes[k]-align_time))
                i_pSdiff  += 1
            elif k == 'sSdiff':
                plt.scatter(seis[0].stats.traveltimes[k]-align_time, azi,c='orange',marker='o',s=20, label='sSdiff' if i_sSdiff==0 else '')
                print('sSdiff: ' + str(seis[0].stats.traveltimes[k]-align_time))
                i_sSdiff  += 1
            elif k == 'pSKKS':
                plt.scatter(seis[0].stats.traveltimes[k]-align_time, azi,c='yellow',marker='o',s=20, label='pSKKS' if i_pSKKS==0 else '')
                print('pSKKS: ' + str(seis[0].stats.traveltimes[k]-align_time))
                i_pSKKS  += 1
            elif k == 'PS':
                plt.scatter(seis[0].stats.traveltimes[k]-align_time, azi,c='yellow',marker='o',s=20, label='PS' if i_SP==0 else '')
                print('PS: ' + str(seis[0].stats.traveltimes[k]-align_time))
                i_SP  += 1
 
           # plt.text(seis[0].stats.traveltimes[k]-align_time, np.round(seis[0].stats['az']),k, fontsize = 8)
                     # plt.text(seis[0].stats.traveltimes[k]-seis[0].stats.traveltimes[phase],np.round(seis[0].stats['az'])-0.5, k)              
    timewindow = 3*(1/fmin)   
    print('NORM VALUE: ' + str(norm))     
    w0 = np.argmin(np.abs(seistoplot.times(reftime=seistoplot.stats['eventtime'])-phase_time+timewindow/3))            
    w1 = np.argmin(np.abs(seistoplot.times(reftime=seistoplot.stats['eventtime'])-phase_time-timewindow*2/3))
    window_wid = seistoplot.times(reftime=seistoplot.stats['eventtime'])[w1] - seistoplot.times(reftime=seistoplot.stats['eventtime'])[w0]
    window_hei = np.max(np.abs(hilbert(seistoplot.data[w0:w1])))/norm
 
    print('NORM VALUE: ' + str(norm))     
   
    w0_ref = np.argmin(np.abs(seistoplot.times(reftime=seistoplot.stats['eventtime'])-align_time+10))        # arg of ref, adapative time window     
    w1_ref = np.argmin(np.abs(seistoplot.times(reftime=seistoplot.stats['eventtime'])-align_time-20))   
    A0 = np.max(np.abs(seistoplot.data[w0_ref:w1_ref]))/norm                
    #gca().add_patch(patches.Rectangle((seistoplot.timesarray[w0_ref]-align_time,np.round(seis[0].stats['az'])-A0),seistoplot.timesarray[w1_ref]-seistoplot.timesarray[w0_ref],2*A0,alpha = 0.4, color = 'red'))
    threshold = A0 #np.max(seistoplot.data/norm)
    
    print('threshold: '+str(threshold))
    if ((threshold>5 or threshold<0.05)):# and seis[0].stats['dist']>100) or (threshold<0.1 and seis[0].stats['dist']<100):
        strange_trace.append([s,seis[0].stats['az'],s_name,threshold])   
        
   # plt.text(81,np.round(seis[0].stats['az'])+A0/5,s_name+' #'+str(s), fontsize = 8)
# Put labels on graphs
print('!!!!!!!!!!!!!!!!!!!Stange Traces:----------------------->>>>>>')
print(strange_trace)
azis = np.array(azis)
dists = np.array(dists)

# plt.subplot(1,4,1)
# plt.title(' Sdiff dist < %d' % dist_range_1)
# plt.ylim(azis.min()-1,azis.max()+1)
# plt.xlabel('time around predicted arrival (s)')
# plt.ylabel('azimuth (dg)')
# if switch_yaxis:
#    plt.gca().invert_yaxis()
   
plt.subplot(1,1,1)
#plt.title('100 < Sdiff distance < 110')
# plt.ylim([])
plt.ylim(azis.min()-4.9,azis.max()+4.9)
#plt.ylim(0,31)
plt.xlabel('Time around predicted arrival (s)')
plt.ylabel('Azimuth (deg)')
if switch_yaxis:
   plt.gca().invert_yaxis()


plt.legend(loc=1,fontsize='xx-small')
plt.show()
