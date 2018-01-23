      PROGRAM xsimpr
C     driver for routine simpr
      INTEGER NMAX,NVAR
      REAL HTOT,X1
      PARAMETER(NMAX=3,NVAR=3,X1=0.,HTOT=50.)
      INTEGER i
      REAL a1,a2,a3,y(NMAX),yout(NMAX),
     *     dfdx(NMAX),dfdy(NMAX,NMAX),dydx(NMAX)
      EXTERNAL derivs
      y(1)=1.
      y(2)=1.
      y(3)=0.
      a1=0.5976
      a2=1.4023
      a3=0.
      call derivs(X1,y,dydx)
      call jacobn(X1,y,dfdx,dfdy,NVAR,NMAX)
      write(*,'(1x,a/)') 'Test Problem'
      do 11 i=5,50,5
        call simpr(y,dydx,dfdx,dfdy,NMAX,NVAR,X1,HTOT,i,yout,derivs)
        write(*,'(1x,a,f6.4,a,f7.4,a,i2,a)') 'X = ',X1,
     *       ' to ',X1+HTOT,' in ',i,' steps'
        write(*,'(1x,t5,a,t20,a)') 'Integration','Answer'
        write(*,'(1x,2f12.6)') yout(1),a1
        write(*,'(1x,2f12.6)') yout(2),a2
        write(*,'(1x,2f12.6)') yout(3),a3
11    continue
      END
