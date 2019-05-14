import glob
import sys
import time
import os

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.patches import Rectangle
from scipy.signal import hilbert

import obspy
from obspy import read
from obspy.core import Stream, trace
from geographiclib.geodesic import Geodesic

nv = 2
## Frequencies for filter
fmin = 1/5. #Hz
fmax = 1/1.  #Hzseis

time_min = -100
time_max = 200

# Parameter for beamforming
StartWindow = -100
EndWindow = 200
LongStartWindow = -100
LongEndWindow = 200
norm_constant = 1

pc_start = 25
pc_end = 80
main_start = -20
main_end = 25

# slowness1 = np.linspace(0.0,7.5,16)
# slowness2 = np.linspace(7.6,8.9,131)
# slowness3 = np.linspace(9.0,10.0,3)
# slowness = np.append(slowness1,np.append(slowness2,slowness3))

slowness = 8.323
backazimuth = np.linspace(45,135,181) # Fixed backazimuth
# Data Directory
fk_dir = '/raid1/zl382/Data/Hawaii/20100320/fk_analysis/'
save_dir = '/raid1/zl382/Pictures/BeamForming/traveltime_%d-%ds/' %(1/fmax, 1/fmin)
arraylist = glob.glob(fk_dir + '*')


#################################### Edit Before This Line ########################
if not os.path.exists(save_dir):
    os.makedirs(save_dir)
def progress(count, total, status=''):
    bar_len = 60
    filled_len = int(round(bar_len * count / float(total)))

    percents = round(100.0 * count / float(total), 1)
    bar = '=' * filled_len + '-' * (bar_len - filled_len)

    sys.stdout.write('[%s] %s%s ...%s\r' % (bar, percents, '%', status))
    sys.stdout.flush()  # As suggested by Rom Ruben (see: http://stackoverflow.com/questions/3173320/text-progress-bar-in-the-console/27871113#comment50529068_27871113)

baz = np.deg2rad(backazimuth)
baz_resolution = np.diff(backazimuth).min()

slx = slowness*np.sin(baz)
sly = slowness*np.cos(baz)
slxy = np.stack((slx,sly),axis=-1)

array_dir = '/raid1/zl382/Data/Hawaii/20100320/fk_analysis/TA.Q29A'
STARTTIME = time.time()
ArrayLocation = []
ArrayXY = []
stTOGETHER = Stream()
align_time = []
azlist = []
sname_list = []
array_name = os.path.split(array_dir)[1]
print('Procesing ', array_name)

seislist = glob.glob(array_dir + '/*PICKLE')
# Find the reference station
center_seisname = array_dir+'/'+array_name+'.PICKLE'
seis = read(array_dir+'/'+array_name+'.PICKLE',format='PICKLE')
try:
    seis.resample(10)
except:
    print(array_name+' resample error')
 
center_lat = seis[0].stats['stla']
center_lon = seis[0].stats['stlo']
center_az = seis[0].stats['az']
center_dist = seis[0].stats['dist']

trace_location = Geodesic.WGS84.Inverse(seis[0].stats['evla'],seis[0].stats['evlo'],center_lat,center_lon,outmask=1929)
center_backazimuth = trace_location['azi2']


CenterSdifftime = seis[0].stats.traveltimes['Sdiff'] or seis[0].stats.traveltimes['S']
stTOGETHER += seis.select(channel='BHT')    # Add ref station as the first trace
stTOGETHER[0].stats = seis[0].stats
ArrayLocation.append([0,0])
ArrayXY.append([0,0])
align_time.append(CenterSdifftime)
azlist.append(center_az)
sname_list.append(array_name)

Bundles_name = array_dir + '/Bundles.PICKLE'
seisloop = (seisname for seisname in seislist \
    if (seisname != center_seisname) and (seisname != Bundles_name))   # Make sure the ref trace is not in the loop
for seisname in seisloop:
    seis = read(seisname,format='PICKLE')
    sname = os.path.split(seisname)[1][:-7]
    try:
        seis.resample(10)
    except:
        print(seisname+' resample error')
        continue
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
    sname_list.append(sname)

ArrayLocation = np.array(ArrayLocation)
ArrayXY = np.array(ArrayXY)
align_time = np.array(align_time)
azlist = np.array(azlist)
T = np.dot(slxy,np.transpose(ArrayXY))

# stTOGETHER.write(array_dir+'Bundles.PICKLE','PICKLE')  # Store the raw data before filter
stTOGETHER.filter('bandpass', freqmin=fmin,freqmax=fmax, zerophase=True)
norm = np.max(stTOGETHER[0].data) / norm_constant

# Loop in slowness meshrid
N = len(stTOGETHER)
index = 0
total = np.size(baz)

for c, sl in enumerate(baz):
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
        power = np.abs(hilbert(PWS_Stack))
    else:          
        power = np.vstack((power, np.abs(hilbert(PWS_Stack))))


stddev = np.std(power,axis=1)
stddev_array = np.repeat(stddev[:,np.newaxis],np.shape(power)[1],1)
power[np.abs(power)<2*stddev_array] = 0

cut_time = stTOGETHER[0].times(reftime=stTOGETHER[0].stats['eventtime'])[w1:w2]-CenterSdifftime

fig, ax = plt.subplots()
pp = ax.pcolorfast(cut_time,backazimuth+180,power,cmap='seismic')  # main plot of power

A = np.logical_and(cut_time>pc_start, cut_time<pc_end)
taper_pc = np.repeat(A[np.newaxis,:],len(backazimuth),0)    # taper of the post cursor signal
power_pc = power*taper_pc

