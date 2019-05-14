import os

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.colors import LinearSegmentedColormap
from matplotlib.ticker import ScalarFormatter
from matplotlib.ticker import NullFormatter
from matplotlib.patches import Rectangle
from scipy.signal import hilbert

import obspy
from obspy import read
from obspy.signal.tf_misfit import cwt
from obspy.imaging.cm import obspy_sequential

Location = 'Hawaii'
Event = '20180910'


real_component = 'BHT'
dir = '/raid1/zl382/Data/'+Location+'/'+Event + '/'# '/raid2/sc845/Lowermost/EastPacific/Data/20161225/'

Tmin, Tmax = 1, 10
StartTime, EndTime = -50, 120
select_azi = 52
per_norm = True

plt.rcParams.update({'font.size': 20})   
for select_azi in range(5,22):
    ####### Edit Before This Line ##########
    cmap = 'batlow'
    cm_data = np.loadtxt('/home/zl382/Downloads/ScientificColourMaps5/%s/%s.txt' %(cmap, cmap))
    CBname_map = LinearSegmentedColormap.from_list(cmap, cm_data)


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
        elif per_norm:
            stack_data_series = stack_data_series + data_series/data_series.max()
        else:
            stack_data_series = stack_data_series + data_series/norm
    
        count = count + 1

    scalogram = cwt(stack_data_series, 0.1, 8, fmin, fmax)
    x, y = np.meshgrid(
        time_series,
        np.logspace(np.log10(fmin), np.log10(fmax), scalogram.shape[0]))  

    fig, ax = plt.subplots(figsize=(9, 9))  
    ax.pcolormesh(x, 1/y, np.abs(scalogram), cmap=CBname_map)
    plt.xlabel('Time around ' +'Sdiff' + ' (s)', fontsize=18)
    plt.ylabel('Period (s)',fontsize=18)
    ax.set_yscale('log')      # set linear(detail in 1-2-3) or log(even)
    ax.set_ylim(Tmin, Tmax)
    majors = [1,2,3,4,5,6,7,8,9,10]
    ax.yaxis.set_major_locator(plt.FixedLocator(majors))
    # ax.yaxis.set_minor_locator(plt.NullLocator())
    ax.yaxis.set_major_formatter(ScalarFormatter())
    ax.yaxis.set_minor_formatter(NullFormatter())
    ax.xaxis.set_major_locator(plt.MultipleLocator(20))   
    ax.xaxis.set_minor_locator(plt.MultipleLocator(5)) 
    # ax.set_yticks([1/10,1/5,1/3,1/2,1], ['10','5','3','2','1'])
    plt.gca().invert_yaxis()

    ax2 = ax.twinx()
    ax2.plot(time_series, stack_data_series/stack_data_series.max(),'k')  # plot the waveform at the bottom
    ax2.set_ylim([-1,50])
    ax2.set_yticklabels([])
    plt.xlim([StartTime,EndTime])


    plt.title('Wavelet Spectrum at Azimuth '+ str(select_azi) +';\n Stacking '+ str(count)+' Traces')

    # plt.show()
    plt.savefig('/home/zl382/Pictures/Events/%s/azi-%s.png' %(Event, select_azi))
    print('Event %s Azimuth %s saved' %(Event, select_azi))