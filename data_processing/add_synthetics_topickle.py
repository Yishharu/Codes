import instaseis
import obspy
from obspy import read
import matplotlib.pyplot as plt
import sys,glob
import obspy.signal.rotate

print(instaseis.__path__)

# input directory with PICKLE data as argument
event = sys.argv[1]
dr='Data/'+event+'/'

###!!!! All previous synthetics can be removed from the PICKLE by this script
cleansyn = input("Do you want all previous synethetics removed? (y/n) ")
if cleansyn == 'y':
    clean = True
else:
    clean = False
    
    # Load database with Green Functions
db = instaseis.open_db("/raid2/sc845/Instaseis/DB/10s_PREM_ANI_FORCES/")

# Directory needs to contain a cmt source text file!!!
with open(dr +'/cmtsource.txt','r') as inf:
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
stalist = glob.glob(dr+'/*PICKLE')

for s in range(len(stalist)):
               seis = read(stalist[s],format='PICKLE')

               for tr in  seis.select(channel='BX*'):
                   seis.remove(tr)
               
 
               #While we are at it there is a mistake in data_processing_2 where the stats of seis[0] (vertical component)  get overwritten by those of a horizontal component... fixing this here. 
               seis[0].stats['channel']='BHZ'
               print(seis[0].stats['channel'])
               receiver = instaseis.Receiver(latitude=seis[0].stats['stla'], longitude=seis[0].stats['stlo'], network=seis[0].stats['network'], station = seis[0].stats['station'])

               start =seis[0].stats['starttime']
               end = seis[0].stats['endtime']
               st = db.get_seismograms(source=source, receiver=receiver,kind='displacement', dt=0.1)
               # Rotate synthetics
               stE = st.select(channel='BXE')
               stN = st.select(channel='BXN')
               stZ = st.select(channel='BXZ')
               [stRtmp,stTtmp]=obspy.signal.rotate.rotate_ne_rt(stN[0].data,stE[0].data,seis[0].stats['baz'])
               stR=stN[0].copy()
               stR.stats['channel']='BXR'
               stR.data = stRtmp
               stT=stN[0].copy()
               stT.stats['channel']='BXT'
               stT.data = stTtmp
               
               

               
               seis+=stR
               seis+=stT
               seis+=stZ
               #print(streamnew)
               for x in seis:
                   print(x.stats['channel'])
               #OVERWRITES previous PICKLE with synthetics included
               seis.write(stalist[s],format='PICKLE')
               #plt.show()