A = np.logical_and(cut_time>main_start, cut_time<main_end)
taper_main = np.repeat(A[np.newaxis,:],len(backazimuth),0) 
power_main = power*taper_main

c1 = np.unravel_index(np.argmax(power_main,axis=None),power.shape)  # Find the peak of main arrival 
PeakTime1 = cut_time[c1[1]]
PeakBackazimuth1 = backazimuth[c1[0]]

c2 = np.unravel_index(np.argmax(power_pc,axis=None),power.shape)  # Find the peak of post cursor
PeakTime2 = cut_time[c2[1]]
PeakBackazimuth2 = backazimuth[c2[0]]
# For main arrival
ERRORBAR_VALUE = power_main.max()*0.8
index = np.argwhere(np.abs(power_main-ERRORBAR_VALUE)<ERRORBAR_VALUE/20)

cmax_azi1, cmax_time1 = np.amax(index,axis=0)
cmin_azi1, cmin_time1 = np.amin(index,axis=0)
PeakTime1_min, PeakTime1_max = cut_time[[cmin_time1,cmax_time1]]
PeakAzi1_min, PeakAzi1_max = backazimuth[[cmin_azi1,cmax_azi1]]

# plt.vlines(PeakTime1_min,PeakAzi1_min,PeakAzi1_max)
# plt.vlines(PeakTime1_max,PeakAzi1_min,PeakAzi1_max)
# plt.hlines(PeakAzi1_min,PeakTime1_min,PeakTime1_max)
# plt.hlines(PeakAzi1_max,PeakTime1_min,PeakTime1_max)
# For pc
ERRORBAR_VALUE = power_pc.max()*0.8
index = np.argwhere(np.abs(power_pc-ERRORBAR_VALUE)<ERRORBAR_VALUE/20)

cmax_azi2, cmax_time2 = np.amax(index,axis=0)
cmin_azi2, cmin_time2 = np.amin(index,axis=0)
PeakTime2_min, PeakTime2_max = cut_time[[cmin_time2,cmax_time2]]
PeakAzi2_min, PeakAzi2_max = backazimuth[[cmin_azi2,cmax_azi2]]


# rect = Rectangle((PeakTime2_min, PeakAzi2_min), PeakTime2_max-PeakTime2_min, PeakAzi2_max-PeakAzi2_min,fill=False,linestyle='--')
# plt.vlines(PeakTime2_min,PeakAzi2_min,PeakAzi2_max)
# plt.vlines(PeakTime2_max,PeakAzi2_min,PeakAzi2_max)
# plt.hlines(PeakAzi2_min,PeakTime2_min,PeakTime2_max)
# plt.hlines(PeakAzi2_max,PeakTime2_min,PeakTime2_max)
plt.axhline(y=center_backazimuth+180,linestyle='--',color='y')

plt.scatter(PeakTime1, PeakBackazimuth1+180, c='y',marker='*')
plt.scatter(PeakTime2, PeakBackazimuth2+180, c='y',marker='*')

print('Find Main arrvial at time %.1f (%.1f-%.1f) Backazimuth %.1f (%.1f-%.1f)' %(PeakTime1,PeakTime1_min,PeakTime1_max,PeakBackazimuth1,PeakAzi1_min,PeakAzi1_max))
print('Find pc arrvial at time %.1f (%.1f-%.1f) Backazimuth %.1f (%.1f-%.1f)' %(PeakTime2,PeakTime2_min,PeakTime2_max,PeakBackazimuth2,PeakAzi2_min,PeakAzi2_max))

ENDTIME = time.time()
print('time-slowness STACK Excution Time: %s s!' %(ENDTIME-STARTTIME))
# print('Find Peak at baz %.0f deg slowness at %.2f' %(baz[c], sl[c]))
plt.colorbar(pp)
plt.xlabel('Time around Predicted Arrivial (s)', fontsize=15)
plt.ylabel('Beamforming BackAzimuth (deg)', fontsize=15)
# plt.title('Beamforming Power\
#     \n Event %s    Real data: %s  Window: %ds - %ds \
#     \n freq: %.0f s - %.0f s  slowness at %f deg backazimuth at %.2f(\u00B1%s)'\
#     % ('20100320', 'BHT', StartWindow, EndWindow, 1/fmax, 1/fmin, slowness, backazimuth[c],repr(baz_resolution)))

# Plot the array with maximum power slowness
# c = slowness.index(8.51)
c = np.argmin(np.abs(backazimuth-PeakBackazimuth1))   # Index of the PeakBackazimuth

plt.show()
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
    plt.text(time_max+2,T[c][i], sname_list[i])
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
plt.text(time_max+2, -20, 'Phase Stack')
plt.text(time_max+2, -21, 'Linear Stack')
plt.text(time_max+2, -22, 'Phase Weighted Stack')
plt.xlim([time_min,time_max])
plt.xlabel('Time around Predicted Arrivial (s)', fontsize=25)
plt.ylabel('Traveltime Difference Relative to Center Station', fontsize=20)
plt.rc('xtick', labelsize=25)    # fontsize of the tick labels
plt.rc('ytick', labelsize=25)    # fontsize of the tick labels
# plt.title('Array Waveform (Event time)\
#     \n Event %s    Real data: %s  Window: %ds - %ds \
#     \n freq: %s s - %s s \
#     \n Center distance at %.1f , azimuth at %.1f' \
#     % ('20100320', 'BHT', StartWindow, EndWindow, str(1/fmax), str(1/fmin), center_dist, center_az))
# savename = save_dir + array_name + '_b.png'
# plt.savefig(savename,format='png')
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