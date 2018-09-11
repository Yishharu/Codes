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

pick = 'hilb'#'diff'   # or hilb or integral or RMS
#model_or_dara = 'model' # or 'data'
Phases = ['S', 'Sdiff']
data_component = 'BHT'
ref_component = 'BX90T'
events = [sys.argv[1]]
#['20121210']# ['REF_modelPICKLES','ULVZ2kmPICKLES','ULVZ5kmPICKLES','ULVZ10km_wavefieldPICKLES','ULVZ20kmPICKLES'] # 'ULVZ5kmPICKLES' ['ULVZ20km_5%vsPICKLES','ULVZ20km_10%vsPICKLES']
#period = [30, 21.2, 15, 10.6, 7.5, 5.3, 3.7, 2.7]

fmin = [1/30,1/20,1/10,1/5,1/2]
fmax = [1/20,1/10,1/5,1/2,1]

color_toplot = ['brown', 'purple', 'blue', 'green', 'orange', 'fuchsia', 'red', 'brown']
cm_toplot = ['YlOrBr','Purples','Blues','Greens','Oranges','PuRd','Reds','YlOrBr']
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
            timewindow = 3*1/fmin[k]               
            w0_data = np.argmin(np.abs(trf.timesarray-Sdifftime+timewindow/2))        # arg of data, adapative time window     
            w1_data = np.argmin(np.abs(trf.timesarray-Sdifftime-timewindow/2))  
            if pick == 'hilb':
                A = np.max(np.abs(hilbert(trf.data)[w0_data:w1_data]))
            elif pick == 'integral':
                A = np.sum(np.abs(hilbert(trf.data)[w0_data:w1_data]))
            elif pick == 'RMS':
                A = np.sqrt(np.mean(hilbert(trf.data)[w0_data:w1_data]**2))         
                
            if ref_component == 'BX90T':
                Sdifftime = seis[0].stats['traveltimes']['S90']
            
            reff= ref.copy()
            reff = reff.filter('bandpass', freqmin=fmin[k],freqmax=fmax[k], zerophase=True)    
            w0_ref = np.argmin(np.abs(reff.timesarray-Sdifftime+timewindow/2))        # arg of ref, adapative time window     
            w1_ref = np.argmin(np.abs(reff.timesarray-Sdifftime-timewindow/2))   
            if pick == 'hilb':
                A0 = np.max(np.abs(hilbert(reff.data)[w0_ref:w1_ref]))
            elif pick == 'integral':
                A0 = np.sum(np.abs(hilbert(reff.data)[w0_ref:w1_ref]))               
            elif pick == 'RMS':
                A0 = np.sqrt(np.mean(hilbert(reff.data)[w0_ref:w1_ref]**2)) 
                        
            cm=plt.cm.get_cmap(cm_toplot[k])
            cm_ref=plt.cm.get_cmap('Greys')
            if s == 0:
                sc1 = plt.scatter(seis[0].stats['az'], np.log(A),s=25, c=seis[0].stats['dist'], vmin= 0, vmax=135, marker='o', cmap=cm, edgecolors='none', label = 'Data A')
                sc2 = plt.scatter(seis[0].stats['az'], np.log(A0),s=25, c=seis[0].stats['dist'], vmin= 0, vmax=135, marker='o', cmap=cm_ref, edgecolors='none', label = 'Ref A0')
            else:
                sc1 = plt.scatter(seis[0].stats['az'], np.log(A), s=25, c=seis[0].stats['dist'], vmin= 0, vmax=135, marker='o', cmap=cm, edgecolors='none')
                sc2 = plt.scatter(seis[0].stats['az'], np.log(A0), s=25, c=seis[0].stats['dist'], vmin= 0, vmax=135, marker='o', cmap=cm_ref, edgecolors='none')
#            print('A = '+str(A))
#            print('A0 = '+str(A0))
#            print('log(A/A0) = '+str(np.log(A/A0)))
                
           # plt.annotate(s_name+' #'+str(s), (seis[0].stats['dist'], np.log(A/A0)), fontsize = 5)
        #plt.legend(shadow=True,fontsize=8,fancybox=True,framealpha=0.5)
        #plt.colorbar(sc1)
        plt.colorbar(sc2)
        plt.xlabel('Azimuth (deg)')
        plt.ylabel('No-Normlized amplitude (ln(A)) and ln(A0)')
        plt.suptitle('Event ' + event + ' Amplitude Decay \n Period : ' + str(1/fmin[k])+' - '+str(1/fmax[k])+'s ; timewindow: ' +str(timewindow)+' s;'+'Real: '+data_component+'Ref: '+ref_component, fontsize = 14) 
   #     plt.ylim([-7,4])
        
        filefolder='/home/zl382/Pictures/Amplitude/Real_data_per_period/' + event
        if not os.path.exists(filefolder):
            os.makedirs(filefolder)      
        
        filename = filefolder + '/90Az_AandA0_'+pick+'_'+event + '_ak135norm_T_'+str(1/fmin[k])+'-'+str(1/fmax[k])+'.png'
        plt.savefig(filename)
        plt.close('all')           
