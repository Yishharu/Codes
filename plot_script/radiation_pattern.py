#/usr/bin:
import matplotlib.pyplot as plt
import numpy as np
import sys
import glob

event=sys.argv[1]
dir='/raid3/zl382/Data/'+event
seislist=glob.glob(dir+'/*PICKLE')

with open(dir +'/cmtsource.txt','r') as inf:
    srcdict= eval(inf.read())

theta = np.linspace(0,2*np.pi,200)
incident = 23
i_s = incident*np.pi/180
strike = srcdict['strike']*np.pi/180  ###
delta = srcdict['dip']*np.pi/180  ## dip   90*np.pi//180
lamda = srcdict['slip']*np.pi/180  ## slip   0

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

P = np.cos(lamda)*np.sin(delta)*(np.sin(i_s))**2*np.sin(2*cotheta) - np.cos(lamda)*np.cos(delta)*np.sin(2*i_s)*np.cos(cotheta) \
     + np.sin(lamda)*np.sin(2*delta)*(np.cos(i_s)**2-np.sin(i_s)**2*np.sin(cotheta)**2) \
     - np.sin(lamda)*np.cos(2*delta)*np.sin(2*i_s)*np.sin(cotheta)
     
ax = plt.subplot(133,projection='polar')
ax.set_rmax(np.max(P))
ax.plot(theta,np.abs(P))
ax.set_theta_zero_location('N')
ax.set_theta_direction(-1)
ax.set_title('P Radiation Pattern')

plt.suptitle('Event %s \n incident angel: %.1f ; strike: %.1f ; dip: %.1f ; slip: %.1f ' % (event, incident, srcdict['strike'],srcdict['dip'],srcdict['slip']))
plt.show()