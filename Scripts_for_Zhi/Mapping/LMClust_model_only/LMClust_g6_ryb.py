# -*- coding: iso-8859-1 -*-
import sys
#sys.path.append('/raid2/sc845/Python/lib/python/mpl_toolkits/')
#sys.path.append('/raid2/sc845/Python/lib/python/')
sys.path.append('/raid2/sc845/Python/geographiclib-1.34/')
from geographiclib.geodesic import Geodesic as geo
import numpy as np
import matplotlib
#matplotlib.use('GTK') 
#matplotlib=reload(matplotlib)
import matplotlib.pylab as plt
from mpl_toolkits.basemap import Basemap,shiftgrid
import subprocess
import time
import scipy.ndimage
import colorsys
import scipy.io
import math
from matplotlib.colors import LinearSegmentedColormap
from matplotlib.transforms import Affine2D
import mpl_toolkits.axisartist.floating_axes as floating_axes
import numpy as np
import mpl_toolkits.axisartist.angle_helper as angle_helper
from matplotlib.projections import PolarAxes
from mpl_toolkits.axisartist.grid_finder import (FixedLocator, MaxNLocator,DictFormatter)
import matplotlib.pyplot as plt
#########################################################################
#- define ses3d model class
#########################################################################


def _cubic(t, a, b):
    weight = t * t * (3 - 2*t)
    return a + weight * (b - a)

def ryb_to_rgb(r, y, b): # Assumption: r, y, b in [0, 1]
    ### Stolen from stackoverflow: http://stackoverflow.com/questions/14095849/calculating-the-analogous-color-with-python
    # red
    x0, x1 = _cubic(b, 1.0, 0.163), _cubic(b, 1.0, 0.0)
    x2, x3 = _cubic(b, 1.0, 0.5), _cubic(b, 1.0, 0.2)
    y0, y1 = _cubic(y, x0, x1), _cubic(y, x2, x3)
    red = _cubic(r, y0, y1)

    # green
    x0, x1 = _cubic(b, 1.0, 0.373), _cubic(b, 1.0, 0.66)
    x2, x3 = _cubic(b, 0., 0.), _cubic(b, 0.5, 0.094)
    y0, y1 = _cubic(y, x0, x1), _cubic(y, x2, x3)
    green = _cubic(r, y0, y1)

    # blue
    x0, x1 = _cubic(b, 1.0, 0.6), _cubic(b, 0.0, 0.2)
    x2, x3 = _cubic(b, 0.0, 0.5), _cubic(b, 0.0, 0.0)
    y0, y1 = _cubic(y, x0, x1), _cubic(y, x2, x3)
    blue = _cubic(r, y0, y1)

    return (red, green, blue)

def haversine(loc1, locs2):#(lat1, long1), (lats2, longs2)):
    """
    Calculate the distance between two points on earth in m
    """
    d=[]
    lat1=loc1[0]
    long1=loc1[1]

    try:
        lats2=locs2[:,0]
        longs2=locs2[:,1]
    except:
        lats2=locs2[0]
        longs2=locs2[1]      
    
    for i in range(len(lats2)):
        lat2=lats2[i]
        long2=longs2[i]
        earth_radius = 6371.e3  # m
        dLat = math.radians(lat2 - lat1)
        dLong = math.radians(long2 - long1)

        a = (math.sin(dLat / 2) ** 2 +
             math.cos(math.radians(lat1)) * math.cos(math.radians(lat2)) * math.sin(dLong / 2) ** 2)
        c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a))
        d.append(earth_radius * c)

    return np.array(d)


def godown(v1,rad1,v2,rad2,slow):
    # calculates time (s) and radial distance (rad) for one segment
    dr=rad1-rad2
    v_av=(v1+v2)/2.
    slow=slow*(180./(np.pi))#!! Slowness is given in sec/deg -- convert to sec/rad
    dtheta=slow*dr/rad1*1/np.sqrt((rad1/v_av)**2-slow**2)
    dtime=dr/rad1*(rad1/v_av)**2/np.sqrt((rad1/v_av)**2-slow**2)
    return dtheta,dtime

