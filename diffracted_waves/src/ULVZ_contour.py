import matplotlib.pyplot as plt
import numpy as np
import scipy.special as spf
from numpy.linalg import inv


T = 100
f = 1/T
a0 = 3480.
a1 = 3900
rs=6271.
omega = 2*np.pi*f
bbeta0 = 2.5
bbeta1 = 6.5
mu0 = 20
mu1 = 80
N = 300# sum order
n = 200 # Angular meshgrid
step = 20 # Radius step

theta = np.linspace(0,2*np.pi,n)
rho = np.arange(0,4*a0,step)
R,Th = np.meshgrid(rho,theta)  

X = R*np.cos(Th)
Y = R*np.sin(Th)
U = np.zeros(np.shape(X)) 

sig0 = (R>=a0)*(R<a1)
sig1 = (R>=a1)*(R<rs)
sig2 = (R>=rs)

i_a0 = np.where(R[0]>=a0)[0][0]
i_a1 = np.where(R[0]>=a1)[0][0]
i_rs = np.where(R[0]>=rs)[0][0]


U = np.zeros(np.shape(X))
disp_m = np.zeros(np.shape(U))

mlist = list(range(-N,N+1))

k0 = omega/bbeta0
k1 = omega/bbeta1

for m in range(-N,N+1):
    print('m=',m)
    A = np.array([[spf.jvp(m,k0*a0),spf.yvp(m,k0*a0),0,0,0],
                  [spf.jn(m,k0*a1),spf.yn(m,k0*a1),-spf.jn(m,k1*a1),-spf.yn(m,k1*a1),0],
                  [spf.jvp(m,k0*a1),spf.yvp(m,k0*a1),-mu1/mu0*bbeta0/bbeta1*spf.jvp(m,k1*a1),-mu1/mu0*bbeta0/bbeta1*spf.yvp(m,k1*a1),0],
                  [0,0,spf.jn(m,k1*rs),spf.yn(m,k1*rs),-spf.hankel2(m,k1*rs)],
                  [0,0,spf.jvp(m,k1*rs),spf.yvp(m,k1*rs),-spf.h2vp(m,k1*rs)]])

    b = [0,0,0,0,1/(mu1*k1*2*np.pi*rs)]
    c = np.dot(inv(A),b)

    disp0_m = c[0]*spf.jn(m,k0*R[:,i_a0:i_a1])+c[1]*spf.yn(m,k0*R[:,i_a0:i_a1])   
    disp1_m = c[2]*spf.jn(m,k1*R[:,i_a1:i_rs])+c[3]*spf.yn(m,k1*R[:,i_a1:i_rs])
    disp2_m = c[4]*spf.hankel2(m,k1*R[:,i_rs:-1])
    
    
    disp_m[:,i_a0:i_a1] = disp0_m
    disp_m[:,i_a1:i_rs] = disp1_m
    
    dis1_ratio = np.linalg.norm(disp1_m[:,0] - disp0_m[:,-1],ord=2)/np.linalg.norm(disp1_m[:,0],ord=2)
    print('Discounity ratio at a1:', dis1_ratio)
    
    disp_m[:,i_rs:-1] = disp2_m
    
    dis2_ratio = np.linalg.norm(disp2_m[:,0] - disp1_m[:,-1],ord=2)/np.linalg.norm(disp2_m[:,0],ord=2)
    print('Discounity ratio at rs:', dis2_ratio)
        
    U = U + disp_m*np.exp(1j*m*Th)


    
#    alpha = -spf.h1vp(m,k*a)/spf.h2vp(m,k*a)
#    beta = (spf.hankel1(m,k*rs)+alpha*spf.hankel2(m,k*rs))/spf.hankel2(m,k*rs)
#    c1 = (spf.h1vp(m,k*rs)+alpha*spf.h2vp(m,k*rs)-beta*spf.h2vp(m,k*rs))**(-1)/(k*mu*2*np.pi*rs)
#    c2 = alpha*c1
#    c3 = beta*c1   
#    disp1_m = c1*spf.hankel1(m,k*R)+c2*spf.hankel2(m,k*R)
#    disp2_m = c3*spf.hankel2(m,k*R)
    
#    disp_m = disp1_m*sig1.astype(int)+disp2_m*sig2.astype(int)
    
#    U = U + disp_m*np.exp(1j*m*Th)

plt.contourf(X,Y,U.real)

plt.colorbar()
plt.show()
