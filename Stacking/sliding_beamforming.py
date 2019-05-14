import glob
import sys
import time
import os.path
from multiprocessing import Pool

import numpy as np
import matplotlib.pyplot as plt
from scipy.signal import hilbert

import obspy
from obspy import read
from obspy.core import Stream, trace
from geographiclib.geodesic import Geodesic

nproc = 4

nv = 2
## Frequencies for filter
fmin = 1/5. #Hz
fmax = 1/1.  #Hzseis

time_min = -100
time_max = 200

# Parameter for beamforming
StartWindow = 40
EndWindow = 90
LengthWindow = 20
StepWindow = 1
LongStartWindow = -100
LongEndWindow = 200
norm_constant = 1

# Data Directory
dir = '/raid3/zl382/Data/20100320/fk_analysis/TA.T29A/'
save_pic_path = '/home/zl382/Pictures/beamforming/high_freq/'
################################## Edit Before This Line ####################
if not os.path.exists(save_pic_path):
    os.makedirs(save_pic_path)

def progress(count, total, status=''):
    bar_len = 60
    filled_len = int(round(bar_len * count / float(total)))

    percents = round(100.0 * count / float(total), 1)
    bar = '=' * filled_len + '-' * (bar_len - filled_len)

    sys.stdout.write('[%s] %s%s ...%s\r' % (bar, percents, '%', status))
    sys.stdout.flush()  # As suggested by Rom Ruben (see: http://stackoverflow.com/questions/3173320/text-progress-bar-in-the-console/27871113#comment50529068_27871113)

def POWER(c):
    global index
    index += nproc
    progress(index, total, status='Doing very long job')
    # time.sleep(0.1)
    for i, st in enumerate(stTOGETHER):
        w1 = np.argmin(np.abs(st.times(reftime=st.stats['eventtime'])-Sdifftime-SWindow-T[c][i]))
        w2 = np.argmin(np.abs(st.times(reftime=st.stats['eventtime'])-Sdifftime-EWindow-T[c][i]))
        cut_trace = st.data[w1:w2]
        if i == 0:
            Linear_Stack = np.zeros(np.shape(cut_trace))
            PS_Stack = np.zeros(np.shape(cut_trace),dtype='complex')
            PWS_Stack = np.zeros(np.shape(cut_trace))
        Linear_Stack += cut_trace /norm
        PHASE = np.unwrap(np.angle(hilbert(cut_trace)))
        PS_Stack += np.exp(1j*PHASE)
    Linear_Stack = Linear_Stack/N
    PS_Stack = np.abs(PS_Stack)/N
    PWS_Stack += Linear_Stack*PS_Stack**nv
    power = np.abs(hilbert(PWS_Stack)).max()
    return power

seislist = glob.glob(dir + '*PICKLE')
slowness1 = np.linspace(0.0,7.5,16)
slowness2 = np.linspace(7.6,8.9,131)
slowness3 = np.linspace(9.0,10.0,3)
slowness = np.append(slowness1,np.append(slowness2,slowness3))

backazimuth = np.linspace(0,360,721)
backradian = np.deg2rad(backazimuth)

sl_resolution = np.diff(slowness).min()
baz_resolution = np.diff(backazimuth).min()

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

center_lat = np.load(dir+'stla.npy')
center_lon = np.load(dir+'stlo.npy')
center_seisname = dir+'TA.T29A.PICKLE'
seis = read(dir+'TA.T29A.PICKLE',format='PICKLE')
center_az = seis[0].stats['az']
center_dist = seis[0].stats['dist']
seis.filter('bandpass', freqmin=fmin,freqmax=fmax, zerophase=True)
Sdifftime = seis[0].stats.traveltimes['Sdiff'] or seis[0].stats.traveltimes['S']
norm = np.max(seis[0].data) / norm_constant
stTOGETHER += seis.select(channel='BHT')    # Add ref station as the first trace
ArrayLocation.append([0,0])
ArrayXY.append([0,0])
align_time.append(Sdifftime)
azlist.append(center_az)

Bundles_name = dir + 'Bundles.PICKLE'
seisloop = (seisname for seisname in seislist \
     if (seisname != center_seisname) and (seisname != Bundles_name))   # Make sure the ref trace is not in the loop
