import glob
import sys
import time

import numpy as np
import matplotlib.pyplot as plt
from scipy.signal import hilbert

import obspy
from obspy import read
from obspy.core import Stream, trace
from geographiclib.geodesic import Geodesic


nv = 2
## Frequencies for filter
fmin = 1/20. #Hz
fmax = 1/10.  #Hzseis

time_min = -100
time_max = 200

# Parameter for beamforming
StartWindow = -100
EndWindow = 200
LongStartWindow = -100
LongEndWindow = 200
norm_constant = 1

# slowness1 = np.linspace(0.0,7.5,16)
# slowness2 = np.linspace(7.6,8.9,131)
# slowness3 = np.linspace(9.0,10.0,3)
# slowness = np.append(slowness1,np.append(slowness2,slowness3))

slowness = np.linspace(7.5,9.5,201)
backazimuth = 86 # Fixed backazimuth
# Data Directory
dir = '/raid3/zl382/Data/20100320/fk_analysis/TA.T29A/'

#################################### Edit Before This Line ########################
def progress(count, total, status=''):
    bar_len = 60
    filled_len = int(round(bar_len * count / float(total)))

    percents = round(100.0 * count / float(total), 1)
    bar = '=' * filled_len + '-' * (bar_len - filled_len)

    sys.stdout.write('[%s] %s%s ...%s\r' % (bar, percents, '%', status))
    sys.stdout.flush()  # As suggested by Rom Ruben (see: http://stackoverflow.com/questions/3173320/text-progress-bar-in-the-console/27871113#comment50529068_27871113)
STARTTIME = time.time()

seislist = glob.glob(dir + '*PICKLE')
sl_resolution = np.diff(slowness).min()

backradian = np.deg2rad(backazimuth)

ArrayLocation = []
ArrayXY = []
stTOGETHER = Stream()
align_time = []
azlist = []

baz = np.deg2rad(backazimuth)
slx = slowness*np.sin(baz)
sly = slowness*np.cos(baz)
slxy = np.stack((slx,sly),axis=-1)


# Find the reference station
center_seisname = dir+'TA.T29A.PICKLE'
seis = read(dir+'TA.T29A.PICKLE',format='PICKLE')
seis.resample(10)
center_lat = seis[0].stats['stla']
center_lon = seis[0].stats['stlo']
center_az = seis[0].stats['az']
center_dist = seis[0].stats['dist']
CenterSdifftime = seis[0].stats.traveltimes['Sdiff'] or seis[0].stats.traveltimes['S']
stTOGETHER += seis.select(channel='BHT')    # Add ref station as the first trace
stTOGETHER[0].stats = seis[0].stats
ArrayLocation.append([0,0])
ArrayXY.append([0,0])
align_time.append(CenterSdifftime)
azlist.append(center_az)

Bundles_name = dir + 'Bundles.PICKLE'
seisloop = (seisname for seisname in seislist \
     if (seisname != center_seisname) and (seisname != Bundles_name))   # Make sure the ref trace is not in the loop
for seisname in seisloop:
    seis = read(seisname,format='PICKLE')
    seis.resample(10)
    stTOGETHER += seis.select(channel='BHT')
    stTOGETHER[-1].stats = seis[0].stats
    slat = seis[0].stats['stla']
    slon = seis[0].stats['stlo']
    Location = Geodesic.WGS84.Inverse(center_lat,center_lon,slat,slon, outmask=1929) # Relative Location to Center Station
    ArrayLocation.append([Location['a12'],Location['azi1']])
    ArrayX = Location['a12']*np.sin(np.deg2rad(Location['azi1']))
    ArrayY = Location['a12']*np.cos(np.deg2rad(Location['azi1']))
    ArrayXY.append([ArrayX,ArrayY])
    align_time.append(seis[0].stats.traveltimes['Sdiff'] or seis[0].stats.traveltimes['S'])
    azlist.append(seis[0].stats['az'])

ArrayLocation = np.array(ArrayLocation)
ArrayXY = np.array(ArrayXY)
align_time = np.array(align_time)
azlist = np.array(azlist)
T = np.dot(slxy,np.transpose(ArrayXY))

stTOGETHER.write(dir+'Bundles.PICKLE','PICKLE')  # Store the raw data before filter
stTOGETHER.filter('bandpass', freqmin=fmin,freqmax=fmax, zerophase=True)
norm = np.max(stTOGETHER[0].data) / norm_constant

# Loop in slowness meshrid
N = len(stTOGETHER)
index = 0
total = np.size(slowness)

