#/usr/bin/python3
# Usage: python3 plot_data_azimuth.py [event]
# Example: python3 plot_data_azimuth.py 20100320
import matplotlib.pyplot as plt
import numpy as np
import os.path
import shutil
import obspy
from obspy import read
import glob
import pickle

event = '20100320' #sys.argv[1]
data_path = '/raid3/zl382/Data/' + event + '/'
seislist = glob.glob(data_path + '*PICKLE')

## Frequencies for filter
fmin = 1/35. #Hz
fmax = 5.  #Hzseis
azim_min = 39
azim_max = 61

time_min = -20
time_max = 100

newfilefolder= '/raid3/zl382/Data/' + event + '/' + 'STACK' + '/'
if not os.path.exists(newfilefolder):
    os.makedirs(newfilefolder)

if os.path.exists(newfilefolder+'stack_list.npy'):
  az_list = np.load(newfilefolder+'stack_list.npy')
  print('loaded stack list')
else:
  az_list = np.array([])

 # Loop through seismograms 
count = 0
for s in range(0,len(seislist),1):
  seis = read(seislist[s],format='PICKLE') # read seismogram
  if seis[0].stats['dist']>=100 and seis[0].stats['dist']<=110:
      try:
          seis.resample(10)
      except:
          print('resample error')
          continue
      seistoplot = seis.select(channel='BHT')[0]
      s_name = os.path.splitext(os.path.split(seislist[s])[1])[0]
      print('Load ' + s_name +' # '+str(s))
      seistoplot.filter('bandpass', freqmin=fmin,freqmax=fmax, zerophase=True)    
      
      stacking_azimuth = str(np.round(seis[0].stats['az']))
      if seis[0].stats.traveltimes['Sdiff']!=None:
        phase = 'Sdiff'
      else:
        phase = 'S'
      align_time = seis[0].stats.traveltimes[phase]
      
      category_az_folder = newfilefolder+'az_'+stacking_azimuth+'/'
      if not os.path.exists(category_az_folder):
        os.makedirs(category_az_folder)
        az_list = np.append(az_list,float(stacking_azimuth))
      w0 = np.argmin(np.abs(seistoplot.times(reftime=seistoplot.stats['eventtime'])-align_time-time_min))
      w1 = np.argmin(np.abs(seistoplot.times(reftime=seistoplot.stats['eventtime'])-align_time-time_max))
          
      stack_data_path = category_az_folder + s_name + '.npy'
      A  = np.array([(seistoplot.times(reftime=seistoplot.stats['eventtime'])-align_time)[w0:w1], seistoplot.data[w0:w1]])
     # print(np.shape(A[0]),np.shape(A[0]))
      np.save(stack_data_path,A)
      
np.save(newfilefolder+'stack_list.npy', az_list)
np.save(newfilefolder+'sample.npy', A)