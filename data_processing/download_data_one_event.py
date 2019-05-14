#

import obspy
from obspy.clients.fdsn import Client as IRISClient
from obspy import UTCDateTime
import matplotlib.pyplot as plt
import os.path
import time
import obspy.geodetics.base
from obspy.geodetics import kilometers2degrees
import numpy as np
import sys

area = sys.argv[1]
event = sys.argv[2]
dir='/raid1/zl382/Data/'+area+'/'+event+'/'

cat = obspy.read_events(dir+'CMTSOLUTION')

# load IRIS client
irisclient=IRISClient("IRIS")

# event parameters
latitude = cat[0].origins[0].latitude
longitude = cat[0].origins[0].longitude
starttime = cat[0].origins[0].time - 30
endtime = cat[0].origins[0].time + 30
minmag = cat[0].magnitudes[0].mag - 0.8
maxmag = cat[0].magnitudes[0].mag + 0.8
maxrad = 5.0

# Station paramaters
distmin = float(sys.argv[3])
distmax = float(sys.argv[4])
azmin = float(sys.argv[5])  #True north azimuth
azmax = float(sys.argv[6])
lengthoftrace=60.*45.

# define a filter band to prevent amplifying noise during the deconvolution
# not being used, as responses are not being removed
fl1 = 0.005
fl2 = 0.01
fl3 = 5.
fl4 = 10.

# Make directories for data
if not os.path.exists(dir):
    os.makedirs(dir)

# save search parameter
with open(dir+'catelog_parameter.txt','w') as f:
    line_par = 'Catelog Parameter\n event = {0}\n latitude = {1:.4f}\n longitude = {2:.4f}\n starttime = {3}\n endtime = {4}\n maxrad = {5}\n minrag = {6}\n maxmag = {7}\n\n Station paramaters\n distmin = {8}\n distmax ={9}\n azmin = {10}\n azmax = {11}\n lengthoftrace = {12}\n'.format(event, latitude, longitude, starttime, endtime, maxrad, minmag, maxmag, distmin, distmax, azmin, azmax, lengthoftrace)
    f.write(line_par)

dirresp=dir+'Responsefiles'
if not os.path.exists(dirresp):
    os.makedirs(dirresp)

dirorigin=dir+'Originals'
if not os.path.exists(dirorigin):
    os.makedirs(dirorigin)   
   
# save event catalog
cat=irisclient.get_events(latitude=latitude, longitude=longitude, maxradius=maxrad, starttime=starttime,endtime=endtime,minmagnitude=minmag)
evtlatitude=cat[0].origins[0]['latitude']
evtlongitude=cat[0].origins[0]['longitude']
evtdepth=cat[0].origins[0]['depth']/1.e3 # convert to km from m
evstarttime=cat[0].origins[0].time

eventtime=cat[0].origins[0].time+lengthoftrace
if len(cat)>1:
    print('more than one event is selected')
    sys.exit()

# Select what stations are present at the time
inventory = irisclient.get_stations(starttime=evstarttime, endtime=eventtime)# Channel information does not seem to work ...,channel='BH*')
count = 0
inventory.get_response

for nw in inventory:
    print(nw)

    for sta in nw:
        print(sta)
    
        seis=[]
        distm, az, baz = obspy.geodetics.base.gps2dist_azimuth(evtlatitude, evtlongitude,sta.latitude, sta.longitude)
        distdg = kilometers2degrees(distm/1.0e3)
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
                seis[0].stats['stelv']=sta.elevation

                seis[0].stats['dist']=distdg
                seis[0].stats['az']=az
                seis[0].stats['baz']=baz

                seis[0].stats['station']=sta.code
                seis[0].stats['network']=nw.code


                filename=dirorigin+'/'+seis[0].stats.station+'.'+seis[0].stats.network+'.PICKLE'
                print('writing to ', filename)
                count = count +1
                seis.write(filename,format='PICKLE')
            except:
                print('response removal or saving failed for, ', nw.code,' ',sta.code)
        

print('Seismograms found for ', str(count),', stations')
            
