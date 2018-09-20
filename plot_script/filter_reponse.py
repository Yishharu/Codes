# -*- coding: utf-8 -*-
"""
Created on Wed May 30 15:46:16 2018

@author: zl382
"""

from scipy import signal
import matplotlib.pyplot as plt
import numpy as np

N = 5
ftype_name='butter'
db = False
freq = np.array([[1/30,1/20],[1/20,1/10],[1/10,1/5],[1/5,1/2],[1/2,1]])

fig = plt.figure()
ax = fig.add_subplot(111)

for f in freq:
    b, a = signal.iirfilter(N, (2*np.pi)*f, btype='bandpass', analog=True, ftype=ftype_name)
    w, h = signal.freqs(b, a, 1000)
    w = (2*np.pi)/w
    tips = str(1/f[0]) + 's - ' + str(1/f[1])+'s'
    if db == True: ax.semilogx(w, 20 * np.log10(abs(h)),label = tips)
    elif db == False: ax.semilogx(w, abs(h), label = tips)


ax.set_title(ftype_name +' Order '+str(N)+ ' bandpass frequency response')
ax.set_xlabel('Periods [s]')
ax.set_ylabel('Amplitude')
ax.axis((0.1, 100, 0, 1.5))
ax.grid(which='both', axis='both')
ax.legend(shadow=True,fontsize=8,fancybox=True,framealpha=0.5)
plt.show()


