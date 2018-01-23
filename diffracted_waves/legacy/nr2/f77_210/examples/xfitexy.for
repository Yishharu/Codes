      PROGRAM xfitexy
C     driver for routine fitexy
      INTEGER NPT
      PARAMETER (NPT=30)
      REAL a,b,chi2,gasdev,q,ran1,sa,sb,siga,sigb
      REAL x(NPT),y(NPT),dx(NPT),dy(NPT),dz(NPT)
      INTEGER idum,j
      DATA dz /NPT*0./
      idum=-1
      do 11 j=1,NPT
        dx(j)=0.1+ran1(idum)
        dy(j)=0.1+ran1(idum)
        x(j)=10.+10.*gasdev(idum)
        y(j)=2.*x(j)-5.+dy(j)*gasdev(idum)
        x(j)=x(j)+dx(j)*gasdev(idum)
11    continue
      write(*,*) 'Values of a,b,siga,sigb,chi2,q:'
      write(*,*) 'Fit with x and y errors gives:'
      call fitexy(x,y,NPT,dx,dy,a,b,siga,sigb,chi2,q)
      write(*,'(6f11.6)') a,b,siga,sigb,chi2,q
      write(*,*)
      write(*,*) 'Setting x errors to zero gives:'
      call fitexy(x,y,NPT,dz,dy,a,b,siga,sigb,chi2,q)
      write(*,'(6f11.6)') a,b,siga,sigb,chi2,q
      write(*,*) '...to be compared with fit result:'
      call fit(x,y,NPT,dy,1,a,b,siga,sigb,chi2,q)
      write(*,'(6f11.6)') a,b,siga,sigb,chi2,q
      write(*,*)
      write(*,*) 'Setting y errors to zero gives:'
      call fitexy(x,y,NPT,dx,dz,a,b,siga,sigb,chi2,q)
      write(*,'(6f11.6)') a,b,siga,sigb,chi2,q
      write(*,*) '...to be compared with fit result:'
      call fit(y,x,NPT,dx,1,a,b,siga,sigb,chi2,q)
      sa=sqrt(siga**2+sigb**2*(a/b)**2)/b
      sb=sigb/b**2
      write(*,'(6f11.6)') -a/b,1./b,sa,sb,chi2,q
      END
