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
import sys
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
event = '20100320' #sys.argv[1]

if_model = False
model = 'ULVZ63'
##################################Edit After This Line ##################

dist_min = 100
dist_max = 110

az_min = 45
az_max = 65

vx_min = -0.1
vx_max =  0.0
vy_min =  0.0
vy_max =  0.1

component = 'BHT'   # Synthetic for  'BXT', BCT'
time_min = 40
time_max = 90

if_postcursor_cut = True

cut_distance_min1 = 100
cut_distance_max1 = 110
# Y should be increasing
[x1,y1] = [20,65]
[x2,y2] = [50,50]
[x3,y3] = [70,40]

cut_distance_min2 = 0
cut_distance_max2 = 0
[x11,y11] = [20,312]
[x22,y22] = [25,325]
[x33,y33] = [51,337]

# Output Pictures Path
if if_model:
    if if_postcursor_cut:
      save_picture_path = '/home/zl382/Pictures/'+event+model+'pc_fk_analysis/'
    else:
      save_picture_path = '/home/zl382/Pictures/part_'+event+model+'_fk_analysis/'
else:
    if if_postcursor_cut:
      save_picture_path = '/home/zl382/Pictures/high_freq_'+event+'pc_fk_analysis/'
    else:
      save_picture_path = '/home/zl382/Pictures/'+event+'_fk_analysis/'    
      
# Array Data Path
if if_model:
    dir = '/raid3/zl382/Data/'+event+'_synthetics/'+model+'/fk_analysis/'
else:
    dir = '/raid3/zl382/Data/'+event+'/high_freq_fk_analysis/'
# dir = '/raid3/zl382/Data/20161225_synthetics/' +model+ '/fk_analysis' + '/'

##################################Edit Before This Line ##################
if not os.path.exists(save_picture_path):
    os.makedirs(save_picture_path)

for f in glob.glob(dir+'*/baz.npy'):
  os.remove(f)
for f in glob.glob(dir+'*/slowness.npy'):
  os.remove(f)  

cut_x1 = np.linspace(x1,x2, num=10, endpoint=False)    # First Line
cut_y1 = np.linspace(y1,y2, num=10, endpoint=False)
cut_x1 = np.append(cut_x1,np.linspace(x2,x3, num = 11))
cut_y1 = np.append(cut_y1,np.linspace(y2,y3, num=11))

cut_x2 = np.linspace(x11,x22, num=10, endpoint=False)    # First Line
cut_y2 = np.linspace(y11,y22, num=10, endpoint=False)
cut_x2 = np.append(cut_x2,np.linspace(x22,x33, num = 11))
cut_y2 = np.append(cut_y2,np.linspace(y22,y33, num=11))

array_list = glob.glob(dir+'*')
# Loop in the whole arrays
for s, array in enumerate(array_list):
  seislist = glob.glob(array + '/*PICKLE')
  array_name = os.path.split(array)[1]
  test = read(array+'/'+array_name+'*PICKLE',format='PICKLE')
  if test[0].stats['az']<az_min or test[0].stats['az']>az_max:
    continue
  if (test[0].stats['dist']< cut_distance_max1 and test[0].stats['dist']> cut_distance_min1) or \
  (test[0].stats['dist']< cut_distance_max2 and test[0].stats['dist']> cut_distance_min2) :
    if if_postcursor_cut:
      if test[0].stats['dist']< cut_distance_max1 and test[0].stats['dist']> cut_distance_min1:
        time_min = np.interp(test[0].stats['az'],cut_y1,cut_x1)
      elif test[0].stats['dist']< cut_distance_max2 and test[0].stats['dist']> cut_distance_min2:
        time_min = np.interp(test[0].stats['az'],cut_y2,cut_x2)
      else:
        continue  
    st = Stream()
    stime_list = []
    # Loop in the specific arrays
    for i, seisname in enumerate(seislist):
      print(seisname)
      seis = read(seisname,format='PICKLE')
      st += seis.select(channel=component)
      st[i].stats.coordinates = AttribDict({
          'latitude': seis[0].stats['stla'],
          'elevation': 0, #seis[0].stats['stelv']/1000,
          'longitude': seis[0].stats['stlo']})
      stime_list.append(seis[0].stats.traveltimes['Sdiff'])
    st.resample(10)
    stime_list = np.array(stime_list)
    print('Sdiff time deviation of %s is  %f' %(array_name,stime_list.max()-stime_list.min()))
    print(stime_list)
    
    # Choose the specific time section
    Sdifftime = test[0].stats.traveltimes['Sdiff'] or test[0].stats.traveltimes['S']
    if if_model:
        stime = test[0].stats['eventtime'] + Sdifftime + time_min + 746.6995
        etime = test[0].stats['eventtime'] + Sdifftime + time_max + 746.6995      
    else:            
        stime = test[0].stats['eventtime'] + Sdifftime + time_min
        etime = test[0].stats['eventtime'] + Sdifftime + time_max
        
        
    zerotime = test[0].stats['eventtime'] + Sdifftime

    # Execute array_processing
    kwargs = dict(
      # slowness grid: X min, X max, Y min, Y max, Slow Step
      sll_x=vx_min, slm_x=vx_max, sll_y=vy_min, slm_y=vy_max, sl_s=0.001,
      # sliding window properties
      win_len=15.0, win_frac=0.01,
      # frequency properties
      frqlow=1/5.0, frqhigh=1/1.0, prewhiten=0,
      # restrict output
      coordsys='lonlat', semb_thres=-1e9, vel_thres=-1e9, timestamp='mlabday',
      stime=stime, etime=etime
    )
    print(' Starting Processing Array: ' + array)
    print('az: '+str(test[0].stats['az'])+'dist: '+str(test[0].stats['dist']))
    print('time_min: '+str(time_min))
    print('time_max: '+str(time_max))
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
        tr = seis.select(channel=component)[0]
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
    plt.close('all')
    #################### Polar plot ##########################
    cmap = obspy_sequential

    # make output human readable, adjust backazimuth to values between 0 and 360
    t, rel_power, abs_power, baz, slow = out.T
    baz[baz < 0.0] += 360

    # choose number of fractions in plot (desirably 360 degree/N is an integer!)
    N = 360
    N2 = 100
    abins = np.arange(N + 1) * 360. / N
    sbins = np.linspace(0, 0.1, N2 + 1)

    # sum rel power in bins given by abins and sbins
    hist, baz_edges, sl_edges = \
        np.histogram2d(baz, slow, bins=[abins, sbins], weights=abs_power)
    hist[:,((sl_edges<0.07) | (sl_edges>0.08))[:-1]] = 0
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

    np.save(save_picture_path+array_name+'_baz.npy', np.rad2deg(baz_edges[ind[0]]+dw/2))
    print('baz: ')
    print(np.rad2deg(baz_edges[ind[0]]+dw/2))
    np.save(save_picture_path+array_name+'_slowness.npy', sl_edges[ind[1]]+dh/2)
    print('slowness: ')
    print(sl_edges[ind[1]]+dh/2)

    # plt.title('Peak Azimuth: %.2f Peak slowness: %f' %(
    #   np.rad2deg(baz_edges[ind[0]]+dw/2), sl_edges[ind[1]]+dh/2))
    # plt.savefig(filename, format='png')
    # print('Plot done and saved in '+ filename + ' !!!')

    print('############# '+array+' Been Processed !!! ##'+'   #'+str(s)+ '/'+ str(len(array_list))+' ####')
    plt.close('all')