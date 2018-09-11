#/usr/bin/python3
# Usage:   python3 add_synthetics_topickle_extra.py [event]
# Example:  python3 add_synthetics_topickle_extra.py 20100320
import numpy as np
import instaseis
import obspy
from obspy import read, UTCDateTime
import matplotlib.pyplot as plt
import sys,glob
import obspy.signal.rotate
import geopy
from geopy.distance import VincentyDistance

print(instaseis.__path__)

# input directory with PICKLE data as argument
event = sys.argv[1]
dr='/raid3/zl382/Data/'+event+'/'
###!!!! All previous synthetics can be removed from the PICKLE by this script
cleansyn = input("Do you want all previous synethetics removed? (y/n) ")
if cleansyn == 'y':
    clean = True
else:
    clean = False
    
    # Load database with Green Functions
db  = instaseis.open_db("syngine://ak135f_2s")

# Directory needs to contain a cmt source text file!!!
with open(dr +'cmtsource.txt','r') as inf:
    srcdict= eval(inf.read())

# Read in source
source = instaseis.Source(latitude=srcdict['latitude'], longitude=srcdict['longitude'], depth_in_m=srcdict['depth']*1.e3,
                          m_rr = srcdict['Mrr'] / 1E7,
                          m_tt = srcdict['Mtt']  / 1E7,
                          m_pp = srcdict['Mpp'] / 1E7,
                          m_rt = srcdict['Mrt'] / 1E7,
                          m_rp = srcdict['Mrp']/ 1E7,
                          m_tp = srcdict['Mtp'] / 1E7,
                          origin_time=obspy.UTCDateTime(srcdict['year'],srcdict['month'],srcdict['day'],srcdict['hour'],srcdict['min'],srcdict['sec'],srcdict['msec']))

# Read and loop through stationlist
stalist = glob.glob(dr+'*PICKLE')

for s in range(0,len(stalist)):
               print(str(s)+'/'+str(len(stalist))+' of '+ event)
               seis = read(stalist[s],format='PICKLE')
               
               if clean:
                   for tr in seis.select(channel='BX*'):
                       seis.remove(tr)
                       print('delete channel '+tr.stats['channel'])
               else:
                   for tr in seis.select(channel='BX90*'):
                       seis.remove(tr) 
                       print('delete channel '+tr.stats['channel'])

               #While we are at it there is a mistake in data_processing_2 where the stats of seis[0] (vertical component)  get overwritten by those of a horizontal component... fixing this here. 
               seis[0].stats['channel']='BHZ'
            #   print(seis[0].stats['channel'])
               #Calculate receiver at 90 distance 
               origin = geopy.Point(srcdict['latitude'],srcdict['longitude'])
               destination = VincentyDistance(kilometers=90*(6371*np.pi/180.)).destination(origin, seis[0].stats['az'])
               receiver = instaseis.Receiver(latitude=destination.latitude, longitude=destination.longitude, network=seis[0].stats['network'], station = seis[0].stats['station'])

               eventtime =seis[0].stats['eventtime']
               starttime =seis[0].stats['starttime']
               endtime = seis[0].stats['endtime']
               st = db.get_seismograms(source=source, receiver=receiver,kind='displacement', dt=0.1)
               # Rotate synthetics
               stE = st.select(channel='BXE')
               stN = st.select(channel='BXN')
               stZ = st.select(channel='BXZ')
               [stRtmp,stTtmp]=obspy.signal.rotate.rotate_ne_rt(stN[0].data,stE[0].data,seis[0].stats['baz'])
               stR=stN[0].copy()
               stR.stats['channel']='BX90R'
               stR.stats['starttime'] = starttime
               stR.stats['eventtime'] = eventtime
               stR.timesarray = stR.times(reftime = starttime)
               stR.data = stRtmp
               stT=stN[0].copy()
               stT.stats['channel']='BX90T'
               stT.stats['starttime'] = starttime
               stT.stats['eventtime'] = eventtime  
               stT.timesarray = stT.times(reftime = starttime)   
               stT.data = stTtmp
               
               stZ[0].stats['channel']='BX90Z'   
               stZ[0].stats['starttime'] = starttime
               stZ[0].stats['eventtime'] = eventtime  
               stZ[0].timesarray = stZ[0].times(reftime = starttime)                 
                                           
               seis+=stR
               seis+=stT
               seis+=stZ
               #print(streamnew)   
                       
               for x in seis:
#                   if not type(x.times) is np.ndarray:
#                       time = x.stats['eventtime']
#                       x.timesarray = x.times(reftime = time)                      
                   print(x.stats['channel'])
               #OVERWRITES previous PICKLE with synthetics included
               seis.write(stalist[s],format='PICKLE')
               #plt.show()
