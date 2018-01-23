      PROGRAM xsprstm
C     driver for routine sprstm
      INTEGER NP,NMAX
      REAL THRESH
      PARAMETER(NP=5,NMAX=2*NP*NP+1,THRESH=0.99)
      INTEGER i,j,k,ija(NMAX),ijb(NMAX),ijbt(NMAX),ijc(NMAX),msize
      REAL sa(NMAX),sb(NMAX),sbt(NMAX),sc(NMAX)
      REAL a(NP,NP),b(NP,NP),c(NP,NP),ab(NP,NP)
      DATA a/1.0,0.5,0.0,0.0,0.0,
     *     0.5,2.0,0.5,0.0,0.0,
     *     0.0,0.5,3.0,0.5,0.0,
     *     0.0,0.0,0.5,4.0,0.5,
     *     0.0,0.0,0.0,0.5,5.0/
      DATA b/1.0,1.0,0.0,0.0,0.0,
     *     1.0,2.0,1.0,0.0,0.0,
     *     0.0,1.0,3.0,1.0,0.0,
     *     0.0,0.0,1.0,4.0,1.0,
     *     0.0,0.0,0.0,1.0,5.0/
      call sprsin(a,NP,NP,0.5,NMAX,sa,ija)
      call sprsin(b,NP,NP,0.5,NMAX,sb,ijb)
      call sprstp(sb,ijb,sbt,ijbt)
      msize=ija(ija(1)-1)-1
      call sprstm(sa,ija,sbt,ijbt,THRESH,msize,sc,ijc)
      do 13 i=1,NP
        do 12 j=1,NP
          ab(i,j)=0.0
          do 11 k=1,NP
            ab(i,j)=ab(i,j)+a(i,k)*b(k,j)
11        continue
12      continue
13    continue
      write(*,*) 'Reference matrix:'
      write(*,'(5f7.1)') ((ab(i,j),j=1,NP),i=1,NP)
      write(*,*) 'sprstm matrix (off-diag. elements of mag >):',THRESH
      do 15 i=1,NP
        do 14 j=1,NP
          c(i,j)=0.0
14      continue
15    continue
      do 17 i=1,NP
        c(i,i)=sc(i)
        do 16 j=ijc(i),ijc(i+1)-1
          c(i,ijc(j))=sc(j)
16      continue
17    continue
      write(*,'(5f7.1)') ((c(i,j),j=1,NP),i=1,NP)
      END
