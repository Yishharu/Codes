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

event = '20100320' #sys.argv[1]
data_path = '/raid3/zl382/Data/' + event + '/'
seislist = glob.glob(data_path + '*PICKLE')

azim_min = 39
azim_max = 61

time_min = -20
time_max = 70

norm_constant = 2
per_norm = False

newfilefolder= '/raid3/zl382/Data/' + event + '/' + 'STACK' + '/'

az_list = np.load(newfilefolder+'stack_list.npy')
sample = np.load(newfilefolder+'sample.npy')

norm = np.max(sample[1])/norm_constant
  
for az in az_list:
  category_az_folder = newfilefolder+'az_'+str(az)+'/'
  num_of_trace = len(glob.glob(category_az_folder+'*.npy'))
  print(str(num_of_trace)+' found in ' + 'az_'+str(az))
  seislist = glob.glob(category_az_folder + '*npy')
  stack_data = np.zeros(len(sample[1]))  # initialize the array
  for seis in seislist:
    stack_data = stack_data + 1/num_of_trace*np.load(seis)[1]
  if per_norm:
    norm = np.max(stack_data)
  sigmoid = -np.log(1/(1+np.exp(-num_of_trace/2+0.5)))
  plt.plot(sample[0],stack_data/norm + az,color=(sigmoid,0,0))
  
plt.xlabel('time around predicted arrival (s)')
plt.ylabel('azimuth (dg)')
plt.gca().invert_yaxis()
plt.show()