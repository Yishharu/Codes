#

import obspy
from obspy import read

import obspy.signal
import matplotlib.pyplot as plt
import os.path
import time
import glob
import shutil
import numpy as np
import scipy
import sys


event=sys.argv[1]

outfile='receivers_forcsem_'+event+'.dat'
f=open(outfile,'w')

dir=  '/raid3/zl382/Data/'+event+'/'  
seislist=glob.glob(dir+'/*PICKLE') 
azis=[]

f.write('Number of stations is:\n')
f.write('%d \n' % len(seislist))
f.write('     nw stn lat lon:\n')
for s in range(len(seislist)):
       print(s)
       seis= read(seislist[s],format='PICKLE')
       sta = seis[0].stats.station
       nw  = seis[0].stats.network
       slat = seis[0].stats['stla']
       slon = seis[0].stats['stlo']

       while len(nw)<2:
              nw='_'+nw
       while len(sta)<4:
              sta='_'+sta
       if len(sta)>4:
              sta=sta[:4]

       f.write('%s %s  %2.3f  %3.3f\n'% (nw, sta, slat, slon))

f.close()
