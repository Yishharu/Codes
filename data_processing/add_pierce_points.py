#/usr/bin/python3
# Usage: python3 add_pierce_points.py [event] [piercedepth] [phase]
# Example: python3 add_pierce_points.py 20100320 2600. Sdiff

import obspy
from obspy import read
from obspy.core import Stream
from obspy.core import event
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
from obspy.clients.fdsn import Client as IRISClient
from subprocess import call
import subprocess
import sys


# Input event name as first argument
area = sys.argv[1]
event = sys.argv[2]
piercedepth = float(sys.argv[3])
# Phases to get pierce depths for
phase=[]
for i in range(4,len(sys.argv)):
  phase.append(sys.argv[i])


# This code assumes the data is in a Data directory and in PICKLE format. Change here if different. 
dir='/raid1/zl382/Data/'+area+'/'+event+'/'
seislist=glob.glob(dir+'/*PICKLE') 
print(seislist)

# Loop thgrou data and read
for s in range(len(seislist)):
   seis= read(seislist[s],format='PICKLE')
   #Start travetime dictionary
   if not hasattr(seis[0].stats,'piercepoints'):
       seis[0].stats.piercepoints=dict()
   #Loop through phases and call TauP_time to get pierepoints
   for ph in range(len(phase)):

       elon =seis[0].stats['evlo']
       elat =seis[0].stats['evla']
       slat =seis[0].stats['stla']
       slon =seis[0].stats['stlo']
       depth =  seis[0].stats['evdp']
       test=['taup_pierce -mod prem -evt ' +str(elat)+ ' ' +str(elon) + ' -sta '+str(slat) + ' ' + str(slon)+ ' -h '+str(depth) +'  -ph Sdiff -Pierce '+str(piercedepth)]
       print(test)
       out=subprocess.check_output(test,shell=True,universal_newlines=True)

       t= out.split()
 
       if len(t)>0:
           l=[x for x in range(len(t)) if t[x]==str(piercedepth)]
           pierce1lat= float(t[l[0]+2])
           pierce1lon=float(t[l[0]+3]) 
           pierce2lat=float(t[l[1]+2])
           pierce2lon=float(t[l[1]+3])

           print(pierce1lat,pierce1lon,pierce2lat,pierce2lon)
           #seis[0].stats.traveltimes[phase[ph]]=time
       
   ## Write out seismogram again
   #seis.write(seislist[s],format='PICKLE')
 
