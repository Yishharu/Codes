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

event = '20100320' #sys.argv[1]
model = 'ULVZ63'

dist_min = 100
dist_max = 110

az_min = 45
az_max = 65

# data_path = '/raid2/sc845/Lowermost/EastPacific/Data/20161225/CSEM/'+model+'/'
# newfilefolder= '/raid3/zl382/Data/20161225_synthetics/' +model+ '/fk_analysis' + '/'

data_path = '/raid3/zl382/Data/' + event + '/' #'/raid3/zl382/Data/' + event + '/'
newfilefolder= '/raid3/zl382/Data/' + event + '/' + 'high_freq_fk_analysis' + '/'
seislist = glob.glob(data_path + '*PICKLE')

if not os.path.exists(newfilefolder):
    os.makedirs(newfilefolder)

 # Loop through seismograms 
count = 0

for i, center in enumerate(seislist):
  print('#### Start sorting '+ ' #' + str(i)+'/'+ str(len(seislist))+' '+center+' ########')
  center_seis = read(center,format='PICKLE') # read seismogram
  if center_seis[0].stats['dist']<dist_min or center_seis[0].stats['dist']>dist_max \
  or center_seis[0].stats['az']<az_min or center_seis[0].stats['az']>az_max:
    continue

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
  if distance_rank_sorted[20][1] < 2: # Make sure the closest 20 stations are within 4 degree grid
    if not os.path.exists(category_folder):
      os.makedirs(category_folder)
    np.save(category_folder+'stla.npy', center_seis[0].stats['stla'])
    np.save(category_folder+'stlo.npy', center_seis[0].stats['stlo'])
    for name, distance in distance_rank_sorted[:20]:
      copy2(name, category_folder)
      print(name + ' : ' + str(distance)+ ' successfully copied !!')