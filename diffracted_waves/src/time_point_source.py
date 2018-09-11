# -*- coding: utf-8 -*-
"""
Created on Wed Feb 21 15:11:12 2018

@author: zl382
"""

import matplotlib.pyplot as plt
import numpy as np
import scipy.special as spf

a=3480.
rs=6271.
bbeta=6.5
mu=80
N = 200# sum order
#n = 200 # Angular meshgrid
r = 1.5*a
theta = np.pi/6

Fs = 20  #Sample frequency
t = 1/Fs #Sample Period

arrival = (r**2+rs**2-2*r*rs*np.cos(theta))**0.5/bbeta

n =  int((arrival/t*3)//2*2+1)  #32767

freq = np.fft.fftfreq(n,1/Fs)
T = np.linspace(0,n*t,num=n,endpoint=False)   # From 0 to n-1 t
U = np.zeros(np.shape(T))

#omega = np.linspace(0,2*np.pi*Fs,n)

epsilon = 1/(0.2*n*t)
omega = 2*np.pi*freq[0:n//2+1]-1j*epsilon

k = omega/bbeta
pome = 2*np.pi*1
R = 2*omega**2/(np.pi**0.5*pome**3)*np.exp(-omega**2/pome**2)


for m in range(-N,N+1):
    print('m=',m)    
    alpha = spf.jv(m,k*rs)/spf.hankel2(m,k*rs)
    c1 = (alpha*spf.h2vp(m,k*rs)-spf.jvp(m,k*rs))**(-1)/(k*mu*2*np.pi*rs)*R
    c2 = alpha*c1      
    if r<a:
        disp_m = 0
    elif r>=a and r<rs:
        disp_m = c1*spf.jv(m,k*r)
        
    elif rs<=r:
        disp_m = c2*spf.hankel2(m,k*r)
        
    disp_m = np.append(disp_m,np.conj(disp_m[::-1][0:-1]))
    disp_t = np.fft.ifft(disp_m)*np.exp(epsilon*T)
    
    U = U + disp_t*np.exp(1j*m*theta)
    
plt.plot(T,U.real)
print('First arrival should be %.2f'% arrival, ' (s)')
plt.show