class LMClust(object):
  """ class for reading, writing, plotting and manipulating and ses3d model
  """

  def __init__(self):
    """ initiate the ses3d_model class
    initiate list of submodels and read rotation_parameters.txt
    """

    self.lat_min=0.0
    self.lat_max=0.0
    self.lon_min=0.0
    self.lon_max=0.0
    self.lat_centre=0.0
    self.lon_centre=0.0


    self.lat=[]
    self.lon=[]
    self.depth=[]
    self.clust=[]




  #########################################################################
  #- read a 3D model
  #########################################################################

  def read(self,directory,verbose=False, write=False):
    """ read an ses3d model from a file

    read(self,directory,filename,verbose=False):
    """

    #- read block files ====================================================

    #mat = scipy.io.loadmat('/raid2/sc845/Side_projects/Clustering/Allmodels/ModelsForSanne_L12_5Models.mat')
    #lats=mat['latgrid']
    #lons=mat['longrid']
    #map_indx=mat['map_indx']-1 # minus one for python indexing
    #lats=np.array(lats)
    #lons=np.array(lons)
    #lon=np.sort(np.array(list(set(lons.ravel()))))
    print('reading in model, this happens to take a while')
    mat = scipy.io.loadmat(directory+'finer_grid.mat')

    lon=np.arange(0,360.01,1.)
    lat=np.arange(-90.,90.01,1.)

    lats,lons=np.meshgrid(lat,lon)
    map_indx=mat['map_indx']
    long6=mat['lonsg6']
    latg6=mat['latsg6']


    models=['S362AN-L18','S40RTS-L18','SAVANI-L18','SEMUCBWM1-L18','SPani-L18']#'GyPSuM-L18']
    #models=['SPani_Tesoniero-L18','SAVANI-L18','S40RTS-L18','SandP_Raj-L18','SEMUCBWM1-L18']

    for mod in models:
        mat = scipy.io.loadmat(directory+'Clusters/Clustersg6'+mod+'.mat')
        clst=mat['clsttmp'][0][0]

        deps=np.squeeze(clst['deps'])
        oneclst=np.squeeze(clst['indxs'])
        if not 'clust' in locals():
            clust=np.zeros((len(oneclst),4))
        clust[np.where(oneclst==3),0]=clust[np.where(oneclst==3),0]+0.2
        clust[np.where(oneclst==2),1]=clust[np.where(oneclst==2),1]+0.2
        clust[np.where(oneclst==1),2]=clust[np.where(oneclst==1),2]+0.2
    saveclust=clust
    # normalize colors
    maxclusts=np.max(clust,axis=1)
    clust[:,3]=np.ones_like(maxclusts)
    
    #make colorbar
    clustforcolor=[tuple(row)for row in clust]
    clustforcolor=np.array(clustforcolor)
    b = np.ascontiguousarray(clustforcolor).view(np.dtype((np.void, clustforcolor.dtype.itemsize * clustforcolor.shape[1])))
    _, idx = np.unique(b, return_index=True)
    clustcolor=clustforcolor[idx]
    
    # convert to clustindeces    
    clustidx=np.zeros(np.shape(clust)[0])
    for i in range(len(clustcolor)):
        for j in range(len(clust)):
            if tuple(clustcolor[i])==tuple(clust[j]):
                clustidx[j]=i+1


    ### convert the colorscale
    modcolors_convert=clustcolor.copy()
    modcolors_light=clustcolor.copy()   
    modcolors=clustcolor.copy()
    for c in range(len(modcolors_convert)):
           r,g, b =ryb_to_rgb(modcolors_convert[c,0],modcolors_convert[c,1],modcolors_convert[c,2])
           modcolors_convert[c,0],modcolors_convert[c,1],modcolors_convert[c,2] = r,g,b
           h,s,v = colorsys.rgb_to_hsv(modcolors_convert[c,0],modcolors_convert[c,1],modcolors_convert[c,2])
           #v =  1.1-(np.max(modcolors[c,[0,2]])+modcolors[c,1]-np.min(modcolors[c,[0,2]]))/2.
           # adjust brightness. Darker means less dissagreement between fast and slow. 
           v=((np.max(modcolors[c,[0,2]])+modcolors[c,1]-np.min(modcolors[c,[0,2]]))+.4)/1.4 
           # More saturation, with more agreement between models
           s = np.max(modcolors[c,:-1])
           modcolors_convert[c,0],modcolors_convert[c,1],modcolors_convert[c,2] = colorsys.hsv_to_rgb(h,s,v)
           h,l,s = colorsys.rgb_to_hls(modcolors_convert[c,0],modcolors_convert[c,1],modcolors_convert[c,2])
           l=0.8
           modcolors_light[c,0],modcolors_light[c,1],modcolors_light[c,2] = colorsys.hls_to_rgb(h,l,s)
           
    clustcolor=modcolors_convert.copy()
    clustcolor_light =modcolors_light.copy()
    rgb_map=LinearSegmentedColormap.from_list('rgbmap',clustcolor,N=len(clustcolor))
    rgb_map_light=LinearSegmentedColormap.from_list('rgbmap_light',clustcolor_light,N=len(clustcolor))

    depths=np.unique(deps)
    hugecluster=[]
    slowcluster=[]
    neutralcluster=[]
    fastcluster=[]
    latgrid=[]
    longrid=[]
    depgrid=[]
    for p in reversed(range(len(depths))):
        el=np.where(deps==depths[p])
        clusttmp=np.squeeze(clustidx[el])
        hugecluster.append(np.reshape(np.squeeze(clusttmp[map_indx]),(361,181),order='F'))

        slowtmp=np.squeeze(saveclust[el,0])
        slowcluster.append(np.reshape(np.squeeze(slowtmp[map_indx]),(361,181),order='F'))
        neutraltmp=np.squeeze(saveclust[el,1])
        neutralcluster.append(np.reshape(np.squeeze(neutraltmp[map_indx]),(361,181),order='F'))        
        fasttmp=np.squeeze(saveclust[el,2])
        fastcluster.append(np.reshape(np.squeeze(fasttmp[map_indx]),(361,181),order='F'))
        
        latgrid.append(lats)
        longrid.append(lons)
        depgrid.append(np.ones(np.shape(lats))*depths[p])
    hugeclusterref=np.array(hugecluster)
    slowclusterref=np.array(slowcluster)
    neutralclusterref=np.array(neutralcluster)
    fastclusterref=np.array(fastcluster)
    hugecluster=np.array(hugecluster)
    slowcluster=np.array(slowcluster)
    neutralcluster=np.array(neutralcluster)
    fastcluster=np.array(fastcluster)    
    latgridref=np.array(latgrid)
    longridref=np.array(longrid)
    depgridref=np.array(depgrid)
     
    self.lon=np.unique(lon)
    self.lat=np.unique(lats)
 
    self.depth=np.flipud(np.unique(depths))
    clust1=hugecluster.reshape((len(self.depth),len(self.lon),len(self.lat)),order='F')
    slowcluster=slowcluster.reshape((len(self.depth),len(self.lon),len(self.lat)),order='F')
    slowcluster=np.transpose(slowcluster,(1,2,0))
    neutralcluster=neutralcluster.reshape((len(self.depth),len(self.lon),len(self.lat)),order='F')
    neutralcluster=np.transpose(neutralcluster,(1,2,0))
    fastcluster=fastcluster.reshape((len(self.depth),len(self.lon),len(self.lat)),order='F')
    fastcluster=np.transpose(fastcluster,(1,2,0))    
    self.clust=np.transpose(clust1,(1,2,0))
    self.colors=clustcolor
    self.votes = modcolors
    self.levels=np.linspace(0.5,len(clustcolor)+.5,len(clustcolor)+1.)
    self.rgb_map=rgb_map
    self.rgb_map_light=rgb_map_light
    self.lon_min=np.min(self.lon)
    self.lon_max=np.max(self.lon)
    self.lat_min=np.min(self.lat)
    self.lat_max=np.max(self.lat)
    self.dlat=np.abs(self.lat[1]-self.lat[0])
    self.dlon=np.abs(self.lon[1]-self.lon[0])

    self.votesslow=slowcluster
    self.votesneutral=neutralcluster   
    self.votesfast=fastcluster
    
    self.long6 = long6
    self.latg6 = latg6
    self.deps  = deps
    self.indg6 = clustidx
    self.slowg6 = np.squeeze(clust[:,0]).ravel()
    self.neutralg6=np.squeeze(clust[:,1]).ravel()
    self.fastg6 = np.squeeze(clust[:,2]).ravel()

    if write == True:
        #f = 'cluster_results_2016.txt'
        #data = list(zip(long6,latg6, deps, self.slowg6, self.neutralg6, self.fastg6))
        #np.savetxt(f,data, fmt='%5.2f', delimiter = '\t')
        f = 'cluster_votes_Vs_CottaarLekic2016.txt'
        data = list(zip(longridref.ravel(),latgridref.ravel(),depgridref.ravel(),5.*slowclusterref.ravel(),5.*neutralclusterref.ravel(),5.*fastclusterref.ravel(),hugeclusterref.ravel()))
        np.savetxt(f,data, fmt='%5.f', delimiter = '\t')
        f2 = 'colortriangle.txt'
        np.savetxt(f2,clustcolor[:,:3], fmt='%5.3f', delimiter = '\t')
        

  ####################################
  #- plot horizontal slices
  #########################################################################

  def plot_slice(self,depth,whattoplot='clust',colormap='jet',res='i',verbose=False):
    """ plot horizontal slices through an ses3d model

    plot_slice(self,depth,colormap='tomo',res='i',verbose=False)

    depth=depth in km of the slice
    colormap='tomo','mono'
    res=resolution of the map, admissible values are: c, l, i, h f

    """

 
    #- set up a map and colourmap -----------------------------------------
    m=Basemap(projection='hammer',lon_0=130.,resolution=res)
    m.drawparallels(np.arange(self.lat_min,self.lat_max,10.),labels=[0,0,0,0])#[1,0,0,1])
    m.drawmeridians(np.arange(self.lon_min,self.lon_max,10.),labels=[0,0,0,0])#[1,0,0,1])

    m.drawcoastlines()
    m.drawcountries()

    m.drawmapboundary(fill_color=[1.0,1.0,1.0])


    model=getattr(self,whattoplot)
    layer=np.argmin(np.abs(self.depth-depth))
    print('True plotting depth is ', self.depth[layer])


    xx,yy= np.meshgrid(self.lon,self.lat)
    x,y=m(xx.T,yy.T)

 
    minval=np.min(np.min(model[:,:,layer]))
    maxval=np.max(np.max(model[:,:,layer]))
    contours=np.round(np.linspace(minval,maxval,10),2)
    plt.contourf(x,y,model[:,:,layer],contours,cmap=plt.cm.get_cmap(colormap))
    #plt.pcolor(x,y,self.dvs[:,:,layer],vmin=-0.04, vmax=0.04,cmap=plt.cm.get_cmap('jet_r'))
    plt.colorbar()
    plt.title(whattoplot+' at '+str(depth)+' km')
 #########################################################################
  #- retrieve horizontal slices
  #########################################################################

  def get_slice(self,depth,whattoplot='clust',verbose=False):
    """ plot horizontal slices through an ses3d model

    plot_slice(self,depth,colormap='tomo',res='i',verbose=False)

    depth=depth in km of the slice
    colormap='tomo','mono'
    res=resolution of the map, admissible values are: c, l, i, h f

    """


    model=getattr(self,whattoplot)
    layer=np.argmin(np.abs(self.depth-depth))
    xx,yy= np.meshgrid(self.lon,self.lat)
 

    return xx.T, yy.T, model[:,:,layer]

 #########################################################################
  #- plot vertical cross-section - only handles along one latitude or longitude
  #########################################################################

  def plot_crosssection(self,direction,lonorlat,whattoplot='clust', plotmap=False):
    """ plot horizontal slices through an ses3d model

    plot_slice(self,depth,colormap='tomo',res='i',verbose=False)

    depth=depth in km of the slice
    colormap='tomo','mono'
    res=resolution of the map, admissible values are: c, l, i, h f

    """

    if plotmap:
    #- set up a map and colourmap -----------------------------------------
        plt.subplot(2,1,1)
        m=Basemap(projection='hammer',lon_0=-50.,resolution='i')
        m.drawparallels(np.arange(self.lat_min,self.lat_max,10.),labels=[0,0,0,0])#[1,0,0,1])
        m.drawmeridians(np.arange(self.lon_min,self.lon_max,10.),labels=[0,0,0,0])#[1,0,0,1])

        m.drawcoastlines()
        m.drawcountries()

        m.drawmapboundary(fill_color=[1.0,1.0,1.0])


    model=getattr(self,whattoplot)
    if direction=='NS':
        lon=lonorlat
        if plotmap:
            x1,y1=m(lon,self.lat_min)
            x2,y2=m(lon,self.lat_max)
            m.plot([x1,x2],[y1,y2],color='r')
        layer=np.argmin(np.abs(self.lon-lon))
        xx,yy= np.meshgrid(self.lat,self.depth)
        #x,y=m(xx.T,yy.T)
        toplot=model[layer,:,:]
        xlabel='latitude (dg)'
    if direction=='EW':
        lat=lonorlat
        if plotmap:
            x1,y1=m(self.lon_min,lat)
            x2,y2=m(self.lon_max,lat) 
            m.plot([x1,x2],[y1,y2],color='r')
        layer=np.argmin(np.abs(self.lat-lat))
        xx,yy= np.meshgrid(self.lon,self.depth)
        #x,y=m(xx.T,yy.T)
        toplot=model[:,layer,:]
        xlabel='longitude (dg)'
    
    plt.subplot(2,1,2)
    minval=np.min(np.min(toplot))
    maxval=np.max(np.max(toplot))
 
    contours=np.round(np.linspace(-1.1,1.1,12),1)    
    cs=plt.contourf(xx,yy,toplot.T,contours,cmap=plt.cm.get_cmap('jet'))
    plt.colorbar(cs)
    #plt.pcolor(x,y,self.dvs[:,:,layer],vmin=-0.04, vmax=0.04,cmap=plt.cm.get_cmap('jet_r'))
    plt.gca().invert_yaxis()
    plt.xlabel(xlabel)
    plt.ylabel('depth (km)')
