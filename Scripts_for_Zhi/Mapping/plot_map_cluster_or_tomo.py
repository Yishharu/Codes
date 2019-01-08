#
import sys
sys.path.append('LMClust_model_only/')
import LMClust_g6_ryb
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
from mpl_toolkits.basemap import Basemap, shiftgrid
from mpl_toolkits.basemap import addcyclic
import matplotlib.image as mpimg
import matplotlib.cm as cm
import subprocess
from matplotlib.colors import LinearSegmentedColormap

event=sys.argv[1]
model_to_plot = 'tomo'  # 'clust' or 'tomo'


if model_to_plot == 'clust':
   # Load clustering map
   LMC=LMClust_g6_ryb.LMClust()
   LMC.read('LMClust_model_only/')
   # make light coloramp
   RGB_light =LinearSegmentedColormap.from_list('rgbmap', LMC.colors/2.+0.5,N=len(LMC.colors))


# Azimuth limits
azmin=180.
azmax=270.

# Depths to collect piercepoints from (these need to be computed first with add_pierce_points.py)
piercedepth=2800.




# Loop through data and collect values to plot
dir='Data/'+event+'/'
seislist=glob.glob(dir+'/*PICKLE') 



slat=[]
slon=[]
azi=[]
dist=[]
pierce1lon=[]
pierce1lat=[]
pierce2lon=[]
pierce2lat=[]
piercesks1lon=[]
piercesks1lat=[]
piercesks2lon=[]
piercesks2lat=[]

dt=[]

for s in range(len(seislist)):
# try:
   print(s,seislist[s])
   seis= read(seislist[s],format='PICKLE')
   if s==0:
       elat=seis[0].stats['evla']
       elon=seis[0].stats['evlo']

   if seis[0].stats['dist']>110. and seis[0].stats['az']>azmin and  seis[0].stats['az']< azmax :
       slat.append(seis[0].stats['stla'])
       slon.append(seis[0].stats['stlo'])
       azi.append(seis[0].stats['az'])
       dist.append(seis[0].stats['dist'])
       depth=seis[0].stats['evdp']
       line=[]

       if 'Sdiff' in seis[0].stats.piercepoints:
           pierce = seis[0].stats.piercepoints['Sdiff']
           line = [pierce[x] for x in range(len(pierce)) if pierce[x][0]==piercedepth][0]
       elif 'S' in seis[0].stats.piercepoints:
           pierce = seis[0].stats.piercepoints['S']
           line = [pierce[x] for x in range(len(pierce)) if pierce[x][0]==piercedepth][0]
       print(line)
       if len(line)>0:
           print(line[1])
           pierce1lat.append(line[1])
           pierce1lon.append(line[2]) 
           pierce2lat.append(line[3])
           pierce2lon.append(line[4])
       pierce = seis[0].stats.piercepoints['SKS']
       line = [pierce[x] for x in range(len(pierce)) if pierce[x][0]==piercedepth][0]
       piercesks1lat.append(line[1])
       piercesks1lon.append(line[2]) 
       piercesks2lat.append(line[3])
       piercesks2lon.append(line[4])

# except:
#     pass


# Set ranges of map (this doesn't always work terribly well, and might have to be manually adapted)
latmin= np.min((elat,np.min(slat)))-30.
latmax= np.max((elat,np.max(slat)))+10.
lonmin= np.min((elon,np.min(slon)))-25.
lonmax= np.max((elon,np.max(slon)))+25.
'''
if lonmin< 0:
    lonmin=lonmin+360.
if lonmax<0:
    lonmax=lonmax+360.
'''
print('map bounds', latmin,latmax,lonmin,lonmax)


# Start map projection
#m = Basemap(projection='ortho',lat_0=np.mean((latmin,latmax)),lon_0=np.mean((lonmin,lonmax)),resolution='i')
m = Basemap(llcrnrlon=lonmin,llcrnrlat=latmin,urcrnrlon=lonmax,urcrnrlat=latmax,
                resolution='i',projection='merc',lon_0=np.mean((lonmin,lonmax)),lat_0=np.mean((latmin,latmax)))
