import glob
import sys
import time

import numpy as np
import matplotlib.pyplot as plt
from scipy.signal import hilbert
from multiprocessing import Pool

import obspy
from obspy import read
from obspy.core import Stream, trace
from geographiclib.geodesic import Geodesic

nproc = 4 # for hilbert suggest value <= 4

nv = 2
## Frequencies for filter
fmin = 1/10. #Hz
fmax = 1/5.  #Hzseis

time_min = -100
time_max = 200

# Parameter for beamforming
StartWindow = 30
EndWindow = 60
LongStartWindow = -100
LongEndWindow = 200
norm_constant = 1

slowness1 = np.linspace(0.0,7.5,16)
slowness2 = np.linspace(7.6,8.9,131)
slowness3 = np.linspace(9.0,10.0,3)
slowness = np.append(slowness1,np.append(slowness2,slowness3))

# slowness = np.linspace(0,10,11)
# backazimuth = np.linspace(0,360,31)

# Data Directory
model = 'S40RTS+ZD40_5s'
dir = '/raid3/zl382/HPC_axisem3d_run/'+model+'/post_processing/'

backazimuth = np.linspace(0,360,21)

#################################### Edit Before This Line ########################
def progress(count, total, status=''):
    bar_len = 60
    filled_len = int(round(bar_len * count / float(total)))

    percents = round(100.0 * count / float(total), 1)
    bar = '=' * filled_len + '-' * (bar_len - filled_len)

    sys.stdout.write('[%s] %s%s ...%s\r' % (bar, percents, '%', status))
    sys.stdout.flush()  # As suggested by Rom Ruben (see: http://stackoverflow.com/questions/3173320/text-progress-bar-in-the-console/27871113#comment50529068_27871113)
STARTTIME = time.time()

seislist = [dir + 'UV.D%d.PICKLE' %i for i in range(100,110)]
sl_resolution = np.diff(slowness).min()
baz_resolution = np.diff(backazimuth).min()
backradian = np.deg2rad(backazimuth)

sl , baz = np.meshgrid(slowness, backradian)

slx = sl*np.sin(baz)
sly = sl*np.cos(baz)
slxy = np.dstack((slx,sly))


ArrayLocation = []
ArrayXY = []
stTOGETHER = Stream()
align_time = []
azlist = []

# Find the reference station
center_seisname =dir+'UV.D105.PICKLE'
seis = read(center_seisname,format='PICKLE')
center_dist = seis[0].stats['dist']
CenterSdifftime = seis[0].stats.traveltimes['Sdiff'] or seis[0].stats.traveltimes['S']
stTOGETHER += seis.select(channel='BAT')    # Add ref station as the first trace
stTOGETHER[0].stats = seis[0].stats
ArrayLocation.append([0,0])
ArrayXY.append([0,0])
align_time.append(CenterSdifftime)

Bundles_name = dir + 'Bundles.PICKLE'
seisloop = [seisname for seisname in seislist \
     if (seisname != center_seisname) and (seisname != Bundles_name)]   # Make sure the ref trace is not in the loop
for seisname in seisloop:
    seis = read(seisname,format='PICKLE')
    stTOGETHER += seis.select(channel='BAT')
    stTOGETHER[-1].stats = seis[0].stats
    sdist = seis[0].stats['dist']
    ArrayLocation.append([sdist-center_dist,0])
    ArrayXY.append([0,sdist-center_dist])
    align_time.append(seis[0].stats.traveltimes['Sdiff'] or seis[0].stats.traveltimes['S'])

ArrayLocation = np.array(ArrayLocation)
align_time = np.array(align_time)
T = np.dot(slxy,np.transpose(ArrayXY))

stTOGETHER.write(dir+'Bundles.PICKLE','PICKLE')  # Store the raw data before filter
stTOGETHER.filter('bandpass', freqmin=fmin,freqmax=fmax, zerophase=True)
norm = np.max(stTOGETHER[0].data) / norm_constant

# Loop in slowness meshgrid
N = len(stTOGETHER)
power = np.zeros(np.shape(sl))
index = 0
total = np.size(sl)

def POWER(c):
    global index
    index += nproc
    progress(index, total, status='Doing very long job')
    for i, st in enumerate(stTOGETHER):
        w1 = np.argmin(np.abs(st.times()-CenterSdifftime-StartWindow-T[c][i]))
        w2 = np.argmin(np.abs(st.times()-CenterSdifftime-EndWindow-T[c][i]))
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
    power = np.abs(hilbert(PWS_Stack)).max()
    return power

C=[c for c, xy in np.ndenumerate(sl)]  #  Creat index list C for parallel

with Pool(nproc) as p:
    power_list = np.array(p.map(POWER,C))  # Multiprocessing C

power = power_list.reshape(np.shape(sl)) # Reshape power as the shape of sl

