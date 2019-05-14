#/usr/bin:
import matplotlib.pyplot as plt
import numpy as np
import sys
import glob

event = '20100320' 
theta = np.linspace(0,2*np.pi,200)
incident = 23                     # Incident angel, value of specific phase can be caculated from Taup
i_s = np.deg2rad(incident)

strike_cmt = 64     # strike from Standard Global CMT Catalog
delta_cmt = 30      # dip from Standard Global CMT Catalog
lamda_cmt = -93     # slip   from Standard Global CMT Catalog
################ Edit Before This Line ########################

strike = np.deg2rad(strike_cmt)
delta = np.deg2rad(delta_cmt)
lamda = np.deg2rad(lamda_cmt)

cotheta = theta - strike  ## theta is latitude and cotheta is colatitude

SV = np.sin(lamda)*np.cos(2*delta)*np.cos(2*i_s)*np.sin(cotheta) - np.cos(lamda)*np.cos(delta)*np.cos(2*i_s)*np.cos(cotheta) \
     + 0.5*np.cos(lamda)*np.cos(delta)*np.sin(2*i_s)*np.sin(2*cotheta) \
     - 0.5*np.sin(lamda)*np.sin(2*delta)*np.sin(2*i_s)*(1+(np.sin(cotheta))**2)
     
ax = plt.subplot(131,projection='polar')
ax.set_rmax(np.max(SV))
ax.plot(theta,np.abs(SV))
ax.set_theta_zero_location('N')
ax.set_theta_direction(-1)
ax.set_title('SV Radiation Pattern')
#plt.show()

SH = np.cos(lamda)*np.cos(delta)*np.cos(i_s)*np.sin(cotheta) + np.cos(lamda)*np.sin(delta)*np.sin(i_s)*np.cos(2*cotheta) \
     + np.sin(lamda)*np.cos(2*delta)*np.cos(i_s)*np.cos(cotheta) \
     - 0.5*np.sin(lamda)*np.sin(2*delta)*np.sin(i_s)*np.sin(2*cotheta)
     
ax = plt.subplot(132,projection='polar')
ax.set_rmax(np.max(SH))
ax.plot(theta,np.abs(SH))
ax.set_theta_zero_location('N')
ax.set_theta_direction(-1)
ax.set_title('SH Radiation Pattern')
#plt.show()

# No figure means no P Energy at that incident angel
P = np.cos(lamda)*np.sin(delta)*(np.sin(i_s))**2*np.sin(2*cotheta) - np.cos(lamda)*np.cos(delta)*np.sin(2*i_s)*np.cos(cotheta) \
     + np.sin(lamda)*np.sin(2*delta)*(np.cos(i_s)**2-np.sin(i_s)**2*np.sin(cotheta)**2) \
     - np.sin(lamda)*np.cos(2*delta)*np.sin(2*i_s)*np.sin(cotheta)
     
ax = plt.subplot(133,projection='polar')
ax.set_rmax(np.max(P))
ax.plot(theta,np.abs(P))
ax.set_theta_zero_location('N')
ax.set_theta_direction(-1)
ax.set_title('P Radiation Pattern')



plt.suptitle('Event %s \n incident angel: %.1f ; strike: %.1f ; dip: %.1f ; slip: %.1f ' % (event, incident, strike_cmt, delta_cmt, lamda_cmt))
plt.show()