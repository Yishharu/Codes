#

import obspy
from obspy.clients.fdsn import Client as IRISClient
from obspy import UTCDateTime
import matplotlib.pyplot as plt
import os.path
import time
import obspy.geodetics.base
import numpy as np


# load IRIS client
irisclient=IRISClient("IRIS")


# event parameters
name = '20161217'
latitude= -4.51
longitude= 153.45
starttime = UTCDateTime("2016-12-17T10:20:27.000")
endtime =  UTCDateTime("2016-12-17T12:30:35.000")
maxrad=1
minmag=6.5
maxmag=8.0

# Station paramaters
distmin = 80
distmax = 130
azmin = 10
azmax = 76
lengthoftrace=60.*45.

# define a filter band to prevent amplifying noise during the deconvolution
# not being used, as responses are not being removed
fl1 = 0.005
fl2 = 0.01
fl3 = .5
fl4 = 2.

# Make directories for data
dir='Data'
if not os.path.exists(dir):
    os.makedirs(dir)
dir= dir+'/'+name
if not os.path.exists(dir):
    os.makedirs(dir)
dirresp=dir+'/Responsefiles'
if not os.path.exists(dirresp):
    os.makedirs(dirresp)

dir=dir+'/Originals'
if not os.path.exists(dir):
    os.makedirs(dir)   
   
# save event catalog
cat=irisclient.get_events(latitude=latitude, longitude=longitude, maxradius=maxrad, starttime=starttime,endtime=endtime,minmagnitude=minmag)
evtlatitude=cat[0].origins[0]['latitude']
evtlongitude=cat[0].origins[0]['longitude']
evtdepth=cat[0].origins[0]['depth']/1.e3 # convert to km from m
evstarttime=cat[0].origins[0].time

evendtime=cat[0].origins[0].time+lengthoftrace
if len(cat)>1:
    print('more than one event is selected')
    sys.exit()

# Select what stations are present at the time
inventory = irisclient.get_stations(starttime=evstarttime,
                                    endtime=evendtime)# Channel information does not seem to work ...,channel='BH*')
count = 0
inventory.get_response

for nw in inventory:
    print(nw)

    for sta in nw:
        print(sta)
    
        seis=[]
        distm, az, baz = obspy.geodetics.base.gps2dist_azimuth(evtlatitude, evtlongitude,sta.latitude, sta.longitude)
        distdg = distm/(6371.e3*np.pi/180.)
        print(distdg,az)
        # select data depending on distance and azimuths
        if distdg> distmin and distdg <distmax and az>azmin and az < azmax:
            # Try to download data
            try:
                print('trying',nw.code, sta.code, "*", "BH*", evstarttime, evstarttime + lengthoftrace)
                seis = irisclient.get_waveforms(nw.code, sta.code, "*", "BH*", evstarttime, evstarttime + lengthoftrace, attach_response=True)
            except:
                print('failed',nw.code, sta.code, "*", "BH*", evstarttime, evstarttime + lengthoftrace)
        if len(seis)>1:
            # get response file
            try:
                seis.remove_response(output='DISP', pre_filt=[fl1,fl2,fl3,fl4])

                seis[0].stats['evla']=evtlatitude
                seis[0].stats['evlo']=evtlongitude
                seis[0].stats['evdp']=evtdepth
                seis[0].stats['stla']=sta.latitude
                seis[0].stats['stlo']=sta.longitude

                seis[0].stats['dist']=distdg
                seis[0].stats['az']=az
                seis[0].stats['baz']=baz

                seis[0].stats['station']=sta.code
                seis[0].stats['network']=nw.code


                filename=dir+'/'+seis[0].stats.station+'.'+seis[0].stats.network+'.PICKLE'
                print('writing to ', filename)
                count = count +1
                seis.write(filename,format='PICKLE')
            except:
                print('response removal or saving failed for, ', nw.code,' ',sta.code)
        

print('Seismograms found for ', str(count),', stations')
            
