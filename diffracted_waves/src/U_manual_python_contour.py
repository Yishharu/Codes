import matplotlib.pyplot as plt
import numpy as np
import scipy.special as spf
T = 100
f = 1/T
a=3480.
rs=6271.
omega = 2*np.pi*f
bbeta=6.5
mu=80
N = 10# sum order
n = 200 # Angular meshgrid
step = 20 # Radius step

theta = np.linspace(0,2*np.pi,n)
rho = np.arange(0,4*a,step)
R,Th = np.meshgrid(rho,theta)  

X = R*np.cos(Th)
Y = R*np.sin(Th)
U = np.zeros(np.shape(X)) 

sig1 = (R>=a)*(R<rs)
sig2 = (R>=rs)

U = np.zeros(np.shape(X))
mlist = list(range(-N,N+1))

k = omega/bbeta

for m in mlist:
    print('m=',m)
    alpha = -spf.jvp(m,k*a)/spf.yvp(m,k*a)
    beta = (spf.jn(m,k*rs)+alpha*spf.yn(m,k*rs))/spf.hankel2(m,k*rs)
    c1 = (spf.jvp(m,k*rs)+alpha*spf.yvp(m,k*rs)-beta*spf.h2vp(m,k*rs))**(-1)/(k*mu*2*np.pi*rs)
    c2 = alpha*c1
    c3 = beta*c1
    disp1_m = c1*spf.jn(m,k*R)+c2*spf.yn(m,k*R)
    disp2_m = c3*spf.hankel2(m,k*R)
    disp_m = disp1_m*sig1.astype(int)+disp2_m*sig2.astype(int)
    
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

filename =  '/home/zl382/Pictures/Diffraction/U_plot/basic_T'+str(T)+'m'+str(N)+'.tiff'
       
plt.savefig(filename,format='tiff',dpi=300)   
plt.close('all')
    
