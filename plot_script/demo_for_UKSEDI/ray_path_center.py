#
import sys
sys.path.append('/raid1/sc845/Python/lib/python/mpl_toolkits/')
sys.path.append('/raid1/sc845/Python/lib/python/')


sys.path.append('/raid1/sc845/Tomographic_models/LMClust/')
import LMClust_g6_ryb
sys.path.append('/raid1/sc845/Tomographic_models/SEMUCB_WM1/UCB_a3d_dist.SEMUCB-WM1.r20151019/')

sys.path.append('/raid1/sc845/Tomographic_models/')
import basemap_circle

import sys
import obspy
from obspy import read
from obspy.core import Stream
import obspy.signal
import matplotlib.pyplot as plt
import os.path
import glob
import numpy as np
import scipy
import mpl_toolkits
import mpl_toolkits.basemap
print(mpl_toolkits.basemap.__path__)
from mpl_toolkits.basemap import Basemap
from mpl_toolkits.basemap import addcyclic
import matplotlib.image as mpimg
import matplotlib.cm as cm
import subprocess
from matplotlib.colors import LinearSegmentedColormap
from geographiclib.geodesic import Geodesic

plt.figure(figsize=(9, 9))
piercedepth=2800.

LMC=LMClust_g6_ryb.LMClust()
LMC.read('/raid1/sc845/Tomographic_models/LMClust/','clustgr.txt')
RGB_light =LinearSegmentedColormap.from_list('rgbmap', LMC.colors/2.+0.5,N=len(LMC.colors))
jet=cm.get_cmap('jet',12)
jet_vals=jet(np.arange(12))+0.4
for i in range(np.shape(jet_vals)[0]):
    for j in range(np.shape(jet_vals)[1]):
        if jet_vals[i,j]>1.:
            jet_vals[i,j]=1.

m = Basemap(projection='ortho',lat_0=19,lon_0=-166,resolution='i')
#m = Basemap(llcrnrlon=lonmin,llcrnrlat=latmin,urcrnrlon=lonmax,urcrnrlat=latmax#,
#                resolution='i',projection='merc',lon_0=27.,lat_0=46.7)
clip_path = m.drawmapboundary()


#m.contour(x,y,layer,cmap=RGB_light,linewidth=0,rasterized=True)   

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


#m.shadedrelief()
m.drawcoastlines()
m.drawcountries()

Location = 'Hawaii'
event='20100320'#sys.argv[1]

az_min, az_max = 38, 65
dist_min, dist_max = 100,110

dir=  '/raid1/zl382/Data/'+Location+'/'+event+'/'  
location_dict = np.load(dir+'STALOCATION.npy').item()
cat = obspy.read_events(dir+'CMTSOLUTION')
elat = cat[0].origins[0].latitude
elon = cat[0].origins[0].longitude
edepth = cat[0].origins[0].depth/1000


pierce1lon=[]
pierce1lat=[]
pierce2lon=[]
pierce2lat=[]
dt=[]



######      
for s, (s_name, (dist,azi,slat,slon,sazi)) in enumerate(location_dict.items()):

    if azi<az_min or azi>az_max \
    or dist<dist_min or dist>dist_max:
        continue

    # plot station 
    m.scatter(slon,slat,latlon=True,
        s=100,c='w',marker='^',alpha=1,edgecolors='k')

    test=['taup_pierce -mod prem -evt ' +str(elat)+ ' ' +str(elon) + ' -sta '+str(slat) + ' ' + str(slon)+
        ' -h '+str(edepth) +'  -ph Sdiff -Pierce '+str(piercedepth)]
    print(test)
    out=subprocess.check_output(test,shell=True,universal_newlines=True)
    t= out.split()
    if len(t)==0:
        test=['taup_pierce -mod prem -evt ' +str(elat)+ ' ' +str(elon) + ' -sta '+str(slat) + ' ' + str(slon)+
        ' -h '+str(edepth) +'  -ph S -Pierce '+str(piercedepth)]  
        out=subprocess.check_output(test,shell=True,universal_newlines=True)
        t= out.split()
        if len(t)==0:
            print(' Length of taup output is 0 !!')
            sys.exit()
    l=[x for x in range(len(t)) if t[x]==str(piercedepth)]
    if len(l) == 0:
        continue
    # Pierepoint Location
    pierce1lat = float(t[l[0]+2])
    pierce1lon = float(t[l[0]+3])
    pierce2lat = float(t[l[1]+2])
    pierce2lon = float(t[l[1]+3])

    event_station = Geodesic.WGS84.Inverse(elat,elon,slat,slon, outmask=1929)
    event_pierce1 = Geodesic.WGS84.Inverse(elat,elon,pierce1lat,pierce1lon, outmask=1929)
    event_pierce2 = Geodesic.WGS84.Inverse(elat,elon,pierce2lat,pierce2lon, outmask=1929)


    lats = []
    lons= []
    for plot_distance in np.linspace(event_pierce1['a12'], event_pierce2['a12'], 20):
        trace_location = Geodesic.WGS84.ArcDirect(elat,elon,event_station['azi1'],plot_distance, outmask=1929)
        lats.append(trace_location['lat2'])
        lons.append(trace_location['lon2'])

    if azi>61.5:
     m.plot(lons, lats, latlon=True, 
        linestyle='--', alpha=0.8, color='r', zorder=10)  
    m.plot(lons, lats, latlon=True, 
        linestyle='-', alpha=0.1, color='g')
    m.scatter(pierce1lon, pierce1lat,
        latlon=True,s=60,c='purple',marker='o',alpha=0.1)
    m.scatter(pierce2lon, pierce2lat,
        latlon=True,s=60,c='g',marker='o',alpha=0.1)
