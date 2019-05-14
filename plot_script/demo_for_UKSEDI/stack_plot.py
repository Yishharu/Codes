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
Event = '20100320'


real_component = 'BHT'
dir = '/raid1/zl382/Data/'+Location+'/'+Event + '/'# '/raid2/sc845/Lowermost/EastPacific/Data/20161225/'

Tmin, Tmax = 1, 10
StartTime, EndTime = -50, 200
select_azi = 52
per_norm = True
norm_constant = 4

####### Edit Before This Line ##########
plt.rcParams.update({'font.size': 15})   # Font Size of the Axes
cmap = 'batlow'
cm_data = np.loadtxt('/home/zl382/Downloads/ScientificColourMaps5/%s/%s.txt' %(cmap, cmap))
CBname_map = LinearSegmentedColormap.from_list(cmap, cm_data)
ax = plt.axes()
i_Sdiff = 0 
i_pSdiff = 0
i_sSdiff = 0 
i_pSKKS = 0 
i_SP = 0 
i_pSKKS = 0
i_sSKKS = 0
i_sSKS =0

for select_azi in range(35,66):
    print('select_azi is %s ' %select_azi)

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
    if count == 0:
        continue
    stack_data_series = stack_data_series / count * norm_constant
    fig = plt.plot(time_series, stack_data_series + select_azi,'k')  # plot the waveform at the bottom

    align_time = seis[0].stats.traveltimes['Sdiff'] or seis[0].stats.traveltimes['S']


    for k in seis[0].stats.traveltimes.keys():
        if seis[0].stats.traveltimes[k]!=None: #and k!='S90' and k!='P90' and seis[0].stats.traveltimes[k]-align_time<time_max and seis[0].stats.traveltimes[k]-align_time>time_min:
            if k == 'Sdiff' or k == 'S':
                plt.scatter(seis[0].stats.traveltimes[k]-align_time, np.round(seis[0].stats['az']),c='g',marker='o',s=20, label='Sdiff & S' if i_Sdiff==0 else '')
                print('Sdiff: ' + str(seis[0].stats.traveltimes[k]-align_time))
                i_Sdiff += 1
            elif k == 'pSdiff':
                plt.scatter(seis[0].stats.traveltimes[k]-align_time, np.round(seis[0].stats['az']),c='r',marker='o',s=20, label='pSdiff' if i_pSdiff==0 else '')
                print('pSdiff: ' + str(seis[0].stats.traveltimes[k]-align_time))
                i_pSdiff  += 1
            elif k == 'sSdiff':
                plt.scatter(seis[0].stats.traveltimes[k]-align_time, np.round(seis[0].stats['az']),c='orange',marker='o',s=20, label='sSdiff' if i_sSdiff==0 else '')
                print('sSdiff: ' + str(seis[0].stats.traveltimes[k]-align_time))
                i_sSdiff  += 1
            elif k == 'pSKKS':
                plt.scatter(seis[0].stats.traveltimes[k]-align_time, np.round(seis[0].stats['az']),c='yellow',marker='o',s=20, label='pSKKS' if i_pSKKS==0 else '')
                print('pSKKS: ' + str(seis[0].stats.traveltimes[k]-align_time))
                i_pSKKS  += 1
            elif k == 'PS':
                plt.scatter(seis[0].stats.traveltimes[k]-align_time, np.round(seis[0].stats['az']),c='gold',marker='o',s=20, label='PS' if i_SP==0 else '')
                print('PS: ' + str(seis[0].stats.traveltimes[k]-align_time))
                i_SP  += 1
            elif k == 'sSKS':
                plt.scatter(seis[0].stats.traveltimes[k]-align_time, np.round(seis[0].stats['az']),c='pink',marker='o',s=20, label='sSKS' if i_sSKS==0 else '')
                print('sSKS: ' + str(seis[0].stats.traveltimes[k]-align_time))
                i_sSKS  += 1
            elif k == 'sSKKS':
                plt.scatter(seis[0].stats.traveltimes[k]-align_time, np.round(seis[0].stats['az']),c='pink',marker='o',s=20, label='sSKKS' if i_sSKKS==0 else '')
                print('sSKKS: ' + str(seis[0].stats.traveltimes[k]-align_time))
                i_sSKKS  += 1
            elif k == 'pSKKS':
                plt.scatter(seis[0].stats.traveltimes[k]-align_time, np.round(seis[0].stats['az']),c='pink',marker='o',s=20, label='pSKKS' if i_pSKKS==0 else '')
                print('pSKKS: ' + str(seis[0].stats.traveltimes[k]-align_time))
                i_pSKKS  += 1


plt.xlim([StartTime,EndTime])
plt.gca().invert_yaxis()

plt.ylabel('Azimuth (deg)')
plt.ylabel('Time Around Sdiff (s)')
# plt.title('Waveform Stack Plot')
plt.show()
    # plt.savefig('/home/zl382/Pictures/Events/%s/azi-%s.png' %(Event, select_azi))
    # print('Event %s Azimuth %s saved' %(Event, select_azi))