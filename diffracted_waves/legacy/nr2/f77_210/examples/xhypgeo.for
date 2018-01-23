      PROGRAM xhypgeo
C     driver for routine hypgeo
      COMPLEX a,b,c,z,zi,hypgeo,q1,q2,q3,q4
      REAL x,y
      a=0.5
      b=1.
      c=1.5
1     write(*,*) 'INPUT X,Y OF COMPLEX ARGUMENT:'
      read(*,*,END=999) x,y
      z=cmplx(x,y)
      q1=hypgeo(a,b,c,z*z)
      q2=0.5*log((1.+z)/(1.-z))/z
      q3=hypgeo(a,b,c,-z*z)
      zi=cmplx(-y,x)
      q4=0.5*log((1.+zi)/(1.-zi))/zi
      write(*,*) '2F1(0.5,1.0,1.5;Z**2) =',q1
      write(*,*) 'check using log form   ',q2
      write(*,*) '2F1(0.5,1.0,1.5;-Z**2)=',q3
      write(*,*) 'check using log form   ',q4
      goto 1
999   END
