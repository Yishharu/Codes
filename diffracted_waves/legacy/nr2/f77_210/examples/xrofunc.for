      PROGRAM xrofunc
C     driver for routine rofunc
      INTEGER NMAX
      REAL SPREAD
      PARAMETER(NMAX=1000,SPREAD=0.05)
      INTEGER i,idum,npt
      REAL aa,abdev,x(NMAX),y(NMAX),arr(NMAX),b,rf,gasdev,rofunc
      COMMON /arrays/ x,y,arr,aa,abdev,npt
      idum=-11
      npt=100
      do 11 i=1,npt
        x(i)=0.1*i
        y(i)=-2.0*x(i)+1.0+SPREAD*gasdev(idum)
11    continue
      write(*,'(/1x,t10,a,t20,a,t26,a,t37,a/)') 'B','A','ROFUNC','ABDEV'
      do 12 i=-5,5
        b=-2.0+0.02*i
        rf=rofunc(b)
        write(*,'(1x,4f10.2)') b,aa,rofunc(b),abdev
12    continue
      END
