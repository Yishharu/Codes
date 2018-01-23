      PROGRAM xgauleg
C     driver for routine gauleg
      INTEGER NPOINT
      REAL X1,X2,X3
      PARAMETER(NPOINT=10,X1=0.0,X2=1.0,X3=10.0)
      INTEGER i
      REAL func,xx,x(NPOINT),w(NPOINT)
      call gauleg(X1,X2,x,w,NPOINT)
      write(*,'(/1x,t3,a,t10,a,t22,a/)') '#','X(I)','W(I)'
      do 11 i=1,NPOINT
        write(*,'(1x,i2,2f12.6)') i,x(i),w(i)
11    continue
C     demonstrate the use of GAULEG for an integral
      call gauleg(X1,X3,x,w,NPOINT)
      xx=0.0
      do 12 i=1,NPOINT
        xx=xx+w(i)*func(x(i))
12    continue
      write(*,'(/1x,a,f12.6)') 'Integral from GAULEG:',xx
      write(*,'(1x,a,f12.6)') 'Actual value:',1.0-(1.0+X3)*exp(-X3)
      END

      REAL FUNCTION func(x)
      REAL x
      func=x*exp(-x)
      END
