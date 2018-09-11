import matplotlib.pyplot as plt
import numpy as np
import scipy.special as spf
T = 1000
f = 1/T
a=3480.
rs=6271.
omega = 2*np.pi*f
bbeta=6.5
mu=80
N = 17# sum order
n = 200 # Angular meshgrid
step = 20 # Radius step


#for N in range(0,200,40):



theta = np.linspace(0,2*np.pi,n)
rho = np.arange(0,4*a,step)
R,Th = np.meshgrid(rho,theta)  

X = R*np.cos(Th)
Y = R*np.sin(Th)
U = np.zeros(np.shape(X)) 

sig1 = (R>=a)*(R<rs)
sig2 = (R>=rs)
#for N in range(0,100,):

U = np.zeros(np.shape(X)) 


m_add = [-19,19]
mlist.extend(m_add)
for m in mlist:
    print('m=',m)   
    disp1_m = 1./(16*mu)*1j*(2*spf.hankel1(m,omega*R/bbeta)+a*omega*(-spf.hankel1(m-1,a*omega/bbeta)+spf.hankel1(m+1,a*omega/bbeta))*spf.hankel2(m,R*omega/bbeta)/(a*omega*spf.hankel2(m-1,a*omega/bbeta)-m*bbeta*spf.hankel2(m,a*omega/bbeta)))*spf.hankel2(m,rs*omega/bbeta)
    disp2_m = -1/(16.*mu)*1j*a*omega*spf.hankel2(m,R*omega/bbeta)*((spf.hankel1(m-1,a*omega/bbeta)-spf.hankel1(m+1,a*omega/bbeta))*spf.hankel2(m,rs*omega/bbeta)+spf.hankel1(m,rs*omega/bbeta)*(-spf.hankel2(m-1,a*omega/bbeta)+spf.hankel2(m+1,a*omega/bbeta)))/(a*omega*spf.hankel2(m-1,a*omega/bbeta)-m*bbeta*spf.hankel2(m,a*omega/bbeta))
    
    disp_m = disp1_m*sig1.astype(int)+disp2_m*sig2.astype(int)
    
    U = U + disp_m*np.exp(1j*m*Th)

plt.contourf(X,Y,abs(U))

plt.colorbar()
plt.show()
    

#theta0 = np.linspace(0,2*np.pi,n)
#rho0 = np.arange(0,a,step)
#R0,Th0 = np.meshgrid(rho0,theta0)
#
#X0 = R0*np.cos(Th0)
#Y0 = R0*np.sin(Th0)
#U0 = np.zeros(np.shape(X0))
#plt.hold(False)
#plt.contourf(X0,Y0,U0)
## plt.hold(True)
#
#theta1 = np.linspace(0,2*np.pi,n)
#rho1 = np.arange(a,rs,step)
#R1,Th1 = np.meshgrid(rho1,theta1)
#
#X1 = R1*np.cos(Th1)
#Y1 = R1*np.sin(Th1)
#U1 = np.zeros(np.shape(X1))
#disp1_m = np.zeros(np.shape(X1))
#
##for i in range(0,len(R)):
##    for j in range(0,len(Th)):
#for m in range(-N,N+1):
#    print('m1=',m)   
#    disp1_m = -1./(16*mu)*1j*(2*spf.hankel1(m,omega*R1/bbeta)+a*omega*(-spf.hankel1(m-1,a*omega/bbeta)+spf.hankel1(m+1,a*omega/bbeta))*spf.hankel2(m,R1*omega/bbeta)/(a*omega*spf.hankel2(m-1,a*omega/bbeta)-m*bbeta*spf.hankel2(m,a*omega/bbeta)))*spf.hankel2(m,rs*omega/bbeta)
#
#    U1 = U1 + disp1_m*np.exp(1j*m*Th1)
#
#plt.contourf(X1,Y1,abs(U1))
#plt.hold(True)
#
#theta2 = np.linspace(0,2*np.pi,n)
#rho2 = np.arange(rs,3*a,step)
#R2,Th2 = np.meshgrid(rho2,theta2)
#
#X2 = R2*np.cos(Th2)
#Y2 = R2*np.sin(Th2)
#U2 = np.zeros(np.shape(X2))
#disp2_m = np.zeros(np.shape(X2))
#
#for m in range(-N,N+1):
#    print('m2=',m)
#    disp2_m = -1/16.*1j*a*omega*spf.hankel2(m,R2*omega/bbeta)*((-spf.hankel1(m-1,a*omega/bbeta)+spf.hankel1(m+1,a*omega/bbeta))*spf.hankel2(m,rs*omega/bbeta)+spf.hankel1(m,rs*omega/bbeta)*(spf.hankel2(m-1,a*omega/bbeta)-spf.hankel2(m+1,a*omega/bbeta)))/(a*mu*omega*spf.hankel2(m-1,a*omega/bbeta)-m*bbeta*mu*spf.hankel2(m,a*omega/bbeta))
#
##-1/(16*mu)*1j*a*omega*spf.hankel1(m,omega*R2/bbeta)*((-spf.hankel1(m-1,a*omega/bbeta)+spf.hankel1(m+1,a*omega/bbeta))*spf.hankel2(m,rs*omega/bbeta)+spf.hankel1(m,rs*omega/bbeta)*(spf.hankel2(m-1,a*omega/bbeta)-spf.hankel2(m+1,a*omega/bbeta)))/(a*omega*spf.hankel1(m-1,omega*a/bbeta)-m*bbeta*spf.hankel1(m,a*omega/bbeta))
#    U2 = U2 + disp2_m*np.exp(1j*m*Th2)
#    plt.contourf(X2,Y2,abs(U2))
    #plt.hold(True)
#plt.xlim(-2.5*a,1.5*a)


#r = np.linspace(0,4*a,10000)
#disp = np.zeros(np.shape(r))
#for i in range(0,np.size(r)):
#    disp[i] = Umpy.usum(r[i],omega,np.pi/6,40)
#plt.plot(r,disp)
#
#plt.show()
