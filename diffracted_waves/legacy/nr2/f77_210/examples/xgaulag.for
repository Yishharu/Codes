      PROGRAM xgaulag
C     driver for routine gaulag
      INTEGER NP
      PARAMETER(NP=64)
      INTEGER i,n
      REAL func,alf,checkw,checkx,gammln,xx,x(NP),w(NP)
      alf=1.
1     write(*,*) 'Enter N'
      read(*,*,END=99) n
      call gaulag(x,w,n,alf)
      write(*,'(/1x,t3,a,t10,a,t22,a/)') '#','X(I)','W(I)'
      do 11 i=1,n
        write(*,'(1x,i2,2e14.6)') i,x(i),w(i)
11    continue
      checkx=0.
      checkw=0.
      do 12 i=1,n
        checkx=checkx+x(i)
        checkw=checkw+w(i)
12    continue
      write(*,'(/1x,a,e15.7,a,e15.7)') 'Check value:',checkx,
     *  '  should be:',n*(n+alf)
      write(*,'(/1x,a,e15.7,a,e15.7)') 'Check value:',checkw,
     *  '  should be:',exp(gammln(1.+alf))
C     demonstrate the use of GAULAG for an integral
      xx=0.0
      do 13 i=1,n
        xx=xx+w(i)*func(x(i))
13    continue
      write(*,'(/1x,a,f12.6)') 'Integral from GAULAG:',xx
      write(*,'(1x,a,f12.6)') 'Actual value:        ',1./(2.*sqrt(2.))
      go to 1
99    stop
      END

      REAL FUNCTION func(x)
      REAL x,bessj0
      func=bessj0(x)
      END
