      PROGRAM xludcmp
C     driver for routine ludcmp
      INTEGER NP
      PARAMETER(NP=20)
      INTEGER j,k,l,m,n,indx(NP),jndx(NP)
      REAL d,dum,a(NP,NP),xl(NP,NP),xu(NP,NP),x(NP,NP)
      CHARACTER txt*3
      open(7,file='MATRX1.DAT',status='old')
      read(7,*)
10    read(7,*)
      read(7,*) n,m
      read(7,*)
      read(7,*) ((a(k,l), l=1,n), k=1,n)
      read(7,*)
      read(7,*) ((x(k,l), k=1,n), l=1,m)
C     print out a-matrix for comparison with product of lower
C     and upper decomposition matrices.
      write(*,*) 'Original matrix:'
      do 11 k=1,n
        write(*,'(1x,6f12.6)') (a(k,l), l=1,n)
11    continue
C     perform the decomposition
      call ludcmp(a,n,NP,indx,d)
C     compose separately the lower and upper matrices
      do 13 k=1,n
        do 12 l=1,n
          if (l.gt.k) then
            xu(k,l)=a(k,l)
            xl(k,l)=0.0
          else if (l.lt.k) then
            xu(k,l)=0.0
            xl(k,l)=a(k,l)
          else
            xu(k,l)=a(k,l)
            xl(k,l)=1.0
          endif
12      continue
13    continue
C     compute product of lower and upper matrices for
C     comparison with original matrix.
      do 16 k=1,n
        jndx(k)=k
        do 15 l=1,n
          x(k,l)=0.0
          do 14 j=1,n
            x(k,l)=x(k,l)+xl(k,j)*xu(j,l)
14        continue
15      continue
16    continue
      write(*,*) 'Product of lower and upper matrices (unscrambled):'
      do 17 k=1,n
        dum=jndx(indx(k))
        jndx(indx(k))=jndx(k)
        jndx(k)=dum
17    continue
      do 19 k=1,n
        do 18 j=1,n
          if (jndx(j).eq.k) then
            write(*,'(1x,6f12.6)') (x(j,l), l=1,n)
          endif
18      continue
19    continue
      write(*,*) 'Lower matrix of the decomposition:'
      do 21 k=1,n
        write(*,'(1x,6f12.6)') (xl(k,l), l=1,n)
21    continue
      write(*,*) 'Upper matrix of the decomposition:'
      do 22 k=1,n
        write(*,'(1x,6f12.6)') (xu(k,l), l=1,n)
22    continue
      write(*,*) '***********************************'
      write(*,*) 'Press RETURN for next problem:'
      read(*,*)
      read(7,'(a3)') txt
      if (txt.ne.'END') goto 10
      close(7)
      END
