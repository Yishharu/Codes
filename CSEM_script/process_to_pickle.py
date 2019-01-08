
#
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

event = '20180910'
modscsem = ['ULVZ_20180910']

c=0
savedist=[]
channel_csem=['UT','UL','UR']
channel_real=['BCT','BCR','BCZ']

syn_dir =  '/raid3/zl382/CSEM/'
save_dir = '/raid3/zl382/Data/'

for modcsem in modscsem:
    print('now at', modcsem)
    stalist = glob.glob('/raid3/zl382/Data/'+event+'/*PICKLE')

    for i in range(len(stalist)):
            print(i,os.path.basename(stalist[i]))

            seis=read(stalist[i],'PICKLE')
            syn = Stream()
            for ch in range(len(channel_csem)):
                synTc=seis[0].copy()
                synTc.stats['channel']=channel_real[ch]
                nw = synTc.stats['network']
                if len(nw)<2:
                  nw='_'+nw
                sta = synTc.stats['station']
                if len(sta)<4:
                  sta='_'+sta
                if len(sta)>4:
                  sta=sta[:4]

                filename= syn_dir+event+'/'+modcsem+'/'+channel_csem[ch]+'_'+nw+'_'+sta
                if not os.path.exists(filename):
                    continue
                f=open(filename,'r')
                timesyn=[]
                sync=[]

                lines=f.readlines()
                for line in lines:
                  line=line.split()
                  timesyn.append(float(line[0]))
                  sync.append(float(line[1]))
                synTc.time=np.array(timesyn)-450.
                synTc.data=-.1*np.array(sync)
                synTc.stats.npts=len(synTc.data)
                synTc.stats.delta=synTc.time[1]-synTc.time[0]
                synTc.stats.sampling_rate=1./synTc.stats.delta
                syn+= synTc
            if not os.path.exists(filename):
                continue            
            print(syn)
            if not os.path.exists(save_dir+event+'/CSEM/'+modcsem+'/'):
                os.makedirs(save_dir+event+'/CSEM/'+modcsem+'/')
            syn.write(save_dir+event+'/CSEM/'+modcsem+'/'+os.path.basename(stalist[i]),format='PICKLE')

print('Processing done in: %s' % save_dir+event+'/CSEM/'+modcsem+'/' )