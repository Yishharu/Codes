      PROGRAM xorthog
C     driver for routine orthog
      INTEGER NP
      PARAMETER(NP=64)
      INTEGER i,n
      REAL func,amu0,check,xx,a(NP),b(NP),x(NP),w(NP),anu(2*NP),
     *     alpha(2*NP-1),beta(2*NP-1)
1     write(*,*) 'Enter N'
      read(*,*,END=99) n
      alpha(1)=.5
      beta(1)=1.
      do 11 i=2,2*n-1
        alpha(i)=0.5
        beta(i)=1./(4.*(4.-1./(i-1)**2))
11    continue
      anu(1)=1.
      anu(2)=-.25
      do 12 i=2,2*n-1
        anu(i+1)=-anu(i)*i*(i-1)/(2.*(i+1)*(2*i-1))
12    continue
      call orthog(n,anu,alpha,beta,a,b)
      amu0=1.
      call gaucof(n,a,b,amu0,x,w)
      write(*,'(/1x,t3,a,t10,a,t22,a/)') '#','X(I)','W(I)'
      do 13 i=1,n
        write(*,'(1x,i2,2e14.6)') i,x(i),w(i)
13    continue
      check=0.
      do 14 i=1,n
        check=check+w(i)
14    continue
      write(*,'(/1x,a,e15.7,a,e15.7)') 'Check value:',check,
     *  '  should be:',amu0
C     demonstrate the use of ORTHOG for an integral
      xx=0.0
      do 15 i=1,n
        xx=xx+w(i)*func(x(i))
15    continue
      write(*,'(/1x,a,f12.6)') 'Integral from ORTHOG:',xx
      write(*,'(1x,a,f12.6)') 'Actual value:        ',log(2.)
      go to 1
99    stop
      END

      REAL FUNCTION func(x)
      REAL x
      func=1./(1.+x)**2
      END
