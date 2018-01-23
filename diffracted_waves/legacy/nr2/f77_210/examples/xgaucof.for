      PROGRAM xgaucof
C     driver for routine gaucof
      INTEGER NP
      REAL SQRTPI
      PARAMETER(NP=64,SQRTPI=1.7724539)
      INTEGER i,n
      REAL amu0,check,a(NP),b(NP),x(NP),w(NP)
1     write(*,*) 'Enter N'
      read(*,*,END=99) n
      do 11 i=1,n-1
        a(i)=0.
        b(i+1)=i*.5
11    continue
      a(n)=0.
C     b(1) is arbitrary for call to TQLI
      amu0=SQRTPI
      call gaucof(n,a,b,amu0,x,w)
      write(*,'(/1x,t3,a,t10,a,t22,a/)') '#','X(I)','W(I)'
      do 12 i=1,n
        write(*,'(1x,i2,2e14.6)') i,x(i),w(i)
12    continue
      check=0.
      do 13 i=1,n
        check=check+w(i)
13    continue
      write(*,'(/1x,a,e15.7,a,e15.7)') 'Check value:',check,
     *  '  should be:',SQRTPI
      go to 1
99    stop
      END