clip_path = m.drawmapboundary()


if model_to_plot=='clust':
   # Cluster model
   lon,lat,layer=LMC.get_slice(piercedepth)
   x,y=m(lon.ravel(),lat.ravel())
   x=x.reshape(np.shape(layer))
   y=y.reshape(np.shape(layer))
   minval=np.min(np.min(layer))
   maxval=np.max(np.max(layer))+.1
   m.pcolor(x,y,layer,cmap=RGB_light,linewidth=0,rasterized=True)
   # plot again with 360 degree shift
   x,y=m(lon.ravel()-360.,lat.ravel())
   x=x.reshape(np.shape(layer))
   y=y.reshape(np.shape(layer))
   minval=np.min(np.min(layer))
   maxval=np.max(np.max(layer))+.1
   m.pcolor(x,y,layer,cmap=RGB_light,linewidth=0,rasterized=True)

if model_to_plot == 'tomo':
   tmp = np.loadtxt('/raid2/sc845/Tomographic_models/SEMUCB_WM1/UCB_a3d_dist.SEMUCB-WM1.r20151019/SEMUCB_WM1_2800km.dat')
   dvs = tmp[:,3].reshape((181,361))
   dvs,lon = shiftgrid(0., dvs,np.unique(tmp[:,1])) # change to -180 to 180 instead of 0 to 360
   lat = np.unique(tmp[:,2])
   lon,lat= np.meshgrid(lon,lat)
   print(lon[0,:])
   s = m.transform_scalar(dvs, lon[0,:], lat[:,0], 1000, 500)

   im = m.imshow(s, cmap=plt.cm.seismic_r, clip_path=clip_path, vmin=-4, vmax=4)
   cb = plt.colorbar()
   cb.set_label('dlnVs (%)')
   cb.set_clim(-3,3)


# Draw coastlines
#m.shadedrelief()
m.drawcoastlines()
m.drawcountries()
#for i in range(0,len(slon),30):
#    m.drawgreatcircle(elon,elat,slon[i],slat[i],color='w')


# Draw stations
slon=[slon[x]+360. if slon[x]<0 else slon[x]  for x in range(len(slon))]
x2,y2=m(slon,slat)
m.scatter(x2,y2,s=35,c='w',marker='^',alpha=1)



# Draw event
x2,y2=m(elon,elat)
m.scatter(x2,y2,s=500,marker='*',facecolors='y',alpha=1)


# Draw downgoing pierce points Sdiff
pierce1lon=[pierce1lon[x]+360. if pierce1lon[x]<0 else pierce1lon[x] for x in range(len(pierce1lon))]
x2,y2=m(pierce1lon,pierce1lat)
m.scatter(x2,y2,s=35,c='g',marker='o',alpha=1)
'''
azi=np.array(azi)
for x in range(len(x2)):
        m.scatter(x2[x],y2[x],s=25,c='g',marker='o',alpha=1)
'''

# Draw upgoing pierce points Sdiff
pierce2lon=[pierce2lon[x]+360. if pierce2lon[x]<0 else pierce2lon[x] for x in range(len(pierce2lon))]
x2,y2=m(pierce2lon,pierce2lat)
m.scatter(x2,y2,s=35,c='g',marker='o',alpha=1)


# Draw downgoing pierce points SKS
piercesks1lon=[piercesks1lon[x]+360. if piercesks1lon[x]<0 else piercesks1lon[x] for x in range(len(piercesks1lon))]
x2,y2=m(piercesks1lon,piercesks1lat)
m.scatter(x2,y2,s=35,c='c',marker='o',alpha=1)



# Draw upgoing pierce points SKS
piercesk2lon=[piercesks2lon[x]+360. if piercesks2lon[x]<0 else piercesks2lon[x] for x in range(len(piercesks2lon))]
x2,y2=m(piercesks2lon,piercesks2lat)
m.scatter(x2,y2,s=35,c='c',marker='o',alpha=1)



plt.title('Pierce points at ' +str(piercedepth)+' km depth')

plt.savefig('Plots/'+event+'/'+event+'_map_'+model_to_plot+'.png')

plt.show()
