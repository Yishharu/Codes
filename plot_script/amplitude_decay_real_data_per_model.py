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

pick = 'hilb'#'diff'   # or hilb
model_or_dara = 'model' # or 'data'
Phases = ['S', 'Sdiff']
data_component = 'BHT'
ref_component = 'BH90T'
events = ['20100320']# ['REF_modelPICKLES','ULVZ2kmPICKLES','ULVZ5kmPICKLES','ULVZ10km_wavefieldPICKLES','ULVZ20kmPICKLES'] # 'ULVZ5kmPICKLES' ['ULVZ20km_5%vsPICKLES','ULVZ20km_10%vsPICKLES']
period = [30, 21.2, 15, 10.6, 7.5, 5.3, 3.7, 2.7]
color_toplot = ['grey', 'purple', 'blue', 'green', 'orange', 'fuchsia', 'red', 'brown']
cm_toplot = ['Greys','Purples','Blues','Greens','Oranges','PuRd','Reds','YlOrBr']
marker_toplot = ['s', 'o', 'o', '^', 'v', ',','*','.' ]
 #'REF_modelPICKLES' #'ULVZ20kmPICKLES' 
#'ULVZ10km_wavefieldPICKLES'  # 'ULVZ10kmPICKLES'   #'REF_modelPICKLES' #'ULVZ20kmPICKLES'



for event in events:
    seisfile = '/raid3/zl382/Data/' + event + '/'
    seislist = glob.glob(seisfile+ '*PICKLE')
    for s in range(0,len(seislist),1):                        
        print('Reading Station ' + str(s) +'/'+str(len(seislist))+' of event ' + event+' of whole')
        seis = read(seislist[s],format='PICKLE') # read seismogram    
        try:
            seis.resample(10)
        except:
            print(str(s)+' resample break down!!!!!!!')
            continue
        Sdifftime = None
        for phase in Phases:
            if seis[0].stats['traveltimes'][phase]:
                Sdifftime = seis[0].stats['traveltimes'][phase]
        tr = seis.select(channel=data_component)[0]    
        ref = seis.select(channel=ref_component)[0]
        
        for k in range(len(period)):
            T = period[k]
            trf = tr.copy()
            trf = trf.filter('bandpass', freqmin=1/(T*1.2),freqmax=1/(T*0.8), zerophase=True)    
            timewindow = 3*T                  
            w0_data = np.argmin(np.abs(tr.times-Sdifftime+timewindow/3))        # arg of data, adapative time window     
            w1_data = np.argmin(np.abs(tr.times-Sdifftime-timewindow*2/3))   
            A = np.max(np.abs(hilbert(trf.data[w0_data:w1_data])))   

            reff= ref.copy()
            reff = reff.filter('bandpass', freqmin=1/(T*1.2),freqmax=1/(T*0.8), zerophase=True)     
            w0_ref = np.argmin(np.abs(reff.times-seis[0].stats['traveltimes']['BX90T']+timewindow/3))        # arg of ref, adapative time window     
            w1_ref = np.argmin(np.abs(reff.times-seis[0].stats['traveltimes']['BX90T']-timewindow*2/3))              
            A0 = np.max(np.abs(hilbert(reff.data[w0_ref:w1_ref])))            
                  
            if s == 0:
                plt.scatter(seis[0].stats['dist'],np.log(A/A0),color = color_toplot[k], marker = marker_toplot[k], label = str(T)+'s')
            else:
                plt.scatter(seis[0].stats['dist'],np.log(A/A0),color = color_toplot[k], marker = marker_toplot[k])
#            if  s % 50 == 0:
#                noise_w0 = 0
#                noise_w1 = 3000
#                noise = np.log(np.mean(np.abs(hilbert(tr.data))[noise_w0:noise_w1])/A0)   
#                plt.axhline(y=noise, color='black', linestyle='--')       
    plt.legend(shadow=True,fontsize=8,fancybox=True,framealpha=0.5)
    plt.ylim([-6,6])
    plt.xlabel('Epicentral Distance (deg)')
    plt.ylabel('Normlized amplitude (ln(A/A0))')
    plt.suptitle('Event ' + event + ' Amplitude Decay', fontsize = 16) 
    filename = '/home/zl382/Pictures/Amplitude/Real_data/' + event + '_PREM_norm.png'
    plt.savefig(filename)
    plt.close('all')
                