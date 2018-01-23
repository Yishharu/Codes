      PROGRAM xgaussj
C     driver for routine gaussj
      INTEGER MP,NP
      PARAMETER(MP=20,NP=20)
      INTEGER j,k,l,m,n
      REAL a(NP,NP),b(NP,MP),ai(NP,NP),x(NP,MP)
      REAL u(NP,NP),t(NP,MP)
      CHARACTER dummy*3
      open(7,file='MATRX1.DAT',status='old')
10    read(7,'(a)') dummy
      if (dummy.eq.'END') goto 99
      read(7,*)
      read(7,*) n,m
      read(7,*)
      read(7,*) ((a(k,l), l=1,n), k=1,n)
      read(7,*)
      read(7,*) ((b(k,l), k=1,n), l=1,m)
C     save Matrices for later testing of results
      do 13 l=1,n
        do 11 k=1,n
          ai(k,l)=a(k,l)
11      continue
        do 12 k=1,m
          x(l,k)=b(l,k)
12      continue
13    continue
C     invert Matrix
      call gaussj(ai,n,NP,x,m,MP)
      write(*,*) 'Inverse of Matrix A : '
      do 14 k=1,n
        write(*,'(1h ,(6f12.6))') (ai(k,l), l=1,n)
14    continue
C     test Results
C     check Inverse
      write(*,*) 'A times A-inverse (compare with unit matrix)'
      do 17 k=1,n
        do 16 l=1,n
          u(k,l)=0.0
          do 15 j=1,n
            u(k,l)=u(k,l)+a(k,j)*ai(j,l)
15        continue
16      continue
        write(*,'(1h ,(6f12.6))') (u(k,l), l=1,n)
17    continue
C     check Vector Solutions
      write(*,*) 'Check the following vectors for equality:'
      write(*,'(t12,a8,t23,a12)') 'Original','Matrix*Sol''n'
      do 21 l=1,m
        write(*,'(1x,a,i2,a)') 'Vector ',l,':'
        do 19 k=1,n
          t(k,l)=0.0
          do 18 j=1,n
            t(k,l)=t(k,l)+a(k,j)*x(j,l)
18        continue
          write(*,'(8x,2f12.6)') b(k,l),t(k,l)
19      continue
21    continue
      write(*,*) '***********************************'
      write(*,*) 'Press RETURN for next problem:'
      read(*,*)
      goto 10
99    close(7)
      END
