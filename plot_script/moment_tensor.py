# -*- coding: utf-8 -*-
"""
Created on Fri Mar 23 17:25:27 2018

@author: zl382
"""
#/usr/bin/python3

import matplotlib.pyplot as plt
import numpy as np

strike = 64*np.pi/180  ###
delta = 30*np.pi/180  ## dip   90*np.pi//180
lamda = -93*np.pi/180  ## slip   0
M0 = 9.2e+25

#cotheta = np.pi/2 - theta - strike  ## theta is latitude and cotheta is colatitude

Mxx = -M0*(np.sin(delta)*np.cos(lamda)*np.sin(2*strike)+np.sin(2*delta)*np.sin(lamda)*np.sin(strike)**2)
Mxy = M0*(np.sin(delta)*np.cos(lamda)*np.cos(2*strike)+0.5*np.sin(2*delta)*np.sin(lamda)*np.sin(2*strike))
Myx = Mxy
Mxz = -M0*(np.cos(delta)*np.cos(lamda)*np.cos(strike)+np.cos(2*delta)*np.sin(lamda)*np.sin(strike))
Mzx = Mxz
Myy = M0*(np.sin(delta)*np.cos(lamda)*np.sin(2*strike)-np.sin(2*delta)*np.sin(lamda)*np.cos(strike)**2)
Myz = -M0*(np.cos(delta)*np.cos(lamda)*np.sin(strike)-np.cos(2*delta)*np.sin(lamda)*np.cos(strike))
Mzy = Myz
Mzz = M0*np.sin(2*delta)*np.sin(lamda)


Mrr = Mzz
Mtt = Mxx
Mpp = Myy
Mrt = Mzx
Mrp = -Mzy
Mtp = -Mxy

print('strike = %.1f , dip = %.1f , slip = %.1f , Scalar Moment = %.1e\n' % (strike*180/np.pi,delta*180/np.pi,lamda*180/np.pi,M0))
print('Mrr = %.6e\n Mtt = %.6e\n Mpp = %.6e\n Mrt = %.6e\n Mrp = %.6e\n Mtp = %.6e\n' % (Mrr, Mtt, Mpp, Mrt, Mrp, Mtp))