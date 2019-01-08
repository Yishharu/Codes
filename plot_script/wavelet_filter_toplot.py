# -*- coding: utf-8 -*-
"""
Created on Fri Dec  8 12:49:39 2017

@author: zl382
"""
import scipy.io as sio
import obspy
from obspy import read
from obspy.core import event
import matplotlib.pyplot as plt
import numpy as np
import matplotlib
import glob
import os.path
from obspy import UTCDateTime
import sys

matplotlib.rcParams.update({'font.size':18}) # Sets fontsize in figure

event = sys.argv[1]
component = sys.argv[2]
time_min = -20
time_max = 120
switch_yaxis = True

norm_constant = 3
per_norm = False

azis=[]
dists=[]

dir = '/raid3/zl382/Data/' + event + '/'# '/raid2/sc845/Lowermost/EastPacific/Data/20161225/'
save_path = dir + 'for_matlab/'
    
sname = sio.loadmat(save_path + 'pickle_mat_interface'+ '.mat')['sname']
for i in range(len(sname)):
    sname[i] = sname[i].strip()

count = 0
# Loop through seismograms
for s, s_name in enumerate(sname,1):
    print(' %d / %d station %s' %(s, len(sname), s_name) )

    seisfile =  '/raid3/zl382/Data/' + event +'/'+ s_name + '.PICKLE'
    seis = read(seisfile,format='PICKLE')
    seistoplot= seis.select(channel=component)[0]
   
    print(s_name + '_'+component)
    # Define phase time 
    phase_time = seis[0].stats.traveltimes['Sdiff'] or seis[0].stats.traveltimes['S']

    data_filter = np.reshape(sio.loadmat(save_path + 'filtered_' + s_name + '_' + component + '.mat')['data_filter'],(-1,1))

    w0 = np.argmin(np.abs(seistoplot.times(reftime=seistoplot.stats['eventtime'])-phase_time-time_min))            
    w1 = np.argmin(np.abs(seistoplot.times(reftime=seistoplot.stats['eventtime'])-phase_time-time_max))

    if per_norm:
        norm = np.max(data_filter) / norm_constant
    elif count == 0:
        norm = np.max(data_filter) / norm_constant
    count = count+1 

    if seis[0].stats['dist'] < 110 and seis[0].stats['dist'] > 100:
        plt.plot(seistoplot.times(reftime=seistoplot.stats['eventtime'])[w0:w1]-phase_time, data_filter/norm+ np.round(seis[0].stats['az']),'k')
        azis.append(seis[0].stats['az']) # list all azimuths
        dists.append(seis[0].stats['dist'])

azis = np.array(azis)
dists = np.array(dists)

plt.xlim([time_min,time_max])
plt.ylim(azis.min()-4,azis.max()+4)
plt.xlabel('Time around predicted arrival (s)')
plt.ylabel('Azimuth (deg)')

if switch_yaxis:
   plt.gca().invert_yaxis()
plt.show()