      PROGRAM xbalanc
C     driver for routine balanc
      INTEGER NP
      PARAMETER(NP=5)
      INTEGER i,j
      REAL a(NP,NP),r(NP),c(NP)
      DATA a/1.0,1.0,1.0,1.0,1.0,100.0,1.0,100.0,1.0,100.0,
     *     1.0,1.0,1.0,1.0,1.0,100.0,1.0,100.0,1.0,100.0,
     *     1.0,1.0,1.0,1.0,1.0/
C     print norms
      do 12 i=1,NP
        r(i)=0.0
        c(i)=0.0
        do 11 j=1,NP
          r(i)=r(i)+abs(a(i,j))
          c(i)=c(i)+abs(a(j,i))
11      continue
12    continue
      write(*,*) 'Rows:'
      write(*,*) (r(i),i=1,NP)
      write(*,*) 'Columns:'
      write(*,*) (c(i),i=1,NP)
      write(*,'(/1x,a/)') '***** Balancing Matrix *****'
      call balanc(a,NP,NP)
C     print norms
      do 14 i=1,NP
        r(i)=0.0
        c(i)=0.0
        do 13 j=1,NP
          r(i)=r(i)+abs(a(i,j))
          c(i)=c(i)+abs(a(j,i))
13      continue
14    continue
      write(*,*) 'Rows:'
      write(*,*) (r(i),i=1,NP)
      write(*,*) 'Columns:'
      write(*,*) (c(i),i=1,NP)
      END
