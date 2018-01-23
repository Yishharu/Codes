      PROGRAM xsvdcmp
C     driver for routine svdcmp
      INTEGER MP,NP
      PARAMETER(MP=20,NP=20)
      INTEGER j,k,l,m,n
      REAL a(MP,NP),u(MP,NP),w(NP),v(NP,NP)
      CHARACTER dummy*3
      open(7,file='MATRX3.DAT',status='old')
10    read(7,'(a)') dummy
      if (dummy.eq.'END') goto 99
      read(7,*)
      read(7,*) m,n
      read(7,*)
C     copy original matrix into u
      do 12 k=1,m
        read(7,*) (a(k,l), l=1,n)
        do 11 l=1,n
          u(k,l)=a(k,l)
11      continue
12    continue
C     perform decomposition
      call svdcmp(u,m,n,MP,NP,w,v)
C     print results
      write(*,*) 'Decomposition Matrices:'
      write(*,*) 'Matrix U'
      do 13 k=1,m
        write(*,'(1x,6f12.6)') (u(k,l),l=1,n)
13    continue
      write(*,*) 'Diagonal of Matrix W'
      write(*,'(1x,6f12.6)') (w(k),k=1,n)
      write(*,*) 'Matrix V-Transpose'
      do 14 k=1,n
        write(*,'(1x,6f12.6)') (v(l,k),l=1,n)
14    continue
      write(*,*) 'Check product against original matrix:'
      write(*,*) 'Original Matrix:'
      do 15 k=1,m
        write(*,'(1x,6f12.6)') (a(k,l),l=1,n)
15    continue
      write(*,*) 'Product U*W*(V-Transpose):'
      do 18 k=1,m
        do 17 l=1,n
          a(k,l)=0.0
          do 16 j=1,n
            a(k,l)=a(k,l)+u(k,j)*w(j)*v(l,j)
16        continue
17      continue
        write(*,'(1x,6f12.6)') (a(k,l),l=1,n)
18    continue
      write(*,*) '***********************************'
      write(*,*) 'Press RETURN for next problem'
      read(*,*)
      goto 10
99    close(7)
      END
