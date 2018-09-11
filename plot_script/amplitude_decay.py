# usr/bin/python3

import scipy.io as sio
import numpy as np
from obspy import read 
import matplotlib.pyplot as plt
from pylab import *
from matplotlib import cm
from scipy.signal import hilbert
import matplotlib.patches as patches

pick = 'hilb'#'diff'   # or hilb # or 'integral' or 'RMS'

Phases = ['S', 'Sdiff']
component = 'BAT'
events = ['REF_modelPICKLES','ULVZ2kmPICKLES','ULVZ5kmPICKLES','ULVZ10km_wavefieldPICKLES','ULVZ20kmPICKLES'] # 'ULVZ5kmPICKLES' ['ULVZ20km_5%vsPICKLES','ULVZ20km_10%vsPICKLES']
color_toplot = [ 'mediumpurple', 'blue', 'green', 'orange','red']
marker_toplot = ['s', 'o', '^', 'v', ',','*','.','>', '<','D','+']

per_period_or_model = 'model'
 #'REF_modelPICKLES' #'ULVZ20kmPICKLES' 
#'ULVZ10km_wavefieldPICKLES'  # 'ULVZ10kmPICKLES'   #'REF_modelPICKLES' #'ULVZ20kmPICKLES' 
dist = np.arange(40.0, 138.0,0.25)
seisfile_path = '/raid3/zl382/Data/Synthetics/'
A0_array = zeros(10)                  
fmin = [1/30,1/20,1/10,1/5,1/2]
fmax = [1/20,1/10,1/5,1/2,1]
if per_period_or_model == 'model':
    for event in events:
        ampl_2d = []  

     #   plt.figure()
        for s in dist:
            print('Reading Distance ' + str(s)+' of '+event)
            seisfile = '/raid3/zl382/Data/Synthetics/' +  event + '/SYN_' + str(s) + '.PICKLE'
            seis = read(seisfile, format='PICKLE')
            seis.resample(10)
            Sdifftime = None
            for phase in Phases:
                if seis[0].stats['traveltimes'][phase]:
                    Sdifftime = seis[0].stats['traveltimes'][phase]
            if Sdifftime == None:
                print('Distance ' + str(s)+' Sdiiftime break down!!!!!!!')
                continue 
            tr = seis.select(channel=component)[0]
            
            ampl = []
            for i in range(len(fmin)):
                timewindow = 3*1/fmin[i]
                w0 = np.argmin(np.abs(tr.times()-Sdifftime+10))            
                w1 = np.argmin(np.abs(tr.times()-Sdifftime-20))          
#                test_window = 0.9*timewindow    
#                test_w0 = np.argmin(np.abs(tr.times()-Sdifftime+test_window/3))            
#                test_w1 = np.argmin(np.abs(tr.times()-Sdifftime-test_window*2/3))                
#                if tr.times()[w1]-tr.times()[w0]<2.8*T: # 2.8*T:
#                    print('diff phase at ' + str(s)+' near the boundary break down!!!!!!!')
#                    ampl.extend([None])
#                    continue               
                trf = tr.copy()
                trf = trf.filter('bandpass', freqmin=fmin[i],freqmax=fmax[i], zerophase=True, corners=4)                   
                if pick == 'diff':
                    A = np.max(trf.data[w0:w1])-np.min(trf.data[w0:w1])
#                    if np.max(trf.data[w0:w1])-np.min(trf.data[test_w0:test_w1]) != A:
#                        print('diff phase at ' + str(s)+' out of time window!!!!!!!')
#                        ampl.extend([None])
#                        continue                    
                elif pick == 'hilb':                        
                    A = np.max(np.abs(hilbert(trf.data))[w0:w1])
                elif pick == 'integral':
                    A = np.sum(np.abs(hilbert(trf.data))[w0:w1])
                elif pick == 'RMS':
                    A = np.sqrt( np.mean(np.abs(hilbert(trf.data)[w0:w1])**2) ) 
            
                if s == 40:
                    A0_array[i] = A                     
                ampl.extend([A/A0_array[i]])
                  
               # A0 = np.max(trf.data[w0:w1])
                #plt.plot(trf.times()-Sdifftime,trf.data/A0+s, color = 'black')
                # plt.hlines(y=np.max(np.abs(hilbert(trf.data))[w0:w1])/A0+s, xmin=trf.times()[w0]-Sdifftime, xmax=trf.times()[w1]-Sdifftime, color='red', linestyle='--')      
 #               window_wid = trf.times()[w1] - trf.times()[w0]
 #               window_hei = np.max(np.abs(hilbert(trf.data))[w0:w1])/A0             
 #               gca().add_patch(patches.Rectangle((trf.times()[w0]-Sdifftime,s-window_hei),window_wid,2*window_hei,alpha = 0.4, color = 'red'))  # width height
            
            ampl_2d.append(ampl)
        ampl_toplot = np.array(ampl_2d)
