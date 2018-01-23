      PROGRAM xqrupdt
C     driver for routine qrdupd
      INTEGER NP
      PARAMETER(NP=20)
      INTEGER i,j,k,l,m,n
      REAL con,a(NP,NP),au(NP,NP),c(NP),d(NP),q(NP,NP),qt(NP,NP),
     *     r(NP,NP),s(NP,NP),u(NP),v(NP),x(NP,NP)
      CHARACTER txt*3
      LOGICAL sing
      open(7,file='MATRX1.DAT',status='old')
      read(7,*)
10    read(7,*)
      read(7,*) n,m
      read(7,*)
      read(7,*) ((a(k,l), l=1,n), k=1,n)
      read(7,*)
      read(7,*) ((s(k,l), k=1,n), l=1,m)
C     print out a-matrix for comparison with product of Q and R
C     decomposition matrices.
      write(*,*) 'Original matrix:'
      do 11 k=1,n
        write(*,'(1x,6f12.6)') (a(k,l), l=1,n)
11      continue
C     updated matrix we'll use later
      do 13 k=1,n
        do 12 l=1,n
            au(k,l)=a(k,l)+s(k,1)*s(l,2)
12        continue
13      continue
C     perform the initial decomposition
      call qrdcmp(a,n,NP,c,d,sing)
      if (sing) write(*,*) 'Singularity in QR decomposition.'
C     find the Q and R matrices
      do 15 k=1,n
        do 14 l=1,n
          if (l.gt.k) then
            r(k,l)=a(k,l)
            q(k,l)=0.0
          else if (l.lt.k) then
            r(k,l)=0.0
            q(k,l)=0.0
          else
            r(k,l)=d(k)
            q(k,l)=1.0
          endif
14        continue
15      continue
      do 23 i=n-1,1,-1
        con=0.0
        do 16 k=i,n
          con=con+a(k,i)**2
16        continue
        con=con/2.0
        do 19 k=i,n
          do 18 l=i,n
            qt(k,l)=0.0
            do 17 j=i,n
              qt(k,l)=qt(k,l)+q(j,l)*a(k,i)*a(j,i)/con
17            continue
18          continue
19        continue
        do 22 k=i,n
          do 21 l=i,n
            q(k,l)=q(k,l)-qt(k,l)
21          continue
22        continue
23      continue
C     compute product of Q and R matrices for comparison with original matrix.
      do 26 k=1,n
        do 25 l=1,n
          x(k,l)=0.0
          do 24 j=1,n
            x(k,l)=x(k,l)+q(k,j)*r(j,l)
24          continue
25        continue
26      continue
      write(*,*) 'Product of Q and R matrices:'
      do 27 k=1,n
          write(*,'(1x,6f12.6)') (x(k,l), l=1,n)
27        continue
      write(*,*) 'Q matrix of the decomposition:'
      do 28 k=1,n
        write(*,'(1x,6f12.6)') (q(k,l), l=1,n)
28      continue
      write(*,*) 'R matrix of the decomposition:'
      do 29 k=1,n
        write(*,'(1x,6f12.6)') (r(k,l), l=1,n)
29      continue
C     Q transpose
      do 32 k=1,n
        do 31 l=1,n
          qt(k,l)=q(l,k)
31        continue
32      continue
      do 34 k=1,n
        v(k)=s(k,2)
        u(k)=0.0
        do 33 l=1,n
          u(k)=u(k)+qt(k,l)*s(l,1)
33        continue
34      continue
      call qrupdt(r,qt,n,NP,u,v)
      do 37 k=1,n
        do 36 l=1,n
          x(k,l)=0.0
          do 35 j=1,n
            x(k,l)=x(k,l)+qt(j,k)*r(j,l)
35          continue
36        continue
37      continue
      write(*,*) 'Updated matrix:'
      do 38 k=1,n
        write(*,'(1x,6f12.6)') (au(k,l), l=1,n)
38      continue
      write(*,*) 'Product of new Q and R matrices:'
      do 39 k=1,n
          write(*,'(1x,6f12.6)') (x(k,l), l=1,n)
39        continue
      write(*,*) 'New Q matrix'
      do 41 k=1,n
        write(*,'(1x,6f12.6)') (qt(l,k), l=1,n)
41      continue
      write(*,*) 'New R matrix'
      do 42 k=1,n
        write(*,'(1x,6f12.6)') (r(k,l), l=1,n)
42      continue
      write(*,*) '***********************************'
      write(*,*) 'Press RETURN for next problem:'
      read(*,*)
      read(7,'(a3)') txt
      if (txt.ne.'END') goto 10
      close(7)
      END
