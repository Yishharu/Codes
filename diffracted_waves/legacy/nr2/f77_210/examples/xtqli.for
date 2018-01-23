      PROGRAM xtqli
C     driver for routine tqli
      INTEGER NP
      REAL TINY
      PARAMETER(NP=10,TINY=1.0e-6)
      INTEGER i,j,k
      REAL a(NP,NP),c(NP,NP),d(NP),e(NP),f(NP)
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
      call tqli(d,e,NP,NP,a)
      write(*,'(/1x,a)') 'Eigenvectors for a real symmetric matrix'
      do 16 i=1,NP
        do 14 j=1,NP
          f(j)=0.0
          do 13 k=1,NP
            f(j)=f(j)+c(j,k)*a(k,i)
13        continue
14      continue
        write(*,'(/1x,a,i3,a,f10.6)') 'Eigenvalue',i,' =',d(i)
        write(*,'(/1x,t7,a,t17,a,t31,a)') 'Vector','Mtrx*Vect.','Ratio'
        do 15 j=1,NP
          if (abs(a(j,i)).lt.TINY) then
            write(*,'(1x,2f12.6,a12)') a(j,i),f(j),'div. by 0'
          else
            write(*,'(1x,2f12.6,e14.6)') a(j,i),f(j),
     *           f(j)/a(j,i)
          endif
15      continue
        write(*,'(/1x,a)') 'press ENTER to continue...'
        read(*,*)
16    continue
      END
