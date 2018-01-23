      PROGRAM xmmid
C     driver for routine mmid
      INTEGER NVAR
      REAL HTOT,X1
      PARAMETER(NVAR=4,X1=1.0,HTOT=0.5)
      INTEGER i
      REAL bessj,bessj0,bessj1
      REAL b1,b2,b3,b4,xf,y(NVAR),yout(NVAR),dydx(NVAR)
      EXTERNAL derivs
      y(1)=bessj0(X1)
      y(2)=bessj1(X1)
      y(3)=bessj(2,X1)
      y(4)=bessj(3,X1)
      call derivs(X1,y,dydx)
      xf=X1+HTOT
      b1=bessj0(xf)
      b2=bessj1(xf)
      b3=bessj(2,xf)
      b4=bessj(3,xf)
      write(*,'(1x,a/)') 'First four Bessel functions'
      do 11 i=5,50,5
        call mmid(y,dydx,NVAR,X1,HTOT,i,yout,derivs)
        write(*,'(1x,a,f6.4,a,f6.4,a,i2,a)') 'X = ',X1,
     *       ' to ',X1+HTOT,' in ',i,' steps'
        write(*,'(1x,t5,a,t20,a)') 'Integration','BESSJ'
        write(*,'(1x,2f12.6)') yout(1),b1
        write(*,'(1x,2f12.6)') yout(2),b2
        write(*,'(1x,2f12.6)') yout(3),b3
        write(*,'(1x,2f12.6)') yout(4),b4
        write(*,'(/1x,a)') 'press RETURN to continue...'
        read(*,*)
11    continue
      END

      SUBROUTINE derivs(x,y,dydx)
      REAL x,y(*),dydx(*)
      dydx(1)=-y(2)
      dydx(2)=y(1)-(1.0/x)*y(2)
      dydx(3)=y(2)-(2.0/x)*y(3)
      dydx(4)=y(3)-(3.0/x)*y(4)
      END
