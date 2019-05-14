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
fmin = 1/5. #Hz
fmax = 1/1.  #Hzseis

dist_range_1 = 90
dist_range_2 = 100
dist_range_3 = 110
dist_range_4 = 120

time_min = -20
time_max = 120

azim_min = 37
azim_max = 66

dist_min = 101
dist_max = 110

norm_constant = 3

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

# Loop through seismograms
count = 0
location_dict = np.load(dir+'location.npy').item()


for s, (s_name, (dist,azi)) in enumerate(location_dict.items()):
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

    if real:        #seistoplot.timesarray          
       plt.plot(seistoplot.times(reftime=seistoplot.stats['eventtime'])-align_time, seistoplot.data / norm + np.round(seis[0].stats['az']),'k')
    if syn:
        plt.plot(seissyn.timesarray-align_time,seissyn.data / norm + np.round(seis[0].stats['az']),'r')        

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
            # elif k == 'pSKKS':
            #     plt.plot(seis[0].stats.traveltimes[k]-align_time, np.round(seis[0].stats['az']),'yellow',marker='o',markersize=4)
            #     print('pSKKS: ' + str(seis[0].stats.traveltimes[k]-align_time))
            # elif k == 'SP':
            #     plt.plot(seis[0].stats.traveltimes[k]-align_time, np.round(seis[0].stats['az']),'blue',marker='o',markersize=4)
            #     print('SP: ' + str(seis[0].stats.traveltimes[k]-align_time))
 
           # plt.text(seis[0].stats.traveltimes[k]-align_time, np.round(seis[0].stats['az']),k, fontsize = 8)
                     # plt.text(seis[0].stats.traveltimes[k]-seis[0].stats.traveltimes[phase],np.round(seis[0].stats['az'])-0.5, k)              
    timewindow = 3*(1/fmin)   
    print('NORM VALUE: ' + str(norm))     
    w0 = np.argmin(np.abs(seistoplot.times(reftime=seistoplot.stats['eventtime'])-phase_time+timewindow/3))            
    w1 = np.argmin(np.abs(seistoplot.times(reftime=seistoplot.stats['eventtime'])-phase_time-timewindow*2/3))
    window_wid = seistoplot.times(reftime=seistoplot.stats['eventtime'])[w1] - seistoplot.times(reftime=seistoplot.stats['eventtime'])[w0]
    window_hei = np.max(np.abs(hilbert(seistoplot.data[w0:w1])))/norm
    # plot the picked window
    # gca().add_patch(patches.Rectangle((seistoplot.times(reftime=seistoplot.stats['eventtime'])[w0]-phase_time,np.round(seis[0].stats['az'])-window_hei),window_wid,2*window_hei,alpha = 0.2, color = 'red'))  # width height
    # A0_phase = np.abs(hilbert(seistoplot.data[w0:w1])).max()/norm


    # w0_noise1 = np.argmin(np.abs(seistoplot.times(reftime=seistoplot.stats['eventtime'])-noise_time+timewindow/3))        # arg of ref, adapative time window     
    # w1_noise1 = np.argmin(np.abs(seistoplot.times(reftime=seistoplot.stats['eventtime'])-noise_time-timewindow*2/3))   
    # A0_noise1 = np.abs(hilbert(seistoplot.data[w0_noise1:w1_noise1])).max()/norm                
    # #gca().add_patch(patches.Rectangle((seistoplot.timesarray[w0_ref]-phase_time,np.round(seis[0].stats['az'])-A0),seistoplot.timesarray[w1_ref]-seistoplot.timesarray[w0_ref],2*A0,alpha = 0.4, color = 'red'))
    # w0_noise2 = np.argmin(np.abs(seistoplot.times(reftime=seistoplot.stats['eventtime'])-noise_time+timewindow/3-100))        # arg of ref, adapative time window     
    # w1_noise2 = np.argmin(np.abs(seistoplot.times(reftime=seistoplot.stats['eventtime'])-noise_time-timewindow*2/3-100))   
    # A0_noise2 = np.abs(hilbert(seistoplot.data[w0_noise2:w1_noise2])).max()/norm   

    # w0_noise3 = np.argmin(np.abs(seistoplot.times(reftime=seistoplot.stats['eventtime'])-noise_time+timewindow/3-200))        # arg of ref, adapative time window     
    # w1_noise3 = np.argmin(np.abs(seistoplot.times(reftime=seistoplot.stats['eventtime'])-noise_time-timewindow*2/3-200))   
    # A0_noise3 = np.abs(hilbert(seistoplot.data[w0_noise3:w1_noise3])).max()/norm           

    # print('A0_phase: ' +str(A0_phase)+' A0_noise: ' +str(A0_noise1)+ ' SNR: ' +str(A0_phase/A0_noise1))
    # print('A0_phase: ' +str(A0_phase)+' A0_noise: ' +str(A0_noise2)+ ' SNR: ' +str(A0_phase/A0_noise2))
    # print('A0_phase: ' +str(A0_phase)+' A0_noise: ' +str(A0_noise3)+ ' SNR: ' +str(A0_phase/A0_noise3))

    # SNR = np.mean([A0_phase/A0_noise1, A0_phase/A0_noise2, A0_phase/A0_noise3]) 

    # print('total SNR:')
    # print(SNR)
    # if SNR < 2:
    #     continue
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
# plt.plot(cut_x,cut_y, '--', color='blue')
# plt.plot(cut_x+50,cut_y, '--', color='blue')
# plt.subplot(1,2,2)   
# plt.title('100 < Sdiff distance < 110' )
# plt.ylim(azis.min()-4,32)
# plt.xlabel('Time around predicted arrival (s)', fontsize=15)
# # plt.ylabel('Azimuth (deg)', fontsize=15)
# if switch_yaxis:
#    plt.gca().invert_yaxis()
# plt.plot(cut_x,cut_y, '--', color='blue')

