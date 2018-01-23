      PROGRAM xgamdev
C     driver for routine gamdev
      INTEGER N,NPTS,ISCAL,LLEN
      PARAMETER(N=20,NPTS=10000,ISCAL=200,LLEN=50)
      INTEGER i,ia,idum,j,k,klim
      REAL gamdev,dist(21)
      CHARACTER text(50)*1
      idum=-13
10    do 11 j=1,21
        dist(j)=0.0
11    continue
      write(*,*) 'Order of Gamma distribution (n=1..20); -1 to END.'
      read(*,*) ia
      if (ia.le.0) goto 99
      if (ia.gt.20) goto 10
      do 12 i=1,NPTS
        j=int(gamdev(ia,idum))+1
        if ((j.ge.1).and.(j.le.21)) dist(j)=dist(j)+1
12    continue
      write(*,'(1x,a,i2,a,i6,a)') 'Gamma-distribution deviate, order ',
     *     ia,' of ',NPTS,' points'
      write(*,'(1x,t6,a,t14,a,t23,a)') 'x','p(x)','graph:'
      do 15 j=1,20
        dist(j)=dist(j)/NPTS
        do 13 k=1,50
          text(k)=' '
13      continue
        klim=int(ISCAL*dist(j))
        if (klim.gt.LLEN) klim=LLEN
        do 14 k=1,klim
          text(k)='*'
14      continue
        write(*,'(1x,f7.2,f10.4,4x,50a1)')
     *       float(j),dist(j),(text(k),k=1,50)
15    continue
      goto 10
99    END
