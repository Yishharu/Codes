      PROGRAM xcntab2
C     driver for routine cntab2
      INTEGER NI,NMON
      PARAMETER(NI=9,NMON=12)
      INTEGER i,j,nmbr(NI,NMON)
      REAL h,hx,hxgy,hy,hygx,uxgy,uxy,uygx
      CHARACTER fate(NI)*15,mon(NMON)*5,text*64
      open(7,file='TABLE.DAT',status='OLD')
      read(7,*)
      read(7,'(a)') text
      read(7,'(15x,12a5/)') (mon(i),i=1,12)
      do 11 i=1,NI
        read(7,'(a15,12i5)') fate(i),(nmbr(i,j),j=1,12)
11    continue
      close(7)
      write(*,'(/1x,a/)') text
      write(*,'(1x,15x,12a5)') (mon(i),i=1,12)
      do 12 i=1,NI
        write(*,'(1x,a,12i5)') fate(i),(nmbr(i,j),j=1,12)
12    continue
      call cntab2(nmbr,NI,NMON,h,hx,hy,hygx,hxgy,uygx,uxgy,uxy)
      write(*,'(/1x,a,t30,f10.4)') 'Entropy of Table',h
      write(*,'(1x,a,t30,f10.4)') 'Entropy of x-distribution',hx
      write(*,'(1x,a,t30,f10.4)') 'Entropy of y-distribution',hy
      write(*,'(1x,a,t30,f10.4)') 'Entropy of y given x',hygx
      write(*,'(1x,a,t30,f10.4)') 'Entropy of x given y',hxgy
      write(*,'(1x,a,t30,f10.4)') 'Dependency of y on x',uygx
      write(*,'(1x,a,t30,f10.4)') 'Dependency of x on y',uxgy
      write(*,'(1x,a,t30,f10.4/)') 'Symmetrical dependency',uxy
      END