#########################################################################
  #- plot vertical cross-section , any lon lat combinations
  #########################################################################

  def plot_crosssection_any(self,lon1,lon2,lat1,lat2,numpoints=400,whattoplot='clust', title='',stretch=1,greatcirclepath=True,lon0=180, spherical=False):
    """ plot horizontal slices through an ses3d model

    plot_slice(self,depth,colormap='tomo',res='i',verbose=False)

    depth=depth in km of the slice
    colormap='tomo','mono'
    res=resolution of the map, admissible values are: c, l, i, h f

    """
    model=getattr(self,whattoplot)
    #lon=(lon1+lon2)/2.
    #- set up a map and colourmap -----------------------------------------
    fig=plt.figure()
    plt.subplot(2,1,1)
    m = Basemap(projection='hammer',lon_0=lon0)
    #m.drawparallels(np.arange(self.lat_min,self.lat_max,45.),labels=[0,0,0,0])#[1,0,0,1])
    #m.drawmeridians(np.arange(self.lon_min,self.lon_max,60.),labels=[0,0,0,0])#[1,0,0,1])

 
    coasts = m.drawcoastlines(zorder=1,color='white',linewidth=0)
    coasts_paths = coasts.get_paths()
    ipolygons = range(40) # want Baikal, but not Tanganyika
        # 80 = Superior+Michigan+Huron, 81 = Victoria, 82 = Aral, 83 = Tanganyika,
        # 84 = Baikal, 85 = Great Bear, 86 = Great Slave, 87 = Nyasa, 88 = Erie
        # 89 = Winnipeg, 90 = Ontario
    for ipoly in ipolygons:
            r = coasts_paths[ipoly]
            # Convert into lon/lat vertices
            polygon_vertices = [(vertex[0],vertex[1]) for (vertex,code) in
                                r.iter_segments(simplify=False)]
            px = [polygon_vertices[i][0] for i in range(len(polygon_vertices))]
            py = [polygon_vertices[i][1] for i in range(len(polygon_vertices))]
            m.plot(px,py,linewidth=1.,zorder=3,color=[0.2,0.2,0.2])
    #m.drawmapboundary(fill_color=[1.0,1.0,1.0])
    #m.drawmapboundary(fill_color=[1.0,1.0,1.0])
    if lon0==180:
        z=(model[:,:,0])
        #z=z.transpose([1,0,2])
        #zt,lonstmp=shiftgrid(0,z.T,self.lon)
    #lonst,lonstmp=shiftgrid(0,lons.T,lons[:,0])
        x1,y1=np.meshgrid(self.lon, self.lat)
        x, y = m(x1.T,y1.T)
    else:
        z=(model[:,:,0])
        zt,lonstmp=shiftgrid(0,z.T,self.lon,start=False)
        x1,y1=np.meshgrid(self.lon, self.lat)
        print(np.shape(x1),np.shape(y1))
        x, y = m(x1.T,y1.T)
    #x=m.shiftdata(x,lon_0=lon0)    rgb =np.array(np.transpose(clustmap,(1,2,0)),dtype='float32')
    #rgb =zt.transpose([1,2,0])
    #color_tuple=rgb.reshape((rgb.shape[1]*rgb.shape[0],rgb.shape[2]),order='C')
    #mapper=np.linspace(0.,1.,rgb.shape[1]*rgb.shape[0]).reshape(rgb.shape[0],rgb.shape[1])
 
    #rgb_map=LinearSegmentedColormap.from_list('rgbmap',color_tuple,N=rgb.shape[1]*rgb.shape[0])

        
    cs=m.pcolor(x,y,z,cmap=self.rgb_map,linewidth=0, rasterized=True)
    #plt.colorbar()



    inv=geo.WGS84.Inverse(lat1,lon1,lat2,lon2)
    points=np.linspace(0,inv['s12'],numpoints)
    line=geo.WGS84.Line(lat1,lon1,inv['azi1'])
    if greatcirclepath:
        [x1,y1]=m.gcpoints(lon1,lat1,lon2,lat2, numpoints)
        m.plot(x1,y1,'k',linewidth=3)
        m.plot(x1[0],y1[0],'.c',markersize=15,markeredgecolor='k')            
        m.plot(x1[-1],y1[-1],'.m',markersize=15,markeredgecolor='k')   

        dist=[]
        lonsline=[]
        latsline=[]
        for i in range(len(points)):
            loc=line.Position(points[i])
            # dist.append(haversine((loc['lat2'],loc['lon2']),([lat1],[lon1]))/111194.)
            dist.append(loc['s12']/111194.)
            lonsline.append(loc['lon2'])
            latsline.append(loc['lat2'])

        lonsline=np.array(lonsline)
        latsline=np.array(latsline)

    else:
        lonsline=np.linspace(lon1,lon2,numpoints)
        latsline=np.linspace(lat1,lat2,numpoints)
        dist=haversine((lat1,lon1),(latsline,lonsline))/111194.

        [x1,y1]=m(lonsline,latsline)
        m.plot(x1,y1,'k',linewidth=3)
        m.plot(x1[0],y1[0],'.c',markersize=15,markeredgecolor='k')            
        m.plot(x1[-1],y1[-1],'.m',markersize=15,markeredgecolor='k')  

    modeltoplot = getattr(self,'indg6')
    idxs=[]
    for i in range(len(lonsline)):
        idxs.append(np.argmin(haversine((latsline[i],lonsline[i]),(self.latg6,self.long6))))
    idxs=np.array(idxs)

    toplot=np.empty((len(lonsline),len(self.depth)))
 
    for d in range(len(self.depth)):
             el=np.where(self.deps==self.depth[d])
             clusttmp=np.squeeze(modeltoplot[el])
             for i in range(len(lonsline)):
                        toplot[i,d]=clusttmp[idxs[i]]

             #toplot.append(np.round(scipy.ndimage.map_coordinates(model[:,:,d], np.vstack((row,col)),order=0,mode='constant')))
    
    toplot=np.array(toplot).T


    xx,yy= np.meshgrid(dist,self.depth)


    if spherical==False:
        ax=plt.subplot(2,1,2)      
        minval=np.min(np.min(toplot))
        maxval=np.max(np.max(toplot))

        contours=np.round(np.linspace(-1.1,1.1,12),2)    
        plt.title(title)

        cs=plt.pcolor(xx,yy,toplot,cmap=self.rgb_map,vmin=0.5,vmax=21.5)
        plt.plot([dist[0],dist[-1]],[min(self.depth),min(self.depth)],'k',linewidth=8)
        plt.plot(dist[0],min(self.depth),'.c',markersize=40,markeredgecolor='k')            
        plt.plot(dist[-1],min(self.depth),'.m',markersize=40,markeredgecolor='k')


        #plt.pcolor(x,y,self.dvs[:,:,layer],vmin=-0.04, vmax=0.04,cmap=plt.cm.get_cmap('jet_r'))

        plt.ylim([min(self.depth),2890])
        plt.gca().invert_yaxis()
        plt.xlim([min(dist),max(dist)])
        ax.set_aspect(.015/stretch)
        #plt.xlabel(xlabel)
        plt.ylabel('depth (km)')
    if spherical ==True:

        thetamin=0
        thetamax=inv['a12']*np.pi/180.

        tr = PolarAxes.PolarTransform()

        pi = np.pi
        shift = pi/2-(thetamax+thetamin)/2
        xx=xx+shift*180./pi
        angle_ticks = [(thetamin+shift, r""),
                       ((thetamax+thetamin)/2+shift, r""),
                        (thetamax+shift, r"")]
        grid_locator1 = FixedLocator([v for v, s in angle_ticks])
        tick_formatter1 = DictFormatter(dict(angle_ticks))

        grid_locator2 = MaxNLocator(6)

        grid_helper = floating_axes.GridHelperCurveLinear(
            tr, extremes=(thetamin+shift,thetamax+shift, 6371, 3480),
            grid_locator1=grid_locator1,
            grid_locator2=grid_locator2,
            tick_formatter1=tick_formatter1,
            tick_formatter2=None)
  
        ax1 = floating_axes.FloatingSubplot(fig, 212, grid_helper=grid_helper)
        fig.add_subplot(ax1)

        # create a parasite axes whose transData in RA, cz
        aux_ax = ax1.get_aux_axes(tr)

        aux_ax.patch = ax1.patch  # for aux_ax to have a clip path as in ax
        ax1.patch.zorder = 0.9  # but this has a side effect that the patch is
        # drawn twice, and possibly over some other
        # artists. So, we decrease the zorder a bit to
        # prevent this.

        #ax=plt.subplot(212, polar = True) 
        minval=np.min(np.min(toplot))
        maxval=np.max(np.max(toplot))

        contours=np.round(np.linspace(-1.1,1.1,12),2)
  
        #plt.title(title)

        cs=aux_ax.pcolor((180.-xx)*np.pi/180.,6371.-yy,toplot,cmap=self.rgb_map,vmin=0.5,vmax=21.5)
        aux_ax.plot(np.pi-(thetamin+shift),6371.,'.c',markersize=55,markeredgecolor='k')            
        aux_ax.plot(np.pi-(thetamax+shift),6371.,'.m',markersize=55,markeredgecolor='k') 
        return aux_ax,shift

