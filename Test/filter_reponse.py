# -*- coding: utf-8 -*-
"""
Created on Wed May 30 15:46:16 2018

@author: zl382
"""

from scipy import signal
import matplotlib.pyplot as plt
import numpy as np

N = 4
ftype_name='butter'
db = False

if db == True:
    b, a = signal.iirfilter(N, [1/30, 1/15], btype='band', analog=True, ftype=ftype_name)
    w, h = signal.freqs(b, a, 1000)
    fig = plt.figure()
    ax = fig.add_subplot(111)
    ax.semilogx(w, 20 * np.log10(abs(h)),label = '30s - 20s')
    
    b, a = signal.iirfilter(N, [1/20, 1/10], btype='band', analog=True, ftype=ftype_name)
    w, h = signal.freqs(b, a, 1000)
    ax.semilogx(w, 20 * np.log10(abs(h)),'r',label = '20s - 10s')
    
    b, a = signal.iirfilter(N, [1/10, 1/5], btype='band', analog=True, ftype=ftype_name)
    w, h = signal.freqs(b, a, 1000)
    ax.semilogx(w, 20 * np.log10(abs(h)),'black',label = '10s - 5s')
    
    b, a = signal.iirfilter(N, [1/5, 1/2.5], btype='band', analog=True, ftype=ftype_name)
    w, h = signal.freqs(b, a, 1000)
    ax.semilogx(w, 20 * np.log10(abs(h)),'g',label = '5s - 2s')
    
    b, a = signal.iirfilter(N, [1/2, 1/1], btype='band', analog=True, ftype=ftype_name)
    w, h = signal.freqs(b, a, 1000)
    ax.semilogx(w, 20 * np.log10(abs(h)),'purple',label = '2s - 1s')

elif db == False:
    b, a = signal.iirfilter(N, [1/30, 1/20], btype='band', analog=True, ftype=ftype_name)
    w, h = signal.freqs(b, a, 1000)
    fig = plt.figure()
    ax = fig.add_subplot(111)
    ax.semilogx(w, abs(h),label = '30s - 20s')
    
    b, a = signal.iirfilter(N, [1/20, 1/10], btype='band', analog=True, ftype=ftype_name)
    w, h = signal.freqs(b, a, 1000)
    ax.semilogx(w,  abs(h),'r',label = '20s - 10s')
    
    b, a = signal.iirfilter(N, [1/10, 1/5], btype='band', analog=True, ftype=ftype_name)
    w, h = signal.freqs(b, a, 1000)
    ax.semilogx(w,  abs(h),'black',label = '10s - 5s')
    
    b, a = signal.iirfilter(N, [1/5, 1/2.5], btype='band', analog=True, ftype=ftype_name)
    w, h = signal.freqs(b, a, 1000)
    ax.semilogx(w, abs(h),'g',label = '5s - 2s')
    
    b, a = signal.iirfilter(N, [1/2, 1/1], btype='band', analog=True, ftype=ftype_name)
    w, h = signal.freqs(b, a, 1000)
    ax.semilogx(w, abs(h),'purple',label = '2s - 1s')



ax.set_title(ftype_name +' Order '+str(N)+ ' bandpass frequency response')
ax.set_xlabel('Frequency [radians / second]')
ax.set_ylabel('Amplitude')
ax.axis((1/100, 10, 0, 1.5))
ax.grid(which='both', axis='both')
ax.legend(shadow=True,fontsize=8,fancybox=True,framealpha=0.5)
plt.show()

