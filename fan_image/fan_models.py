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
plot_column = 4

# Set phase to plot
phases = sio.loadmat(save_path + 'pickle_mat_interface'+ '.mat')['phases']
for i in range(len(phases)):
    phases[i] = phases[i].strip()
# Set component to plot
components = sio.loadmat(save_path + 'pickle_mat_interface'+ '.mat')['components']
for i in range(len(components)):
    components[i] = components[i].strip()

# Set filename for figure
filename = 'Plots/Sdiff_T_B1.png'
# Set models to plot
events = sio.loadmat(save_path + 'pickle_mat_interface'+ '.mat')['events']
for i in range(len(events)):
    events[i] = events[i].strip()
# Set model titles
#titles = ['REF_model','ULVZ2km','ULVZ5km','ULVZ10km','ULVZ20km']
titles = ['PREM','5%vs 20km ULVZ','10%vs 20km ULVZ','20%vs 20km ULVZ']
#titles = ['REF_model','ULVZ2km','ULVZ5km']

ref_phase = ['SKKS']


# Set center frequencies for the Fan
# centerfreq=np.linspace(2,25,200)
s = 106.0

plt.figure(figsize=(11.69,8.27))
for j in [0,1,2,3]:#range(len(events)):
    event = events[j]

    seisfile = '/raid3/zl382/Data/Synthetics/' +  event + '/SYN_' + str(s) + '.PICKLE'
    seis = read(seisfile,format='PICKLE')
    seis.resample(10)# Resampling makes things quicker

#    for i in range(len(phases)):
#        # Initialize plot for each model
    print(event + '_' + 'BAT')
    component = 'BAT'
    phase = 'Sdiff'
    if j==0:
        ax0=plt.subplot(plot_row, plot_column, j+1)
    else:
        plt.subplot(plot_row, plot_column, j+1)
           
          # Load file
    
    Sdifftime = seis[0].stats['traveltimes'][phase] # find time of phase              
        # Cut window around phase on selected component       
    tr = seis.select(channel=component)[0]
#        w0 = np.argmin(np.abs(tr.times()-Sdifftime+100))
#        w1 = np.argmin(np.abs(tr.times()-Sdifftime-190))
        
    for x in range (0,len(ref_phase)):
        if  seis[0].stats.traveltimes[ref_phase[x]]!=None:
            ref_phase_name = ref_phase[x]
            ref_phase_time = seis[0].stats.traveltimes[ref_phase[x]]
                
    w0 = np.argmin(np.abs(tr.times()-Sdifftime+120))
    
    w1 = np.argmin(np.abs(tr.times()-Sdifftime-180))

        
    w_start_maxima = np.argmin(np.abs(tr.times()-Sdifftime+20))-w0;
    w_end_maxima = np.argmin(np.abs(tr.times()-Sdifftime-30))-w0
        
    
    #              # Copy trace
    #              tr1=tr.copy()
    #              tr1=tr1.filter('bandpass', freqmin=1/40.,freqmax=1/10.)
                  # Plot reference phase with wide filter
    data_filter = np.reshape(sio.loadmat(save_path + 'toplot_' + event + '_'+ component + '.mat')['data_filter'],(-1,1))
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
    toplot = sio.loadmat(save_path + 'toplot_' + event +'_'+ component + '.mat')['toplot']
    #    centerfreq = np.reshape(sio.loadmat(save_path + 'toplot_' + event + '.mat')['centerfreq'],(-1,1))
    T_toplot = np.reshape(sio.loadmat(save_path + 'toplot_' + event + '_'+ component + '.mat')['T_toplot'],(-1,1))
        
    #    x, y = np.meshgrid(tr.times()[w0:w1]-Sdifftime, centerfreq)
                   
    #    plt.pcolormesh(x, y, np.abs(toplot), cmap='Greys'
        
    plt.pcolor(tr.times()[w0:w1]-Sdifftime,T_toplot,toplot,cmap='Greys')    # Plot the fan image
    plt.ylim([-1,max(T_toplot)])
        
    maxima = np.argmax(toplot[:,w_start_maxima:w_end_maxima],axis=1)      # Plot the maxima
        #plt.scatter(tr.times()[w0+w_start_maxima+maxima]-Sdifftime,T_toplot,s=10,c='g')
        

    plt.xlim([-50,60])

        #if i == 2 or i==3:
    plt.xlabel('Time around ' +phase + ' (s), Ref phase: '+ref_phase_name, fontsize=10)

    if j==0:
        plt.ylabel(r'Centre Period (s)',fontsize=16)
    
    plt.title(titles[j],fontsize=12)
    plt.plot([0, 0],[min(T_toplot), max(T_toplot)],'--k')  # Mark the Sdiff Phase
    if (phase == 'S') or (phase == 'Sdiff'):
        if (seis[0].stats.traveltimes['SKS']):
            plt.plot([seis[0].stats.traveltimes['SKS']-Sdifftime, seis[0].stats.traveltimes['SKS']-Sdifftime],[min(T_toplot), max(T_toplot)],'-.k')  # Mark the Ref Phase
        if (seis[0].stats.traveltimes['SKKS']):
            plt.plot([seis[0].stats.traveltimes['SKKS']-Sdifftime, seis[0].stats.traveltimes['SKKS']-Sdifftime],[min(T_toplot), max(T_toplot)],':k') 
    plt.gca().tick_params(labelsize=10)
    #    plt.yscale('log')
    
#plt.suptitle('Model Comparison'+ ' Distance = ' + str(distance))  
#Set colorbar
#cbar = plt.colorbar()
#cbar.ax.tick_params(labelsize=10)
filename =  '/home/zl382/Pictures/fan_image/Synthetic/' + '106_three' + '.pdf'    
    
#plt.savefig(filename,format='pdf')     
plt.show()
#plt.close('all')