#####################################################################################
  def get_crosssection_any(self,lonsline,latsline,whattoplot='indg6'):    
    '''
    model=getattr(self,whattoplot)

    
    # pixelize lon and lat
    row=(lonsline-self.lon_min)/self.dlon

    for i in range(len(row)):
        if row[i]<0:
            row[i]=row[i]+len(self.lon)-1
        if row[i]>360:
            row[i]=row[i]-len(self.lon)+1
    col=(90+latsline)/self.dlat
    '''


                            
    modeltoplot = getattr(self,whattoplot)
    idxs=[]
    for i in range(len(lonsline)):
        idxs.append(np.argmin(haversine((latsline[i],lonsline[i]),(self.latg6,self.long6))))
    idxs=np.array(idxs)

    toplot=np.empty((len(lonsline),len(self.depth)))
 
    for d in range(len(self.depth)):
             el=np.where(self.deps==self.depth[d])
             clusttmp=np.squeeze(modeltoplot[el])
             for i in range(len(lonsline)):
                        toplot[i,d]=clusttmp[idxs[i]]

             #toplot.append(np.round(scipy.ndimage.map_coordinates(model[:,:,d], np.vstack((row,col)),order=0,mode='constant')))
    
    toplot=np.array(toplot)

  #xx,yy= np.meshgrid(dist,self.depth)

    return np.array(toplot.T), self.depth

