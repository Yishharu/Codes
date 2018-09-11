#/usr/bin/python3
# Usage: python3 plot_data_azimuth.py [event]
# Example: python3 plot_data_azimuth.py 20100320
import matplotlib.pyplot as plt
import numpy as np
import os.path
import obspy
from obspy import read
import glob
import pickle

event = '20100320' #sys.argv[1]
data_path = '/raid3/zl382/Data/' + event + '/'
seislist = glob.glob(data_path + '*PICKLE')

## Frequencies for filter
fmin = 1/30. #Hz
fmax = 1/10.  #Hzseis
azim_min = 39
azim_max = 61

time_min = -20
time_max = 70

newfilefolder= '/raid3/zl382/Data/' + event + '/' + 'STACK' + '/'
if not os.path.exists(newfilefolder):
    os.makedirs(newfilefolder)

for s in range(0,len(seislist),50):
  print(s)
  seis = read(seislist[s],format='PICKLE') # read seismogram
  seistoplot= seis.select(channel='BHT')[0]
  seistoplot.filter('bandpass', freqmin=fmin,freqmax=fmax, zerophase=True)
  stacking_azimuth = str(np.round(seis[0].stats['az']))
  if seis[0].stats.traveltimes['Sdiff']!=None:
    phase = 'Sdiff'
  else:
    phase = 'S'
  align_time = seis[0].stats.traveltimes[phase]
  
  stack_datapath = newfilefolder + 'stack_'+ stacking_azimuth + '.npy'
  A  = np.array([seistoplot.timesarray-align_time, seistoplot.data])
  np.save(stack_datapath,A)

 # plt.plot(seistoplot.timesarray-align_time, seistoplot.data/np.max(seistoplot.data) + np.round(seis[0].stats['az']),'b')

plt.ylim(azim_min,azim_max)
plt.xlim(time_min,time_max)
plt.gca().invert_yaxis()
plt.show()