#/usr/bin/python3
# Usage: python3 plot_map.py [event] [phase]
# Example: python3 plot_map.py 20100320 Sdiff

import sys
sys.path.append('/raid2/sc845/Python/lib/python/mpl_toolkits/')
sys.path.append('/raid2/sc845/Python/lib/python/')
sys.path.append('/raid2/sc845/Tomographic_models/LMClust/')
import LMClust_g6_Vp_ryb
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
from mpl_toolkits.basemap import Basemap
from mpl_toolkits.basemap import addcyclic
import matplotlib.image as mpimg
import matplotlib.cm as cm
import subprocess
from matplotlib.colors import LinearSegmentedColormap

LMC=LMClust_g6_Vp_ryb.LMClust()
LMC.read('/raid2/sc845/Tomographic_models/LMClust/','clustgr.txt')

event=sys.argv[1]
phase=[]
for i in range(2,len(sys.argv)):
    phase.append(sys.argv[i])

piercedepth=2600.

dir='/raid3/zl382/Data/'+event+'/'
seislist = sorted(glob.glob(dir+'/*PICKLE')) 


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

for s in range(0,len(seislist),1):
    
# try:
   print(s,seislist[s])
   seis= read(seislist[s],format='PICKLE')
   if s==0:
       elat=seis[0].stats['evla']
       elon=seis[0].stats['evlo']

   if seis[0].stats['dist']>90. and seis[0].stats['dist']<110 and seis[0].stats['az']<30:
       slat.append(seis[0].stats['stla'])
       slon.append(seis[0].stats['stlo'])
       azi.append(seis[0].stats['az'])
       dist.append(seis[0].stats['dist'])
       depth=seis[0].stats['evdp']
       test=['taup_pierce -mod prem -evt ' +str(elat)+ ' ' +str(elon) + ' -sta '+str(slat[-1]) + ' ' + str(slon[-1])+ ' -h '+str(depth) +'  -ph Sdiff -Pierce '+str(piercedepth)]
       print(test)
       out=subprocess.check_output(test,shell=True,universal_newlines=True)

       t= out.split()
 
       if len(t)>0:
           l=[x for x in range(len(t)) if t[x]==str(piercedepth)]
           pierce1lat.append(float(t[l[0]+2]))
           pierce1lon.append(float(t[l[0]+3])) 
           pierce2lat.append(float(t[l[1]+2]))
           pierce2lon.append(float(t[l[1]+3]))
       else:
           test=['taup_pierce -mod prem -evt ' +str(elat)+ ' ' +str(elon) + ' -sta '+str(slat[-1]) + ' ' + str(slon[-1])+ ' -h '+str(depth) +'  -ph S -Pierce '+str(piercedepth)]  
           out=subprocess.check_output(test,shell=True,universal_newlines=True)
           t= out.split()
           if len(t)>0:
               l=[x for x in range(len(t)) if t[x]==str(piercedepth)]
               pierce1lat.append(float(t[l[0]+2]))
               pierce1lon.append(float(t[l[0]+3])) 
               pierce2lat.append(float(t[l[1]+2]))
               pierce2lon.append(float(t[l[1]+3]))
           else:
               pierce1lat.append(float(0.))
               pierce1lon.append(float(0.)) 
               pierce2lat.append(float(0.))
               pierce2lon.append(float(0.))

# except:
#     pass

latmin= np.min((elat,np.min(slat)))-10.
latmax= np.max((elat,np.max(slat)))+30.
lonmax= np.min((elon,np.min(slon)))+35.+360
lonmin= np.max((elon,np.max(slon)))-15.
print(latmin,latmax,lonmax,lonmin)

m = Basemap(projection='ortho',lat_0=np.mean((latmin,latmax)),lon_0=-150,resolution='i')
#m = Basemap(llcrnrlon=lonmin,llcrnrlat=latmin,urcrnrlon=lonmax,urcrnrlat=latmax,
#                resolution='i',projection='merc',lon_0=27.,lat_0=46.7)
clip_path = m.drawmapboundary()


lon,lat,layer=LMC.get_slice(2700.)
x,y=m(lon.ravel(),lat.ravel())
x=x.reshape(np.shape(layer))
y=y.reshape(np.shape(layer))
minval=np.min(np.min(layer))
maxval=np.max(np.max(layer))+.1
#contours=np.round(np.linspace(minval,maxval,21),1)
#print(contours)
m.pcolor(x,y,layer,cmap=LMC.rgb_map,linewidth=0,rasterized=True)


#m.shadedrelief()
m.drawcoastlines()
m.drawcountries()
#for i in range(0,len(slon),30):
#    m.drawgreatcircle(elon,elat,slon[i],slat[i],color='w')


# plot stations
slon=[slon[x]+360. if slon[x]<0 else slon[x]  for x in range(len(slon))]
x2,y2=m(slon,slat)
m.scatter(x2,y2,s=35,c='w',marker='^',alpha=1)

#for i in range(0,len(slon),30):
#    plt.text(x2[i],y2[i],str(azi[i]),color='w')
# plot event
x2,y2=m(elon,elat)
m.scatter(x2,y2,s=265,marker='*',facecolors='y',alpha=1)

# plot pierce points
pierce1lon=[pierce1lon[x]+360. if pierce1lon[x]<0 else pierce1lon[x] for x in range(len(pierce1lon))]
x2,y2=m(pierce1lon,pierce1lat)
m.scatter(x2,y2,s=25,c='m',marker='o',alpha=1)

pierce2lon=[pierce2lon[x]+360. if pierce2lon[x]<0 else pierce2lon[x] for x in range(len(pierce2lon))]
x2,y2=m(pierce2lon,pierce2lat)
m.scatter(x2,y2,s=25,c='g',marker='o',alpha=1)

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



plt.title('Event ' + str(event) + '\nPierce points at ' + str(piercedepth) + ' km depth')
plt.savefig('/home/zl382/Pictures/Pierce_Point_Maps/'+event+'_map_Vpcluster.png')

plt.show()