for c, sl in enumerate(slowness):
    progress(index, total, status='Doing very long job')
    # time.sleep(0.1)
    index +=1
    for i, st in enumerate(stTOGETHER):
        w1 = np.argmin(np.abs(st.times(reftime=st.stats['eventtime'])-CenterSdifftime-StartWindow-T[c][i]))
        w2 = np.argmin(np.abs(st.times(reftime=st.stats['eventtime'])-CenterSdifftime-EndWindow-T[c][i]))
        long_trace = st.data[w1:w2]
        if i == 0:
            Linear_Stack = np.zeros(np.shape(long_trace))
            PS_Stack = np.zeros(np.shape(long_trace),dtype='complex')
            PWS_Stack = np.zeros(np.shape(long_trace))
        Linear_Stack += long_trace /norm
        PHASE = np.unwrap(np.angle(hilbert(long_trace)))
        PS_Stack += np.exp(1j*PHASE)
    Linear_Stack = Linear_Stack/N
    PS_Stack = np.abs(PS_Stack)/N
    PWS_Stack += Linear_Stack*PS_Stack**nv
    if c == 0:
        power = PWS_Stack # np.abs(hilbert(PWS_Stack))
    else:          
        power = np.vstack((power,PWS_Stack)) # np.abs(hilbert(PWS_Stack))))

stddev = np.std(power,axis=1)
stddev_array = np.repeat(stddev[:,np.newaxis],np.shape(power)[1],1)
power[np.abs(power)<2*stddev_array] = 0

fig, ax = plt.subplots()
pp = ax.pcolorfast(stTOGETHER[0].times(reftime=stTOGETHER[0].stats['eventtime'])[w1:w2]-CenterSdifftime,slowness,power,cmap='seismic')

ENDTIME = time.time()
print('time-slowness STACK Excution Time: %s s!' %(ENDTIME-STARTTIME))
# print('Find Peak at baz %.0f deg slowness at %.2f' %(baz[c], sl[c]))
plt.colorbar(pp)
plt.title('Beamforming Power\
    \n Event %s    Real data: %s  Window: %ds - %ds \
    \n freq: %.0f s - %.0f s  baz at %.0f deg slowness at %.2f(\u00B1%s)'\
    % ('20100320', 'BHT', StartWindow, EndWindow, 1/fmax, 1/fmin, backazimuth, slowness[c],repr(sl_resolution)))

# Plot the array with maximum power slowness
# c = slowness.index(8.51)
c = np.argmin(np.abs(slowness-8.51))

plt.figure()
for i, st in enumerate(stTOGETHER):
    plt.plot(st.times(reftime=st.stats['eventtime'])-CenterSdifftime, st.data /norm + T[c][i],'k')
    w1_long = np.argmin(np.abs(st.times(reftime=st.stats['eventtime'])-CenterSdifftime-LongStartWindow-T[c][i]))   # Example of a long trace
    w2_long = np.argmin(np.abs(st.times(reftime=st.stats['eventtime'])-CenterSdifftime-LongEndWindow-T[c][i]))
    w1_cut = np.argmin(np.abs(st.times(reftime=st.stats['eventtime'])-CenterSdifftime-StartWindow-T[c][i]))
    w2_cut = np.argmin(np.abs(st.times(reftime=st.stats['eventtime'])-CenterSdifftime-EndWindow-T[c][i]))         # Real timewindow demo
    long_trace = st.data[w1_long:w2_long]
    cut_trace = st.data[w1_cut:w2_cut]
    plt.plot(st.times(reftime=st.stats['eventtime'])[w1_cut:w2_cut]-CenterSdifftime, cut_trace/norm + T[c][i],'r')  # Plot real timewindow
    if i == 0:
        Linear_Stack = np.zeros(np.shape(long_trace))
        PS_Stack = np.zeros(np.shape(long_trace),dtype='complex')
        PWS_Stack = np.zeros(np.shape(long_trace))
    Linear_Stack += long_trace /norm
    PHASE = np.unwrap(np.angle(hilbert(long_trace)))
    PS_Stack += np.exp(1j*PHASE)
Linear_Stack = Linear_Stack/N
PS_Stack = np.abs(PS_Stack)/N
PWS_Stack += Linear_Stack*PS_Stack**nv