for seisname in seisloop:
    seis = read(seisname,format='PICKLE')
    seis.filter('bandpass', freqmin=fmin,freqmax=fmax, zerophase=True)
    stTOGETHER += seis.select(channel='BHT')
    slat = seis[0].stats['stla']
    slon = seis[0].stats['stlo']
    Location = Geodesic.WGS84.Inverse(center_lat,center_lon,slat,slon, outmask=1929)
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

N = len(seislist)

SWindow = StartWindow
EWindow = StartWindow + LengthWindow
while SWindow + LengthWindow <=  EndWindow:
    STARTTIME = time.time()
    print('Processing %d - %d s' %(SWindow, EWindow))
    power = np.zeros(np.shape(sl))
    index = 0
    total = np.size(sl)

    C=[c for c, xy in np.ndenumerate(sl)]
    stime2 = time.time()
    with Pool(nproc) as p:
        power_list = np.array(p.map(POWER,C))
    power = power_list.reshape(np.shape(sl))

    c = np.unravel_index(np.argmax(power,axis=None),power.shape)  # Find the peak of beamforming
    fig, ax = plt.subplots(subplot_kw=dict(projection='polar'))
    ax.set_theta_direction(-1)
    ax.set_theta_zero_location("N")
    ax.contourf(baz,sl,power)
    ax.scatter(baz[c],sl[c],c='r',marker='*')
    plt.title('Beamforming Power\
        \n Event %s    Real data: %s  Window: %ds - %ds \
        \n freq: %.0fs - %.0fs  baz at %.0f(\u00B1%s)deg slowness at %.2f(\u00B1%s)'\
        % ('20100320', 'BHT', SWindow, EWindow, 1/fmax, 1/fmin, np.rad2deg(baz[c]),repr(baz_resolution), sl[c],repr(sl_resolution)))        
    savename = save_pic_path + str(SWindow)+'s'+'_a'
    plt.savefig(savename,format='png')
    print('Done '+savename)

    # Plot the maximum power array
    plt.figure()
    for i, st in enumerate(stTOGETHER):
        plt.plot(st.times(reftime=st.stats['eventtime'])-Sdifftime, st.data /norm + T[c][i],'k')
        w1_long = np.argmin(np.abs(st.times(reftime=st.stats['eventtime'])-Sdifftime-LongStartWindow-T[c][i]))   # Example of a long trace
        w2_long = np.argmin(np.abs(st.times(reftime=st.stats['eventtime'])-Sdifftime-LongEndWindow-T[c][i]))
        w1_real = np.argmin(np.abs(st.times(reftime=st.stats['eventtime'])-Sdifftime-SWindow-T[c][i]))
        w2_real = np.argmin(np.abs(st.times(reftime=st.stats['eventtime'])-Sdifftime-EWindow-T[c][i]))    # Real timewindow demo
        cut_trace = st.data[w1_long:w2_long]
        plot_trace = st.data[w1_real:w2_real]
        plt.plot(st.times(reftime=st.stats['eventtime'])[w1_real:w2_real]-Sdifftime, plot_trace/norm + T[c][i],'r')  # Plot real timewindow
        if i == 0:
            Linear_Stack = np.zeros(np.shape(cut_trace))
            PS_Stack = np.zeros(np.shape(cut_trace),dtype='complex128')
            PWS_Stack = np.zeros(np.shape(cut_trace))
        Linear_Stack += cut_trace /norm
        PHASE = np.unwrap(np.angle(hilbert(cut_trace)))
        PS_Stack += np.exp(1j*PHASE)
    Linear_Stack = Linear_Stack/N
    PS_Stack = np.abs(PS_Stack)/N
    PWS_Stack += Linear_Stack*PS_Stack**nv

    plt.plot(stTOGETHER[0].times(reftime=stTOGETHER[0].stats['eventtime'])-Sdifftime, stTOGETHER[0].data /norm + T[c][0],'y')  # Ref Trace
    plt.axhline(y=1-20, xmin=LongStartWindow, xmax=LongEndWindow,linestyle='--')   # Show Phase Stack from 0 to 1
    plt.axhline(y=0-20, xmin=LongStartWindow, xmax=LongEndWindow,linestyle='--')
    plt.plot(stTOGETHER[0].times(reftime=stTOGETHER[0].stats['eventtime'])[w1_long:w2_long]-Sdifftime, PS_Stack - 20,'r')  # Plot long trace
    plt.plot(stTOGETHER[0].times(reftime=stTOGETHER[0].stats['eventtime'])[w1_long:w2_long]-Sdifftime, Linear_Stack - 21,'r')
    plt.plot(stTOGETHER[0].times(reftime=stTOGETHER[0].stats['eventtime'])[w1_long:w2_long]-Sdifftime, PWS_Stack - 22,'r')

    plt.xlim([time_min,time_max])
    plt.title('Array Waveform (Event time)\
        \n Event %s    Real data: %s  Window: %ds - %ds \
        \n freq: %s s - %s s \
        \n Center distance at %.1f , azimuth at %.1f' \
        % ('20100320', 'BHT', SWindow, EWindow, str(1/fmax), str(1/fmin), center_dist, center_az))

    savename = save_pic_path + str(SWindow)+'s'+'_b'
    plt.savefig(savename,format='png')
    print('Done '+savename)
    # Plot the maximum power array in relative Sdifftime
    plt.figure()
    for i, st in enumerate(stTOGETHER):
        plt.plot(st.times(reftime=st.stats['eventtime'])-align_time[i], st.data /norm + T[c][i],'k')
        w1_long = np.argmin(np.abs(st.times(reftime=st.stats['eventtime'])-Sdifftime-LongStartWindow-T[c][i]))   # Example of a long trace
        w2_long = np.argmin(np.abs(st.times(reftime=st.stats['eventtime'])-Sdifftime-LongEndWindow-T[c][i]))
        w1_real = np.argmin(np.abs(st.times(reftime=st.stats['eventtime'])-Sdifftime-SWindow-T[c][i]))
        w2_real = np.argmin(np.abs(st.times(reftime=st.stats['eventtime'])-Sdifftime-EWindow-T[c][i]))    # Real timewindow demo
        cut_trace = st.data[w1_long:w2_long]
        plot_trace = st.data[w1_real:w2_real]
        plt.plot(st.times(reftime=st.stats['eventtime'])[w1_real:w2_real]-align_time[i], plot_trace/norm + T[c][i],'r')  # Plot real timewindow
        if i == 0:
            Linear_Stack = np.zeros(np.shape(cut_trace))
            PS_Stack = np.zeros(np.shape(cut_trace),dtype='complex128')
            PWS_Stack = np.zeros(np.shape(cut_trace))
        Linear_Stack += cut_trace /norm
        PHASE = np.unwrap(np.angle(hilbert(cut_trace)))
        PS_Stack += np.exp(1j*PHASE)
    Linear_Stack = Linear_Stack/N
    PS_Stack = np.abs(PS_Stack)/N
    PWS_Stack += Linear_Stack*PS_Stack**nv

    plt.plot(stTOGETHER[0].times(reftime=stTOGETHER[0].stats['eventtime'])-align_time[0], stTOGETHER[0].data /norm + T[c][0],'y')  # Ref Trace
    plt.axhline(y=1-20, xmin=LongStartWindow, xmax=LongEndWindow,linestyle='--')   # Show Phase Stack from 0 to 1
    plt.axhline(y=0-20, xmin=LongStartWindow, xmax=LongEndWindow,linestyle='--')
    plt.plot(stTOGETHER[0].times(reftime=stTOGETHER[0].stats['eventtime'])[w1_long:w2_long]-align_time[0], PS_Stack - 20,'r')  # Plot long trace
    plt.plot(stTOGETHER[0].times(reftime=stTOGETHER[0].stats['eventtime'])[w1_long:w2_long]-align_time[0], Linear_Stack - 21,'r')
    plt.plot(stTOGETHER[0].times(reftime=stTOGETHER[0].stats['eventtime'])[w1_long:w2_long]-align_time[0], PWS_Stack - 22,'r')

    plt.xlim([time_min,time_max])

    plt.title('Array Waveform (Aligned with Sdiff)\
        \n Event %s    Real data: %s  Window: %ds - %ds \
        \n freq: %s s - %s s \
        \n Center distance at %.1f , azimuth at %.1f' \
        % ('20100320', 'BHT', SWindow, EWindow, str(1/fmax), str(1/fmin), center_dist, center_az))

    savename = save_pic_path + str(SWindow)+'s'+'_c'
    plt.savefig(savename,format='png')
    print('Done '+savename)

    SWindow += StepWindow
    EWindow += StepWindow

    ENDTIME = time.time()
    print('BeamForming Excution Time: %s s!' %(ENDTIME-STARTTIME))
    plt.close('all')