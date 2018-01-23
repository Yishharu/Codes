      PROGRAM xsobseq
C     driver for routine sobseq
      INTEGER j,jj
      REAL x(3)
      call sobseq(-1,x)
      do 11 jj=1,32
        call sobseq(3,x)
        write(*,'(3(1x,f10.5),1x,i5)') (x(j),j=1,3),jj
11    continue
      END
