#/usr/bin/python3
# Usage:   python3 add_synthetics_topickle.py [event]
# Example:  python3 add_synthetics_topickle.py 20100320

import instaseis
import obspy
from obspy import read
import matplotlib.pyplot as plt
import sys,glob
import obspy.signal.rotate

print(instaseis.__path__)

# default ak135f
if_velocity = False
if_acceleration = False
if_iasp91_2s = False
if_prem_2s = False
if_prem_10s = False
# input directory with PICKLE data as argument
area = sys.argv[1]
event = sys.argv[2]
dr='/raid1/zl382/Data/'+area+'/'+event+'/'
###!!!! All previous synthetics can be removed from the PICKLE by this script
# cleansyn = input("Do you want all previous synethetics removed? (y/n) ")
# if cleansyn == 'y':
#     clean = True
# else:
#     clean = False
clean = True
    
    # Load database with Green Functions
db  = instaseis.open_db("syngine://ak135f_2s")
db_iasp91_2s = instaseis.open_db("syngine://iasp91_2s")
db_prem_a_2s = instaseis.open_db("syngine://prem_a_2s")
db_prem_a_10s = instaseis.open_db("syngine://prem_a_10s")
# db_ak135f_2s = instaseis.open_db("syngine://ak135f_2s")

# Directory needs to contain a CMTSOLUTION source text file!!!
cat = obspy.read_events(dr+'CMTSOLUTION')

# Read in source
source = instaseis.Source(latitude=cat[0].origins[0].latitude, longitude=cat[0].origins[0].longitude, depth_in_m=cat[0].origins[0].depth,
                          m_rr = cat[0].focal_mechanisms[0].moment_tensor.tensor.m_rr,
                          m_tt = cat[0].focal_mechanisms[0].moment_tensor.tensor.m_tt,
                          m_pp = cat[0].focal_mechanisms[0].moment_tensor.tensor.m_pp,
                          m_rt = cat[0].focal_mechanisms[0].moment_tensor.tensor.m_rt,
                          m_rp = cat[0].focal_mechanisms[0].moment_tensor.tensor.m_rp,
                          m_tp = cat[0].focal_mechanisms[0].moment_tensor.tensor.m_tp,
                          origin_time=cat[0].origins[0].time)
print(source)
# Read and loop through stationlist
stalist = glob.glob(dr+'*PICKLE')

for s in range(0,len(stalist)):
    print(str(s)+'/'+str(len(stalist))+' of '+event)
    seis = read(stalist[s],format='PICKLE')

    for tr in seis.select(channel='BX*'):
        seis.remove(tr)
    
    #While we are at it there is a mistake in data_processing_2 where the stats of seis[0] (vertical component)  get overwritten by those of a horizontal component... fixing this here. 
    seis[0].stats['channel']='BHZ'
