import glob
import os
from os.path import splitext
import sys
sys.path.append('/raid1/sc845/Python/lib/python/mpl_toolkits/')
sys.path.append('/raid1/sc845/Python/lib/python/')
sys.path.append('/raid1/sc845/Tomographic_models/LMClust/')
import LMClust_g6_ryb
sys.path.append('/raid1/sc845/Tomographic_models/SEMUCB_WM1/UCB_a3d_dist.SEMUCB-WM1.r20151019/')
sys.path.append('/raid1/sc845/Tomographic_models/')

import numpy as np
import scipy
from scipy import stats
import matplotlib.pyplot as plt

import basemap_circle
import mpl_toolkits
import mpl_toolkits.basemap
print(mpl_toolkits.basemap.__path__)
from itertools import chain
from mpl_toolkits.basemap import Basemap
from mpl_toolkits.basemap import addcyclic
import matplotlib.image as mpimg
import matplotlib.cm as cm
import subprocess
from matplotlib.colors import LinearSegmentedColormap
from geographiclib.geodesic import Geodesic
import obspy
from obspy import read

Location = 'Hawaii'
Event = '20100320'

piercedepth=2800.

data_folder = '/raid1/zl382/Pictures/BeamForming/traveltime_1-5s/'

###################### Edit Before This Line ######################################
dir='/raid1/zl382/Data/'+Location+'/'+Event+'/'
sta_location = np.load(dir+'STALOCATION.npy').item()
cat = obspy.read_events(dir+'CMTSOLUTION')
event_latitude = cat[0].origins[0].latitude
event_longitude = cat[0].origins[0].longitude

LMC=LMClust_g6_ryb.LMClust()
LMC.read('/raid1/sc845/Tomographic_models/LMClust/','clustgr.txt')
RGB_light =LinearSegmentedColormap.from_list('rgbmap', LMC.colors/2.+0.5,N=len(LMC.colors))

plt.figure(figsize=(9, 9))
radii=[833]
# Set number 1:
centerlon = -166
centerlat = 19

m = Basemap(projection='ortho',lat_0=centerlat,lon_0=centerlon,resolution='i')


jet=cm.get_cmap('jet',12)
jet_vals=jet(np.arange(12))+0.4
for i in range(np.shape(jet_vals)[0]):
    for j in range(np.shape(jet_vals)[1]):
        if jet_vals[i,j]>1.:
            jet_vals[i,j]=1.

clip_path = m.drawmapboundary()
tmp = np.loadtxt('/raid1/sc845/Tomographic_models/SEMUCB_WM1/UCB_a3d_dist.SEMUCB-WM1.r20151019/SEMUCB_WM1_2800km.dat')
lon = tmp[:,1].reshape((181,361))
lat = tmp[:,2].reshape((181,361))
dvs = tmp[:,3].reshape((181,361))  
s = m.transform_scalar(dvs, lon[0,:], lat[:,0], 1000, 500)
im = m.imshow(s, cmap=plt.cm.seismic_r, clip_path=clip_path, vmin=-3, vmax=0)
cb = plt.colorbar()
cb.set_label('dlnVs (%)')
cb.set_clim(-15,15)
cb.remove()
x,y=m(lon,lat)
lon,lat,layer=LMC.get_slice(piercedepth, whattoplot='votesslow')
x,y=m(lon.ravel(),lat.ravel())
x=x.reshape(np.shape(layer))
y=y.reshape(np.shape(layer))
minval=np.min(np.min(layer))
maxval=np.max(np.max(layer))+.1
m.drawcoastlines()
m.drawcountries()


# plot event
m.scatter(event_longitude, event_latitude,latlon=True,
    s=265,marker='*',facecolors='y',alpha=1,zorder=100,edgecolors='k')
print('event lon :')
print(event_longitude)
print('event lat :')
print(event_latitude)

count = 0
for array in glob.glob(data_folder+'*_traveltime.npy'):
    count += 1
    # if not count %5 == 0:
    #     continue
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

    # if T1<24.5 and (T1_error>4).all() and (T1_error<10).all() \
    #     and (Azi1_error<15).all() and (Azi1_error>1).all(): # 10-20s main arrival

    # if (T2_error<10).all() \
    # and (T2_error>4).all() \
    # and T2>25.5 and Azi2>60 and Azi2<140 \
    # and (Azi2_error<12).all() and  (Azi2_error>5).all(): # 10-20s post cursor

    # if (T1_error<10).all() and  (T1_error>0.5).all() \
    #     and (Azi1_error<5).all() and  (Azi1_error>1).all() and Azi1>75 and Azi1<115:     # 1-5s main arrival
    #     print(Azi1)


    if (T2_error<10).all() and  (T2_error>0.5).all() \
        and (Azi2_error<5).all() and  (Azi2_error>1).all() and Azi2>75 and Azi2<115:        # 1-5s postcursor
        print(Azi2)
        # plot station arrays
        m.scatter(center_stlo,center_stla,latlon=True,s=100,c='w',marker='^',alpha=0.8,edgecolors='k')

        lats = []
        lons= []
        for plot_distance in np.linspace(0, 120, 20):
            trace_location = Geodesic.WGS84.ArcDirect(center_stla,center_stlo,Azi2+180,plot_distance, outmask=1929)
            lats.append(trace_location['lat2'])
            lons.append(trace_location['lon2'])

            m.plot(lons, lats, latlon=True, linestyle='-', alpha=0.005, color='purple')   
for radius in radii:
    basemap_circle.equi(m, centerlon, centerlat, radius,lw=3.,color='grey')


radii=[833]
# Set number 1:
centerlon = -172.3
centerlat = 15.4
for radius in radii:
    basemap_circle.equi(m, centerlon, centerlat, radius,lw=3.,color='k')
plt.show()
