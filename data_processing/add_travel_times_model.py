#!/usr/bin python3
# python3 add_travel_times.py 20100320 S P Sdiff Pdiff SKS SKKS SKKKS SKKKKS ...  (edit dir below)
import obspy
from obspy import read
from obspy.core import Stream
from obspy.core import event
#from obspy.taup.taup import getTravelTimes
from obspy import UTCDateTime
import obspy.signal
import matplotlib.pyplot as plt
import os.path
import time
import glob
import shutil
import numpy as np
import scipy
from obspy.io.xseed import Parser
from obspy.clients.arclink import Client as ARCLINKClient
from obspy.clients.fdsn import Client as IRISClient
from subprocess import call
import subprocess
#from obspy.taup.taup import getTravelTimes
import sys

# Input event name as first argument
event= sys.argv[1]  # data_path = '/raid3/zl382/Data/Synthetics/PREM_20100320_90distPICKLES/'

# Add phase names as additional arguments (these are the TauP phase names)
phase=[]
for i in range(2,len(sys.argv)):
    phase.append(sys.argv[i])

# This code assumes the data is in a Data directory and in PICKLE format. Change here if different. 
dir = '/raid3/zl382/Data/Synthetics/'+event
seislist = glob.glob(dir + '/*PICKLE') 
print(seislist)

# Loop thgrou data and read
for s in range(len(seislist)):
   seis= read(seislist[s],format='PICKLE')
   #Start travetime dictionary
   if not hasattr(seis[0].stats,'traveltimes'):
       seis[0].stats.traveltimes=dict()
   #Loop through phases and call TauP_time to get traveltimes
   for ph in range(len(phase)):
       test=['taup_time -mod prem -deg '+str(seis[0].stats['dist'])+' -h '+ str(seis[0].stats['evdp']) +' -ph ' + phase[ph]]
       out=subprocess.check_output(test,shell=True,universal_newlines=True) 
       t=out.split()
       print(t)
       l=[x for x in range(len(t)) if t[x]==phase[ph]]
       try:
       
           time= float(t[l[0]+1])
           print(phase[ph],time)
       except:
           time=None
       seis[0].stats.traveltimes[phase[ph]]=time
       
   # Write out seismogram again
   seis.write(seislist[s],format='PICKLE')
 
