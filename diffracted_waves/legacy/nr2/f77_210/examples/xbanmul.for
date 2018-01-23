      PROGRAM xbanmul
C     driver for routine banmul
      INTEGER NP,M1,M2,MP
      PARAMETER (NP=7,M1=2,M2=1,MP=M1+1+M2)
      INTEGER i,j,k
      REAL a(NP,MP),aa(NP,NP),ax(NP),b(NP),x(NP)
      do 12 i=1,M1
        do 11 j=1,NP
          a(j,i)=10*j+i
11      continue
12    continue
C     lower band
      do 13 i=1,NP
        a(i,M1+1)=i
13    continue
C     diagonal
      do 15 i=1,M2
        do 14 j=1,NP
          a(j,M1+1+i)=0.1*j+i
14      continue
15    continue
C     upper band
      do 17 i=1,NP
        do 16 j=1,NP
          k=i-M1-1
          if (j.ge.max(1,1+k).and.j.le.min(M1+M2+1+k,NP)) then
            aa(i,j)=a(i,j-k)
          else
            aa(i,j)=0.0
          endif
16      continue
17    continue
      do 18 i=1,NP
        x(i)=i/10.0
18    continue
      call banmul(a,NP,M1,M2,NP,MP,x,b)
      do 21 i=1,NP
        ax(i)=0.0
        do 19 j=1,NP
          ax(i)=ax(i)+aa(i,j)*x(j)
19      continue
21    continue
      write(*,'(t8,a,t32,a)') 'Reference vector','banmul vector'
      do 22 i=1,NP
        write(*,'(t8,f12.4,t32,f12.4)') ax(i),b(i)
22    continue
      END
