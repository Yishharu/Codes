      PROGRAM xsvdvar
C     driver for routine svdvar
      INTEGER NCVM,MA,MP
      PARAMETER(MP=6,MA=3,NCVM=MA)
      INTEGER i,j
      REAL v(MP,MP),w(MP),cvm(NCVM,NCVM),tru(MA,MA)
      DATA w/0.0,1.0,2.0,3.0,4.0,5.0/
      DATA v/1.0,2.0,3.0,4.0,5.0,6.0,1.0,2.0,3.0,4.0,5.0,6.0,
     *     1.0,2.0,3.0,4.0,5.0,6.0,1.0,2.0,3.0,4.0,5.0,6.0,
     *     1.0,2.0,3.0,4.0,5.0,6.0,1.0,2.0,3.0,4.0,5.0,6.0/
      DATA tru/1.25,2.5,3.75,2.5,5.0,7.5,3.75,7.5,11.25/
      write(*,'(/1x,a)') 'Matrix V'
      do 11 i=1,MP
        write(*,'(1x,6f12.6)') (v(i,j),j=1,MP)
11    continue
      write(*,'(/1x,a)') 'Vector W'
      write(*,'(1x,6f12.6)') (w(i),i=1,MP)
      call svdvar(v,MA,MP,w,cvm,NCVM)
      write(*,'(/1x,a)') 'Covariance matrix from SVDVAR'
      do 12 i=1,MA
        write(*,'(1x,3f12.6)') (cvm(i,j),j=1,MA)
12    continue
      write(*,'(/1x,a)') 'Expected covariance matrix'
      do 13 i=1,MA
        write(*,'(1x,3f12.6)') (tru(i,j),j=1,MA)
13    continue
      END
