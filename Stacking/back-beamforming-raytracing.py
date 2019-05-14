import glob
import os
from os.path import splitext

import numpy as np
from scipy import stats
import matplotlib.pyplot as plt


from mpl_toolkits.basemap import Basemap
from itertools import chain
from geographiclib.geodesic import Geodesic
import obspy
from obspy import read

Location = 'Hawaii'
Event = '20100320'

data_folder = '/raid3/zl382/Pictures/BeamForming/traveltime_10-20s/'

###################### Edit Before This Line ######################################
dir='/raid3/zl382/Data/'+Location+'/'+Event+'/'
sta_location = np.load(dir+'STALOCATION.npy').item()
cat = obspy.read_events(dir+'CMTSOLUTION')
event_latitude = cat[0].origins[0].latitude
event_longitude = cat[0].origins[0].longitude

plt.figure(figsize=(8, 8))
radii=[833]
# Set number 1:
centerlon = -166
centerlat = 19
m = Basemap(projection='ortho', resolution=None, lat_0 = centerlat, lon_0=centerlon)
m.bluemarble(scale=0.5)

def draw_map(m, scale=0.2):
    # draw a shaded-relief image
    m.shadedrelief(scale=scale)
    
    # lats and longs are returned as a dictionary
    lats = m.drawparallels(np.linspace(-90, 90, 13))
    lons = m.drawmeridians(np.linspace(-180, 180, 13))

    # keys contain the plt.Line2D instances
    lat_lines = chain(*(tup[1][0] for tup in lats.items()))
    lon_lines = chain(*(tup[1][0] for tup in lons.items()))
    all_lines = chain(lat_lines, lon_lines)
    
    # cycle through these lines and set the desired style
    for line in all_lines:
        line.set(linestyle='-', alpha=0.3, color='w')

draw_map(m)
# plot event
m.scatter(event_longitude, event_latitude,latlon=True,
    s=265,marker='*',facecolors='y',alpha=1)
print('event lon :')
print(event_longitude)
print('event lat :')
print(event_latitude)


for array in glob.glob(data_folder+'*_traveltime.npy'):
    sname = splitext(os.path.split(array)[1])[0][:-11:]
    print(sname)
    if not sname in sta_location:
        continue
    center_dist = sta_location[sname][0]
    center_azi = sta_location[sname][1]
    center_stla = sta_location[sname][2]
    center_stlo = sta_location[sname][3]

    T1 = np.load(array)[0]
    Azi1 = np.load(array)[1]
    T2 = np.load(array)[2]
    Azi2 = np.load(array)[3]
    T1_error = np.array([T1-np.load(array)[4], np.load(array)[5]-T1])
    Azi1_error = np.array([Azi1-np.load(array)[6], np.load(array)[7]-Azi1])
    T2_error = np.array([T2-np.load(array)[8], np.load(array)[9]-T2])
    Azi2_error = np.array([Azi2-np.load(array)[10], np.load(array)[11]-Azi2])

    if T1<24.5 and (T1_error>4).all() and (T1_error<10).all() \
        and (Azi1_error<15).all() and (Azi1_error>1).all() and Azi1>90:
        # plot station arrays
        m.scatter(center_stlo,center_stla,latlon=True,s=100,c='w',marker='^',alpha=1)

        lats = []
        lons= []
        for plot_distance in np.linspace(0, 120, 20):
            trace_location = Geodesic.WGS84.ArcDirect(center_stla,center_stlo,Azi1+180,plot_distance, outmask=1929)
            lats.append(trace_location['lat2'])
            lons.append(trace_location['lon2'])

            m.plot(lons, lats, latlon=True, linestyle='-', alpha=0.8, color='g')   
plt.show()
