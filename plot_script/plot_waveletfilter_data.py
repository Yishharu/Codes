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
import shutil
import numpy as np
import scipy
from obspy.io.xseed import Parser
from subprocess import call
import subprocess
import sys
import matplotlib.colors as colors
import matplotlib.cm as cm

import scipy.io as sio

event = '20100320'

syn = False # Plot synthetics
real = True # Plot real data
color = False # color by measured travel times
switch_yaxis = True

## Frequencies for filter
fmin = 0.05 #Hz
fmax = 0.1  #Hzseis

dist_range_1 = 88
dist_range_2 = 94
dist_range_3 = 100
dist_range_4 = 110

azim_min = 39
azim_max = 66

norm_constant = 1.0

dir = '/raid3/zl382/Data/' + event + '/'
seislist = glob.glob(dir + '*PICKLE')
norm = None
azis=[]

save_path = '/raid3/zl382/Data/MATLAB/' #'raid3/zl382/Data/MATLAB/' # '/home/zl382/Documents/MATLAB/'
EQ = '20100320'

sname = sio.loadmat(save_path + 'pickle_mat_interface'+ '.mat')['sname']
for i in range(len(sname)):
    sname[i] = sname[i].strip()




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

for s in range(0,len(sname),1):     
   s_name = sname[s]
   #    if (glob.glob(save_path + s_name +'BH*.mat')==[]):
   #        break
   # Load file
   # seisfile = '/raid3/zl382/Data/Synthetics/' +  event + '/SYN_' + str(s) + '.PICKLE'
   seisfile =  '/raid3/zl382/Data/' + EQ +'/'+ s_name + '.PICKLE'
   seis = read(seisfile,format='PICKLE')

             # Time shift to shift data to reference time
   tshift=UTCDateTime(seis[0].stats['starttime']) - UTCDateTime(seis[0].stats['eventtime']) #UTCDateTime('2016-08-31T03:11:40.700')#seis[0].stats['endtime']
    

   azis.append(seis[0].stats['az']) # list all azimuths
   print(seis[0].stats['az'],seis[0].stats['dist'])
   seistoplot= seis.select(channel='BHT')[0]
   w0 = np.argmin(np.abs(seistoplot.times()+tshift-seis[0].stats.traveltimes['Sdiff']+100))
   w1 = np.argmin(np.abs(seistoplot.times()+tshift-seis[0].stats.traveltimes['Sdiff']-190))

   data_filter = np.reshape(sio.loadmat(save_path + 'toplot_' + s_name + '_' + 'BHT' + '.mat')['data_filter'],(-1,1))

   # plot synthetics
   if syn:
      seissyn= seis.select(channel ='BXT')[0]
          

      # Split seismograms by distance range (this needs to be adapted per event to produce a reasonable plot.
       
   print(seis[0].stats.traveltimes['Sdiff'])
   Phase = ['Sdiff', 'S']
   for x in range (0,2):
      if  seis[0].stats.traveltimes[Phase[x]]!=None:
         phase = Phase[x]
      if seis[0].stats['dist'] < dist_range_1:
         plt.subplot(1,4,1)
      elif seis[0].stats['dist'] < dist_range_2:
         plt.subplot(1,4,2)
      elif seis[0].stats['dist'] < dist_range_3:
         plt.subplot(1,4,3)
      elif seis[0].stats['dist'] < dist_range_4:
         plt.subplot(1,4,4)
         s_name = os.path.splitext(os.path.split(seislist[s])[1])[0]
         plt.text(70,seis[0].stats['az'],s_name, fontsize = 8)
  
   print('max',np.max(seistoplot.times()))
   if real:
      norm = None
      if norm == None:
         norm = np.max(seistoplot.data) / norm_constant
            
   plt.plot(seistoplot.times()[w0:w1]+tshift-seis[0].stats.traveltimes[phase],data_filter/norm+np.round(seis[0].stats['az']),'k')
   if syn:
      # if np.max(synnms/np.max(0.5*seis[2].data))>5.:
      if norm == None:
         norm = 20.*np.max(seissyn.data) / norm_constant          
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
plt.title(' Sdiff dist < %d' % dist_range_1)
plt.ylim(azim_min,azim_max)
plt.xlabel('time around predicted arrival (s)')
plt.ylabel('azimuth (dg)')
if switch_yaxis:
   plt.gca().invert_yaxis()
   
plt.subplot(1,4,2)
plt.title(' Sdiff dist < %d' % dist_range_2)
plt.ylim(azim_min,azim_max)
plt.xlabel('time around predicted arrival (s)')
if switch_yaxis:
   plt.gca().invert_yaxis()
   
plt.subplot(1,4,3)
plt.title(' Sdiff dist < %d' % dist_range_3)
plt.ylim(azim_min,azim_max)
plt.xlabel('time around predicted arrival (s)')
if switch_yaxis:
   plt.gca().invert_yaxis()
   
plt.subplot(1,4,4)
plt.title(' Sdiff dist < %d' % dist_range_4)
plt.ylim(azim_min,azim_max)
plt.xlabel('time around predicted arrival (s)')
if switch_yaxis:
   plt.gca().invert_yaxis()

plt.suptitle('Waveform with Azimuth\n Event %s' % event)

   
# Save file and show plot
#plt.savefig('Plots/'+event+'/'+event+'data_with_azimuth.pdf')
plt.show()
 