# plt.subplot(1,4,dsd
# plt.title(' Sdiff dist < %d' % dist_range_4)
# plt.ylim(azis.min()-1,azis.max()+1)
# plt.xlabel('time around predicted arrival (s)')
# if switch_yaxis:
#    plt.gca().invert_yaxis()

# plt.plot(cut_x,cut_y, '--', color='blue')


# plt.suptitle('Waveform with Azimuth\n Event %s    Real data: %s , Syn Data: %s \n Dist %.0f - %.0f Freq: %s s - %s s' \
#     % (Event, real_component, syn_component, dist_min, dist_max, str(1/fmax), str(1/fmin)), fontsize=20)


# # Add trace
# # Data Directory
# dir = '/raid3/zl382/Data/20100320/fk_analysis/TA.T29A/'

# StartWindow = 53
# EndWindow = 73
# stTOGETHER = read(dir+'Bundles.PICKLE')
# T = np.load(dir+'BeamTime.npy')
# stTOGETHER.filter('bandpass', freqmin=fmin,freqmax=fmax, zerophase=True)
# CenterSdifftime = stTOGETHER[0].stats.traveltimes['Sdiff'] or stTOGETHER[0].stats.traveltimes['S']
# for i, st in enumerate(stTOGETHER):
#     plt.plot(st.times(reftime=st.stats['eventtime'])-st.stats.traveltimes['Sdiff'], st.data /norm + np.round(st.stats['az']),'y')
#     w1_cut = np.argmin(np.abs(st.times(reftime=st.stats['eventtime'])-CenterSdifftime-StartWindow-T[i]))
#     w2_cut = np.argmin(np.abs(st.times(reftime=st.stats['eventtime'])-CenterSdifftime-EndWindow-T[i]))         # Real timewindow demo
#     cut_trace = st.data[w1_cut:w2_cut]
#     plt.plot(st.times(reftime=st.stats['eventtime'])[w1_cut:w2_cut]-st.stats.traveltimes['Sdiff'], cut_trace/norm + np.round(st.stats['az']),'r')

# Save file and show plot
#plt.savefig('/home/zl382/Pictures/Syn+Real/'+event+'data_with_azimuth.png')
plt.show()
