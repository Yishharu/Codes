#!/usr/bin python3

import obspy
import obspy.signal
from obspy import read
from obspy.core import Stream
from obspy.core import Trace
from obspy.core import event
from obspy import UTCDateTime
from obspy.imaging.cm import obspy_sequential
from obspy.signal.tf_misfit import cwt

import matplotlib.pyplot as plt
import os.path
import time
import glob
import shutil
import numpy as np
import sys
import matplotlib.colors as colors
import matplotlib.cm as cm
import matplotlib.pyplot as plt

if_norm = False

f_min = 1.0/35.0
f_max = 1.0

time_min = -40
time_max = 80

dist_range_1 = 100
dist_range_2 = 110
dist_range_3 = 120
dist_range_4 = 130

#time_min_ref = -50
#time_max_ref = 50

# Set phase to plot
phases = ['Sdiff','Sdiff','Pdiff']
# Set component to plot
components = ['BHT','BHR','BHZ']
# Set model titles
titles=['SHdiff','SVdiff','Pdiff']

event = sys.argv[1]
# station = '/TA.732A'
if if_norm:
    filefolder= '/home/zl382/Pictures/CWT/'+event+'_norm'
else:
    filefolder= '/home/zl382/Pictures/CWT/'+event+''
if not os.path.exists(filefolder+'/94_' +str(dist_range_1)):
    os.makedirs(filefolder+'/94_' +str(dist_range_1)) 
if not os.path.exists(filefolder+'/'+str(dist_range_1)+'_' +str(dist_range_2)):
    os.makedirs(filefolder+'/'+str(dist_range_1)+'_' +str(dist_range_2))     
if not os.path.exists(filefolder+'/'+str(dist_range_2)+'_' +str(dist_range_3)):
    os.makedirs(filefolder+'/'+str(dist_range_2)+'_' +str(dist_range_3)) 
if not os.path.exists(filefolder+'/'+str(dist_range_3)+'_' +str(dist_range_4)):
    os.makedirs(filefolder+'/'+str(dist_range_3)+'_' +str(dist_range_4)) 

dir = '/raid3/zl382/Data/' + event + '/'
seislist = glob.glob(dir + '*PICKLE')
count = 0
for s in range(0,len(seislist),1):
    plt.figure(figsize=(24,12))
    s_name = os.path.splitext(os.path.split(seislist[s])[1])[0]
    print(str(s)+'/' + str(len(seislist)))
    seisfile = seislist[s]
    seis = read(seisfile, format='PICKLE')         # Read the three component data    

#    try:
#        seis.resample(10)            # resample seems to be important, for the length of data and processing speed~
#    except:
#        count = count + 1
#        print(str(s)+' resample break down!!!!!!!')
#        continue    
    if seis[0].stats['dist']<94 or seis[0].stats['dist']>130:
        continue
    
    for i in range(len(components)):
        title = titles[i]
        phase = phases[i]
        component = components[i] 
        # Initialize plot for each model
        if i == 0:
            ax=plt.subplot(1,3,i+1)
        else:
            ax=plt.subplot(1,3,i+1)
              
        Sdifftime = seis[0].stats['traveltimes'][phase]
        if (Sdifftime == None) and (phase == 'Sdiff'):
            phase = 'S'
            Sdifftime = seis[0].stats['traveltimes'][phase]      
        if (Sdifftime == None) and (phase == 'Pdiff'):
            phase = 'P'
            Sdifftime = seis[0].stats['traveltimes'][phase]   

        plt.axvline(x=0,linestyle='--',color='g')

        tr = seis.select(channel=component)[0]

        w0 = np.argmin(np.abs(tr.timesarray-Sdifftime-time_min))
        w1 = np.argmin(np.abs(tr.timesarray-Sdifftime-time_max))
        
#        w0_ref = np.argmin(np.abs(tr.timesarray-Sdifftime-time_min_ref))
#        w1_ref = np.argmin(np.abs(tr.timesarray-Sdifftime-time_max_ref))
        

        # Copy trace
        trf = tr.copy()
        trf = trf.filter('bandpass', freqmin=1/40.,freqmax=1/10., zerophase=True)
           # Plot reference phase with wide filter
           # plt.plot(tr.times()[w0:w1]-Sdifftime,tr1.data[w0:w1]/np.max(np.abs(tr1.data[w0:w1])),'k')


        scalogram = cwt(tr.data[w0:w1], tr.stats.delta, 8, f_min, f_max)
           

        x, y = np.meshgrid(
               tr.timesarray[w0:w1]-Sdifftime,
               np.logspace(np.log10(f_min), np.log10(f_max), scalogram.shape[0]))

        ax.pcolormesh(x, y, np.abs(scalogram), cmap=obspy_sequential)
        if if_norm:
            norm = np.reshape(np.abs(scalogram).max(1),(-1,1))
            ax.pcolormesh(x, y, np.abs(scalogram)/norm, cmap=obspy_sequential)
        else:
            ax.pcolormesh(x, y, np.abs(scalogram), cmap=obspy_sequential)
        
        plt.xlabel('time around ' +phase + ' (s)', fontsize=12)
        if i ==0:
            plt.ylabel('Period (s)',fontsize=18)
        ax.set_yscale('log')
        ax.set_ylim(f_min, f_max)
          # ax.set_xlim([-40, 180])
        plt.yticks([1/30, 1/20, 1/15, 1/10, 1/5, 1/3, 1/2, 1], ['30', '20', '15', '10', '5', '3', '2', '1'])
        plt.xticks(fontsize=10)
        plt.title(titles[i],fontsize=16)
        ax2 = ax.twinx()
        ax2.plot(trf.timesarray[w0:w1]-Sdifftime, trf.data[w0:w1]/np.max(np.abs(trf.data[w0:w1])),'k')
        ax2.set_ylim([-1,35])
        ax2.set_yticklabels([])
        plt.xlim([time_min,time_max])

    # set filename
    if seis[0].stats['dist'] < dist_range_1 and seis[0].stats['dist'] > 94:
        subfolder =  filefolder +'/94_' +str(dist_range_1)
    elif seis[0].stats['dist'] < dist_range_2 and seis[0].stats['dist'] > dist_range_1:
        subfolder =  filefolder +'/'+str(dist_range_1)+'_' +str(dist_range_2)
    elif seis[0].stats['dist'] < dist_range_3 and seis[0].stats['dist'] > dist_range_2:
        subfolder =  filefolder +'/'+str(dist_range_2)+'_' +str(dist_range_3)
    elif seis[0].stats['dist'] < dist_range_4 and seis[0].stats['dist'] > dist_range_3:
        subfolder =  filefolder +'/'+str(dist_range_3)+'_' +str(dist_range_4)
    else:
        continue
    filename =  subfolder +'/' + 'A'+'%.1f' %seis[0].stats['az']+'_D'+'%2.1f' %seis[0].stats['dist']+'_' +s_name+'.png'
    plt.savefig(filename,format='png')
    plt.close('all')
    print(filename)
