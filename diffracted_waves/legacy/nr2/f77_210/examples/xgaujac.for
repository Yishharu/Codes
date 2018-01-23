      PROGRAM xgaujac
C     driver for routine gaujac
      INTEGER NP
      REAL PIBY2
      PARAMETER(NP=64,PIBY2=1.5707963)
      INTEGER i,n
      REAL func,ak,alf,bet,checkw,checkx,ellf,gammln,xx,x(NP),w(NP)
      alf=-.5
      bet=-.5
1     write(*,*) 'Enter N'
      read(*,*,END=99) n
      call gaujac(x,w,n,alf,bet)
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
     *  '  should be:',n*(bet-alf)/(alf+bet+2*n)
      write(*,'(/1x,a,e15.7,a,e15.7)') 'Check value:',checkw,
     *  '  should be:',exp(gammln(1.+alf)+gammln(1.+bet)-
     *     gammln(2.+alf+bet))*2**(alf+bet+1.)
C     demonstrate the use of GAUJAC for an integral
      ak=.5
      xx=0.0
      do 13 i=1,n
        xx=xx+w(i)*func(ak,x(i))
13    continue
      write(*,'(/1x,a,f12.6)') 'Integral from GAUJAC:',xx
      write(*,'(1x,a,f12.6)') 'Actual value:        ',2.*ellf(PIBY2,ak)
      go to 1
99    stop
      END

      REAL FUNCTION func(ak,x)
      REAL ak,x
      func=1./sqrt(1.-ak**2*(1.+x)/2.)
      END
