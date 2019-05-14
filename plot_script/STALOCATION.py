import numpy as np

import glob
import os
import sys

from obspy import read
from geographiclib.geodesic import Geodesic

Location = sys.argv[1]
Event = sys.argv[2]
dir='/raid1/zl382/Data/'+Location+'/'+Event+'/'

seislist = glob.glob(dir+'*PICKLE')
location = dict()
for station in seislist:
    s_name = os.path.splitext(os.path.split(station)[1])[0]
    print(s_name)
    seis = read(station,format='PICKLE') # read seismogram
    trace_location = Geodesic.WGS84.Inverse(seis[0].stats['evla'],seis[0].stats['evlo'],seis[0].stats['stla'],seis[0].stats['stlo'],outmask=1929)
    station_backazimuth = trace_location['azi2']

    location[s_name]=[seis[0].stats['dist'],seis[0].stats['az'],seis[0].stats['stla'],seis[0].stats['stlo'],station_backazimuth]

save_path = dir+'STALOCATION.npy'
np.save(save_path,location)
print('Location of the station saved in', save_path)