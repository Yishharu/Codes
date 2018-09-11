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
component = 'BHT'
events = ['20100320ALL']# ['REF_modelPICKLES','ULVZ2kmPICKLES','ULVZ5kmPICKLES','ULVZ10km_wavefieldPICKLES','ULVZ20kmPICKLES'] # 'ULVZ5kmPICKLES' ['ULVZ20km_5%vsPICKLES','ULVZ20km_10%vsPICKLES']
period = [30, 21.2, 15, 10.6, 7.5, 5.3, 3.7, 2.7]
color_toplot = ['grey', 'purple', 'blue', 'green', 'orange', 'fuchsia', 'red', 'brown']
marker_toplot = ['s', 'o', 'o', '^', 'v', ',','*','.' ]
per_model = True
 #'REF_modelPICKLES' #'ULVZ20kmPICKLES' 
#'ULVZ10km_wavefieldPICKLES'  # 'ULVZ10kmPICKLES'   #'REF_modelPICKLES' #'ULVZ20kmPICKLES'
data_path = '/raid3/zl382/Data/Synthetics/PREM_20100320_90distPICKLES/'
open_path = '/raid3/zl382/axisem-master/SOLVER/'  #Where axisem data is 
stalist = []
dist = []
az = []
with open(open_path + 'PREM_20100320_90dist' + '/MZZ/Data/receiver_names.dat') as f:
    for line in f.readlines():
        val=line.split()
        stalist.append(val[0])
        dist.append(float(val[2]))
        az.append(float(val[1]))

az_array = np.array(az)
A0 = 1
if per_model == True:
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
            tr = seis.select(channel=component)[0]           
            tshift=UTCDateTime(seis[0].stats['starttime']) - UTCDateTime(seis[0].stats['eventtime'])   
            print('Station: '+seis[0].stats.station+', Distance = '+ str(seis[0].stats['dist'])+ ', Azimuth = '+str(seis[0].stats['az'])+' Sdifftime = '+str(Sdifftime))
            
            ref_name = stalist[np.where(az_array == round(seis[0].stats['az'],1))[0][0]]
            ref_seis = read(data_path+ref_name+'.PICKLE', format='PICKLE') # read seismogram    
            ref_seis.resample(10)
            ref_Sdifftime = None
            for phase in Phases:
                if ref_seis[0].stats['traveltimes'][phase]:
                    ref_Sdifftime = ref_seis[0].stats['traveltimes'][phase]            
            ref_tr = ref_seis.select(channel='BAT')[0]
            w0 = np.argmin(np.abs(ref_tr.times()-ref_Sdifftime))  # arg of ref tr 50s synthtic, so time window should be quite long        
            w1 = np.argmin(np.abs(ref_tr.times()-ref_Sdifftime-150))            
            A0 = np.max(np.abs(hilbert(ref_tr.data[w0:w1])))
            print('Station: '+ref_name+', Distance = '+ str(ref_seis[0].stats['dist'])+ ', Azimuth = '+str(ref_seis[0].stats['azimuth'])+' Sdifftime = '+str(ref_Sdifftime))

#            test_w0 = np.argmin(np.abs(ref_tr.times()-ref_Sdifftime+(-1)))            
#            test_w1 = np.argmin(np.abs(ref_tr.times()-ref_Sdifftime-149)) 
#            test_A0 = np.max(np.abs(hilbert(ref_tr.data[test_w0:test_w1])))
#            print('diff phase at ' + str(s)+' out of REF SYNTHETIC time window!!!!!!!')
#            print('window diffence is '+str((test_A0-A0)/A0))
#            plt.plot(ref_tr.times()-ref_Sdifftime, ref_tr.data/np.max(ref_tr.data) + seis[0].stats['az'],'k')
#            plt.plot(tr.times()+tshift-Sdifftime, tr.data/np.max(tr.data) + seis[0].stats['az'],'k')
#            plt.scatter(seis[0].stats['dist'],np.log(A/A0),color = color_toplot[k], marker = 'x') 
            
            for k in range(len(period)):
                T = period[k]
                trf = tr.copy()
                trf = trf.filter('bandpass', freqmin=1/(T*1.2),freqmax=1/(T*0.8), zerophase=True)    
                timewindow = 3*T                  
                w0_data = np.argmin(np.abs(tr.times()+tshift-Sdifftime+timewindow/3))        # arg of data, adapative time window     
                w1_data = np.argmin(np.abs(tr.times()+tshift-Sdifftime-timewindow*2/3))   
                A = np.max(np.abs(hilbert(trf.data[w0_data:w1_data])))                
