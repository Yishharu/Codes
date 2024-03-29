#/usr/bin/python3
# Usage: python3 plot_data_azimuth.py [event]
# Example: python3 plot_data_azimuth.py 20100320
import matplotlib.pyplot as plt
import matplotlib.colors as colors
import matplotlib.cm as cm
from obspy.imaging.cm import obspy_sequential

import numpy as np
import os.path
import shutil
import obspy
from obspy import read
import glob
from obspy.signal.tf_misfit import cwt

event = '20100320' #sys.argv[1]
data_path = '/raid3/zl382/Data/' + event + '/'
newfilefolder= '/raid3/zl382/Data/' + event + '/' + 'STACK' + '/'
## Frequencies for filter
f_min = 1/35. #Hz
f_max = 1.  #Hzseis
azim_min = 39
azim_max = 61
time_min = -20
time_max = 100
norm_constant = 2
waveform_norm = False  # recommend False  keep the decay info
spectrum_norm = True  # recommend True

if spectrum_norm:
  savefolder = '/home/zl382/Pictures/STACK/'+event + '_norm/'
else:
  savefolder = '/home/zl382/Pictures/STACK/'+event + '/'
if not os.path.exists(savefolder):
    os.makedirs(savefolder) 

az_list = np.load(newfilefolder+'stack_list.npy')
az_list.sort()
sample = np.load(newfilefolder+'sample.npy')
w_norm = np.max(sample[1])/norm_constant
seislist = glob.glob(data_path + '*PICKLE') 

for az in az_list:
  category_az_folder = newfilefolder+'az_'+str(az)+'/'
  num_of_trace = len(glob.glob(category_az_folder+'*.npy'))
  print(str(num_of_trace)+' found in ' + 'az_'+str(az))
  seislist = glob.glob(category_az_folder + '*npy')
  stack_data = np.zeros(len(sample[1]))  # initialize the array
  for seis in seislist:
    stack_data = stack_data + 1/num_of_trace*np.load(seis)[1]
  if waveform_norm:
    w_norm = np.max(stack_data)
  # sigmoid = -np.log(1/(1+np.exp(-num_of_trace/2+0.5)))
  # plt.plot(sample[0],stack_data/norm + az,color=(sigmoid,0,0))

  scalogram = cwt(stack_data/w_norm, 0.1, 8, f_min, f_max)
  x, y = np.meshgrid(
       sample[0],
       np.logspace(np.log10(f_min), np.log10(f_max), scalogram.shape[0]))
  plt.figure(figsize=(5,10))
  ax=plt.subplot()

  if spectrum_norm:
      s_norm = np.reshape(np.abs(scalogram).max(1),(-1,1))
      ax.pcolormesh(x, y, np.abs(scalogram)/s_norm, cmap=obspy_sequential)
  else:
      ax.pcolormesh(x, y, np.abs(scalogram), cmap=obspy_sequential)

  plt.xlabel('time around ' +'Sdiff' + ' (s)', fontsize=18)
  plt.ylabel('Period (s)',fontsize=18)
  ax.set_yscale('log')
  ax.set_ylim(f_min, f_max)
  plt.yticks([1/30, 1/20, 1/10, 1/5, 1/3, 1/2, 1], ['30', '20', '10', '5', '3', '2', '1'])
  plt.xticks(fontsize=10)
  ax2 = ax.twinx()
  ax2.plot(sample[0], stack_data/np.max(np.abs(stack_data)),'k')  # plot the waveform at the bottom
  ax2.set_ylim([-1,50])
  ax2.set_yticklabels([])
  plt.xlim([time_min,time_max])
  plt.title('Wavelet Spectrum at Azimuth '+ str(az) +';\n Stacking '+ str(num_of_trace)+' Traces')

  filename =  savefolder + 'az_' + str(az) +'.png' 
  plt.savefig(filename,format='png')
  print(filename+ ' saved.')
  plt.close('all')