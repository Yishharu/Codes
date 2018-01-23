      PROGRAM xsvbksb
C     driver for routine svbksb, which calls routine svdcmp
      INTEGER MP,NP
      PARAMETER(MP=20,NP=20)
      INTEGER j,k,l,m,n
      REAL a(NP,NP),b(NP,MP),u(NP,NP),w(NP)
      REAL v(NP,NP),c(NP),x(NP)
      REAL wmax,wmin
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
C     copy a into u
      do 12 k=1,n
        do 11 l=1,n
          u(k,l)=a(k,l)
11      continue
12    continue
C     decompose matrix a
      call svdcmp(u,n,n,NP,NP,w,v)
C     find maximum singular value
      wmax=0.0
      do 13 k=1,n
        if (w(k).gt.wmax) wmax=w(k)
13    continue
C     define "small"
      wmin=wmax*(1.0e-6)
C     zero the "small" singular values
      do 14 k=1,n
        if (w(k).lt.wmin) w(k)=0.0
14    continue
C     backsubstitute for each right-hand side vector
      do 18 l=1,m
        write(*,'(1x,a,i2)') 'Vector number ',l
        do 15 k=1,n
          c(k)=b(k,l)
15      continue
        call svbksb(u,w,v,n,n,NP,NP,c,x)
        write(*,*) '    Solution vector is:'
        write(*,'(1x,6f12.6)') (x(k), k=1,n)
        write(*,*) '    Original right-hand side vector:'
        write(*,'(1x,6f12.6)') (c(k), k=1,n)
        write(*,*) '    Result of (matrix)*(sol''n vector):'
        do 17 k=1,n
          c(k)=0.0
          do 16 j=1,n
            c(k)=c(k)+a(k,j)*x(j)
16        continue
17      continue
        write(*,'(1x,6f12.6)') (c(k), k=1,n)
18    continue
      write(*,*) '***********************************'
      write(*,*) 'Press RETURN for next problem'
      read(*,*)
      goto 10
99    close(7)
      END
