import os

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.patches import Rectangle
from scipy.signal import hilbert

import obspy
from obspy import read
from obspy.signal.tf_misfit import cwt
from obspy.imaging.cm import obspy_sequential

Location = 'Hawaii'
Event = '20100320'


real_component = 'BHT'
dir = '/raid3/zl382/Data/'+Location+'/'+Event + '/'# '/raid2/sc845/Lowermost/EastPacific/Data/20161225/'

Tmin, Tmax = 10, 30
StartTime, EndTime = -50, 120
select_azi = 55
####### Edit Before This Line ##########
fmin, fmax = 1/Tmax, 1/Tmin
# Loop through seismograms
count = 0
location_dict = np.load(dir+'STALOCATION.npy').item()


for s, (s_name, (dist,azi,stla,stlo,sbaz)) in enumerate(location_dict.items()):
    if np.round(azi) != select_azi or dist<100 or dist>110:
        continue
    full_path = dir+s_name+'.PICKLE'
    if not os.path.exists(full_path):
        continue
    
    seis = read(dir+s_name+'.PICKLE',format='PICKLE') # read seismogram
    seistoplot= seis.select(channel=real_component)[0]    
    seistoplot.filter('bandpass', freqmin=fmin,freqmax=fmax, zerophase=True)

    # seistoplot_filter =  seistoplot.copy()
    # seistoplot_filter.filter('bandpass', freqmin=fmin,freqmax=fmax, zerophase=True)
    try:
        seis.resample(10)
    except:
        print(s_name+' resample error')
        continue
    
    phase_time = seis[0].stats.traveltimes['Sdiff'] or seis[0].stats.traveltimes['S']
    w0 = np.argmin(np.abs(seistoplot.times(reftime=seistoplot.stats['eventtime'])-phase_time-StartTime))
    w1 = np.argmin(np.abs(seistoplot.times(reftime=seistoplot.stats['eventtime'])-phase_time-EndTime))
    time_series = seistoplot.times(reftime=seistoplot.stats['eventtime'])[w0:w1]-phase_time
    data_series = seistoplot.data[w0:w1]
    # data_series_filter = seistoplot_filter.data[w0:w1]
    if count == 0:
        norm = data_series.max()
        stack_data_series = data_series/norm
        # stack_data_series_filter = data_series_filter/norm
    else:
        stack_data_series = stack_data_series + data_series/norm
        # stack_data_series_filter = stack_data_series_filter + data_series_filter/norm
  
    count = count + 1

scalogram = cwt(stack_data_series, 0.1, 8, fmin, fmax)
x, y = np.meshgrid(
    time_series,
    np.logspace(np.log10(fmin), np.log10(fmax), scalogram.shape[0]))  

fig, ax = plt.subplots(figsize=(9, 9))  
ax.pcolormesh(x,y, np.abs(scalogram), cmap=obspy_sequential)
plt.xlabel('time around ' +'Sdiff' + ' (s)', fontsize=18)
plt.ylabel('Period (s)',fontsize=18)
ax.set_yscale('log')
ax.set_ylim(fmin, fmax)
# ax.set_yticklabels([])
plt.yticks([1/30,1/20,1/10], ['30','20','10'])
plt.xticks(fontsize=10)

ax2 = ax.twinx()
ax2.plot(time_series, stack_data_series/stack_data_series.max(),'k')  # plot the waveform at the bottom
ax2.set_ylim([-1,50])
ax2.set_yticklabels([])
plt.xlim([StartTime,EndTime])

plt.title('Wavelet Spectrum at Azimuth '+ str(select_azi) +';\n Stacking '+ str(count)+' Traces')
plt.show()