from mpl_toolkits.mplot3d import Axes3D
import matplotlib.pyplot as plt
from matplotlib import cm
from matplotlib.ticker import LinearLocator, FormatStrFormatter

import matplotlib.pyplot as plt
import numpy as np

theta_initial = np.linspace(0,2*np.pi,200)
phi_initial = np.linspace(0,np.pi/2,200)

theta, phi = np.meshgrid(theta_initial, phi_initial)
 
strike_cmt = 64     # strike from Standard Global CMT Catalog
delta_cmt = 30      # dip from Standard Global CMT Catalog
lamda_cmt = -93     # slip   from Standard Global CMT Catalog
################ Edit Before This Line ########################

strike = np.deg2rad(strike_cmt)
delta = np.deg2rad(delta_cmt)
lamda = np.deg2rad(lamda_cmt)

cotheta = np.pi/2 - theta  - strike ## theta_initial is latitude and theta is colatitude

SV = np.abs(np.sin(lamda)*np.cos(2*delta)*np.cos(2*phi)*np.sin(cotheta) - np.cos(lamda)*np.cos(delta)*np.cos(2*phi)*np.cos(cotheta) \
     + 0.5*np.cos(lamda)*np.cos(delta)*np.sin(2*phi)*np.sin(2*cotheta) \
     - 0.5*np.sin(lamda)*np.sin(2*delta)*np.sin(2*phi)*(1+(np.sin(cotheta))**2))          
X, Y, Z = SV*np.sin(phi)*np.cos(theta), SV*np.sin(phi)*np.sin(theta), -SV*np.cos(phi)
ax = plt.subplot(131,projection='3d')
ax.plot_surface(X, Y, Z, cmap=cm.coolwarm)
ax.set_xlabel('X')
ax.set_ylabel('Y')
ax.set_zlabel('Z')
ax.set_xlim(-np.max(SV),np.max(SV))
ax.set_ylim(-np.max(SV),np.max(SV))
ax.set_zlim(-np.max(SV),np.max(SV))
ax.set_title('SV Radiation Pattern')
#plt.show()

SH = np.abs(np.cos(lamda)*np.cos(delta)*np.cos(phi)*np.sin(cotheta) + np.cos(lamda)*np.sin(delta)*np.sin(phi)*np.cos(2*cotheta) \
     + np.sin(lamda)*np.cos(2*delta)*np.cos(phi)*np.cos(cotheta) \
     - 0.5*np.sin(lamda)*np.sin(2*delta)*np.sin(phi)*np.sin(2*cotheta))
X, Y, Z = SH*np.sin(phi)*np.cos(theta), SH*np.sin(phi)*np.sin(theta), -SH*np.cos(phi)
ax = plt.subplot(132,projection='3d')
ax.plot_surface(X, Y, Z, cmap=cm.coolwarm)
ax.set_xlabel('X')
ax.set_ylabel('Y')
ax.set_zlabel('Z')
ax.set_xlim(-np.max(SH),np.max(SH))
ax.set_ylim(-np.max(SH),np.max(SH))
ax.set_zlim(-np.max(SH),np.max(SH))
ax.set_title('SH Radiation Pattern')
#plt.show()

P = np.abs(np.cos(lamda)*np.sin(delta)*(np.sin(phi))**2*np.sin(2*cotheta) - np.cos(lamda)*np.cos(delta)*np.sin(2*phi)*np.cos(cotheta) \
    + np.sin(lamda)*np.sin(2*delta)*(np.cos(phi)**2-np.sin(phi)**2*np.sin(cotheta)**2) \
    - np.sin(lamda)*np.cos(2*delta)*np.sin(2*phi)*np.sin(cotheta))
X, Y, Z = P*np.sin(phi)*np.cos(theta), P*np.sin(phi)*np.sin(theta), -P*np.cos(phi)     
ax = plt.subplot(133,projection='3d')
ax.plot_surface(X, Y, Z, cmap=cm.coolwarm)
ax.set_xlabel('X')
ax.set_ylabel('Y')
ax.set_zlabel('Z')
ax.set_xlim(-np.max(P),np.max(P))
ax.set_ylim(-np.max(P),np.max(P))
ax.set_zlim(-np.max(P),np.max(P))
ax.set_title('P Radiation Pattern')
plt.show()
