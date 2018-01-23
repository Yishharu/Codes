      PROGRAM xgasdev
C     driver for routine gasdev
      INTEGER N,NP1,NOVER2,NPTS,ISCAL,LLEN
      PARAMETER(N=20,NP1=N+1,NOVER2=N/2,NPTS=10000,ISCAL=400,LLEN=50)
      INTEGER i,idum,j,k,klim
      REAL gasdev,x,dist(NP1)
      CHARACTER text(50)*1
      idum=-13
      do 11 j=1,NP1
        dist(j)=0.0
11    continue
      do 12 i=1,NPTS
        j=nint(0.25*N*gasdev(idum))+NOVER2+1
        if ((j.ge.1).and.(j.le.NP1)) dist(j)=dist(j)+1
12    continue
      write(*,'(1x,a,i6,a)')
     *     'Normally distributed deviate of ',NPTS,' points'
      write(*,'(1x,t6,a,t14,a,t23,a)') 'x','p(x)','graph:'
      do 15 j=1,NP1
        dist(j)=dist(j)/NPTS
        do 13 k=1,50
          text(k)=' '
13      continue
        klim=int(ISCAL*dist(j))
        if (klim.gt.LLEN) klim=LLEN
        do 14 k=1,klim
          text(k)='*'
14      continue
        x=float(j)/(0.25*N)
        write(*,'(1x,f7.2,f10.4,4x,50a1)')
     *       x,dist(j),(text(k),k=1,50)
15    continue
      END
