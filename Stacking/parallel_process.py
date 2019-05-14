import glob
import sys
import time
from multiprocessing import Pool

import numpy as np
import matplotlib.pyplot as plt
from scipy.signal import hilbert

import obspy
from obspy import read
from obspy.core import Stream, trace
from geographiclib.geodesic import Geodesic

nproc = 8

nv = 2
## Frequencies for filter
fmin = 1/5. #Hz
fmax = 1/1.  #Hzseis

time_min = -100
time_max = 200

# Parameter for beamforming
StartWindow = -5
EndWindow = 15
LongStartWindow = -100
LongEndWindow = 200
norm_constant = 1

slowness1 = np.linspace(0.0,7.5,16)
slowness2 = np.linspace(7.6,8.9,131)
slowness3 = np.linspace(9.0,10.0,3)
slowness = np.append(slowness1,np.append(slowness2,slowness3))

backazimuth = np.linspace(0,360,21)

# slowness = np.linspace(0,10,11)
# backazimuth = np.linspace(0,360,31)

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
center_seisname = dir+'TA.T29A.PICKLE'
seis = read(dir+'TA.T29A.PICKLE',format='PICKLE')
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

# Loop in slowness meshgrid
N = len(seislist)
power = np.zeros(np.shape(sl))
index = 0
total = np.size(sl)

stime1 = time.time()
for c, xy in np.ndenumerate(sl):
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
    power[c] = np.abs(hilbert(PWS_Stack)).max()

fig, ax = plt.subplots(subplot_kw=dict(projection='polar'))
ax.set_theta_direction(-1)
ax.set_theta_zero_location("N")
ax.contourf(baz,sl,power)

etime1 = time.time()
print('Loop Excution Time: %s s!' %(etime1-stime1))

plt.figure()
# Loop in slowness meshgrid
N = len(seislist)
power = np.zeros(np.shape(sl))
index = 0
total = np.size(sl)

def POWER(iproc):
    for c, xy in np.ndenumerate(sl):
        global index
        progress(index, total, status='Doing very long job')
        # time.sleep(0.1)
        index +=1

        if index % nproc != iproc:
            continue

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
        power[c] = np.abs(hilbert(PWS_Stack)).max()
    return power

stime2 = time.time()
with Pool(nproc) as p:
    power_para = p.map(POWER,range(0,nproc))
power = np.sum(power_para,axis=0)
fig, ax = plt.subplots(subplot_kw=dict(projection='polar'))
ax.set_theta_direction(-1)
ax.set_theta_zero_location("N")
ax.contourf(baz,sl,power)

etime2 = time.time()
print('Pool Loop Excution Time: %s s! with %d processor' %(etime2-stime2, nproc))
plt.show()