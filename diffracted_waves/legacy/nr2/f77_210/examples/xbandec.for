      PROGRAM xbandec
C     driver for routine bandec
      REAL ran1
      REAL a(7,4),x(7),b(7),al(7,2),d
      INTEGER indx(7)
      INTEGER i,idum,j
      idum=-1
      do 12 i=1,7
        x(i)=ran1(idum)
        do 11 j=1,4
          a(i,j)=ran1(idum)
11      continue
12    continue
      call banmul(a,7,2,1,7,4,x,b)
      do 13 i=1,7
        write(*,*) i,b(i),x(i)
13    continue
      call bandec(a,7,2,1,7,4,al,2,indx,d)
      call banbks(a,7,2,1,7,4,al,2,indx,b)
      do 14 i=1,7
        write(*,*) i,b(i),x(i)
14    continue
      stop
      END
