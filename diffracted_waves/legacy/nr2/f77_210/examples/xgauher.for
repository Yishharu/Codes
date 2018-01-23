      PROGRAM xgauher
C     driver for routine gauher
      INTEGER NP
      REAL SQRTPI
      PARAMETER(NP=64,SQRTPI=1.7724539)
      INTEGER i,n
      REAL func,check,xx,x(NP),w(NP)
1     write(*,*) 'Enter N'
      read(*,*,END=99) n
      call gauher(x,w,n)
      write(*,'(/1x,t3,a,t10,a,t22,a/)') '#','X(I)','W(I)'
      do 11 i=1,n
        write(*,'(1x,i2,2e14.6)') i,x(i),w(i)
11    continue
      check=0.
      do 12 i=1,n
        check=check+w(i)
12    continue
      write(*,'(/1x,a,e15.7,a,e15.7)') 'Check value:',check,
     *  '  should be:',SQRTPI
C     demonstrate the use of GAUHER for an integral
      xx=0.0
      do 13 i=1,n
        xx=xx+w(i)*func(x(i))
13    continue
      write(*,'(/1x,a,f12.6)') 'Integral from GAUHER:',xx
      write(*,'(1x,a,f12.6)') 'Actual value:        ',SQRTPI*exp(-.25)
      go to 1
99    stop
      END

      REAL FUNCTION func(x)
      REAL x
      func=cos(x)
      END