#############################################################
 
  def plot_discontinuity(self,depth,colormap='tomo',res='i',verbose=False):
    """ plot horizontal slices through an ses3d model

    plot_slice(self,depth,colormap='tomo',res='i',verbose=False)

    depth=depth for discontinuity
    colormap='tomo','mono'
    res=resolution of the map, admissible values are: c, l, i, h f

    """


    #- set up a map and colourmap -----------------------------------------
    m=Basemap(projection='merc',llcrnrlat=np.min(grid_lat),urcrnrlat=np.max(grid_lat),llcrnrlon=np.min(grid_lon),urcrnrlon=np.max(grid_lon),lat_ts=20,resolution=res)
    m.drawparallels(np.arange(self.lat_min,self.lat_max,10.),labels=[0,0,0,0])#[1,0,0,1])
    m.drawmeridians(np.arange(self.lon_min,self.lon_max,10.),labels=[0,0,0,0])#[1,0,0,1])

    m.drawcoastlines()
    m.drawcountries()

    m.drawmapboundary(fill_color=[1.0,1.0,1.0])


    model=getattr(self,'Vs')
    layer=np.argmin(np.abs(self.depth-depth))
    print('True plotting depth is ', self.depth[layer])


    xx,yy= np.meshgrid(self.lon,self.lat)
    x,y=m(xx.T,yy.T)

    topo=np.zeros(np.shape(x))

    for i in range((np.shape(topo)[0])):
      for j in range((np.shape(topo)[1])):
        vel=model[i,j,:]
        ind=np.argmax(np.diff(vel[layer-4:layer+4]))+layer-4
        topo[i,j]=self.depth[ind]+5.


 
    minval=np.min(np.min(topo))
    maxval=np.max(np.max(topo))
    contours=np.round(np.linspace(depth-35.,depth+35.,8))
    plt.contourf(x,y,topo,contours,cmap=plt.cm.get_cmap('jet_r'))
    #plt.pcolor(x,y,self.dvs[:,:,layer],vmin=-0.04, vmax=0.04,cmap=plt.cm.get_cmap('jet_r'))
    plt.colorbar()
    plt.title('Discontinuity at '+str(depth)+' km')



    ################################
    # get value at specific location
    ################################
  def get_value(self,depth,lon,lat,whatmodel='dVs',method='nearest_neighbor'):

      #- loop over subvolumes to collect information ------------------------
      layer=np.argmin(np.abs(self.depth-depth))
      lonind=np.argmin(np.abs(self.lon-lon))
      latind=np.argmin(np.abs(self.lat-lat))
      model=getattr(self,whatmodel)
      val=model[lonind,latind,layer]

