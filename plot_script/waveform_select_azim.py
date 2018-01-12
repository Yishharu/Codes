import obspy
from obspy import read
from obspy.core import Stream
from obspy.core import Trace
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
from obspy.io.xseed import Parser
from obspy.clients.arclink import Client as ARCLINKClient
from obspy.clients.fdsn import Client as IRISClient
from subprocess import call
import subprocess
from obspy.taup.taup import getTravelTimes
import sys
import matplotlib.colors as colors
import matplotlib.cm as cm

event = sys.argv[1]

syn = False # Plot synthetics
real = True # Plot real data
color = False # color by measured travel times
switch_yaxis = True

## Frequencies for filter
fmin = 0.05 #Hz
fmax = 0.1  #Hzseis


dir = '/raid3/zl382/Data/' + event + '/'
dirdump = dir + 'Dump'
if not os.path.exists(dirdump):
    os.makedirs(dirdump)
    
seislist = sorted(glob.glob(dir + '*PICKLE'))
norm = None
azis=[]

# PLot measured differential travel times by coloring the lines
if color:
   dtsta=[]
   dtnw=[]
   dtdt=[]
   rd=open('traveltimes_xcorr_12_30s_20130715.dat','r')
   for line in rd.readlines():
    val=line.split()
    dtsta.append(val[0])
    dtnw.append(val[1])
    dtdt.append(float(val[4]))
    cNorm=colors.Normalize(vmin=-10,vmax=10)
    scalarMap=cm.ScalarMappable(norm=cNorm,cmap=plt.get_cmap('jet'))

# Loop through seismograms
for s in range(0,len(seislist),1):
   #try:
       print(s)
       seis = read(seislist[s],format='PICKLE') # read seismogram
       azis.append(seis[0].stats['az']) # list all azimuths
       print(seis[0].stats['az'],seis[0].stats['dist'])
       seistoplot= seis.select(channel='BHT')[0]

       # plot synthetics
       if syn:
          seissyn= seis.select(channel ='BXT')[0]
          

       # Split seismograms by distance range (this needs to be adapted per event to produce a reasonable plot.
       print(seis[0].stats.traveltimes['Sdiff'])
       Phase = ['Sdiff', 'S']
       for x in range (0,2):
         if  seis[0].stats.traveltimes[Phase[x]]!=None:
          phase = Phase[x]
          if seis[0].stats['dist']<94:
               plt.subplot(1,4,1)
          elif seis[0].stats['dist']<100:
               plt.subplot(1,4,2)
          elif seis[0].stats['dist']<110:
               plt.subplot(1,4,3)
          elif seis[0].stats['dist']<120:
               plt.subplot(1,4,4)
       
         

       # Filter data
      # if seis[0].stats.traveltimes['Sdiff']!=None:
          seistoplot.filter('highpass',freq=fmin,corners=2,zerophase=True)
          seistoplot.filter('lowpass',freq=fmax,corners=2,zerophase=True)
          if syn:
             seissyn.filter('highpass',freq=fmin,corners=2,zerophase=True)
             seissyn.filter('lowpass',freq=fmax,corners=2,zerophase=True)

          # Time shift to shift data to reference time
          tshift=seis[0].stats['starttime']-seis[0].stats['eventtime']
  
          print('max',np.max(seistoplot.times()))
          if real:
             norm=None
             if norm==None:
                norm=np.max(seistoplot.data)
             plt.plot(seistoplot.times()+tshift-seis[0].stats.traveltimes[phase],seistoplot.data/norm+np.round(seis[0].stats['az']),'k')
          if syn:
            # if np.max(synnms/np.max(0.5*seis[2].data))>5.:
             if norm==None:
                norm=  20.*np.max(seissyn.data)          
             print(np.max(seistoplot.data), np.max(seissyn.data))
             plt.plot(seissyn.times()-seis[0].stats.traveltimes[phase],seissyn.data/norm+np.round(seis[0].stats['az']),'b')
          plt.xlim([-20,70])

          # Plot travel time predictions
          for k in seis[0].stats.traveltimes.keys():
                  if seis[0].stats.traveltimes[k]!=None:
                      plt.plot(seis[0].stats.traveltimes[k]-seis[0].stats.traveltimes[phase],np.round(seis[0].stats['az']),'g',marker='o',markersize=4)
                     # plt.text(seis[0].stats.traveltimes[k]-seis[0].stats.traveltimes[phase],np.round(seis[0].stats['az'])-0.5, k)

   #except:
   #	pass
   
