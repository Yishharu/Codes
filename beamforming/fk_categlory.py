#/usr/bin/python3
# Usage: python3 plot_data_azimuth.py [event]
# Example: python3 plot_data_azimuth.py 20100320
import matplotlib.pyplot as plt
import numpy as np
import os.path
import shutil
from shutil import copy2
import obspy
from obspy import read
import glob
import pickle

event = '20161225' #sys.argv[1]
data_path = '/raid3/zl382/Data/' + event + '/'
seislist = glob.glob(data_path + '*PICKLE')

## Frequencies for filter
fmin = 1/35. #Hz
fmax = 5.  #Hzseis
azim_min = 39
azim_max = 61

time_min = -20
time_max = 100

newfilefolder= '/raid3/zl382/Data/' + event + '/' + 'fk_analysis' + '/'
if not os.path.exists(newfilefolder):
    os.makedirs(newfilefolder)

 # Loop through seismograms 
count = 0
for s in range(0,len(seislist),1):
  seis = read(seislist[s],format='PICKLE') # read seismogram
  if seis[0].stats['dist']>=105 and seis[0].stats['dist']<=130:

      seistoplot = seis.select(channel='BHT')[0]
      s_name = os.path.splitext(os.path.split(seislist[s])[1])[0]
      print('Load ' + s_name +' # '+str(s)) 
      
      fk_azimuth = str(np.round(seis[0].stats['az']/3)*3)
      fk_distance = str(np.round(seis[0].stats['dist']/3)*3)
      
      category_folder = newfilefolder+'az_'+fk_azimuth+'dist_'+fk_distance+'/'
      if not os.path.exists(category_folder):
        os.makedirs(category_folder)

      copy2(seislist[s],category_folder)