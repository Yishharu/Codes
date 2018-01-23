      PROGRAM xsprstp
C     driver for routine sprstp
      INTEGER NP,NMAX
      PARAMETER(NP=5,NMAX=2*NP*NP+1)
      INTEGER i,j,ija(NMAX),ijat(NMAX)
      REAL a(NP,NP),at(NP,NP),sa(NMAX),sat(NMAX)
      DATA a/3.0,0.0,0.0,0.0,0.0,
     *     0.0,4.0,7.0,0.0,0.0,
     *     1.0,0.0,5.0,0.0,0.0,
     *     0.0,0.0,9.0,0.0,6.0,
     *     0.0,0.0,0.0,2.0,5.0/
      call sprsin(a,NP,NP,0.5,NMAX,sa,ija)
      call sprstp(sa,ija,sat,ijat)
      do 12 i=1,NP
        do 11 j=1,NP
          at(i,j)=0.0
11      continue
12    continue
      do 14 i=1,NP
        at(i,i)=sat(i)
        do 13 j=ijat(i),ijat(i+1)-1
          at(i,ijat(j))=sat(j)
13      continue
14    continue
      write(*,*) 'Original matrix:'
      write(*,'(5f7.1)') ((a(i,j),j=1,NP),i=1,NP)
      write(*,*) 'Transpose:'
      write(*,'(5f7.1)') ((at(i,j),j=1,NP),i=1,NP)
      END
