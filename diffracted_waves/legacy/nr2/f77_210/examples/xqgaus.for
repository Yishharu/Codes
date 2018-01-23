      PROGRAM xqgaus
C     driver for routine qgaus
      INTEGER NVAL
      REAL X1,X2
      PARAMETER(X1=0.0,X2=5.0,NVAL=10)
      INTEGER i
      REAL dx,func,ss,x
      EXTERNAL func
      dx=(X2-X1)/NVAL
      write(*,'(/1x,a,t12,a,t23,a/)') '0.0 to','QGAUS','Expected'
      do 11 i=1,NVAL
        x=X1+i*dx
        call qgaus(func,X1,x,ss)
        write(*,'(1x,f5.2,2f12.6)') x,ss,
     *       -(1.0+x)*exp(-x)+(1.0+X1)*exp(-X1)
11    continue
      END

      REAL FUNCTION func(x)
      REAL x
      func=x*exp(-x)
      END
