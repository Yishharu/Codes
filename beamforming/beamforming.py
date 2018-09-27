# -*- coding: utf-8 -*-
"""
Created on Mon Sep 24 15:40:02 2018

@author: zl382
"""
import matplotlib.pyplot as plt
import matplotlib.dates as mdates

import obspy
from obspy import read
from obspy.core.util import AttribDict
import glob
from obspy.imaging.cm import obspy_sequential
from obspy.signal.invsim import corn_freq_2_paz
from obspy.signal.array_analysis import array_processing

from obspy.core.stream import Stream 

dir = '/raid3/zl382/Data/20161225/fk_analysis/az_330.0dist_123.0/'
seislist = glob.glob(dir + '*PICKLE')

# Load data
st = Stream()
for i, seisname in enumerate(seislist):
    seis = read(seisname,format='PICKLE')
    st += seis.select(channel='BHT')
    st[i].stats.coordinates = AttribDict({
        'latitude': seis[0].stats['stla'],
        'elevation': 0.0,
        'longitude': seis[0].stats['stla']})
st.resample(10)
# Execute array_processing
Sdifftime = seis[0].stats.traveltimes['Sdiff'] or seis[0].stats.traveltimes['S']
st[0].stats['eventtime'] + Sdifftime
stime = st[0].stats['eventtime'] + Sdifftime - 40
etime = st[0].stats['eventtime'] + Sdifftime + 80

kwargs = dict(
    # slowness grid: X min, X max, Y min, Y max, Slow Step
    sll_x=-3.0, slm_x=3.0, sll_y=-3.0, slm_y=3.0, sl_s=0.03,
    # sliding window properties
    win_len=10.0, win_frac=0.05,
    # frequency properties
    frqlow=1/30.0, frqhigh=1.0, prewhiten=0,
    # restrict output
    coordsys='lonlat', semb_thres=-1e9, vel_thres=-1e9, timestamp='mlabday',
    stime=stime, etime=etime
)
print(' done?')
out = array_processing(st, **kwargs)
print('processing done!')

# Plot
labels = ['rel.power', 'abs.power', 'baz', 'slow']

xlocator = mdates.AutoDateLocator()
fig = plt.figure()
for i, lab in enumerate(labels):
    ax = fig.add_subplot(4, 1, i + 1)
    ax.scatter(out[:, 0], out[:, i + 1], c=out[:, 1], alpha=0.6,
               edgecolors='none', cmap=obspy_sequential)
    ax.set_ylabel(lab)
    ax.set_xlim(out[0, 0], out[-1, 0])
    ax.set_ylim(out[:, i + 1].min(), out[:, i + 1].max())
    ax.xaxis.set_major_locator(xlocator)
    ax.xaxis.set_major_formatter(mdates.AutoDateFormatter(xlocator))

fig.suptitle('Beamforming Around Sdiff %s' % (
    stime.strftime('%Y-%m-%d'), ))
fig.autofmt_xdate()
fig.subplots_adjust(left=0.15, top=0.95, right=0.95, bottom=0.2, hspace=0)
print('plot done!')
plt.show()

# # Load data
# st[0] = read(seislist[s],format='PICKLE')[]
# # Set PAZ and coordinates for all 5 channels
# st[0].stats.paz = AttribDict({
#     'poles': [(-0.03736 - 0.03617j), (-0.03736 + 0.03617j)],
#     'zeros': [0j, 0j],
#     'sensitivity': 205479446.68601453,
#     'gain': 1.0})
# st[0].stats.coordinates = AttribDict({
#     'latitude': 48.108589,
#     'elevation': 0.450000,
#     'longitude': 11.582967})

# st[1].stats.paz = AttribDict({
#     'poles': [(-0.03736 - 0.03617j), (-0.03736 + 0.03617j)],
#     'zeros': [0j, 0j],
#     'sensitivity': 205479446.68601453,
#     'gain': 1.0})
# st[1].stats.coordinates = AttribDict({
#     'latitude': 48.108192,
#     'elevation': 0.450000,
#     'longitude': 11.583120})

# st[2].stats.paz = AttribDict({
#     'poles': [(-0.03736 - 0.03617j), (-0.03736 + 0.03617j)],
#     'zeros': [0j, 0j],
#     'sensitivity': 250000000.0,
#     'gain': 1.0})
# st[2].stats.coordinates = AttribDict({
#     'latitude': 48.108692,
#     'elevation': 0.450000,
#     'longitude': 11.583414})

# st[3].stats.paz = AttribDict({
#     'poles': [(-4.39823 + 4.48709j), (-4.39823 - 4.48709j)],
#     'zeros': [0j, 0j],
#     'sensitivity': 222222228.10910088,
#     'gain': 1.0})
# st[3].stats.coordinates = AttribDict({
#     'latitude': 48.108456,
#     'elevation': 0.450000,
#     'longitude': 11.583049})

# st[4].stats.paz = AttribDict({
#     'poles': [(-4.39823 + 4.48709j), (-4.39823 - 4.48709j), (-2.105 + 0j)],
#     'zeros': [0j, 0j, 0j],
#     'sensitivity': 222222228.10910088,
#     'gain': 1.0})
# st[4].stats.coordinates = AttribDict({
#     'latitude': 48.108730,
#     'elevation': 0.450000,
#     'longitude': 11.583157})