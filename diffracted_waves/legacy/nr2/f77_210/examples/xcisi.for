      PROGRAM xcisi
C     driver for routine cisi
      INTEGER i,nval
      REAL ci,si,x,xci,xsi
      CHARACTER text*25
      open(7,file='FNCVAL.DAT',status='OLD')
10    read(7,'(a)') text
      if (text.ne.'Cosine and Sine Integrals') goto 10
      read(7,*) nval
      write(*,*) text
      write(*,'(1x,t5,a1,t13,a6,t25,a5,t37,a6,t48,a5)')
     *     'X','Actual','CI(X)','Actual','SI(X)'
      do 11 i=1,nval
        read(7,*) x,xci,xsi
        call cisi(x,ci,si)
        write(*,'(f6.2,4f12.6)') x,xci,ci,xsi,si
11    continue
      close(7)
      END