plt.plot(stTOGETHER[0].times(reftime=stTOGETHER[0].stats['eventtime'])-CenterSdifftime, stTOGETHER[0].data /norm + T[c][0],'y')  # Ref Trace
plt.axhline(y=1-20, xmin=LongStartWindow, xmax=LongEndWindow,linestyle='--')   # Show Phase Stack from 0 to 1
plt.axhline(y=0-20, xmin=LongStartWindow, xmax=LongEndWindow,linestyle='--')
plt.plot(stTOGETHER[0].times(reftime=stTOGETHER[0].stats['eventtime'])[w1_long:w2_long]-CenterSdifftime, PS_Stack - 20,'r')  # Plot long trace
plt.plot(stTOGETHER[0].times(reftime=stTOGETHER[0].stats['eventtime'])[w1_long:w2_long]-CenterSdifftime, Linear_Stack - 21,'r')
plt.plot(stTOGETHER[0].times(reftime=stTOGETHER[0].stats['eventtime'])[w1_long:w2_long]-CenterSdifftime, PWS_Stack - 22,'r')

plt.xlim([time_min,time_max])
plt.title('Array Waveform (Event time)\
    \n Event %s    Real data: %s  Window: %ds - %ds \
    \n freq: %s s - %s s \
    \n Center distance at %.1f , azimuth at %.1f' \
    % ('20100320', 'BHT', StartWindow, EndWindow, str(1/fmax), str(1/fmin), center_dist, center_az))

# # Plot the maximum power array in relative Sdifftime
# plt.figure()
# for i, st in enumerate(stTOGETHER):
#     plt.plot(st.times(reftime=st.stats['eventtime'])-align_time[i], st.data /norm + T[c][i],'k')
#     w1_long = np.argmin(np.abs(st.times(reftime=st.stats['eventtime'])-CenterSdifftime-LongStartWindow-T[c][i]))   # Example of a long trace
#     w2_long = np.argmin(np.abs(st.times(reftime=st.stats['eventtime'])-CenterSdifftime-LongEndWindow-T[c][i]))
#     w1_cut = np.argmin(np.abs(st.times(reftime=st.stats['eventtime'])-CenterSdifftime-StartWindow-T[c][i]))
#     w2_cut = np.argmin(np.abs(st.times(reftime=st.stats['eventtime'])-CenterSdifftime-EndWindow-T[c][i]))         # Real timewindow demo
#     long_trace = st.data[w1_long:w2_long]
#     cut_trace = st.data[w1_cut:w2_cut]
#     plt.plot(st.times(reftime=st.stats['eventtime'])[w1_cut:w2_cut]-align_time[i], cut_trace/norm + T[c][i],'r')  # Plot real timewindow
#     if i == 0:
#         Linear_Stack = np.zeros(np.shape(long_trace))
#         PS_Stack = np.zeros(np.shape(long_trace),dtype='complex')
#         PWS_Stack = np.zeros(np.shape(long_trace))
#     Linear_Stack += long_trace /norm
#     PHASE = np.unwrap(np.angle(hilbert(long_trace)))
#     PS_Stack += np.exp(1j*PHASE)
# Linear_Stack = Linear_Stack/N
# PS_Stack = np.abs(PS_Stack)/N
# PWS_Stack += Linear_Stack*PS_Stack**nv

# plt.plot(stTOGETHER[0].times(reftime=stTOGETHER[0].stats['eventtime'])-align_time[0], stTOGETHER[0].data /norm + T[c][0],'y')  # Ref Trace
# plt.axhline(y=1-20, xmin=LongStartWindow, xmax=LongEndWindow,linestyle='--')   # Show Phase Stack from 0 to 1
# plt.axhline(y=0-20, xmin=LongStartWindow, xmax=LongEndWindow,linestyle='--')
# plt.plot(stTOGETHER[0].times(reftime=stTOGETHER[0].stats['eventtime'])[w1_long:w2_long]-align_time[0], PS_Stack - 20,'r')  # Plot long trace
# plt.plot(stTOGETHER[0].times(reftime=stTOGETHER[0].stats['eventtime'])[w1_long:w2_long]-align_time[0], Linear_Stack - 21,'r')
# plt.plot(stTOGETHER[0].times(reftime=stTOGETHER[0].stats['eventtime'])[w1_long:w2_long]-align_time[0], PWS_Stack - 22,'r')

# plt.xlim([time_min,time_max])

# plt.title('Array Waveform (Aligned with Sdiff)\
#     \n Event %s    Real data: %s  Window: %ds - %ds \
#     \n freq: %s s - %s s \
#     \n Center distance at %.1f , azimuth at %.1f' \
#     % ('20100320', 'BHT', StartWindow, EndWindow, str(1/fmax), str(1/fmin), center_dist, center_az))

plt.show()