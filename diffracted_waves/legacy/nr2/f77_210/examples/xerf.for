      PROGRAM xerf
C     driver for routine erf
      INTEGER i,nval
      REAL erf,value,x
      CHARACTER text*14
      open(7,file='FNCVAL.DAT',status='OLD')
10    read(7,'(a)') text
      if (text.ne.'Error Function') goto 10
      read(7,*) nval
      write(*,*) text
      write(*,'(1x,t5,a1,t12,a6,t24,a6)')
     *     'X','Actual','ERF(X)'
      do 11 i=1,nval
        read(7,*) x,value
        write(*,'(f6.2,2f12.7)') x,value,erf(x)
11    continue
      close(7)
      END
