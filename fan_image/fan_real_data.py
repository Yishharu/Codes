# -*- coding: utf-8 -*-
"""
Created on Fri Dec  8 12:49:39 2017

@author: zl382
"""
import scipy.io as sio
import obspy
from obspy import read
from obspy.core import event
import matplotlib.pyplot as plt
import numpy as np
import matplotlib
import glob
import os.path
from obspy import UTCDateTime

matplotlib.rcParams.update({'font.size':18}) # Sets fontsize in figure

EQ = '20100320'
# station = '/TA.732A'
save_path = '/raid3/zl382/Data/MATLAB/' #'raid3/zl382/Data/MATLAB/' # '/home/zl382/Documents/MATLAB/'


plot_row = 1
plot_column = 3

# Set phase to plot
#phase = str(sio.loadmat(save_path + 'pickle_mat_interface'+ '.mat')['phase'])[2:-2]
phases = sio.loadmat(save_path + 'pickle_mat_interface'+ '.mat')['phases']
for i in range(len(phases)):
    phases[i] = phases[i].strip()
# Set component to plot
#components = str(sio.loadmat(save_path + 'pickle_mat_interface'+ '.mat')['components'])[2:-2]
components = sio.loadmat(save_path + 'pickle_mat_interface'+ '.mat')['components']
for i in range(len(components)):
    components[i] = components[i].strip()
    
stations_components = sio.loadmat(save_path + 'pickle_mat_interface'+ '.mat')['stations_components']
for i in range(len(stations_components)):
    stations_components[i] = stations_components[i].strip()
    
sname = sio.loadmat(save_path + 'pickle_mat_interface'+ '.mat')['sname']
for i in range(len(sname)):
    sname[i] = sname[i].strip()
    
events = sio.loadmat(save_path + 'pickle_mat_interface'+ '.mat')['events']
for i in range(len(events)):
    events[i] = events[i].strip()
# Set distance

# Set model titles
# titles = ['a. No ULVZ','b. 20 km ULVZ','c. 10 km ULVZ','d. 5 km ULVZ']


# Set center frequencies for the Fan
# centerfreq=np.linspace(2,25,200)

# Loop through seismograms
for s in range(0,len(sname),1):
    plt.figure(figsize=(11.69,8.27))
    s_name = sname[s]
#    if (glob.glob(save_path + s_name +'BH*.mat')==[]):
#        break
    # Load file
       # seisfile = '/raid3/zl382/Data/Synthetics/' +  event + '/SYN_' + str(s) + '.PICKLE'
    seisfile =  '/raid3/zl382/Data/' + EQ +'/'+ s_name + '.PICKLE'
    seis = read(seisfile,format='PICKLE')
    try:
        seis.resample(10)# Resampling makes things quicker
    except:
        continue
    # Time shift to shift data to reference time   # Important for REAL DATA
    tshift=UTCDateTime(seis[0].stats['starttime']) - UTCDateTime(seis[0].stats['eventtime'])
    
    for i in range(len(components)):
        # Initialize plot for each model
        print(s_name + '_'+components[i])
        if i==0:
            ax0=plt.subplot(plot_row, plot_column, i+1)
        else:
            plt.subplot(plot_row, plot_column, i+1)

        phase = phases[i]
        component = components[i]

        Sdifftime = seis[0].stats['traveltimes'][phase] # find time of phase              
        # Cut window around phase on selected component       
        tr = seis.select(channel=component)[0]
        w0 = np.argmin(np.abs(tr.times()+tshift-Sdifftime+100))
        w1 = np.argmin(np.abs(tr.times()+tshift-Sdifftime-190))
    
    #              # Copy trace
    #              tr1=tr.copy()
    #              tr1=tr1.filter('bandpass', freqmin=1/40.,freqmax=1/10.)
                  # Plot reference phase with wide filter
        data_filter = np.reshape(sio.loadmat(save_path + 'toplot_' + s_name + '_' + component + '.mat')['data_filter'],(-1,1))
        plt.plot(tr.times()[w0:w1]+tshift-Sdifftime, data_filter/np.max(np.abs(data_filter)),'k')
    
                  # Loop through centerfrequencies
    #              for ft in range(len(centerfreq)):
    #                     print(ft)
    #                     f=centerfreq[ft]
    #                     trf= tr.copy()
    #                     # Filter copied trace around center frequency
    #                     trf=trf.filter('bandpass', freqmin=1/(f*1.2),freqmax=1/(f*0.8))
    #                     # Add normalized filtered arrival to the Frequency Fan
    #                     norm = np.max(np.abs(trf.data[w0:w1]))/4.
    #                     if ft ==0:
    #                            toplot = trf.data[w0:w1]/norm
    #                     else:
    #
    #                            toplot = np.vstack((toplot, trf.data[w0:w1]/norm))
        toplot = sio.loadmat(save_path + 'toplot_' + s_name + '_' + component + '.mat')['toplot']
    #    centerfreq = np.reshape(sio.loadmat(save_path + 'toplot_' + event + '.mat')['centerfreq'],(-1,1))
        T_toplot = np.reshape(sio.loadmat(save_path + 'toplot_' + s_name + '_' + component + '.mat')['T_toplot'],(-1,1))
        
    #    x, y = np.meshgrid(tr.times()[w0:w1]-Sdifftime, centerfreq)
                   
    #    plt.pcolormesh(x, y, np.abs(toplot), cmap='Greys')
        
        plt.pcolor(tr.times()[w0:w1]+tshift-Sdifftime,T_toplot,toplot,cmap='Greys')
        plt.ylim([-1,max(T_toplot)])
        plt.xlim([-20,90])
        #if i == 2 or i==3:
        plt.xlabel('Time around ' +phase + ' (s)', fontsize=12)
        if i==0:
            plt.ylabel(r'Centre Period (s)',fontsize=17)
    
        plt.title(events[i],fontsize=14)
        plt.plot([0, 0],[min(T_toplot), max(T_toplot)],'--k')
        plt.gca().tick_params(labelsize=12)
    #    plt.yscale('log')/home/zl382/Codes/Scripts_for_Zhi/
    
    plt.suptitle('EQ  ' + EQ + ' Station  '+ s_name+'  ', fontsize=19) 
    plt.text(120,28,' Distance = ' + '%.2f' %seis[0].stats['dist'] + '\nAzimuth = ' + '%.2f' %seis[0].stats['az'], verticalalignment='top',horizontalalignment='right',fontsize=9)
    filename =  '/home/zl382/Pictures/Fan_plot/' + s_name + '_D'+'%.1f' %seis[0].stats['dist']+'_A'+'%2.1f' %seis[0].stats['az']+'_.png'    
    plt.savefig(filename)     
    plt.close('all')
#    plt.show()