c = np.unravel_index(np.argmax(power,axis=None),power.shape)  # Find the peak of beamforming
fig, ax = plt.subplots(subplot_kw=dict(projection='polar'))
ax.set_theta_direction(-1)
ax.set_theta_zero_location("N")
ax.contourf(baz,sl,power)
ax.scatter(baz[c],sl[c],c='r',marker='*')
ENDTIME = time.time()
print('BeamForming Excution Time: %s s!' %(ENDTIME-STARTTIME))
print('Find Peak at baz %.0f deg slowness at %.2f' %(baz[c], sl[c]))
plt.title('Beamforming Power\
    \n Event %s    Real data: %s  Window: %ds - %ds \
    \n freq: %.0f s - %.0f s  baz at %.0f(\u00B1%s)deg slowness at %.2f(\u00B1%s)'\
    % ('20100320', 'BHT', StartWindow, EndWindow, 1/fmax, 1/fmin, np.rad2deg(baz[c]),repr(baz_resolution), sl[c],repr(sl_resolution)))

np.save(dir+'BeamTime', T[c])
# Plot the array with maximum power slowness
plt.figure()
for i, st in enumerate(stTOGETHER):
    plt.plot(st.times()-CenterSdifftime, st.data /norm + T[c][i],'k')
    w1_long = np.argmin(np.abs(st.times()-CenterSdifftime-LongStartWindow-T[c][i]))   # Example of a long trace
    w2_long = np.argmin(np.abs(st.times()-CenterSdifftime-LongEndWindow-T[c][i]))
    w1_cut = np.argmin(np.abs(st.times()-CenterSdifftime-StartWindow-T[c][i]))
    w2_cut = np.argmin(np.abs(st.times()-CenterSdifftime-EndWindow-T[c][i]))         # Real timewindow demo
    long_trace = st.data[w1_long:w2_long]
    cut_trace = st.data[w1_cut:w2_cut]
    plt.plot(st.times()[w1_cut:w2_cut]-CenterSdifftime, cut_trace/norm + T[c][i],'r')  # Plot real timewindow
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

plt.plot(stTOGETHER[0].times()-CenterSdifftime, stTOGETHER[0].data /norm + T[c][0],'y')  # Ref Trace
plt.axhline(y=1-20, xmin=LongStartWindow, xmax=LongEndWindow,linestyle='--')   # Show Phase Stack from 0 to 1
plt.axhline(y=0-20, xmin=LongStartWindow, xmax=LongEndWindow,linestyle='--')
plt.plot(stTOGETHER[0].times()[w1_long:w2_long]-CenterSdifftime, PS_Stack - 50,'r')  # Plot long trace
plt.plot(stTOGETHER[0].times()[w1_long:w2_long]-CenterSdifftime, Linear_Stack - 51,'r')
plt.plot(stTOGETHER[0].times()[w1_long:w2_long]-CenterSdifftime, PWS_Stack - 52,'r')

plt.xlim([time_min,time_max])
plt.title('Array Waveform (Event time)\
    \n Event %s    Real data: %s  Window: %ds - %ds \
    \n freq: %s s - %s s \
    \n Center distance at %.1f , azimuth at %.1f' \
    % ('20100320', 'BHT', StartWindow, EndWindow, str(1/fmax), str(1/fmin), center_dist, 0))

# Plot the maximum power array in relative Sdifftime
plt.figure()
for i, st in enumerate(stTOGETHER):
    plt.plot(st.times()-align_time[i], st.data /norm + T[c][i],'k')
    w1_long = np.argmin(np.abs(st.times()-CenterSdifftime-LongStartWindow-T[c][i]))   # Example of a long trace
    w2_long = np.argmin(np.abs(st.times()-CenterSdifftime-LongEndWindow-T[c][i]))
    w1_cut = np.argmin(np.abs(st.times()-CenterSdifftime-StartWindow-T[c][i]))
    w2_cut = np.argmin(np.abs(st.times()-CenterSdifftime-EndWindow-T[c][i]))         # Real timewindow demo
    long_trace = st.data[w1_long:w2_long]
    cut_trace = st.data[w1_cut:w2_cut]
    plt.plot(st.times()[w1_cut:w2_cut]-align_time[i], cut_trace/norm + T[c][i],'r')  # Plot real timewindow
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

plt.plot(stTOGETHER[0].times()-align_time[0], stTOGETHER[0].data /norm + T[c][0],'y')  # Ref Trace
plt.axhline(y=1-20, xmin=LongStartWindow, xmax=LongEndWindow,linestyle='--')   # Show Phase Stack from 0 to 1
plt.axhline(y=0-20, xmin=LongStartWindow, xmax=LongEndWindow,linestyle='--')
plt.plot(stTOGETHER[0].times()[w1_long:w2_long]-align_time[0], PS_Stack - 50,'r')  # Plot long trace
plt.plot(stTOGETHER[0].times()[w1_long:w2_long]-align_time[0], Linear_Stack - 51,'r')
plt.plot(stTOGETHER[0].times()[w1_long:w2_long]-align_time[0], PWS_Stack - 52,'r')

plt.xlim([time_min,time_max])

plt.title('Array Waveform (Aligned with Sdiff)\
    \n Event %s    Real data: %s  Window: %ds - %ds \
    \n freq: %s s - %s s \
    \n Center distance at %.1f , azimuth at %.1f' \
    % ('20100320', 'BHT', StartWindow, EndWindow, str(1/fmax), str(1/fmin), center_dist, 0))

plt.show()