m.scatter(elon, elat,latlon=True,
    s=365,marker='*',facecolors='y',alpha=1,edgecolors='k')


################# new event ################################################################################################################
xpt,ypt = 5.69813e+06, 5.98138e+06  # 5.6767e+06, 5.7992e+06
lonpt, latpt = m(xpt,ypt,inverse=True)
# Plot the anomoly
radii=[833]
centerlon = lonpt
centerlat = latpt
for radius in radii:
    basemap_circle.equi(m, centerlon, centerlat, radius,lw=3.,color='k')

plt.scatter(xpt,ypt,marker='+',edgecolors='k',s=100)
# plt.show()
################# new event ################################################################################################################
Location = 'Hawaii'
event='20180910'#sys.argv[1]

az_min, az_max = 0,25
dist_min, dist_max = 100,110

dir=  '/raid1/zl382/Data/'+Location+'/'+event+'/'  
location_dict = np.load(dir+'STALOCATION.npy').item()
cat = obspy.read_events(dir+'CMTSOLUTION')
elat = cat[0].origins[0].latitude
elon = cat[0].origins[0].longitude
edepth = cat[0].origins[0].depth/1000

for s, (s_name, (dist,azi,slat,slon,sazi)) in enumerate(location_dict.items()):

    if azi<az_min or azi>az_max \
    or dist<dist_min or dist>dist_max:
        continue

    # plot station 
    m.scatter(slon,slat,latlon=True,
        s=100,c='w',marker='^',alpha=1,edgecolors='k')

    test=['taup_pierce -mod prem -evt ' +str(elat)+ ' ' +str(elon) + ' -sta '+str(slat) + ' ' + str(slon)+
        ' -h '+str(edepth) +'  -ph Sdiff -Pierce '+str(piercedepth)]
    print(test)
    out=subprocess.check_output(test,shell=True,universal_newlines=True)
    t= out.split()
    if len(t)==0:
        test=['taup_pierce -mod prem -evt ' +str(elat)+ ' ' +str(elon) + ' -sta '+str(slat) + ' ' + str(slon)+
        ' -h '+str(edepth) +'  -ph S -Pierce '+str(piercedepth)]  
        out=subprocess.check_output(test,shell=True,universal_newlines=True)
        t= out.split()
        if len(t)==0:
            print(' Length of taup output is 0 !!')
            sys.exit()
    l=[x for x in range(len(t)) if t[x]==str(piercedepth)]
    # Pierepoint Location
    pierce1lat = float(t[l[0]+2])
    pierce1lon = float(t[l[0]+3])
    pierce2lat = float(t[l[1]+2])
    pierce2lon = float(t[l[1]+3])

    event_station = Geodesic.WGS84.Inverse(elat,elon,slat,slon, outmask=1929)
    event_pierce1 = Geodesic.WGS84.Inverse(elat,elon,pierce1lat,pierce1lon, outmask=1929)
    event_pierce2 = Geodesic.WGS84.Inverse(elat,elon,pierce2lat,pierce2lon, outmask=1929)

    lats = []
    lons= []
    for plot_distance in np.linspace(event_pierce1['a12'], event_pierce2['a12'], 20):
        trace_location = Geodesic.WGS84.ArcDirect(elat,elon,event_station['azi1'],plot_distance, outmask=1929)
        lats.append(trace_location['lat2'])
        lons.append(trace_location['lon2'])

    if azi< 9.5 and azi>8.5:
     m.plot(lons, lats, latlon=True, 
        linestyle='--', alpha=0.8, color='r', zorder=10)      

    m.plot(lons, lats, latlon=True, 
        linestyle='-', alpha=0.1, color='g')
    m.scatter(pierce1lon, pierce1lat,
        latlon=True,s=60,c='purple',marker='o',alpha=0.1)
    m.scatter(pierce2lon, pierce2lat,
        latlon=True,s=60,c='g',marker='o',alpha=0.1)


m.scatter(elon, elat,latlon=True,
    s=365,marker='*',facecolors='y',alpha=1,edgecolors='k')

# Plot the possible location by the Sdiff constraint
# A_lat = 11
# A_lon = -180
# B_lat = 27
# B_lon = -144
# band_lats = []
# band_lons = []
# band_direction = Geodesic.WGS84.Inverse(A_lat,A_lon,B_lat,B_lon, outmask=1929)
# for plot_distance in np.linspace(0, band_direction['a12'], 20):
#     band_location = Geodesic.WGS84.ArcDirect(A_lat,A_lon,band_direction['azi1'],plot_distance, outmask=1929)
#     band_lats.append(band_location['lat2'])
#     band_lons.append(band_location['lon2'])
# m.plot(band_lons, band_lats, latlon=True, 
#     linestyle='-', alpha=0.8, color='g')


# plt.title('Pierce points at ' +str(piercedepth)+' km depth')
# plt.text(0.9,0.9,'ULVZ Location: \n Lon:%.1f ; Lat:%.1f' %(centerlon,centerlat))

#plt.savefig('Plots/'+event+'/'+event+'_map_ULVZ47.png')

plt.show()
