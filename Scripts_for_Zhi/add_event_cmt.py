#

import obspy
from obspy import read
from obspy.core import Stream
from obspy.core import event
from obspy.taup.taup import getTravelTimes
from obspy import UTCDateTime
import obspy.signal
import matplotlib.pyplot as plt
import os.path
import time
import glob
import shutil
import numpy as np
import scipy
from obspy.xseed import Parser
from obspy.arclink import Client as ARCLINKClient
from obspy.fdsn import Client as IRISClient
from subprocess import call
import subprocess
from obspy.taup.taup import getTravelTimes
import sys

#Change event name, time and location beneath taken from the CMT catalog. 
#Event name
event=sys.argv[1]


dr='Data/'+event+'/'
seislist=glob.glob(dr+'/*PICKLE')

with open(dr +'/cmtsource.txt','r') as inf:
    srcdict= eval(inf.read())

for s in range(len(seislist)):
        print(s)
        
        seis= read(seislist[s],format='PICKLE')
        #Event time
        time = UTCDateTime(srcdict['year'],srcdict['month'],srcdict['day'],srcdict['hour'],srcdict['min'],srcdict['sec'],srcdict['msec'])
        seis[0].stats['eventtime']=time
        seis[1].stats['eventtime']=time
        seis[2].stats['eventtime']=time
        #Event location
        seis[0].stats['evla']=srcdict['latitude']
        seis[0].stats['evlo']=srcdict['longitude']
        #Event depth
        seis[0].stats['evdp']=srcdict['depth']
        seis.write(seislist[s],format='PICKLE')
 
