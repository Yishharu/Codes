#usr/bin python3
#example: python3 process_to_pickle.py OUT_ULVZ20km

import sys
import obspy
from obspy import read
from obspy.core import Stream
from obspy.core import trace
import matplotlib.pyplot as plt
import os.path
import time
import glob
import shutil
import numpy as np
from obspy import UTCDateTime
import subprocess

moment = False
runs =[]
for arg in sys.argv[1:]:                         #Input is the model name
    runs.append(arg)
open_path = '/raid3/zl382/axisem-master/SOLVER/'  #Where axisem data is 
c=0
fmax=.5
fmin=0.05 
savedist=[]
# Create source trace
for rnum, run in enumerate(runs):
    dir= '/raid3/zl382/Data/Synthetics/' +run+'PICKLES'                    #dir is where the processed data dir
    stalist=[]
    dist=[]
    az=[]
    if moment:
        f=open(open_path + run + '/MZZ/Data/receiver_names.dat')
    else:
        f=open(open_path + run + '/Data/receiver_names.dat')
    for line in f.readlines():
        val=line.split()
        stalist.append(val[0])
        dist.append(float(val[2]))
        az.append(float(val[1]))
    if moment:
        f=open(open_path + run+'/MZZ/simulation.info')
    else:
        f=open(open_path + run+'/simulation.info')
    line=f.readlines()[8]
    print(line)
    val=line.split()
    depth = float(val[0])
    
    if not os.path.exists(dir):
        os.makedirs(dir)
    for i in range(len(stalist)): #range(cat.count()):
            print(i)
            seis=Stream()

            #add Z trace #No rotation needed, as along equator
            SHref=trace.Trace()
            tmptimes,SHref.data=np.loadtxt(open_path + run + '/Data_Postprocessing/SEISMOGRAMS/'+stalist[i]+'_disp_post_mij_conv0000_Z.dat',unpack=True)

            # Setup times etc.
            SHref.ts=np.arange(tmptimes[0],tmptimes[-1],0.04)
            SHref.stats.delta=0.04
            SHref.data=np.interp(SHref.ts,tmptimes,SHref.data)
            SHref.stats.channel='BAZ'
            seis+=SHref

            #add R trace #No rotation needed, as along equator
            SHref=trace.Trace()
            tmptimes,SHref.data=np.loadtxt(open_path + run + '/Data_Postprocessing/SEISMOGRAMS/'+stalist[i]+'_disp_post_mij_conv0000_E.dat',unpack=True)

            # Setup times etc.
            SHref.ts=np.arange(tmptimes[0],tmptimes[-1],0.04)
            SHref.stats.delta=0.04
            SHref.data=np.interp(SHref.ts,tmptimes,SHref.data)
            SHref.stats.channel='BAR'
            seis+=SHref            

            
            #add T trace #No rotation needed, as along equator
            SHref=trace.Trace()
            tmptimes,SHref.data=np.loadtxt(open_path+run+'/Data_Postprocessing/SEISMOGRAMS/'+stalist[i]+'_disp_post_mij_conv0000_N.dat',unpack=True)

            # Setup times etc.
            SHref.ts=np.arange(tmptimes[0],tmptimes[-1],0.04)
            SHref.stats.delta=0.04
            SHref.data=np.interp(SHref.ts,tmptimes,SHref.data)
            SHref.stats.channel='BAT'
            seis+=SHref
            
            seis[0].stats['distancedg']=dist[i]
            seis[0].stats['dist']=dist[i]
            seis[0].stats['azimuth']=az[i]
            seis[0].stats['az']=az[i]
            seis[0].stats['backazimuth'] = az[i] - 180

            try:
                test=['taup_time -mod prem -deg '+str(dist[i])+' -h '+ str(depth) + ' -ph P']
                out=subprocess.check_output(test,shell=True,universal_newlines=True)
                # Parrival
                t=out.split()
                print(t)
                l=[x for x in range(len(t)) if t[x]=='P']
                Ptime=float(t[l[0]+1])


                seis[0].stats['Ptime']=Ptime
            except:
                print('no P wave arrival')
            seis[0].stats['event']=run
            seis[0].stats['latitude']=-az[i]+90
            seis[0].stats['longitude']=dist[i]
            seis[0].stats['evdp']=depth

            if moment:
                filename= dir+'/'+stalist[i]+'.PICKLE'
            else:
                filename= dir+'/SYN_'+str(dist[i])+'.PICKLE'
            print(filename)
            seis.write(filename,'PICKLE')


        