#        if event == 'REF_modelPICKLES':
#            ref_ampl = ampl_toplot
#        ampl_toplot = ampl_toplot / ref_ampl
      
        fig = plt.figure()
        ax = fig.add_subplot(111)
        fig.subplots_adjust(top=0.90)  
            
        for k in range(len(fmin)):
            ax.plot(dist, np.log(ampl_toplot[:,k]), color = color_toplot[k], label = str(1/fmin[k])+' - '+str(1/fmax[k])+' s')

        dist = np.array(dist)        
        
      #  lamdas = np.linspace(0.05, 0.15, num=11)
#        lamda = 0.13
#        dist_merge = 70
#        dist_start = np.where(dist>dist_merge)[0][0]
#        for i in range(len(period)):
#            T = period[i]
#            omega = 2*np.pi/T
#            A_predicted = -omega**(1/3)*lamda*np.sin(np.pi/3)*(dist-dist_merge)    
           # plt.plot(dist[dist_start:-1],A_predicted[dist_start:-1],'k', marker=marker_toplot[i], label = 'Predicted A with T '+str(T)+'s')  
        
        
        ax.legend(shadow=True,fontsize=8,fancybox=True,framealpha=0.5)
        plt.ylim([-14,0])
        ax.set_xlabel('Epicentral Distance (deg)')
        ax.set_ylabel('Normlized amplitude (ln(A/A0))')
        ax.set_title('window pick: '+pick+'; '+'30s timewindow ', fontsize = 10)
        fig.suptitle('Model ' + event + ' Amplitude Decay', fontsize = 16) 
    #    plt.show()
        filename = '/home/zl382/Pictures/Amplitude/Models/new_'+event + '.png'

        fig.savefig(filename)        
        plt.close('all')
#plt.xlim([-20,70])
#plt.ylim([40,140])
plt.show()


if per_period_or_model == 'period':
    for i in range(2,len(fmin)):

        ampl_2d = []
        for event in events:
            Phases = ['S', 'Sdiff']
            component = 'BAT'        
            ampl = []
            A0 =1
            for s in dist:
                print('Reading Distance ' + str(s)+' T=' +str(1/fmin[i])+' event = '+event)
                seisfile = '/raid3/zl382/Data/Synthetics/' +  event + '/SYN_' + str(s) + '.PICKLE'
                seis = read(seisfile, format='PICKLE')
                seis.resample(10)  
                Sdifftime = None
                for phase in Phases:
                    if seis[0].stats['traveltimes'][phase]:
                        Sdifftime = seis[0].stats['traveltimes'][phase]
                if Sdifftime == None:
                    print('Distance ' + str(s)+' Sdiiftime break down!!!!!!!')
                    continue 
                tr = seis.select(channel=component)[0]
                timewindow = 3*1/fmin[i]
                w0 = np.argmin(np.abs(tr.times()-Sdifftime+timewindow/2))            
                w1 = np.argmin(np.abs(tr.times()-Sdifftime-timewindow/2))
                
#                if tr.times()[w1]-tr.times()[w0]<2.8*T:
#                    print('diff phase at ' + str(s)+' near the boundary break down!!!!!!!')
#                    continue     

                trf = tr.copy()
                trf = trf.filter('bandpass', freqmin=fmin[i],freqmax=fmax[i], zerophase=True)
                
                if pick == 'diff':
                    ampl.extend([  np.log((np.max(trf.data[w0:w1])-np.min(trf.data[w0:w1]))/A0)  ])
                elif pick == 'hilb':
                    ampl.extend([  np.log(np.max(np.abs(hilbert(trf.data))[w0:w1])/A0)  ])
                elif pick == 'integral':
                    ampl.extend([  np.log(np.sum(np.abs(hilbert(tr.data))[w0:w1])/A0)   ])
            
            ampl_2d.append(ampl)
        ampl_toplot = np.array(ampl_2d)
        
        fig = plt.figure()
        ax = fig.add_subplot(111)
        fig.subplots_adjust(top=0.85)

        for k in range(len(events)):
            plt.plot(dist, ampl_toplot[k,:], color = color_toplot[k], label = str(events[k]))
        ax.legend(shadow=True,fontsize=8,fancybox=True,framealpha=0.5)
        #ax.ylim([-20,0])
        ax.set_xlabel('Epicentral Distance (deg)')
        ax.set_ylabel('Normlized amplitude (ln(A/A0))')
        fig.suptitle('Model ' + str(1/fmin[i]) + 's Amplitude Decay', fontsize = 16) 
        filename = '/home/zl382/Pictures/Amplitude/T/new_' + str(1/fmin[i]) + 's'+pick+'.png'
        fig.savefig(filename,format='png')
        plt.close('all') 