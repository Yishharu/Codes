import numpy as np
import matplotlib.pyplot as plt
from obspy import read

########  Edit After This Line  ############
model = 'Bottom5km-40pct'

# Frequencies for filter
fmin = 1/20. #Hz
fmax = 1/10.  #Hzseis

time_min = -50
time_max = 100
per_norm = False
norm_constant = 30
component = 'BAT'
# Data Directory
dir = '/raid1/zl382/HPC_axisem3d_run'
########  Edit Before This Line  ############

plt.figure(dpi=200)

dist_list = np.arange(90,141,3) # [90,95,100,105,110,115,120,125,130,135]

# Loop through seismograms
count = 0
for idist, dist in enumerate(dist_list):
    file = dir + '/' + model + '/' + 'post_processing/' + 'UV.D%d.PICKLE' %dist
    seis = read(file,format='PICKLE')
    seistoplot = seis.select(channel=component)[0]
    # Set the norm value 
    if per_norm:
        norm = np.max(np.abs(seistoplot.data)) / norm_constant
    elif count == 0:
        norm = np.max(np.abs(seistoplot.data)) / norm_constant
    count = count+1
    print('Norm value: %f' % norm)
    align_time = seis[0].stats.traveltimes['Sdiff'] or seis[0].stats.traveltimes['S']
    plt.plot(seistoplot.ts-align_time,seistoplot.data/norm + dist, c='r')

plt.xlim(time_min, time_max)
plt.ylim(dist_list.min()-4,dist_list.max()+4)
plt.suptitle('%s' % model)
plt.title('freq: %d - %d s' %(1/fmax, 1/fmin), fontsize=10)
plt.show()