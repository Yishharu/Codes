      PROGRAM xpoidev
C     driver for routine poidev
      INTEGER N,NPTS,ISCAL,LLEN
      PARAMETER(N=20,NPTS=10000,ISCAL=200,LLEN=50)
      INTEGER i,idum,j,k,klim
      REAL poidev,xm,dist(21)
      CHARACTER text(50)*1
      idum=-13
10    do 11 j=1,21
        dist(j)=0.0
11    continue
      write(*,*) 'Mean of Poisson distrib. (x=0 to 20); neg. to END'
      read(*,*) xm
      if (xm.lt.0.0) goto 99
      if (xm.gt.20.0) goto 10
      do 12 i=1,NPTS
        j=int(poidev(xm,idum))+1
        if ((j.ge.1).and.(j.le.21)) dist(j)=dist(j)+1
12    continue
      write(*,'(1x,a,f5.2,a,i6,a)')
     *     'Poisson-distributed deviate, mean ',
     *     xm,' of ',NPTS,' points'
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
