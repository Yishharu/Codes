      PROGRAM xsplie2
C     driver for routine splie2
      INTEGER M,N
      PARAMETER(M=10,N=10)
      INTEGER i,j
      REAL x1x2,x1(M),x2(N),y(M,N),y2(M,N)
      do 11 i=1,M
        x1(i)=0.2*i
11    continue
      do 12 i=1,N
        x2(i)=0.2*i
12    continue
      do 14 i=1,M
        do 13 j=1,N
          x1x2=x1(i)*x2(j)
          y(i,j)=x1x2**2
13      continue
14    continue
      call splie2(x1,x2,y,M,N,y2)
      write(*,'(/1x,a)') 'Second derivatives from SPLIE2'
      write(*,'(1x,a/)') 'Natural spline assumed'
      do 15 i=1,5
        write(*,'(1x,5f12.6)') (y2(i,j),j=1,5)
15    continue
      write(*,'(/1x,a/)') 'Actual second derivatives'
      do 17 i=1,5
        do 16 j=1,5
          y2(i,j)=2.0*(x1(i)**2)
16      continue
        write(*,'(1x,5f12.6)') (y2(i,j),j=1,5)
17    continue
      END
