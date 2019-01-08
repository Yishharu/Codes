#
import sys
sys.path.append('/raid2/sc845/Python/lib/python/mpl_toolkits/')
sys.path.append('/raid2/sc845/Python/lib/python/')
sys.path.append('/raid2/sc845/Tomographic_models/LMClust/')
import LMClust_g6_ryb
sys.path.append('/raid2/sc845/Tomographic_models/SEMUCB_WM1/UCB_a3d_dist.SEMUCB-WM1.r20151019/')
sys.path.append('/raid2/sc845/Tomographic_models/')
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

LMC=LMClust_g6_ryb.LMClust()
LMC.read('/raid2/sc845/Tomographic_models/LMClust/','clustgr.txt')
RGB_light =LinearSegmentedColormap.from_list('rgbmap', LMC.colors/2.+0.5,N=len(LMC.colors))
##############################################
event = '20100320'

if_model = False
model = 'ULVZ63'

az_min=40
az_max=60

dist_min=100
dist_max=110

if_postcursor_cut = True
# Output Pictures Path
if if_model:
    if if_postcursor_cut:
      save_picture_path = '/home/zl382/Pictures/'+event+model+'pc_fk_analysis/'
    else:
      save_picture_path = '/home/zl382/Pictures/'+event+model+'_fk_analysis/'
else:
    if if_postcursor_cut:
      save_picture_path = '/home/zl382/Pictures/high_freq_'+event+'pc_fk_analysis/'
    else:
      save_picture_path = '/home/zl382/Pictures/'+event+'_fk_analysis/' 

print('loading the data from %s' %save_picture_path)
piercedepth=2800.
dir='/raid3/zl382/Data/'+event+'/'
cat = obspy.read_events(dir+'CMTSOLUTION')
event_latitude = cat[0].origins[0].latitude
event_longitude = cat[0].origins[0].longitude

array_list = glob.glob(dir + 'high_freq_fk_analysis/*')
array = array_list[0]
array_name = os.path.split(array)[1]

seislist=glob.glob(dir+'/*PICKLE') 

radii=[833]
# Set number 1:
centerlon = -166
centerlat = 19

m = Basemap(projection='ortho',lat_0=centerlat,lon_0=-90,resolution='i')


jet=cm.get_cmap('jet',12)
jet_vals=jet(np.arange(12))+0.4
for i in range(np.shape(jet_vals)[0]):
    for j in range(np.shape(jet_vals)[1]):
        if jet_vals[i,j]>1.:
            jet_vals[i,j]=1.

slat=[]
slon=[]
azi=[]
dist=[]
pierce1lon=[]
pierce1lat=[]
pierce2lon=[]
pierce2lat=[]
dt=[]

clip_path = m.drawmapboundary()
tmp = np.loadtxt('/raid2/sc845/Tomographic_models/SEMUCB_WM1/UCB_a3d_dist.SEMUCB-WM1.r20151019/SEMUCB_WM1_2800km.dat')
lon = tmp[:,1].reshape((181,361))
lat = tmp[:,2].reshape((181,361))
dvs = tmp[:,3].reshape((181,361))  
s = m.transform_scalar(dvs, lon[0,:], lat[:,0], 1000, 500)
im = m.imshow(s, cmap=plt.cm.seismic_r, clip_path=clip_path, vmin=-3, vmax=0)
cb = plt.colorbar()
cb.set_label('dlnVs (%)')
cb.set_clim(-5,5)
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
################# Plot ray trace ##############
for array in array_list:
    array_name = os.path.split(array)[1]
    test = read(array+'/'+array_name+'*PICKLE',format='PICKLE')
    if test[0].stats['az']<az_min or test[0].stats['az']>az_max \
    or test[0].stats['dist']< dist_min or test[0].stats['dist']> dist_max:
        continue
        print('%s not suitable' %array_name)

    if os.path.exists(save_picture_path+array_name+'_baz.npy'):# and test[0].stats['az']<= 330:
        print('######## This is array: ' + array+' ###############')
        baz = float(str(np.load(save_picture_path+array_name+'_baz.npy')))
        slowness = float(str(np.load(save_picture_path+array_name+'_slowness.npy')))
        print('Load Data from: '+save_picture_path+array_name+'_baz.npy'+' !!')
        print('baz: ')
        print(baz)
        print('slowness: ')
        print(slowness)        
        if baz<10:
            continue
        array_stla = np.load(array+'/stla.npy')
        array_stlo = np.load(array+'/stlo.npy')
        # plot station arrays
        m.scatter(array_stlo,array_stla,latlon=True,
            s=100,c='w',marker='^',alpha=1)

        lats = []
        lons= []
        for plot_distance in np.linspace(0, 120, 20):
            trace_location = Geodesic.WGS84.ArcDirect(array_stla,array_stlo,baz,plot_distance, outmask=1929)
            lats.append(trace_location['lat2'])
            lons.append(trace_location['lon2'])

        if slowness < 0.071 or slowness > 0.079:
            print('slowness at the boundary')
            # m.plot(lons, lats, latlon=True, 
            #     linestyle='-', alpha=0.9, color='r')
        else:
            m.plot(lons, lats, latlon=True, 
                linestyle='-', alpha=0.7, color='g') 



m.scatter(event_longitude, event_latitude,latlon=True,
    s=265,marker='*',facecolors='y',alpha=1,zorder=100)
# Plot the anomoly  (Hawaii)
radii=[833]
centerlon = -166
centerlat = 19
# for radius in radii:
#     basemap_circle.equi(m, centerlon, centerlat, radius,lw=3.,color='k')
# centerlon = -117
# centerlat = 26
for radius in radii:
    basemap_circle.equi(m, centerlon, centerlat, radius,lw=3.,color='k')



if if_model:
    plt.title('Model: '+model+'\nPierce points at ' +str(piercedepth)+' km depth')
else:
    plt.title('Real Data'+'\nPierce points at ' +str(piercedepth)+' km depth')    
#plt.savefig('Plots/'+event+'/'+event+'_map_ULVZ47.png')

plt.show()