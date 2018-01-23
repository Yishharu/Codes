      PROGRAM xcholsl
C     driver for routine cholsl
      INTEGER N
      PARAMETER (N=3)
      INTEGER i,j,k
      REAL sum,a(N,N),aorig(N,N),atest(N,N),chol(N,N),p(N),b(N),x(N)
      DATA a/100.,15.,.01,15.,2.3,.01,.01,.01,1./
      DATA b/.4,.02,99./
      do 12 i=1,N
        do 11 j=1,N
          aorig(i,j)=a(i,j)
11      continue
12    continue
      call choldc(a,N,N,p)
      do 14 i=1,N
        do 13 j=1,N
          if (i.gt.j) then
            chol(i,j)=a(i,j)
          else if (i.eq.j) then
            chol(i,j)=p(i)
          else
            chol(i,j)=0.
          endif
13      continue
14    continue
      do 17 i=1,N
        do 16 j=1,N
          sum=0.
          do 15 k=1,N
            sum=sum+chol(i,k)*chol(j,k)
15        continue
          atest(i,j)=sum
16      continue
17    continue
      write(*,*) 'Original matrix:'
      write(*,100) ((aorig(i,j),j=1,N),i=1,N)
      write(*,*)
      write(*,*) 'Product of Cholesky factors:'
      write(*,100) ((atest(i,j),j=1,N),i=1,N)
100   format(1p3e16.6)
      write(*,*)
      call cholsl(a,N,N,p,b,x)
      do 19 i=1,N
        sum=0.
        do 18 j=1,N
          sum=sum+aorig(i,j)*x(j)
18      continue
        p(i)=sum
19    continue
      write(*,*) 'Check solution vector:'
      write(*,101) (p(i),b(i),i=1,N)
101   format(1p2e16.6)
      END
