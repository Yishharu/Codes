      PROGRAM xbnldev
C     driver for routine bnldev
      INTEGER N,NPTS,ISCAL,NN
      PARAMETER(N=20,NPTS=1000,ISCAL=200,NN=100)
      INTEGER i,idum,j,k,klim,llen
      REAL bnldev,dist(21),pp,xm
      CHARACTER text(50)*1
      idum=-133
      llen=50
10    do 11 j=1,21
        dist(j)=0.0
11    continue
      write(*,*)
     *     'Mean of binomial distribution (0 to 20) (Negative to END)'
      read(*,*) xm
      if (xm.lt.0) goto 99
      pp=xm/NN
      do 12 i=1,NPTS
        j=int(bnldev(pp,NN,idum))
        if ((j.ge.0).and.(j.le.N)) dist(j+1)=dist(j+1)+1
12    continue
      write(*,'(1x,t5,a,t10,a,t18,a)') 'x','p(x)','graph:'
      do 15 j=1,N
        dist(j)=dist(j)/NPTS
        do 13 k=1,50
          text(k)=' '
13      continue
        text(1)='*'
        klim=int(ISCAL*dist(j))
        if (klim.gt.llen) klim=llen
        do 14 k=1,klim
          text(k)='*'
14      continue
        write(*,'(1x,f5.1,f8.4,3x,50a1)') float(j-1),dist(j),
     *       (text(k),k=1,50)
15    continue
      goto 10
99    END
