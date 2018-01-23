      PROGRAM xtred2
C     driver for routine tred2
      INTEGER NP
      PARAMETER(NP=10)
      INTEGER i,j,k,l,m
      REAL a(NP,NP),c(NP,NP),d(NP),e(NP),f(NP,NP)
      DATA c/5.0,4.3,3.0,2.0,1.0,0.0,-1.0,-2.0,-3.0,-4.0,
     *     4.3,5.1,4.0,3.0,2.0,1.0,0.0,-1.0,-2.0,-3.0,
     *     3.0,4.0,5.0,4.0,3.0,2.0,1.0,0.0,-1.0,-2.0,
     *     2.0,3.0,4.0,5.0,4.0,3.0,2.0,1.0,0.0,-1.0,
     *     1.0,2.0,3.0,4.0,5.0,4.0,3.0,2.0,1.0,0.0,
     *     0.0,1.0,2.0,3.0,4.0,5.0,4.0,3.0,2.0,1.0,
     *     -1.0,0.0,1.0,2.0,3.0,4.0,5.0,4.0,3.0,2.0,
     *     -2.0,-1.0,0.0,1.0,2.0,3.0,4.0,5.0,4.0,3.0,
     *     -3.0,-2.0,-1.0,0.0,1.0,2.0,3.0,4.0,5.0,4.0,
     *     -4.0,-3.0,-2.0,-1.0,0.0,1.0,2.0,3.0,4.0,5.0/
      do 12 i=1,NP
        do 11 j=1,NP
          a(i,j)=c(i,j)
11      continue
12    continue
      call tred2(a,NP,NP,d,e)
      write(*,'(/1x,a)') 'Diagonal elements'
      write(*,'(1x,5f12.6)') (d(i),i=1,NP)
      write(*,'(/1x,a)') 'Off-diagonal elements'
      write(*,'(1x,5f12.6)') (e(i),i=2,NP)
C     check transformation matrix
      do 16 j=1,NP
        do 15 k=1,NP
          f(j,k)=0.0
          do 14 l=1,NP
            do 13 m=1,NP
              f(j,k)=f(j,k)
     *             +a(l,j)*c(l,m)*a(m,k)
13          continue
14        continue
15      continue
16    continue
C     how does it look?
      write(*,'(/1x,a)') 'Tridiagonal matrix'
      do 17 i=1,NP
        write(*,'(1x,10f7.2)') (f(i,j),j=1,NP)
17    continue
      END
