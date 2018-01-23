      PROGRAM xvander
C     driver for routine vander
      INTEGER N
      PARAMETER(N=5)
      INTEGER i,j
      DOUBLE PRECISION sum,x(N),q(N),w(N),term(N)
      DATA x/1.0d0,1.5d0,2.0d0,2.5d0,3.0d0/
      DATA q/1.0d0,1.5d0,2.0d0,2.5d0,3.0d0/
      call vander(x,w,q,N)
      write(*,*) 'Solution vector:'
      do 11 i=1,N
        write(*,'(5x,a2,i1,a4,e12.6)') 'W(',i,') = ',w(i)
11    continue
      write(*,'(/1x,a)') 'Test of solution vector:'
      write(*,'(1x,t6,a,t19,a)') 'mtrx*sol''n','original'
      sum=0.0
      do 12 i=1,N
        term(i)=w(i)
        sum=sum+w(i)
12    continue
      write(*,'(1x,2f12.4)') sum,q(1)
      do 14 i=2,N
        sum=0.0
        do 13 j=1,N
          term(j)=term(j)*x(j)
          sum=sum+term(j)
13      continue
        write(*,'(1x,2f12.4)') sum,q(i)
14    continue
      END
