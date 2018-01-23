      PROGRAM xgcf
C     driver for routine gcf
      INTEGER i,nval
      REAL a,gammcf,gammln,gln,value,x
      CHARACTER text*25
      open(7,file='FNCVAL.DAT',status='OLD')
10    read(7,'(a)') text
      if (text.ne.'Incomplete Gamma Function') goto 10
      read(7,*) nval
      write(*,*) text
      write(*,'(1x,t5,a,t16,a,t25,a,t36,a,t47,a,t62,a)')
     *     'A','X','Actual','GCF(A,X)','GAMMLN(A)','GLN'
      do 11 i=1,nval
        read(7,*) a,x,value
        if (x.ge.a+1.0) then
          call gcf(gammcf,a,x,gln)
          write(*,'(1x,f6.2,5f12.6)') a,x,1.0-value,
     *         gammcf,gammln(a),gln
        endif
11    continue
      close(7)
      END