# Put labels on graphs
plt.subplot(1,4,1)
plt.title(' S dist<94')
plt.ylim(39,66)
plt.xlabel('time around predicted arrival (s)')
plt.ylabel('azimuth (dg)')
if switch_yaxis:
   plt.gca().invert_yaxis()
   
plt.subplot(1,4,2)
plt.title(' Sdiff dist<100')
plt.ylim(39,66)
plt.xlabel('time around predicted arrival (s)')
if switch_yaxis:
   plt.gca().invert_yaxis()
   
plt.subplot(1,4,3)
plt.title(' Sdiff dist <110')
plt.ylim(39,66)
plt.xlabel('time around predicted arrival (s)')
if switch_yaxis:
   plt.gca().invert_yaxis()
   
plt.subplot(1,4,4)
plt.title(' Sdiff dist <120')
plt.ylim(39,66)
plt.xlabel('time around predicted arrival (s)')
if switch_yaxis:
   plt.gca().invert_yaxis()

# Hightlight the selected waveform 

for s in range(140,len(seislist),1):
   s_name = os.path.splitext(os.path.split(seislist[s])[1])[0]
   print(s_name, 'Trace#', s, '/', len(seislist))
   seis = read(seislist[s],format='PICKLE') # read seismogram
   azis.append(seis[0].stats['az']) # list all azimuths
   print('Azimuth: ', seis[0].stats['az'],'Distance: ',seis[0].stats['dist'])
   seistoplot = seis.select(channel='BHT')[0]

       # plot synthetics
   if syn:
      seissyn= seis.select(channel ='BXT')[0]
       

   # Split seismograms by distance range (this needs to be adapted per event to produce a reasonable plot.
   print(seis[0].stats.traveltimes['Sdiff'])
   Phase = ['Sdiff', 'S']
   for x in range (0,2):
      if  seis[0].stats.traveltimes[Phase[x]]!=None:
         phase = Phase[x]
         if seis[0].stats['dist']<94:
            plt.subplot(1,4,1)
         elif seis[0].stats['dist']<100:
            plt.subplot(1,4,2)
         elif seis[0].stats['dist']<110:
            plt.subplot(1,4,3)
         elif seis[0].stats['dist']<120:
            plt.subplot(1,4,4)
       
         

       # Filter data
      # if seis[0].stats.traveltimes['Sdiff']!=None:
   seistoplot.filter('highpass',freq=fmin,corners=2,zerophase=True)
   seistoplot.filter('lowpass',freq=fmax,corners=2,zerophase=True)


          # Time shift to shift data to reference time
   tshift=seis[0].stats['starttime']-seis[0].stats['eventtime']
  
   print('max',np.max(seistoplot.times()))
   if real:
      norm=None
      if norm==None:
         norm=np.max(seistoplot.data)
   [tr] = plt.plot(seistoplot.times()+tshift-seis[0].stats.traveltimes[phase],seistoplot.data/norm+np.round(seis[0].stats['az']),'r')
        
   plt.xlim([-20,70])
   plt.show(block=False)

   likeness = ''
   while (likeness != 'y' and likeness != 'n'):
      likeness = input('Do you like the waveform (y/n)?')
      if (likeness == 'y'):
         like = True
         if (s >= len(seislist)):
            print('This is the last waveform')
         if (likeness == 'n'):
            like = False
            shutil.move(seislist[s],dirdump)
            if (s >= len(seislist)):
               print('This is the last waveform')



               
   tr.set_visible(False)
   plt.draw()
 