#    print(seis[0].stats['channel'])
    receiver = instaseis.Receiver(latitude=seis[0].stats['stla'], longitude=seis[0].stats['stlo'], network=seis[0].stats['network'], station = seis[0].stats['station'])


    eventtime =seis[0].stats['eventtime']
    starttime =seis[0].stats['starttime']
    endtime = seis[0].stats['endtime']
    st = db.get_seismograms(source=source, receiver=receiver,kind='displacement', dt=0.1)  # displacement, velocity, acceleration 
    # Rotate synthetics
    stE = st.select(channel='BXE')
    stN = st.select(channel='BXN')
    stZ = st.select(channel='BXZ')
    [stRtmp,stTtmp]=obspy.signal.rotate.rotate_ne_rt(stN[0].data,stE[0].data,seis[0].stats['baz'])
    stR=stN[0].copy()
    stR.stats['channel']='BXR'
    stR.stats['starttime'] = starttime
    stR.stats['eventtime'] = eventtime
    stR.timesarray = stR.times(reftime = starttime)
    stR.data = stRtmp
    stT=stN[0].copy()
    stT.stats['channel']='BXT'
    stT.stats['starttime'] = starttime
    stT.stats['eventtime'] = eventtime   
    stT.timesarray = stT.times(reftime = starttime)
    stT.data = stTtmp
    stZ[0].stats['channel']='BXZ'   
    stZ[0].stats['starttime'] = starttime
    stZ[0].stats['eventtime'] = eventtime  
    stZ[0].timesarray = stZ[0].times(reftime = starttime)    
      
    seis+=stR
    seis+=stT
    seis+=stZ
    
    if if_velocity:     
        st = db.get_seismograms(source=source, receiver=receiver,kind='velocity', dt=0.1)  # displacement, velocity, acceleration 
        # Rotate synthetics
        stE = st.select(channel='BXE')
        stN = st.select(channel='BXN')
        stZ = st.select(channel='BXZ')
        [stRtmp,stTtmp]=obspy.signal.rotate.rotate_ne_rt(stN[0].data,stE[0].data,seis[0].stats['baz'])
        stR=stN[0].copy()
        stR.stats['channel']='BXR_V'
        stR.stats['starttime'] = starttime
        stR.stats['eventtime'] = eventtime
        stR.timesarray = stR.times(reftime = starttime)
        stR.data = stRtmp
        stT=stN[0].copy()
        stT.stats['channel']='BXT_V'
        stT.stats['starttime'] = starttime
        stT.stats['eventtime'] = eventtime   
        stT.timesarray = stT.times(reftime = starttime)
        stT.data = stTtmp
        stZ[0].stats['channel']='BXZ_V'   
        stZ[0].stats['starttime'] = starttime
        stZ[0].stats['eventtime'] = eventtime  
        stZ[0].timesarray = stZ[0].times(reftime = starttime)    
          
        seis+=stR
        seis+=stT
        seis+=stZ    
        
    if if_acceleration:     
        st = db.get_seismograms(source=source, receiver=receiver,kind='acceleration', dt=0.1)  # displacement, velocity, acceleration 
        # Rotate synthetics
        stE = st.select(channel='BXE')
        stN = st.select(channel='BXN')
        stZ = st.select(channel='BXZ')
        [stRtmp,stTtmp]=obspy.signal.rotate.rotate_ne_rt(stN[0].data,stE[0].data,seis[0].stats['baz'])
        stR=stN[0].copy()
        stR.stats['channel']='BXR_A'
        stR.stats['starttime'] = starttime
        stR.stats['eventtime'] = eventtime
        stR.timesarray = stR.times(reftime = starttime)
        stR.data = stRtmp
        stT=stN[0].copy()
        stT.stats['channel']='BXT_A'
        stT.stats['starttime'] = starttime
        stT.stats['eventtime'] = eventtime   
        stT.timesarray = stT.times(reftime = starttime)
        stT.data = stTtmp
        stZ[0].stats['channel']='BXZ_A'   
        stZ[0].stats['starttime'] = starttime
        stZ[0].stats['eventtime'] = eventtime  
        stZ[0].timesarray = stZ[0].times(reftime = starttime)    
          
        seis+=stR
        seis+=stT
        seis+=stZ   
        
    if if_iasp91_2s:     
        st = db_iasp91_2s.get_seismograms(source=source, receiver=receiver,kind='displacement', dt=0.1)  # displacement, velocity, acceleration 
        # Rotate synthetics
        stE = st.select(channel='BXE')
        stN = st.select(channel='BXN')
        stZ = st.select(channel='BXZ')
        [stRtmp,stTtmp]=obspy.signal.rotate.rotate_ne_rt(stN[0].data,stE[0].data,seis[0].stats['baz'])
        stR=stN[0].copy()
        stR.stats['channel']='BXR_iasp91_2s'
        stR.stats['starttime'] = starttime
        stR.stats['eventtime'] = eventtime
        stR.timesarray = stR.times(reftime = starttime)
        stR.data = stRtmp
        stT=stN[0].copy()
        stT.stats['channel']='BXT_iasp91_2s'
        stT.stats['starttime'] = starttime
        stT.stats['eventtime'] = eventtime   
        stT.timesarray = stT.times(reftime = starttime)
        stT.data = stTtmp
        stZ[0].stats['channel']='BXZ_iasp91_2s'   
        stZ[0].stats['starttime'] = starttime
        stZ[0].stats['eventtime'] = eventtime  
        stZ[0].timesarray = stZ[0].times(reftime = starttime)    
          
        seis+=stR
        seis+=stT
        seis+=stZ       
    if if_prem_2s:
        st = db_prem_a_2s.get_seismograms(source=source, receiver=receiver,kind='displacement', dt=0.1)  # displacement, velocity, acceleration 
        # Rotate synthetics
        stE = st.select(channel='BXE')
        stN = st.select(channel='BXN')
        stZ = st.select(channel='BXZ')
        [stRtmp,stTtmp]=obspy.signal.rotate.rotate_ne_rt(stN[0].data,stE[0].data,seis[0].stats['baz'])
        stR=stN[0].copy()
        stR.stats['channel']='BXR_prem_a_2s'
        stR.stats['starttime'] = starttime
        stR.stats['eventtime'] = eventtime
        stR.timesarray = stR.times(reftime = starttime)
        stR.data = stRtmp
        stT=stN[0].copy()
        stT.stats['channel']='BXT_prem_a_2s'
        stT.stats['starttime'] = starttime
        stT.stats['eventtime'] = eventtime   
        stT.timesarray = stT.times(reftime = starttime)
        stT.data = stTtmp
        stZ[0].stats['channel']='BXZ_prem_a_2s'   
        stZ[0].stats['starttime'] = starttime
        stZ[0].stats['eventtime'] = eventtime  
        stZ[0].timesarray = stZ[0].times(reftime = starttime)    
          
        seis+=stR
        seis+=stT
        seis+=stZ  
    if if_prem_10s:
        st = db_prem_a_10s.get_seismograms(source=source, receiver=receiver,kind='displacement', dt=0.1)  # displacement, velocity, acceleration 
        # Rotate synthetics
        stE = st.select(channel='BXE')
        stN = st.select(channel='BXN')
        stZ = st.select(channel='BXZ')
        [stRtmp,stTtmp]=obspy.signal.rotate.rotate_ne_rt(stN[0].data,stE[0].data,seis[0].stats['baz'])
        stR=stN[0].copy()
        stR.stats['channel']='BXR_prem_a_10s'
        stR.stats['starttime'] = starttime
        stR.stats['eventtime'] = eventtime
        stR.timesarray = stR.times(reftime = starttime)
        stR.data = stRtmp
        stT=stN[0].copy()
        stT.stats['channel']='BXT_prem_a_10s'
        stT.stats['starttime'] = starttime
        stT.stats['eventtime'] = eventtime   
        stT.timesarray = stT.times(reftime = starttime)
        stT.data = stTtmp
        stZ[0].stats['channel']='BXZ_prem_a_10s'   
        stZ[0].stats['starttime'] = starttime
        stZ[0].stats['eventtime'] = eventtime  
        stZ[0].timesarray = stZ[0].times(reftime = starttime)    
          
        seis+=stR
        seis+=stT
        seis+=stZ          
        
        
    #print(streamnew)
    for x in seis:
        print(x.stats['channel'])
    #OVERWRITES previous PICKLE with synthetics included
    seis.write(stalist[s],format='PICKLE')
    #plt.show()
