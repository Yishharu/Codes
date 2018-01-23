      PROGRAM xpredic
C     driver for routine predic
      INTEGER NPTS,NPOLES,NFUT
      REAL PI
      PARAMETER(NPTS=500,NPOLES=10,NFUT=20,PI=3.1415926)
      INTEGER i,n
      REAL f,dum,data(NPTS),d(NPOLES),future(NFUT)
      f(n)=exp(-1.0*n/NPTS)*sin(2.0*PI*n/50.0)
     *     +exp(-2.0*n/NPTS)*sin(2.2*PI*n/50.0)
      do 11 i=1,NPTS
        data(i)=f(i)
11    continue
      call memcof(data,NPTS,NPOLES,dum,d)
      call fixrts(d,NPOLES)
      call predic(data,NPTS,d,NPOLES,future,NFUT)
      write(*,'(6x,a,t13,a,t25,a)') 'I','Actual','PREDIC'
      do 12 i=1,NFUT
        write(*,'(1x,i6,2f12.6)') i,f(i+NPTS),future(i)
12    continue
      END
