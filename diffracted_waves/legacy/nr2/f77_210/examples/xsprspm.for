      PROGRAM xsprspm
C     driver for routine sprspm
      INTEGER NP,NMAX
      PARAMETER(NP=5,NMAX=2*NP*NP+1)
      INTEGER i,j,k,ija(NMAX),ijb(NMAX),ijbt(NMAX),ijc(NMAX)
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
C     specify tridiagonal output, using fact that a is tridiagonal
      do 11 i=1,ija(ija(1)-1)-1
        ijc(i)=ija(i)
11    continue
      call sprspm(sa,ija,sbt,ijbt,sc,ijc)
      do 14 i=1,NP
        do 13 j=1,NP
          ab(i,j)=0.0
          do 12 k=1,NP
            ab(i,j)=ab(i,j)+a(i,k)*b(k,j)
12        continue
13      continue
14    continue
      write(*,*) 'Reference matrix:'
      write(*,'(5f7.1)') ((ab(i,j),j=1,NP),i=1,NP)
      write(*,*) 'sprspm matrix (should show only tridiagonals):'
      do 16 i=1,NP
        do 15 j=1,NP
          c(i,j)=0.0
15      continue
16    continue
      do 18 i=1,NP
        c(i,i)=sc(i)
        do 17 j=ijc(i),ijc(i+1)-1
          c(i,ijc(j))=sc(j)
17      continue
18    continue
      write(*,'(5f7.1)') ((c(i,j),j=1,NP),i=1,NP)
      END
