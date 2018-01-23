      PROGRAM xgammln
C     driver for routine gammln
      INTEGER i,nval
      REAL actual,calc,gammln,x
      CHARACTER text*14
      open(7,file='FNCVAL.DAT',status='OLD')
10    read(7,'(a)') text
      if (text.ne.'Gamma Function') goto 10
      read(7,*) nval
      write(*,*) 'Log of gamma function:'
      write(*,'(1x,t11,a1,t24,a6,t40,a10)')
     *     'X','Actual','GAMMLN(X)'
      do 11 i=1,nval
        read(7,*) x,actual
        if (x.gt.0.0) then
          if (x.ge.1.0) then
            calc=gammln(x)
          else
            calc=gammln(x+1.0)-log(x)
          endif
          write(*,'(f12.2,2f18.6)') x,log(actual),calc
        endif
11    continue
      close(7)
      END
