      PROGRAM xpzextr
C     driver for routine pzextr
      INTEGER NV
      PARAMETER(NV=4)
      INTEGER i,iest,j
      REAL dum,xest,yest(NV),yz(NV),dy(NV)
      do 12 i=1,10
        iest=i
        xest=1.0/float(i)
        dum=1.0-xest+xest*xest*xest
        do 11 j=1,NV
          dum=dum/(xest+1.0)
          yest(j)=dum
11      continue
        call pzextr(iest,xest,yest,yz,dy,NV)
        write(*,'(/1x,a,i2)') 'I = ',i
        write(*,'(1x,a,4f12.6)') 'Extrap. function:',(yz(j),j=1,NV)
        write(*,'(1x,a,4f12.6)') 'Estimated error: ',(dy(j),j=1,NV)
12    continue
      write(*,'(/1x,a,4f12.6)') 'Actual values:   ',1.0,1.0,1.0,1.0
      END
