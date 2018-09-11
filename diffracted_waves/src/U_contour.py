import matplotlib.pyplot as plt
#import Umpy
import scipy.special as spf
import numpy as np
T=1000
f = 1/T
omega= 2*np.pi*f
a=3480.
bbeta=6.5
mu = 80

N = 1# sum order
n = 200 # meshgrid
#x = np.linspace(-10000,10000,n)
#y = np.linspace(-10000,10000,n)
#X,Y = np.meshgrid(x,y)
def um(r,m):
    T=1000
    f = 1/T
    omega= 2*np.pi*f
    a=3480.
    rs=6271.
    omega = 0.05
    bbeta=6.5
    mu=80
    
    if r < a:
        um = 0
        return um
    
    elif a <= r and r < rs:
        um = -1./(16*mu)*1j*(2*spf.hankel1(m,omega*r/bbeta)+a*omega*(-spf.hankel1(m-1,a*omega/bbeta)+spf.hankel1(m+1,a*omega/bbeta))*spf.hankel2(m,r*omega/bbeta)/(a*omega*spf.hankel2(m-1,a*omega/bbeta)-m*bbeta*spf.hankel2(m,a*omega/bbeta)))*spf.hankel2(m,rs*omega/bbeta)
      #  um = -1./(16*mu)*1j*(2*spf.hankel1(m,r*omega/bbeta)+  a*omega*(-spf.hankel1(m-1,a*omega/bbeta)+spf.hankel1(m+1,a*omega/bbeta))*spf.hankel2(m,r*omega/bbeta) /  (a*omega*spf.hankel2(m-1,a*omega/bbeta)-m*bbeta*spf.hankel2(m,a*omega/bbeta)) )*spf.hankel2(m,rs*omega/bbeta)
        
      #  *spf.hankel1(m,omega*rs/bbeta)*(2*spf.hankel2(m,omega*r/bbeta)+omega*a*spf.hankel1(m,omega*r/bbeta)*(spf.hankel2(m+1,omega*a/bbeta)-spf.hankel2(m-1,omega*a/bbeta))/(omega*a*spf.hankel1(m-1,omega*a/bbeta)-m*bbeta*spf.hankel1(m,omega*a/bbeta)))


#        1./(16*mu)*1j*spf.hankel1(m,omega*rs/bbeta)*(2*spf.hankel2(m,omega*r/bbeta)+omega*a*spf.hankel1(m,omega*r/bbeta)*(spf.hankel2(m+1,omega*a/bbeta)-spf.hankel2(m-1,omega*a/bbeta))/(omega*a*spf.hankel1(m-1,omega*a/bbeta)-m*bbeta*spf.hankel1(m,omega*a/bbeta)))
        return um
    
    elif rs <= r:
        um =  -1/16.*1j*a*omega*spf.hankel2(m,r*omega/bbeta)*((-spf.hankel1(m-1,a*omega/bbeta)+spf.hankel1(m+1,a*omega/bbeta))*spf.hankel2(m,rs*omega/bbeta)+spf.hankel1(m,rs*omega/bbeta)*(spf.hankel2(m-1,a*omega/bbeta)-spf.hankel2(m+1,a*omega/bbeta)))/(a*mu*omega*spf.hankel2(m-1,a*omega/bbeta)-m*bbeta*mu*spf.hankel2(m,a*omega/bbeta))
        #-1./16.*a*omega*spf.hankel2(m,r*omega/bbeta)*((-spf.hankel1(m-1,a*omega/bbeta)+spf.hankel1(m+1,a*omega/bbeta))*spf.hankel2(m,rs*omega/bbeta)+spf.hankel1(m,rs*omega)*(spf.hankel2(m-1,a*omega/bbeta)-spf.hankel2(m+1,a*omega/bbeta)))/(a*mu*omega*spf.hankel2(m-1,a*omega/bbeta)-m*bbeta*mu*spf.hankel2(m,a*omega/bbeta))       
    #    -1/(16*mu)*1j*a*omega*spf.hankel1(m,omega*r/bbeta)*((-spf.hankel1(m-1,a*omega/bbeta)+spf.hankel1(m+1,a*omega/bbeta))*spf.hankel2(m,rs*omega/bbeta)+spf.hankel1(m,rs*omega/bbeta)*(spf.hankel2(m-1,a*omega/bbeta)-spf.hankel2(m+1,a*omega/bbeta)))/(a*omega*spf.hankel1(m-1,omega*a/bbeta)-m*bbeta*spf.hankel1(m,a*omega/bbeta))
        #-1/(16*mu)*1j*a*omega*spf.hankel1(m,omega*r/bbeta)*((-spf.hankel1(m-1,a*omega/bbeta)+spf.hankel1(m+1,a*omega/bbeta))*spf.hankel2(m,rs*omega/bbeta)+spf.hankel1(m,rs*omega/bbeta)*(spf.hankel2(m-1,a*omega/bbeta)-spf.hankel2(m+1,a*omega/bbeta)))/(a*omega*spf.hankel1(m-1,omega*a/bbeta)-m*bbeta*spf.hankel1(m,a*omega/bbeta))
        return um


def usum(r,phi,N):
    SUM = 0
    for m in range(-N, N+1):
        SUM = SUM + um(r,m)*np.exp(1j*m*phi) 
    usum = abs(SUM)
    return usum

theta = np.linspace(0,2*np.pi,n)
rho = np.linspace(a,4*a,n)
R,Th = np.meshgrid(rho,theta)

X = R*np.cos(Th)
Y = R*np.sin(Th)
U = np.zeros(np.shape(X))


for N in range(1,20,50): #sum order
    for i in range(0,np.size(rho)):
        print('i=',i)
        for j in range(0,np.size(theta)):
           # r = np.sqrt(x[i]**2+y[j]**2)           # theta = np.arctan(y[j]/x[i])
            U[i,j] = usum(R[i,j],Th[i,j],N)

   # fig, ax = plt.subplots(subplot_kw=dict(projection='polar')) 
    plt.contourf(X,Y,U)
    
    plt.show()



r = np.linspace(0,4*a,n)
disp = np.zeros(np.shape(r))
for i in range(0,np.size(r)):
    disp[i] = usum(r[i],0,40)
plt.plot(r,disp)

plt.show()
