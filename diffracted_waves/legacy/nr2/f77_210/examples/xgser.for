      PROGRAM xgser
C     driver for routine gser
      INTEGER i,nval
      REAL a,gammln,gamser,gln,value,x
      CHARACTER text*25
      open(7,file='FNCVAL.DAT',status='OLD')
10    read(7,'(a)') text
      if (text.ne.'Incomplete Gamma Function') goto 10
      read(7,*) nval
      write(*,*) text
      write(*,'(1x,t5,a,t16,a,t25,a,t36,a,t47,a,t62,a)')
     *     'A','X','Actual','GSER(A,X)','GAMMLN(A)','GLN'
      do 11 i=1,nval
        read(7,*) a,x,value
        call gser(gamser,a,x,gln)
        write(*,'(1x,f6.2,5f12.6)') a,x,value,gamser,
     *       gammln(a),gln
11    continue
      close(7)
      END
