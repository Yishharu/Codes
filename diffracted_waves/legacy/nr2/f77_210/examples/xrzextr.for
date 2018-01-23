      PROGRAM xrzextr
C     driver for routine rzextr
      INTEGER NV
      PARAMETER(NV=4)
      INTEGER i,iest,j
      REAL dum,xest,yest(NV),yz(NV),dy(NV)
      do 12 i=1,10
        iest=i
        xest=1.0/float(i)
        dum=1.0-xest+xest**3
        do 11 j=1,NV
          dum=dum/(xest+1.0)
          yest(j)=dum
11      continue
        call rzextr(iest,xest,yest,yz,dy,NV)
        write(*,'(/1x,a,i2,a,f8.4)') 'IEST = ',i,'   XEST =',xest
        write(*,'(1x,a,4f12.6)') 'Extrap. Function: ',(yz(j),j=1,NV)
        write(*,'(1x,a,4f12.6)') 'Estimated Error:  ',(dy(j),j=1,NV)
12    continue
      write(*,'(/1x,a,4f12.6)') 'Actual Values:    ',1.0,1.0,1.0,1.0
      END
