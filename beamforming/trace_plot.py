#matplotlib inline
import numpy as np
import matplotlib.pyplot as plt
from mpl_toolkits.basemap import Basemap
from itertools import chain
from geographiclib.geodesic import Geodesic
import obspy
import os.path
from obspy import read
import glob

plt.figure(figsize=(8, 8))
m = Basemap(projection='ortho', resolution=None, lat_0 = 20, lon_0=-100)
m.bluemarble(scale=0.5)

dir='/raid3/zl382/Data/20161225/'
cat = obspy.read_events(dir+'CMTSOLUTION')
event_latitude = cat[0].origins[0].latitude
event_longitude = cat[0].origins[0].longitude

array_list = glob.glob(dir + 'fk_analysis/*')

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


for array in array_list:
    array_name = os.path.split(array)[1]
    test = read(array+'/'+array_name+'*PICKLE',format='PICKLE')
    if test[0].stats['dist']< 130 and test[0].stats['dist']> 120 and test[0].stats['az']<= 330:
        print('######## This is array: ' + array+' ###############')
        baz = float(str(np.load(array+'/baz.npy')))
        print('baz: ')
        print(baz)
        array_stla = np.load(array+'/stla.npy')
        array_stlo = np.load(array+'/stlo.npy')
        # plot station arrays
        m.scatter(array_stlo,array_stla,latlon=True,
            s=100,c='w',marker='^',alpha=1)

        lats = []
        lons= []
        for plot_distance in np.linspace(0, 130, 20):
            trace_location = Geodesic.WGS84.ArcDirect(array_stla,array_stlo,baz,plot_distance, outmask=1929)
            lats.append(trace_location['lat2'])
            lons.append(trace_location['lon2'])

        m.plot(lons, lats, latlon=True, 
            linestyle='-', alpha=0.9, color='g')

plt.show()