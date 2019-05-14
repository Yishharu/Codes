import glob
import sys
import time
import os.path
from multiprocessing import Pool

import numpy as np
import matplotlib.pyplot as plt
from scipy.signal import hilbert
from numpy import linalg as LA

import obspy
from obspy import read
from obspy.core import Stream, trace
from geographiclib.geodesic import Geodesic

nproc = 4

nv = 2
## Frequencies for filter
fmin = 1/20. #Hz
fmax = 1/10.  #Hzseis

time_min = -100
time_max = 200

if_pc = True
# Data Directory
fk_dir = '/raid3/zl382/Data/20100320/fk_analysis/'

if if_pc == False: # Main arrival
    save_dir = '/home/zl382/Pictures/BeamForming/main_%d-%ds/' %(1/fmax, 1/fmin)
    print('Result in : ', save_dir)
elif if_pc == True: # post cursor
    save_dir = '/home/zl382/Pictures/BeamForming/pc_%d-%ds/' %(1/fmax, 1/fmin)
    print('Result in : ', save_dir)
# Parameter for beamforming
StartWindow = -20
EndWindow = 30
LengthWindow = 40
StepWindow = 5
LongStartWindow = -100
LongEndWindow = 200
norm_constant = 1

slowness = np.linspace(7.5,9.5,201)

backazimuth = np.linspace(45,135,181)

if if_pc == True:
    # 1-5s post cursor
    [x1,y1] = [10,65]
    [x2,y2] = [30,50]
    [x3,y3] = [50,35]

    # [x1,y1] = [30,65]
    # [x2,y2] = [50,50]
    # [x3,y3] = [80,35]

    cut_x = np.linspace(x1,x2, num=10, endpoint=False)    # First Line
    cut_y = np.linspace(y1,y2, num=10, endpoint=False)
    cut_x = np.append(cut_x,np.linspace(x2,x3, num = 11))
    cut_y = np.append(cut_y,np.linspace(y2,y3, num=11))
################################## Edit Before This Line ####################

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

arraylist = glob.glob(fk_dir + '*')

backradian = np.deg2rad(backazimuth)

sl_resolution = np.diff(slowness).min()
baz_resolution = np.diff(backazimuth).min()

sl , baz = np.meshgrid(slowness, backradian)

slx = sl*np.sin(baz)
sly = sl*np.cos(baz)

slxy = np.dstack((slx,sly))

for array_dir in arraylist[145::]:

    ArrayLocation = []
    ArrayXY = []
    stTOGETHER = Stream()
    align_time = []
    azlist = []

    seislist = glob.glob(array_dir + '/*PICKLE')
    array_name = os.path.split(array_dir)[1]
    save_pic_path = save_dir + array_name+'/'
    if not os.path.exists(save_pic_path):
        os.makedirs(save_pic_path)
    # Find the reference station
    center_seisname = array_dir+'/'+array_name+'.PICKLE'
    seis = read(array_dir+'/'+array_name+'.PICKLE',format='PICKLE')
    try:
        seis.resample(10)
    except:
        print(array_name+' resample error')
        continue            
    center_lat = seis[0].stats['stla']
    center_lon = seis[0].stats['stlo']
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

    Bundles_name = array_dir + '/Bundles.PICKLE'
    seisloop = (seisname for seisname in seislist \
        if (seisname != center_seisname) and (seisname != Bundles_name))   # Make sure the ref trace is not in the loop
    for seisname in seisloop:
        seis = read(seisname,format='PICKLE')
        try:
            seis.resample(10)
        except:
            print(seisname+' resample error')
            continue
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

    N = len(stTOGETHER)
    print(N, 'traces found in this array')

    SWindow = StartWindow
    EWindow = StartWindow + LengthWindow

    if if_pc == True:
        SWindow = np.round(np.interp(center_az, cut_y[::-1], cut_x[::-1]))
        EWindow = SWindow + LengthWindow
        EndWindow = SWindow + 50
        print('**** pc timewindow from %d - %d s at az %.1f deg ****' % (SWindow, EndWindow, center_az))

    while SWindow + LengthWindow <=  EndWindow:
        STARTTIME = time.time()
        print('Execuating Beamforming \
            \n Event: %s  Array: %s  Real data: %s  Window: %ds - %ds \
            \n freq: %.0f s - %.0f s  baz from %.0f to %.0f(\u00B1%s)deg slowness from %.2f to %.2f(\u00B1%s)'\
            % ('20100320', array_name, 'BHT', SWindow, EWindow, 1/fmax, 1/fmin, np.rad2deg(baz.min()), np.rad2deg(baz.max()),repr(baz_resolution), sl.min(), sl.max(), repr(sl_resolution)))

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

        # Plot the maximum power array
        plt.figure()
        for i, st in enumerate(stTOGETHER):
            w1_real = np.argmin(np.abs(st.times(reftime=st.stats['eventtime'])-Sdifftime-SWindow-T[c][i]))
            w2_real = np.argmin(np.abs(st.times(reftime=st.stats['eventtime'])-Sdifftime-EWindow-T[c][i]))    # Real timewindow demo
            real_trace = st.data[w1_real:w2_real]
            if i == 0:
                Linear_Stack = np.zeros(np.shape(real_trace))
                PS_Stack = np.zeros(np.shape(real_trace),dtype='complex')
                PWS_Stack = np.zeros(np.shape(real_trace))
            Linear_Stack += real_trace /norm
            PHASE = np.unwrap(np.angle(hilbert(real_trace)))
            PS_Stack += np.exp(1j*PHASE)
        Linear_Stack = Linear_Stack/N
        PS_Stack = np.abs(PS_Stack)/N
        PWS_Stack += Linear_Stack*PS_Stack**nv

        energy = LA.norm(Linear_Stack)
        coherence = LA.norm(PS_Stack, 1)/len(PS_Stack)

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
                PS_Stack = np.zeros(np.shape(cut_trace),dtype='complex')
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
                PS_Stack = np.zeros(np.shape(cut_trace),dtype='complex')
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

        savename = save_pic_path + str(SWindow)+'s'+'_BSEC.npy'
        np.save(savename, [baz[c], sl[c], energy, coherence])

        print('Find Peak at baz %.0f deg slowness at %.2f' %(baz[c], sl[c]))
        print('Signal energy: %f ; coherence : %f' %(energy, coherence))  

        SWindow += StepWindow
        EWindow += StepWindow

        ENDTIME = time.time()
        print('BeamForming Excution Time: %s s!' %(ENDTIME-STARTTIME))
        plt.close('all')