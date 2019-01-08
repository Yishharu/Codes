#
import sys
sys.path.append('/raid2/sc845/Python/lib/python/mpl_toolkits/')
sys.path.append('/raid2/sc845/Python/lib/python/')


sys.path.append('/raid2/sc845/Tomographic_models/LMClust/')
import LMClust_g6_ryb
sys.path.append('/raid2/sc845/Tomographic_models/SEMUCB_WM1/UCB_a3d_dist.SEMUCB-WM1.r20151019/')

sys.path.append('/raid2/sc845/Tomographic_models/')
import basemap_circle

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



LMC=LMClust_g6_ryb.LMClust()
LMC.read('/raid2/sc845/Tomographic_models/LMClust/','clustgr.txt')
RGB_light =LinearSegmentedColormap.from_list('rgbmap', LMC.colors/2.+0.5,N=len(LMC.colors))



event='20100320'#sys.argv[1]


piercedepth=2800.

dir=  '/raid3/zl382/Data/'+event+'/'  
seislist=glob.glob(dir+'/*PICKLE') 


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

azmin=300.
azmax=340.
for s in range(len(seislist)):
# try:
   print(s,seislist[s])
   seis= read(seislist[s],format='PICKLE')
   if s==0:
       elat=seis[0].stats['evla']
       elon=seis[0].stats['evlo']

   if seis[0].stats['dist']>100. and seis[0].stats['az']>azmin and  seis[0].stats['az']< azmax :
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


# except:
#     pass


slon=[slon[x]+360. if slon[x]<0 else slon[x]  for x in range(len(slon))]
latmin= -0#np.min((elat,np.min(slat)))-10.
latmax= -0#np.max((elat,np.max(slat)))+30.
lonmin= -98#np.min((elon,np.min(slon)))-35.+360.
lonmax= -98#np.max((elon,np.max(slon)))+15.+360.
print(latmin,latmax,lonmax,lonmin)

m = Basemap(projection='ortho',lat_0=np.mean((latmin,latmax)),lon_0=np.mean((lonmin,lonmax)),resolution='i')
#m = Basemap(llcrnrlon=lonmin,llcrnrlat=latmin,urcrnrlon=lonmax,urcrnrlat=latmax#,
#                resolution='i',projection='merc',lon_0=27.,lat_0=46.7)
clip_path = m.drawmapboundary()


#m.contour(x,y,layer,cmap=RGB_light,linewidth=0,rasterized=True)   

tmp = np.loadtxt('/raid2/sc845/Tomographic_models/SEMUCB_WM1/UCB_a3d_dist.SEMUCB-WM1.r20151019/SEMUCB_WM1_2800km.dat')
lon = tmp[:,1].reshape((181,361))
lat = tmp[:,2].reshape((181,361))
dvs = tmp[:,3].reshape((181,361))  
s = m.transform_scalar(dvs, lon[0,:], lat[:,0], 1000, 500)
im = m.imshow(s, cmap=plt.cm.seismic_r, clip_path=clip_path, vmin=-3, vmax=0)
cb = plt.colorbar()
cb.set_label('dlnVs (%)')
cb.set_clim(-3,3)
x,y=m(lon,lat)
#m.contour(x,y,dvs,levels= [-2],linewidth=0,rasterized=True)


#lon,lat,layer=LMC.get_slice(piercedepth)
lon,lat,layer=LMC.get_slice(piercedepth, whattoplot='votesslow')
x,y=m(lon.ravel(),lat.ravel())
x=x.reshape(np.shape(layer))
y=y.reshape(np.shape(layer))
minval=np.min(np.min(layer))
maxval=np.max(np.max(layer))+.1
#contours=np.round(np.linspace(minval,maxval,21),1)
#print(contours)
#m.pcolor(x,y,layer,cmap=RGB_light,linewidth=0,rasterized=True)
#m.contour(x,y,layer,levels= [0.59,0.79,0.99],linewidth=0,rasterized=True)

#m.shadedrelief()
m.drawcoastlines()
m.drawcountries()
#for i in range(0,len(slon),30):
#    m.drawgreatcircle(elon,elat,slon[i],slat[i],color='w')



slon=[slon[x]+360. if slon[x]<0 else slon[x]  for x in range(len(slon))]
x2,y2=m(slon,slat)
m.scatter(x2,y2,s=35,c='w',marker='^',alpha=1)

#for i in range(0,len(slon),30):
#    plt.text(x2[i],y2[i],str(azi[i]),color='w')
x2,y2=m(elon+360.,elat)
m.scatter(x2,y2,s=565,marker='*',facecolors='y',alpha=1)

pierce1lon=[pierce1lon[x]+360. if pierce1lon[x]<0 else pierce1lon[x] for x in range(len(pierce1lon))]
x2,y2=m(pierce1lon,pierce1lat)
#m.scatter(x2,y2,s=25,c='g',marker='o',alpha=1)

azi=np.array(azi)
for x in range(len(azi)):
        m.scatter(x2[x],y2[x],s=25,c='g',marker='o',alpha=1,zorder=100)


pierce2lon=[pierce2lon[x]+360. if pierce2lon[x]<0 else pierce2lon[x] for x in range(len(pierce2lon))]
x2,y2=m(pierce2lon,pierce2lat)
#m.scatter(x2,y2,s=25,c='g',marker='o',alpha=1)
azi=np.array(azi)
for x in range(len(azi)):
        m.scatter(x2[x],y2[x],s=25,c='g',marker='o',alpha=1)

'''
listslow=[x for x in range(len(slat)) if (azi[x]>285. and azi[x]<292. and dist[x]<120.)]
print listslow
listslow=np.array(listslow)
print listslow
for i in listslow:
    print azi[i],dist[i]
    x2,y2=m(pierce2lon[i],pierce2lat[i])
    m.scatter(x2,y2,s=15,c='r',marker='o',alpha=1)


    x2,y2=m(pierce1lon[i],pierce1lat[i])
    m.scatter(x2,y2,s=15,c='r',marker='o',alpha=1)

    x2,y2=m(slon[i],slat[i])
    m.scatter(x2,y2,s=15,c='r',marker='^',alpha=1)
'''
radii=[500]
# Set number 1:
centerlon = 256-360
centerlat = -4
for radius in radii:
    basemap_circle.equi(m, centerlon, centerlat, radius,lw=3.,color='k')

plt.title('Pierce points at ' +str(piercedepth)+' km depth')
#plt.savefig('Plots/'+event+'/'+event+'_map_ULVZ47.png')

plt.show()