#                test_window = 0.95*timewindow    
#                test_w0 = np.argmin(np.abs(tr.times()+tshift-Sdifftime+test_window/3))            
#                test_w1 = np.argmin(np.abs(tr.times()+tshift-Sdifftime-test_window*2/3))                   
#                test_A = np.max(np.abs(hilbert(trf.data[test_w0:test_w1])))  
#
#                if np.abs(test_A-A)/A > 0.1 :
#                    print('diff phase at ' + str(s)+' out of DATA time window!!!!!!! with difference: '+str((test_A-A)/A))
#                    plt.scatter(seis[0].stats['dist'],np.log(A/A0),color = color_toplot[k], marker = 'x')
#                    continue                     
                if s == 0:
                    plt.scatter(seis[0].stats['dist'],np.log(A),color = color_toplot[k], marker = marker_toplot[k], label = str(T)+'s')
                else:
                    plt.scatter(seis[0].stats['dist'],np.log(A),color = color_toplot[k], marker = marker_toplot[k])
#            if  s % 50 == 0:
#                noise_w0 = 0
#                noise_w1 = 3000
#                noise = np.log(np.mean(np.abs(hilbert(tr.data))[noise_w0:noise_w1])/A0)   
#                plt.axhline(y=noise, color='black', linestyle='--')       
        plt.legend(shadow=True,fontsize=8,fancybox=True,framealpha=0.5)
        plt.ylim([-20,-8])
        plt.xlabel('Epicentral Distance (deg)')
        plt.ylabel('Nonormlized amplitude (ln(A))')
        plt.suptitle('Event ' + event + ' Amplitude Decay', fontsize = 16) 
        filename = '/home/zl382/Pictures/Amplitude/Real_data/nonorm' + event + '_PREM_norm.png'
        plt.savefig(filename)
        plt.close('all')
        
        for k in range(len(period)):
            T = period[k]
            for s in range(0,len(seislist),1):                        
                print('Reading Station ' + str(s) + '/'+str(len(seislist))+' of event ' + event+' of T='+str(T))
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
                if Sdifftime == None:
                    print('Distance ' + str(s)+' Sdiiftime break down!!!!!!!')
                    continue 
                tr = seis.select(channel=component)[0]           
                tshift=UTCDateTime(seis[0].stats['starttime']) - UTCDateTime(seis[0].stats['eventtime'])   
                timewindow = 3*T              
                w0_data = np.argmin(np.abs(tr.times()+tshift-Sdifftime+timewindow/3))            
                w1_data = np.argmin(np.abs(tr.times()+tshift-Sdifftime-timewindow*2/3))                   
                
                ref_name = stalist[np.where(az_array == round(seis[0].stats['az'],1))[0][0]]
                ref_seis = read(data_path+ref_name+'.PICKLE', format='PICKLE') # read syn seismogram    
                ref_seis.resample(10)
                ref_Sdifftime = None
                for phase in Phases:
                    if ref_seis[0].stats['traveltimes'][phase]:
                        ref_Sdifftime = ref_seis[0].stats['traveltimes'][phase]            
                ref_tr = ref_seis.select(channel='BAT')[0]
                
                w0 = np.argmin(np.abs(ref_tr.times()-ref_Sdifftime))  # arg of ref tr 50s synthtic, so time window should be quite long        
                w1 = np.argmin(np.abs(ref_tr.times()-ref_Sdifftime-150))            
                A0 = np.max(np.abs(hilbert(ref_tr.data[w0:w1])))                

#                test_window = 0.9*timewindow    
#                test_w0 = np.argmin(np.abs(tr.times()+tshift-Sdifftime+test_window/3))            
#                test_w1 = np.argmin(np.abs(tr.times()+tshift-Sdifftime-test_window*2/3))                 
              
#                if pick == 'diff':
#                    A0 = np.max(ref_tr.data[w0:w1])-np.min(ref_tr.data[w0:w1])
#                    A = np.log((np.max(trf.data[w0_data:w1_data])-np.min(trf.data[w0_data:w1_data]))/A0)
                trf = tr.copy()
                trf = trf.filter('bandpass', freqmin=1/(T*1.2),freqmax=1/(T*0.8), zerophase=True)               
                A = np.max(np.abs(hilbert(trf.data[w0_data:w1_data])))   
#                if np.max(np.abs(hilbert(trf.data[test_w0:test_w1]))) != A:
#                    print('diff phase at ' + str(s)+' out of time window!!!!!!!')
#                    plt.scatter(seis[0].stats['dist'],np.log(A/A0),color = color_toplot[k], marker = 'x')
#                    continue 
                if s == 0:
                    plt.scatter(seis[0].stats['dist'],np.log(A),color = color_toplot[k], marker = marker_toplot[k], label = str(T)+'s')
                else:
                    plt.scatter(seis[0].stats['dist'],np.log(A),color = color_toplot[k], marker = marker_toplot[k])            
            plt.legend(shadow=True,fontsize=8,fancybox=True,framealpha=0.5)
            plt.ylim([-20,-8])
            plt.xlabel('Epicentral Distance (deg)')
            plt.ylabel('Normlized amplitude (ln(A/A0))')
            plt.suptitle('Event ' + event + ' Amplitude Decay', fontsize = 16) 
            filename = '/home/zl382/Pictures/Amplitude/Real_data/nonorm' + event + '_PREM_norm_T_'+str(T)+'.png'
            plt.savefig(filename)
            plt.close('all')           
