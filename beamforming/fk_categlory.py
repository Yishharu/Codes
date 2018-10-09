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
import obspy.geodetics.base
from obspy.geodetics import kilometers2degrees

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

for i, center in enumerate(seislist):
  print('#### Start sorting '+ ' #' + str(i)+'/'+ str(len(seislist))+' '+center+' ########')
  center_seis = read(center,format='PICKLE') # read seismogram
  if center_seis[0].stats['dist']>=96 and center_seis[0].stats['dist']<=130:
    distance_rank = dict()
    name = os.path.splitext(os.path.split(center)[1])[0]
    category_folder = newfilefolder+name+'/'

    for periphery in seislist:
      periphery_seis = read(periphery,format='PICKLE')
      distm, az, baz = obspy.geodetics.base.gps2dist_azimuth(
        center_seis[0].stats['stla'], center_seis[0].stats['stlo'],periphery_seis[0].stats['stla'], periphery_seis[0].stats['stlo'])
      distdg = kilometers2degrees(distm/1.0e3)
      distance_rank[periphery] = distdg

    distance_rank_sorted = sorted(distance_rank.items(),key=lambda kv: kv[1])
    if distance_rank_sorted[20][1] < 3: # Make sure the closest 20 stations are within 4 degree grid
      if not os.path.exists(category_folder):
        os.makedirs(category_folder)
      np.save(category_folder+'stla.npy', center_seis[0].stats['stla'])
      np.save(category_folder+'stlo.npy', center_seis[0].stats['stlo'])
      for name, distance in distance_rank_sorted[:20]:
        copy2(name, category_folder)
        print(name + ' : ' + str(distance)+ ' successfully copied !!')