import os
import numpy as np
import matplotlib.pyplot as plt
import obspy
import subprocess
from obspy.core import Stream, trace

########  Edit After This Line  ############
model = 'Bottom5km-40pct'
Phases = ['S','Sdiff']

delta = 0.04
# Data Directory
Dir = '/raid1/zl382/HPC_axisem3d_run/'
SavePostProcessDir = Dir+model+'/' + 'post_processing'
########  Edit Before This Line  ############
if not os.path.exists(SavePostProcessDir):
    os.makedirs(SavePostProcessDir)


dist_list = np.arange(60,141)  #[90,95,100,105,110,115,120,125,130,135]
cat = obspy.read_events(Dir+'/'+model+'/'+'input/CMTSOLUTION')
EventDepth = cat[0].origins[0].depth/1000.
# Loop through seismograms
count = 0
for idist, dist in enumerate(dist_list):
    print('proccessing distance %d' %dist)
    ReadData = np.loadtxt(Dir + '/' + model + '/' + 'output/stations/UV.D%d.RTZ.ascii' % dist)
    time = ReadData[:,0]
    # Total Stream
    seis = Stream()
    # R Component
    seisR = trace.Trace() 
    seisR.ts = np.arange(time[0],time[-1], delta)
    seisR.stats.delta = delta
    seisR.data = np.interp(seisR.ts,time,ReadData[:,1])
    seisR.stats.channel = 'BAR'
    seis+=seisR

    # T Component
    seisT = trace.Trace()  
    seisT.ts = np.arange(time[0],time[-1], delta)
    seisT.stats.delta = delta
    seisT.data = np.interp(seisT.ts,time,ReadData[:,2])
    seisT.stats.channel = 'BAT'
    seis+=seisT

    # Z Component
    seisZ = trace.Trace()  
    seisZ.ts = np.arange(time[0],time[-1], delta)
    seisZ.stats.delta = delta
    seisZ.data = np.interp(seisZ.ts,time,ReadData[:,3])
    seisZ.stats.channel = 'BAZ'
    seis+=seisZ

    seis[0].stats['event'] = model
    seis[0].stats['dist'] = dist
    seis[0].stats['evdp'] = EventDepth

    # Use Taup to get reference arrival time
 #   if not hasattr(seis[0].stats,'traveltimes'):
    seis[0].stats.traveltimes=dict()
    for ph in Phases:
        test = ['taup_time -mod prem -deg '+str(dist)+' -h '+ str(EventDepth) + ' -ph '+ph]
        out = subprocess.check_output(test,shell=True,universal_newlines=True)
        # Sdiff arrival
        ResultTaup = iter(out.split())
        ph_time = [next(ResultTaup,x) for x in ResultTaup if x==ph]
        if ph_time != []:
            seis[0].stats.traveltimes[ph]=float(ph_time[0])
        else:
            seis[0].stats.traveltimes[ph]=None

    # Write out seismogram
    filename = SavePostProcessDir+'/'+'UV.D%d' % dist +'.PICKLE'
    seis.write(filename, format='PICKLE')
    print('Saved in %s' % filename)