      PROGRAM xanneal
C     driver for routine anneal
      INTEGER NCITY
      PARAMETER (NCITY=10)
      INTEGER i,idum,ii,iorder(NCITY)
      REAL ran3,x(NCITY),y(NCITY)
C     create points of sale
      idum=-111
      do 11 i=1,NCITY
        x(i)=ran3(idum)
        y(i)=ran3(idum)
        iorder(i)=i
11    continue
      call anneal(x,y,iorder,NCITY)
      write(*,*) '*** System Frozen ***'
      write(*,*) 'Final path:'
      write(*,'(1x,t3,a,t13,a,t23,a)') 'city','x','y'
      do 12 i=1,NCITY
        ii=iorder(i)
        write(*,'(1x,i4,2f10.4)') ii,x(ii),y(ii)
12    continue
      END
