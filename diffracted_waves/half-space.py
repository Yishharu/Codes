import numpy as np
from scipy.integrate import solve_ivp

import matplotlib.pyplot as plt

# T_array = np.linspace(0.01,1,101)
# omega_array = 2*np.pi/T_array 

omega_array = np.linspace(1,51,201)
T_array = 2*np.pi/omega_array

k = 0.16

z = np.linspace(-10,510,521)
rho = np.zeros_like(z)
vp = np.zeros_like(z)
vs = np.zeros_like(z)

start_depth = 100

vs0 = 10
rho[z<500], vs[z<500] = 3.38, vs0   # Boundary of Bottom Homogeous Layer
rho[z<=100], vs[z<=100] = 3.38, 4.41 # Start of Bottom Homogeous Layer
rho[z<90], vs[z<90] = 3.37, 4.46
rho[z<80], vs[z<80] = 3.36, 4.51
rho[z<70], vs[z<70] = 3.35, 4.57
rho[z<60], vs[z<60] = 3.34, 4.62
rho[z<50], vs[z<50] = 3.32, 4.65
rho[z<38], vs[z<38] = 3.00, 3.80
rho[z<19], vs[z<19] = 2.74, 3.55

mu = rho*vs**2

z = z - start_depth

def DS_differential(t, y):  # displacement-stress differential
    rho_t = np.interp(t,z,rho)
    mu_t = np.interp(t,z,mu)
    return np.dot([[0, 1/mu_t],[k**2*mu_t-omega**2*rho_t, 0]], y)


traction = []
for omega in omega_array:
    print('omega = %.3f' %omega)
    if k**2-omega**2/vs0**2 < 0:
        traction.append(0)
        continue
    eta0 = np.sqrt(k**2-omega**2/vs0**2)
    print('eta0 = sqrt(%.3f) = %.3f' %(k**2-omega**2/vs0**2, eta0))

    sol = solve_ivp(DS_differential, [0, start_depth], [1,eta0], method='RK45')
    traction.append(sol.y[1,-1])  # Final traction hope to be 0

np.array(traction)

plt.subplot(1,2,1)
plt.plot(T_array, traction)
plt.xlabel('Period')
plt.ylabel('Traction at h=100km')
plt.subplot(1,2,2)
plt.scatter(omega_array, traction)

plt.xlabel('Frequency')
plt.ylabel('Traction at h=100km')
plt.show()