#!/usr/bin python3
# python3 add_event_cmt.py 20100320
import obspy
from obspy import read
from obspy.core import Stream
from obspy.core import event
from obspy import UTCDateTime
import obspy.signal
import matplotlib.pyplot as plt
import os.path

import glob
import shutil
import numpy as np
import scipy
#from obspy.xseed import Parser
#from obspy.arclink import Client as ARCLINKClient
#from obspy.fdsn import Client as IRISClient
from subprocess import call
import subprocess
#from obspy.taup.taup import getTravelTimes
import sys

#Change event name, time and location beneath taken from the CMT catalog. 
#Event name
event=sys.argv[1]
#event = '20100320ALL'

dir='/raid3/zl382/Data/'+event
seislist=glob.glob(dir+'/*PICKLE')

with open(dir +'/cmtsource.txt','r') as inf:
    srcdict= eval(inf.read())

f_sta = open(dir+'/STATIONS','w')  # write STATIONS file, SPECFEM-style
f_rec = open(dir+'/receivers.dat','w')  # write receiver file
count = 0
for s in range(0,len(seislist)):
        print(s)
        
        seis= read(seislist[s],format='PICKLE')
        #Event time
        time = UTCDateTime(srcdict['year'],srcdict['month'],srcdict['day'],srcdict['hour'],srcdict['min'],srcdict['sec'],1000*srcdict['msec'])
        for i in range(3):
            #Event location
            seis[i].stats['evla']=srcdict['latitude']
            seis[i].stats['evlo']=srcdict['longitude']
            #Event depth
            seis[i].stats['evdp']=srcdict['depth']
            #Event time
            seis[i].stats['eventtime']=time
            seis[i].timesarray = seis[i].times(reftime=time)
        seis.write(seislist[s],format='PICKLE')
        # SPECFEM-style stations file with latitude, longitude and station name
        line_sta = '{0:10} {1:6} {2:10.4f} {3:12.4f} {4:6.1f} {5:6.1f}\n'.format(seis[0].stats.station, seis[0].stats.network, seis[0].stats.stla, seis[0].stats.stlo, 0., 0.)
        f_sta.write(line_sta)
        # receiver file with numbers(first line), colatitude, longitude
        line_rec = '{0:.1f} {1:4.1f}\n'.format(seis[0].stats.az, np.sign(seis[0].stats.az)*90.)
        f_rec.write(line_rec)
        count = count + 1

f_sta.close()
f_rec.close()

with open(dir+'/receivers.dat','r+') as f:
    content = f.read()
    f.seek(0,0)
    f.write('{0}\n'.format(count) + content) 
