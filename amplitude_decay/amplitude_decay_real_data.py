# usr/bin/python3
import scipy.io as sio
import numpy as np
from obspy import read 
import matplotlib.pyplot as plt
from matplotlib import cm
from scipy.signal import hilbert
from obspy import UTCDateTime
import glob
from pylab import *
import matplotlib.patches as patches
import os.path
import sys

pick = 'hilb'#'diff'   # or hilb or integral or RMS
#model_or_dara = 'model' # or 'data'
Phases = ['S','Sdiff']
data_component = 'BHT'
ref_component = 'BXT'
events = ['20100320']#[sys.argv[1], sys.argv[2]]
#['20121210']# ['REF_modelPICKLES','ULVZ2kmPICKLES','ULVZ5kmPICKLES','ULVZ10km_wavefieldPICKLES','ULVZ20kmPICKLES'] # 'ULVZ5kmPICKLES' ['ULVZ20km_5%vsPICKLES','ULVZ20km_10%vsPICKLES']
#period = [30, 21.2, 15, 10.6, 7.5, 5.3, 3.7, 2.7]

fmin = [1/30,1/20,1/10,1/5,1/3]
fmax = [1/20,1/10,1/5,1/2,1]

norm_constant = 1
per_norm = False

color_toplot = ['mediumpurple', 'lightblue', 'lightgreen', 'orange','red']
cm_toplot = ['Purples','Blues','Greens','Oranges','Reds']
marker_toplot = ['s', 'o', 'o', '^', 'v', ',','*','.' ]

 #'REF_modelPICKLES' #'ULVZ20kmPICKLES' 
