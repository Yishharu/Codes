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
ref_component = 'BXT_prem_a_2s'
events = [sys.argv[1]]
#['20121210']# ['REF_modelPICKLES','ULVZ2kmPICKLES','ULVZ5kmPICKLES','ULVZ10km_wavefieldPICKLES','ULVZ20kmPICKLES'] # 'ULVZ5kmPICKLES' ['ULVZ20km_5%vsPICKLES','ULVZ20km_10%vsPICKLES']
#period = [30, 21.2, 15, 10.6, 7.5, 5.3, 3.7, 2.7]

fmin = [1/30,1/20,1/10,1/5,1/3]
fmax = [1/20,1/10,1/5,1/2,1]

color_toplot = ['mediumpurple', 'lightblue', 'lightgreen', 'orange','red']
cm_toplot = ['Purples','Blues','Greens','Oranges','Reds']
marker_toplot = ['s', 'o', 'o', '^', 'v', ',','*','.' ]

 #'REF_modelPICKLES' #'ULVZ20kmPICKLES' 
#'ULVZ10km_wavefieldPICKLES'  # 'ULVZ10kmPICKLES'   #'REF_modelPICKLES' #'ULVZ20kmPICKLES'
for event in events:
    seisfile = '/raid3/zl382/Data/' + event + '/'
    seislist = glob.glob(seisfile+ '*PICKLE')
    
    for k in range(len(fmin)):

        for s in range(0,len(seislist),1):                        
            print('Reading Station ' + str(s) + '/'+str(len(seislist))+' of event ' + event+' of T '+ str(1/fmin[k])+' - '+str(1/fmax[k]))
            seis = read(seislist[s],format='PICKLE') # read seismogram   
            s_name = os.path.splitext(os.path.split(seislist[s])[1])[0]

            Sdifftime = None
            for phase in Phases:
                if seis[0].stats['traveltimes'][phase]:
                    Sdifftime = seis[0].stats['traveltimes'][phase]

            tr = seis.select(channel=data_component)[0]  
            ref = seis.select(channel=ref_component)[0]
            
            trf = tr.copy()
            trf = trf.filter('bandpass', freqmin=fmin[k],freqmax=fmax[k], zerophase=True)    
            timewindow = 30#3*1/fmin[k]               
            w0_data = np.argmin(np.abs(trf.timesarray-Sdifftime+timewindow/2))        # arg of data, adapative time window     
            w1_data = np.argmin(np.abs(trf.timesarray-Sdifftime-timewindow/2))  
            if pick == 'hilb':
                A = np.max(np.abs(hilbert(trf.data)[w0_data:w1_data]))
            elif pick == 'integral':
                A = np.sum(np.abs(hilbert(trf.data)[w0_data:w1_data]))
            elif pick == 'RMS':
                A = np.sqrt(np.mean(hilbert(trf.data)[w0_data:w1_data]**2))               

            reff= ref.copy()
            reff = reff.filter('bandpass', freqmin=fmin[k],freqmax=fmax[k], zerophase=True)    
            w0_ref = np.argmin(np.abs(reff.timesarray-Sdifftime+10))        # arg of ref, adapative time window     
            w1_ref = np.argmin(np.abs(reff.timesarray-Sdifftime-20))   
            if pick == 'hilb':
                A0 = np.max(np.abs(hilbert(reff.data)[w0_ref:w1_ref]))
            elif pick == 'integral':
                A0 = np.sum(np.abs(hilbert(reff.data)[w0_ref:w1_ref]))               
            elif pick == 'RMS':
                A0 = np.sqrt(np.mean(hilbert(reff.data)[w0_ref:w1_ref]**2)) 
                        
            cm=plt.cm.get_cmap(cm_toplot[k])
            cm_ref=plt.cm.get_cmap('Greys')
            
            if s == 0:
                sc01 = plt.scatter(seis[0].stats['dist'], np.log(A),s=25, c=color_toplot[k], marker='o', cmap=cm, edgecolors='face', label = 'Real Data')
                sc02 = plt.scatter(seis[0].stats['dist'], np.log(A0),s=25, c='grey', marker='o', cmap=cm_ref, edgecolors='face', label = 'Synthetic Reference')

            sc1 = plt.scatter(seis[0].stats['dist'], np.log(A), s=25, c=seis[0].stats['az'], vmin=0, vmax=90, marker='o', cmap=cm, edgecolors='face')
            sc2 = plt.scatter(seis[0].stats['dist'], np.log(A0), s=25, c=seis[0].stats['az'], vmin=0, vmax=90, marker='o', cmap=cm_ref, edgecolors='face')
             
#            if np.log(A)<-50:
#                sys.exit(s_name + '<-50')                   
#            print('A = '+str(A))
#            print('A0 = '+str(A0))
#            print('log(A/A0) = '+str(np.log(A/A0)))
                
           # plt.annotate(s_name+' #'+str(s), (seis[0].stats['dist'], np.log(A)), fontsize = 5)
        plt.legend(shadow=True,fontsize=8,fancybox=True,framealpha=0.5)
        sc01.remove()
        sc02.remove()
        plt.colorbar(sc2)
        plt.xlabel('Epicentral Distance (deg)')
        plt.ylabel('Non-normlized amplitude (ln(A))')
        plt.suptitle('Event ' + event + ' Amplitude Decay \n Period : ' + str(1/fmin[k])+' - '+str(1/fmax[k])+'s ; timewindow: ' +str(timewindow)+' s', fontsize = 16) 
        #plt.ylim([-7,4])
        
        filefolder='/home/zl382/Pictures/Amplitude/Real_data_per_period/' + event
        if not os.path.exists(filefolder):
            os.makedirs(filefolder)      
        
        filename = filefolder + '/Sdiff_30swindow_'+pick+'_'+event + ref_component+str(1/fmin[k])+'-'+str(1/fmax[k])+'.png'
        plt.savefig(filename)
        plt.close('all')           
