      PROGRAM xtoeplz
C     driver for routine toeplz
      INTEGER N,N2
      PARAMETER(N=5,N2=2*N)
      INTEGER i,j
      REAL sum,x(N),y(N),r(N2)
      do 11 i=1,N
        y(i)=0.1*i
11    continue
      do 12 i=1,2*N-1
        r(i)=1./i
12    continue
      call toeplz(r,x,y,N)
      write(*,*) 'Solution vector:'
      do 13 i=1,N
        write(*,'(5x,a2,i1,a4,e13.6)') 'X(',i,') = ',x(i)
13    continue
      write(*,'(/1x,a)') 'Test of solution:'
      write(*,'(1x,t6,a,t19,a)') 'mtrx*soln','original'
      do 15 i=1,N
        sum=0.0
        do 14 j=1,N
          sum=sum+r(N+i-j)*x(j)
14      continue
        write(*,'(1x,2f12.4)') sum,y(i)
15    continue
      END
