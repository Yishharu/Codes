      PROGRAM xzrhqr
C     driver for routine zrhqr
      INTEGER M,MP1,NTRY
      PARAMETER(M=4,MP1=M+1,NTRY=21)
      INTEGER i
      REAL a(MP1),rtr(M),rti(M)
      DATA a/-1.0,0.0,0.0,0.0,1.0/
      write(*,'(/1x,a)') 'Roots of polynomial x^4-1'
      write(*,'(/1x,t16,a,t29,a/)') 'Real','Complex'
      call zrhqr(a,M,rtr,rti)
      do 11 i=1,M
        write(*,'(1x,i5,2f15.6)') i,rtr(i),rti(i)
11    continue
      END