##############################################################################
  def calculate_correction(self,lon,lat, evdepth=50.,dist=65.):
    ### do this again for Fichtner mdoel
    xs2=[0.]
    xp2=[0.]
    tsum2=[0.]
    tpsum2=[0.]
    tssum2=[0.]
    dtcorr2=[0.]

    #get depth profile from model
    moddepthtmp=self.depth
    moddepth2= [0.]
    for d in moddepthtmp:
        moddepth2.append(d)
    moddepth2=np.array(moddepth2)
    modrad2=6371-moddepth2
 

    #### Read in PREM
    table=[] 
    prem=dict()
    for line in open('../../Receiver_functions/Tools/prem_table.txt').readlines():
          if line[0]!='#':
              numbers= map(float,line.split())
              table.append(numbers)
    table=np.array(table)
    prem['modrad']=(table[:,0])[::-1]/1.e3
    prem['moddepth']=(6371. - prem['modrad'])
    prem['modvp']=(table[:,3])[::-1]/1.e3
    prem['modvs']=(table[:,4])[::-1]/1.e3
    prem['modvp'][0:2]=prem['modvp'][2]
    prem['modvs'][0:2]=prem['modvs'][2]

    prem['depth']=np.arange(0,1100.,1.)
    prem['rad']=6371.-prem['depth']
    prem['vp']=np.interp(prem['depth'],prem['moddepth'],prem['modvp'])
    prem['vs']=np.interp(prem['depth'],prem['moddepth'],prem['modvs'])
    #####


    ### Calculate PREM times for distance 65 deg
    # Parrival
    label='P'
    test=['/usr/local/taup/bin/taup_time -mod prem -deg 65 -h 10 -ph '+label+','+label+'ms,'+label+'210s,'+label+'410s,'+label+'670s']

    out=subprocess.check_output(test,shell=True)
    t= out.split()
    l=[x for x in range(len(t)) if t[x]==label]
    Pt= float(t[l[0]+1])
    Pslow=float(t[l[0]+2])

    Pi=float(t[l[0]+4])

    start=time.time()

    xs=[0.]
    xp=[0.]
    tsum=[0.]
    tpsum=[0.]
    tssum=[0.]
    dtcorr=[0.]

    for d in range(1,1100):
      #!!! refind vp and vs
      #Pwave

      dtheta,dtime=godown(prem['vp'][d-1],prem['rad'][d-1],prem['vp'][d],prem['rad'][d],Pslow)

      xp.append(xp[d-1]+dtheta)
      tpsum.append(tpsum[d-1]+dtime)


      #Swave

      dtheta,dtime=godown(prem['vs'][d-1],prem['rad'][d-1],prem['vs'][d],prem['rad'][d],Pslow)

      xs.append(xs[d-1]+dtheta)
      tssum.append(tssum[d-1]+dtime)

      # calculate correction for distance between P and Pds where they hit depth d
      r_pslow=Pslow*180./np.pi

      dtcorr.append((xp[d]-xs[d])*r_pslow)
      tsum.append(tssum[d]-tpsum[d]+dtcorr[d])

    tprem410=tssum[410]
    tprem660=tssum[660]
    modvp2=[]
    modvs2=[]
    for d in range(len(moddepth2)):
            modvp2.append(self.get_value(moddepth2[d],lon,lat,'Vp'))
            modvs2.append(self.get_value(moddepth2[d],lon,lat,'Vs'))


    depth=np.arange(0.,1100.,1.)
    rad=6371.-depth
    fichtnervp=np.interp(depth,moddepth2,modvp2)
    fichtnervs=np.interp(depth,moddepth2,modvs2)        
                      


   
    for d in range(1,1100):

        #Pwave
        dtheta,dtime=godown(fichtnervp[d-1],rad[d-1],fichtnervp[d],rad[d],Pslow)
        if np.isnan(dtheta):
            dtheta=0.0
            dtime=0.0
 
        xp2.append(xp2[-1]+dtheta)
 

        tpsum2.append(tpsum2[d-1]+dtime)

        dtheta,dtime=godown(fichtnervs[d-1],rad[d-1],fichtnervs[d],rad[d],Pslow)
        #Swave
        xs2.append(xs2[-1]+dtheta)
        tssum2.append(tssum2[d-1]+dtime)

        # calculate correction for distance between P and Pds where they hit depth d
        r_pslow=Pslow*180./np.pi

        dtcorr2.append((xp2[d]-xs2[d])*r_pslow)
        tsum2.append(tssum2[d]-tpsum2[d]+dtcorr2[d])


    corr410=(tssum2[410]-tprem410)
    corr660=(tssum2[660]-tprem660)
    corr_250_400=(tssum2[400]-tssum[400]-(tssum2[250]-tssum[250]))
    return corr410, corr660,corr_250_400




if __name__ == "__main__":
    
    mod=LMClust()
    mod.read('./', verbose=True, write=True)
    mod.plot_crosssection_any(180,320,-5,-5, spherical=True)
    plt.show()
 
