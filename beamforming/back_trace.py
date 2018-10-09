# -*- coding: utf-8 -*-
"""
Created on Mon Sep 24 15:40:02 2018

@author: zl382
"""
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.dates as mdates
from matplotlib.colorbar import ColorbarBase
from matplotlib.colors import Normalize

import os.path
import obspy
from obspy import read
from obspy.core.util import AttribDict
import glob
from obspy.imaging.cm import obspy_sequential
from obspy.signal.invsim import corn_freq_2_paz
from obspy.signal.array_analysis import array_processing
import matplotlib.ticker as ticker

from obspy.core.stream import Stream 

time_min = 20
time_max = 140

cut_x_120 = np.linspace(35,45,num = 11)
cut_y_120 = np.linspace(326,334, num=11)

cut_x = np.linspace(20,26, num=11)
cut_y = np.linspace(312,325, num=11)
cut_x = np.append(cut_x,np.linspace(28,50,num = 11))
cut_y = np.append(cut_y,np.linspace(326,337, num=11))

# Output Pictures Path
save_picture_path = '/home/zl382/Pictures/fk_analysis/'
if not os.path.exists(save_picture_path):
    os.makedirs(save_picture_path)
# Array Data Path
dir = '/raid3/zl382/Data/20161225/fk_analysis/'
array_list = glob.glob(dir+'*')
# Loop in the whole arrays
for s, array in enumerate(array_list):
  seislist = glob.glob(array + '/*PICKLE')
  array_name = os.path.split(array)[1]
  test = read(array+'/'+array_name+'*PICKLE',format='PICKLE')
  if test[0].stats['dist']< 130 and test[0].stats['dist']> 120:
    timemin = np.interp(test[0].stats['az'],cut_y,cut_x)
  elif test[0].stats['dist']< 120 and test[0].stats['dist']> 110:
    timemin = np.interp(test[0].stats['az'],cut_y_120,cut_x_120)
  else:
    continue  
  st = Stream()
  # Loop in the specific arrays
  for i, seisname in enumerate(seislist):
    print(seisname)
    seis = read(seisname,format='PICKLE')
    st += seis.select(channel='BHT')
    st[i].stats.coordinates = AttribDict({
        'latitude': seis[0].stats['stla'],
        'elevation': seis[0].stats['stelv']/1000,
        'longitude': seis[0].stats['stlo']})
  st.resample(10)
  
  # Choose the specific time section
  Sdifftime = test[0].stats.traveltimes['Sdiff'] or test[0].stats.traveltimes['S']
  stime = test[0].stats['eventtime'] + Sdifftime + time_min
  etime = test[0].stats['eventtime'] + Sdifftime + time_max
  zerotime = test[0].stats['eventtime'] + Sdifftime

  # Execute array_processing
  kwargs = dict(
    # slowness grid: X min, X max, Y min, Y max, Slow Step
    sll_x=-0.1, slm_x=-0.04, sll_y=0.04, slm_y=0.1, sl_s=0.001,
    # sliding window properties
    win_len=60.0, win_frac=0.01,
    # frequency properties
    frqlow=1/30.0, frqhigh=1/10.0, prewhiten=0,
    # restrict output
    coordsys='lonlat', semb_thres=-1e9, vel_thres=-1e9, timestamp='mlabday',
    stime=stime, etime=etime
  )
  print(' Starting Processing Array: ' + array)
  print('az: '+str(test[0].stats['az'])+'dist: '+str(test[0].stats['dist']))
  print('timemin: '+str(timemin))
  out = array_processing(st, **kwargs)
  print('processing done!')
  # Postprocessing of the time array
  out[:,0] = (out[:,0]-719163)*24*3600-zerotime.timestamp

  # Plot
  labels = ['rel.power', 'abs.power', 'baz', 'slow']

  # xlocator = mdates.AutoDateLocator()
  fig = plt.figure(figsize=(20, 10))
  #coef = [1,1,1,111]
  for i, lab in enumerate(labels):
      ax = fig.add_subplot(4, 1, i + 1)
      ax.scatter(out[:, 0], out[:, i + 1], c=out[:, 1], alpha=0.6,
                 edgecolors='none', cmap=obspy_sequential)
      ax.set_ylabel(lab)
      ax.set_xlim(out[0, 0], out[-1, 0])
      ax.set_ylim(out[:, i + 1].min(), out[:, i + 1].max())

      ax.xaxis.set_major_locator(ticker.MultipleLocator(10))
      ax.xaxis.set_minor_locator(ticker.MultipleLocator(1))
      # ax.xaxis.set_major_locator(xlocator)
      # ax.xaxis.set_major_formatter(mdates.AutoDateFormatter(xlocator))

  fig.suptitle('Beamforming Around Sdiff %s; Distance: %.1f Azimuth: %.1f' % (
      stime.strftime('%Y-%m-%d'), test[0].stats['dist'],test[0].stats['az']))
  fig.autofmt_xdate()
  fig.subplots_adjust(left=0.15, top=0.95, right=0.95, bottom=0.2, hspace=0)
  filename = save_picture_path + array_name+'_afourplots.png'
  plt.savefig(filename, format='png')
  print('Plot done and saved in '+ filename + ' !!!')

  #########################Plot the whole Baz together with waveform###############################
  fig = plt.figure(figsize=(20, 15))

  ax = fig.add_subplot(1, 1, 1)
  ax.scatter(out[:, 0], out[:, 3], c=out[:, 1], alpha=0.6,
             edgecolors='none', cmap=obspy_sequential)
  #ax.set_xlim(out[0, 0], out[-1, 0])
  ax.set_ylim(out[:, 3].min(), out[:, 3].max())
  ax.xaxis.set_major_locator(ticker.MultipleLocator(10))
  ax.xaxis.set_minor_locator(ticker.MultipleLocator(1))
  ax2 = ax.twinx()

  w0 = np.argmin(np.abs(st[-1].times(reftime=st[-1].stats['eventtime'])-Sdifftime-time_min))
  w1 = np.argmin(np.abs(st[-1].times(reftime=st[-1].stats['eventtime'])-Sdifftime-time_max))
  norm = np.max(np.abs(st[-1].data[w0:w1]))
  for seisname in seislist:
      seis = read(seisname,format='PICKLE')
      Sdifftime = seis[0].stats.traveltimes['Sdiff'] or seis[0].stats.traveltimes['S']
      tr = seis.select(channel='BHT')[0]
      tr.filter('bandpass', freqmin=1/30.,freqmax=1/10., zerophase=True)
      w0 = np.argmin(np.abs(tr.times(reftime=tr.stats['eventtime'])-Sdifftime-time_min))
      w1 = np.argmin(np.abs(tr.times(reftime=tr.stats['eventtime'])-Sdifftime-time_max))
      ax2.plot(tr.times(reftime=tr.stats['eventtime'])[w0:w1]-Sdifftime, tr.data[w0:w1]/norm+out[:, 3].min(),'k')
      ax2.set_ylim([out[:, 3].min()-1,out[:, 3].min()+30])
      ax2.set_yticklabels([])
  plt.xlim([out[0, 0], out[-1, 0]])
  # fig.autofmt_xdate()

  filename = save_picture_path + array_name+'_baz_waveform.png'
  plt.savefig(filename, format='png')
  print('Plot done and saved in '+ filename + ' !!!')

  #################### Polar plot ##########################
  cmap = obspy_sequential

  # make output human readable, adjust backazimuth to values between 0 and 360
  t, rel_power, abs_power, baz, slow = out.T
  baz[baz < 0.0] += 360

  # choose number of fractions in plot (desirably 360 degree/N is an integer!)
  N = 120
  N2 = 100
  abins = np.arange(N + 1) * 360. / N
  sbins = np.linspace(0, 0.1, N2 + 1)

  # sum rel power in bins given by abins and sbins
  hist, baz_edges, sl_edges = \
      np.histogram2d(baz, slow, bins=[abins, sbins], weights=abs_power)

  # transform to radian
  baz_edges = np.radians(baz_edges)

  # add polar and colorbar axes
  fig = plt.figure(figsize=(15, 15))
  cax = fig.add_axes([0.85, 0.2, 0.05, 0.5])
  ax = fig.add_axes([0.10, 0.1, 0.70, 0.7], polar=True)
  ax.set_theta_direction(-1)
  ax.set_theta_zero_location("N")

  dh = abs(sl_edges[1] - sl_edges[0])
  dw = abs(baz_edges[1] - baz_edges[0])

  # circle through backazimuth
  for i, row in enumerate(hist):
      bars = ax.bar(left=(i * dw) * np.ones(N2),
                    height=dh * np.ones(N2),
                    width=dw, bottom=dh * np.arange(N2),
                    color=cmap(row / hist.max()))

  ax.set_xticks(np.linspace(0, 2 * np.pi, 4, endpoint=False))
  ax.set_xticklabels(['N', 'E', 'S', 'W'])

  # set slowness limits
  ax.set_ylim(0, 0.1)
  [i.set_color('grey') for i in ax.get_yticklabels()]
  ColorbarBase(cax, cmap=cmap,
               norm=Normalize(vmin=hist.min(), vmax=hist.max()))

  filename = save_picture_path + array_name+'_cbeamforming.png'

  ind = np.unravel_index(np.argmax(hist,axis=None), hist.shape)

  np.save(array+'/baz.npy', np.rad2deg(baz_edges[ind[0]]+dw/2))
  print('baz: ')
  print(np.rad2deg(baz_edges[ind[0]]+dw/2))
  np.save(array+'/slowness.npy', sl_edges[ind[1]]+dh/2)
  print('slowness: ')
  print(sl_edges[ind[1]]+dh/2)

  plt.title('Peak Azimuth: %.2f Peak slowness: %f' %(
    np.rad2deg(baz_edges[ind[0]]+dw/2), sl_edges[ind[1]]+dh/2))
  plt.savefig(filename, format='png')
  print('Plot done and saved in '+ filename + ' !!!')

  print('############# '+array+' Been Processed !!! ##'+'   #'+str(s)+ '/'+ str(len(array_list))+' ####')
  plt.close('all')