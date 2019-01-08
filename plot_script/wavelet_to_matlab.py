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
import scipy.io as sio
import os.path

event = sys.argv[1]
component = sys.argv[2]

syn = False# Plot synthetics
real = True # Plot real data
color = False # color by measured travel times
switch_yaxis = True
per_norm = False

## Frequencies for filter

dist_range_1 = 94
dist_range_2 = 100
dist_range_3 = 110
dist_range_4 = 120

time_min = -20
time_max = 120

norm_constant = 10

dir = '/raid3/zl382/Data/' + event + '/'# '/raid2/sc845/Lowermost/EastPacific/Data/20161225/'
save_path = dir+ 'for_matlab/'
if not os.path.exists(save_path):
    os.makedirs(save_path)

###################### Edit Before This Line ######################################

seislist = glob.glob(dir + '*PICKLE')
azis=[]
dists=[]
strange_trace = []
sname = []
# Loop through seismograms
count = 0
for s in range(0,len(seislist),1):
    print(str(s)+'/'+str(len(seislist)))
    seis = read(seislist[s],format='PICKLE') # read seismogram
    seistoplot= seis.select(channel=component)[0]
    s_name = os.path.splitext(os.path.split(seislist[s])[1])[0]
   # print(s_name +' '+ str(s)+' / '+str(len(seislist)) + ' of '+event)
    # print('dist: '+ str(seis[0].stats['dist'])+ 'az: '+str(seis[0].stats['az']))

    # Split seismograms by distance range (this needs to be adapted per event to produce a reasonable plot.
    if seis[0].stats['dist'] < 110 and seis[0].stats['dist'] > 100:

        phase_time = seis[0].stats.traveltimes['Sdiff'] or seis[0].stats.traveltimes['S']

        if per_norm:
            norm = np.max(seistoplot.data) / norm_constant
        elif count == 0:
            norm = np.max(seistoplot.data) / norm_constant
        count = count+1          
           # Filter data

        w0 = np.argmin(np.abs(seistoplot.times(reftime=seistoplot.stats['eventtime'])-phase_time-time_min))            
        w1 = np.argmin(np.abs(seistoplot.times(reftime=seistoplot.stats['eventtime'])-phase_time-time_max))

        sname.append(s_name)
        sio.savemat(save_path + s_name + '_'+ component+'.mat', {'data': seistoplot.data[w0:w1], 'times': seistoplot.times()[w0:w1]})
sio.savemat(save_path + 'pickle_mat_interface.mat', {'sname': sname})