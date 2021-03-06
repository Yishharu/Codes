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
# matplotlib.rcParams.update({'font.size':20}) # Sets fontsize in figure
save_path = '/home/zl382/Documents/MATLAB/'


plot_row = 2
plot_column = 5

# Set phase to plot
phase = str(sio.loadmat(save_path + 'pickle_mat_interface'+ '.mat')['phase'])[2:-2]
# Set component to plot
component = str(sio.loadmat(save_path + 'pickle_mat_interface'+ '.mat')['component'])[2:-2]
# Set distance
distance = np.reshape(sio.loadmat(save_path + 'pickle_mat_interface' + '.mat')['dist'],-1)
# Set filename for figure
filename = 'Plots/Sdiff_T_B1.png'
# Set models to plot
event = str(sio.loadmat(save_path + 'pickle_mat_interface'+ '.mat')['event'])[2:-2]

# Set model titles
# titles = ['a. 20 km ULVZ','b. 10 km ULVZ',  'c. 10 km ULVZ I run']

# Set center frequencies for the Fan
# centerfreq=np.linspace(2,25,200)

plt.figure() #figsize=(11,7))

for i in range(len(distance)):
    # Initialize plot for each model
    if i == 0:
        ax0 = plt.subplot(plot_row, plot_column, i+1)
    else:
        plt.subplot(plot_row, plot_column, i+1)
       
    s = distance[i]
    print(s)
              # Load file
    seisfile = '/raid3/zl382/Data/Synthetics/' +  event + '/SYN_' + str(s) + '.PICKLE'
    seis = read(seisfile,format='PICKLE')
    seis.resample(10)# Resampling makes things quicker
    Sdifftime = seis[0].stats['traveltimes'][phase] # find time of phase              
    # Cut window around phase on selected component       
    tr = seis.select(channel=component)[0]
    w0 = np.argmin(np.abs(tr.times()-Sdifftime+100))
    w1 = np.argmin(np.abs(tr.times()-Sdifftime-190))

#              # Copy trace
#              tr1=tr.copy()
#              tr1=tr1.filter('bandpass', freqmin=1/40.,freqmax=1/10.)
              # Plot reference phase with wide filter
#   sio.savemat(save_path + event + '_deg_' + str(s) + '.mat', {'data': tr.data[w0:w1], 'times': tr.times()[w0:w1]})
    data_filter = np.reshape(sio.loadmat(save_path + 'toplot_' + event + '_deg_' + str(s) + '.mat')['data_filter'],-1)
    plt.plot(tr.times()[w0:w1]-Sdifftime, data_filter/np.max(np.abs(data_filter)),'k')

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
    toplot = sio.loadmat(save_path + 'toplot_' + event + '_deg_' + str(s) + '.mat')['toplot']
#    centerfreq = np.reshape(sio.loadmat(save_path + 'toplot_' + event + '.mat')['centerfreq'],-1)
    T_toplot = np.reshape(sio.loadmat(save_path + 'toplot_' + event + '_deg_' + str(s) + '.mat')['T_toplot'],-1)
    
#    x, y = np.meshgrid(tr.times()[w0:w1]-Sdifftime, centerfreq)
               
#    plt.pcolormesh(x, y, np.abs(toplot), cmap='Greys')
 
    plt.pcolor(tr.times()[w0:w1]-Sdifftime,T_toplot,toplot,cmap='Greys')
    plt.ylim([-1,max(T_toplot)])
    plt.xlim([-20,90])
    #if i == 2 or i==3:
    plt.xlabel('time around ' + phase + ' (s)')  #fontsize=18)
    if (i==0) or (i==plot_column):
        plt.ylabel(r'Centre Period (s)')  #fontsize=18

    plt.title(str(s) + '$^{\circ}$')#fontsize=20)
    plt.plot([0, 0],[min(T_toplot), max(T_toplot)],'--k')
#    plt.gca().tick_params(labelsize=16)
#    plt.yscale('log')


# plt.savefig(filename)   
plt.suptitle('Event ' + event + ' with distance')  
plt.show()