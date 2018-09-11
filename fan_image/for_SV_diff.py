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
matplotlib.rcParams.update({'font.size':20}) # Sets fontsize in figure
save_path = '/home/zl382/Documents/MATLAB/'

plot_row = 1
plot_column = 3

# Set phase to plot
phases = sio.loadmat(save_path + 'pickle_mat_interface'+ '.mat')['phases']
for i in range(len(phases)):
    phases[i] = phases[i].strip()
# Set component to plot
components = sio.loadmat(save_path + 'pickle_mat_interface'+ '.mat')['components']
for i in range(len(components)):
    components[i] = components[i].strip()
# Set distance
distance = 106
# Set filename for figure
filename = 'Plots/Sdiff_T_B1.png'
# Set models to plot
events = sio.loadmat(save_path + 'pickle_mat_interface'+ '.mat')['events']
for i in range(len(events)):
    events[i] = events[i].strip()
# Set model titles
titles = ['SKS','SKKS','Sdiff']

events=['REF_modelPICKLES','ULVZ2kmPICKLES','ULVZ5kmPICKLES']

titles = ['REF','ULVZ2km','ULVZ5km']

ref_phase = ['SKKKKS','SKKKS','SKKS','SKS']


# Set center frequencies for the Fan
# centerfreq=np.linspace(2,25,200)
s = 106

plt.figure(figsize=(11.69,8.27))
for i in range(len(events)):
    event = events[i]
    seisfile = '/raid3/zl382/Data/Synthetics/' +  event + '/SYN_' + str(s) + '.PICKLE'
    seis = read(seisfile,format='PICKLE')
    seis.resample(10)# Resampling makes things quicker

        
    # Initialize plot for each model
    print(event + '_' + 'BAT')
    component = 'BAT'
    phase = 'Sdiff'
    if i ==0:
        ax0=plt.subplot(plot_row, plot_column, i+1)
    else:
        plt.subplot(plot_row, plot_column, i+1)
       
              # Load file

    Sdifftime = seis[0].stats['traveltimes']['Sdiff'] # find time of phase              
    # Cut window around phase on selected component       
    tr = seis.select(channel='BAT')[0]
#        w0 = np.argmin(np.abs(tr.times()-Sdifftime+100))
#        w1 = np.argmin(np.abs(tr.times()-Sdifftime-190))
    
    w0 = np.argmin(np.abs(tr.times()-Sdifftime+20))       
    w1 = np.argmin(np.abs(tr.times()-Sdifftime-30))
    
    
    w_start_maxima = np.argmin(np.abs(tr.times()-Sdifftime+20))-w0;
    w_end_maxima = np.argmin(np.abs(tr.times()-Sdifftime-30))-w0
    

#              # Copy trace
#              tr1=tr.copy()
#              tr1=tr1.filter('bandpass', freqmin=1/40.,freqmax=1/10.)
              # Plot reference phase with wide filter
    data_filter = np.reshape(sio.loadmat(save_path + 'toplot_' + event + '_'+ component + '.mat')['data_filter'],(-1,1))
    plt.plot(tr.times()[w0:w1]-Sdifftime, data_filter/np.max(np.abs(data_filter)),'k')

    toplot = sio.loadmat(save_path + 'toplot_' + event +'_'+ component + '.mat')['toplot']
#    centerfreq = np.reshape(sio.loadmat(save_path + 'toplot_' + event + '.mat')['centerfreq'],(-1,1))
    T_toplot = np.reshape(sio.loadmat(save_path + 'toplot_' + event + '_'+ component + '.mat')['T_toplot'],(-1,1))
    
#    x, y = np.meshgrid(tr.times()[w0:w1]-Sdifftime, centerfreq)
               
#    plt.pcolormesh(x, y, np.abs(toplot), cmap='Greys'
    
    plt.pcolor(tr.times()[w0:w1]-Sdifftime,T_toplot,toplot,cmap='Greys')    # Plot the fan image
    plt.ylim([-1,max(T_toplot)])
    
    maxima = np.argmax(toplot[:,w_start_maxima:w_end_maxima],axis=1)      # Plot the maxima
    #plt.scatter(tr.times()[w0+w_start_maxima+maxima]-Sdifftime,T_toplot,s=10,c='g')
    

    plt.xlim([-20,30])

    #if i == 2 or i==3:
    plt.xlabel('Time around ' +phase + ' (s), Ref phase: ', fontsize=10)

    if i==0:
        plt.ylabel(r'Centre Period (s)',fontsize=16)
    if (seis[0].stats.traveltimes['SKKS']):
            plt.plot([seis[0].stats.traveltimes['SKKS']-Sdifftime, seis[0].stats.traveltimes['SKKS']-Sdifftime],[min(T_toplot), max(T_toplot)],':k')

    plt.title(titles[i],fontsize=14)
    plt.plot([0, 0],[min(T_toplot), max(T_toplot)],'--k')  # Mark the Sdiff Phase
    plt.gca().tick_params(labelsize=10)
    #    plt.yscale('log')
    
plt.suptitle('Model ' + event + ' Distance = ' + str(distance))  
filename =  '/home/zl382/Pictures/fan_image/Synthetic/' + 'try0.8Hz' + '.png'    
plt.savefig(filename)     
plt.show()
    #plt.close('all')