#'ULVZ10km_wavefieldPICKLES'  # 'ULVZ10kmPICKLES'   #'REF_modelPICKLES' #'ULVZ20kmPICKLES'
for event in events:
    seisfile = '/raid3/zl382/Data/' + event + '/'
    seislist = glob.glob(seisfile+ '*PICKLE')
    
    for k in range(len(fmin)):

        count = 0
        for s in range(0,len(seislist),1):        

            print('Reading Station ' + str(s) + '/'+str(len(seislist))+' of event ' + event+' of T '+ str(1/fmin[k])+' - '+str(1/fmax[k]))
            seis = read(seislist[s],format='PICKLE') # read seismogram   
            s_name = os.path.splitext(os.path.split(seislist[s])[1])[0]

            phase_time = seis[0].stats.traveltimes['Sdiff'] or seis[0].stats.traveltimes['S']
            noise_time = seis[0].stats.traveltimes['P'] or seis[0].stats.traveltimes['Pdiff']-300

            tr = seis.select(channel=data_component)[0]  
            ref = seis.select(channel=ref_component)[0]
            
            trf = tr.copy()
            trf = trf.filter('bandpass', freqmin=fmin[k],freqmax=fmax[k], zerophase=True)    
        
            if per_norm:  # set the norm
                norm = np.max(trf.data) / norm_constant
            elif count == 0:
                norm = np.max(trf.data) / norm_constant
            count = count+1 

            timewindow = 3*1/fmin[k]               
            w0_data = np.argmin(np.abs(trf.timesarray-phase_time+timewindow/3))        # arg of data, adapative time window     
            w1_data = np.argmin(np.abs(trf.timesarray-phase_time-timewindow*2/3))  
            if pick == 'hilb':
                A = np.max(np.abs(hilbert(trf.data)[w0_data:w1_data]))/norm
            elif pick == 'integral':
                A = np.sum(np.abs(hilbert(trf.data)[w0_data:w1_data]))/norm
            elif pick == 'RMS':
                A = np.sqrt(np.mean(hilbert(trf.data)[w0_data:w1_data]**2))/norm               

            reff= ref.copy()
            reff = reff.filter('bandpass', freqmin=fmin[k],freqmax=fmax[k], zerophase=True)    
            w0_ref = np.argmin(np.abs(reff.timesarray-phase_time+timewindow/3))        # arg of ref, adapative time window     
            w1_ref = np.argmin(np.abs(reff.timesarray-phase_time-timewindow*2/3))   
            if pick == 'hilb':
                A0 = np.max(np.abs(hilbert(reff.data)[w0_ref:w1_ref]))/norm
            elif pick == 'integral':
                A0 = np.sum(np.abs(hilbert(reff.data)[w0_ref:w1_ref]))/norm            
            elif pick == 'RMS':
                A0 = np.sqrt(np.mean(hilbert(reff.data)[w0_ref:w1_ref]**2))/norm
                        
            cm=plt.cm.get_cmap(cm_toplot[k])
            cm_ref=plt.cm.get_cmap('Greys')
            

            w0_noise1 = np.argmin(np.abs(trf.timesarray-noise_time+timewindow/3))        # arg of data, adapative time window     
            w1_noise1 = np.argmin(np.abs(trf.timesarray-noise_time-timewindow*2/3))
            A0_noise1 = np.abs(hilbert(trf.data[w0_noise1:w1_noise1])).max()/norm

            w0_noise2 = np.argmin(np.abs(trf.timesarray-noise_time+timewindow/3-100))        # arg of data, adapative time window     
            w1_noise2 = np.argmin(np.abs(trf.timesarray-noise_time-timewindow*2/3-100))
            A0_noise2 = np.abs(hilbert(trf.data[w0_noise2:w1_noise2])).max()/norm

            w0_noise3 = np.argmin(np.abs(trf.timesarray-noise_time+timewindow/3-200))        # arg of data, adapative time window     
            w1_noise3 = np.argmin(np.abs(trf.timesarray-noise_time-timewindow*2/3-200))
            A0_noise3 = np.abs(hilbert(trf.data[w0_noise3:w1_noise3])).max()/norm
        
            print('A0_phase: ' +str(A)+' A0_noise: ' +str(A0_noise1)+ ' SNR: ' +str(A/A0_noise1))
            print('A0_phase: ' +str(A)+' A0_noise: ' +str(A0_noise2)+ ' SNR: ' +str(A/A0_noise2))
            print('A0_phase: ' +str(A)+' A0_noise: ' +str(A0_noise3)+ ' SNR: ' +str(A/A0_noise3))
        
            SNR = np.mean([A/A0_noise1, A/A0_noise2, A/A0_noise3])

            if SNR > 2:
                if s == 0:
                    sc01 = plt.scatter(seis[0].stats['dist'], np.log(A),s=25, c=color_toplot[k], marker='o', cmap=cm, edgecolors='face', label = 'Real Data')
                    sc02 = plt.scatter(seis[0].stats['dist'], np.log(A0),s=25, c='grey', marker='o', cmap=cm_ref, edgecolors='face', label = 'Synthetic Reference')

                sc1 = plt.scatter(seis[0].stats['dist'], np.log(A), s=25, c=seis[0].stats['az'], vmin=0, vmax=90, marker='o', cmap=cm, edgecolors='face')
                sc2 = plt.scatter(seis[0].stats['dist'], np.log(A0), s=25, c=seis[0].stats['az'], vmin=0, vmax=90, marker='o', cmap=cm_ref, edgecolors='face')
            else: 
                sc1 = plt.scatter(seis[0].stats['dist'], np.log(A), s=25, marker='x', color='yellow')
                sc2 = plt.scatter(seis[0].stats['dist'], np.log(A0), s=25, c=seis[0].stats['az'], vmin=0, vmax=90, marker='o', cmap=cm_ref, edgecolors='face')

#            if np.log(A)<-50:
#                sys.exit(s_name + '<-50')                   
#            print('A = '+str(A))
#            print('A0 = '+str(A0))
#            print('log(A/A0) = '+str(np.log(A/A0)))
                
           # plt.annotate(s_name+' #'+str(s), (seis[0].stats['dist'], np.log(A)), fontsize = 5)
        plt.legend(shadow=True,fontsize=8,fancybox=True,framealpha=0.5)
        # sc01.remove()
        # sc02.remove()
        plt.colorbar(sc2)
        plt.xlabel('Epicentral Distance (deg)')
        plt.ylabel('Non-normlized amplitude (ln(A))')
        plt.suptitle('Event ' + event + ' Amplitude Decay \n Period : ' + str(1/fmin[k])+' - '+str(1/fmax[k])+'s ; timewindow: ' +str(timewindow)+' s', fontsize = 16) 
        plt.xlim([70,140])
        
        filefolder='/home/zl382/Pictures/Amplitude/test/' + event
        if not os.path.exists(filefolder):
            os.makedirs(filefolder)      
        
        filename = filefolder + '/Sdiff_30swindow_'+pick+'_'+event + ref_component+str(1/fmin[k])+'-'+str(1/fmax[k])+'.png'
        plt.savefig(filename)
        plt.close('all')           
