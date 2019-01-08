#matplotlib inline
import numpy as np
import matplotlib.pyplot as plt
from mpl_toolkits.basemap import Basemap
from itertools import chain
from geographiclib.geodesic import Geodesic
import obspy
import os
from obspy import read
import glob
import sys

event = '20100320' #sys.argv[1]

if_postcursor_cut = False
# Output Pictures Path
if if_postcursor_cut:
  save_picture_path = '/home/zl382/Pictures/'+event+'pc_fk_analysis/'
else:
  save_picture_path = '/home/zl382/Pictures/'+event+'_fk_analysis/'

dir='/raid3/zl382/Data/'+event+'/'
cat = obspy.read_events(dir+'CMTSOLUTION')
event_latitude = cat[0].origins[0].latitude
event_longitude = cat[0].origins[0].longitude

array_list = glob.glob(dir + 'fk_analysis/*')

print('event lon :')
print(event_longitude)
print('event lat :')
print(event_latitude)


for array in array_list:
    array_name = os.path.split(array)[1]
    test = read(array+'/'+array_name+'*PICKLE',format='PICKLE')
    if test[0].stats['dist']< 110 and test[0].stats['dist']> 100 \
        and os.path.exists(save_picture_path+array_name+'_baz.npy'):# and test[0].stats['az']<= 330:
        print('######## This is array: ' + array+' ###############')
        baz = float(str(np.load(save_picture_path+array_name+'_baz.npy')))
        slowness = float(str(np.load(save_picture_path+array_name+'_baz.npy')))
        print(array+' Data Loaded !!')
        print('baz: ')
        print(baz)
        print('slowness: ')
        print(slowness)        
        if baz<200 or baz> 300:
            continue
        array_stla = np.load(array+'/stla.npy')
        array_stlo = np.load(array+'/stlo.npy')
        # plot station arrays
        geo = Geodesic.WGS84.Inverse(event_latitude,event_longitude,array_stla,array_stlo, outmask=1929)
        devia = baz - (geo['azi2'] + 180)
        print('azi1')
        print(geo['azi1'])
        print('azi2')
        print(geo['azi2'])
        plt.scatter(geo['azi1'],devia,color='blue')


save_picture_path = '/home/zl382/Pictures/'+event+'pc_fk_analysis/'

for array in array_list:
    array_name = os.path.split(array)[1]
    test = read(array+'/'+array_name+'*PICKLE',format='PICKLE')
    if test[0].stats['dist']< 110 and test[0].stats['dist']> 100 \
        and os.path.exists(save_picture_path+array_name+'_baz.npy'):# and test[0].stats['az']<= 330:
        print('######## This is array: ' + array+' ###############')
        baz = float(str(np.load(save_picture_path+array_name+'_baz.npy')))
        slowness = float(str(np.load(save_picture_path+array_name+'_baz.npy')))
        print(array+' Data Loaded !!')
        print('baz: ')
        print(baz)
        print('slowness: ')
        print(slowness)        
        if baz<200 or baz> 300:
            continue
        array_stla = np.load(array+'/stla.npy')
        array_stlo = np.load(array+'/stlo.npy')
        # plot station arrays
        geo = Geodesic.WGS84.Inverse(event_latitude,event_longitude,array_stla,array_stlo, outmask=1929)
        devia = baz - (geo['azi2'] + 180)
        print('azi1')
        print(geo['azi1'])
        print('azi2')
        print(geo['azi2'])
        plt.scatter(geo['azi1'],devia,color='red')

plt.ylim([-20,10])
plt.show()