#

import obspy
from obspy import read
from obspy.core import Stream
from obspy.core import event
from obspy.taup.taup import getTravelTimes
from obspy import UTCDateTime
import obspy.signal
import obspy.signal.rotate
import matplotlib.pyplot as plt
import os.path
import time
import glob
import shutil
import numpy as np
import scipy
import sys

# Input eventname as argument
event=sys.argv[1]
# Data is assumed to be in PICKLE format in Data/#eventname/Originals/
dir='Data/'+event+'/'
stalist=glob.glob(dir+'/Originals/*PICKLE') 


for s in range(len(stalist)):
    try:
        onestation = read(stalist[s],format='PICKLE')
        # Cut components to the same length
        onestation.trim(starttime=onestation[0].stats.starttime+300, endtime=onestation[0].stats.endtime-300)
        # Find if component names are different
        seisZ=onestation.select(channel='BHZ')
        if len(seisZ)>1:
            seisZ=seisZ.select(location='10')
        seisN=onestation.select(channel='BHN')
        if len(seisN)==0:
            seisN=onestation.select(channel='BH2') 
        if len(seisN)>1:
            seisN=seisN.select(location='10')                  
        seisE=onestation.select(channel='BHE')
        if len(seisE)==0:
            seisE=onestation.select(channel='BH1') 
        if len(seisE)>1:
            seisE=seisE.select(location='10')
        print(seisZ, seisN, seisE)
        seisZ[0].stats =onestation[0].stats

        # rotate components to from North and East to Radial and Transverse
        [seisRtmp,seisTtmp]=obspy.signal.rotate.rotate_ne_rt(seisN[0].data,seisE[0].data,seisZ[0].stats['baz'])
        seisR=seisN[0].copy()
        seisR.stats['channel']='BHR'
        seisR.data=seisRtmp
        seisT=seisN[0].copy()
        seisT.stats['channel']='BHT'
        seisT.data=seisTtmp

        # Copy values into stats for vertical component
        seisZ[0].stats =onestation[0].stats

        # produce new stream with Vertical Radial and Transverse
        seisnew=Stream()
        seisnew.append(seisZ[0])
        seisnew.append(seisR)
        seisnew.append(seisT)
        ## write out in pickle format
        filename=dir+seisZ[0].stats.network+'.'+seisZ[0].stats.station+'.PICKLE'
        seisnew.write(filename,'PICKLE')
    except:
        print('FAILED for', stalist[s])

