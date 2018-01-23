      PROGRAM xcovsrt
C     driver for routine covsrt
      INTEGER MA,MFIT
      PARAMETER(MA=10,MFIT=5)
      INTEGER i,j,ia(MA)
      REAL covar(MA,MA)
      do 12 i=1,MA
        do 11 j=1,MA
          covar(i,j)=0.0
          if (i.le.MFIT .and. j.le.MFIT) then
            covar(i,j)=i+j-1
          endif
11      continue
12    continue
      write(*,'(//2x,a)') 'Original matrix'
      do 13 i=1,MA
        write(*,'(1x,10f4.1)') (covar(i,j),j=1,MA)
13    continue
      write(*,*) ' press RETURN to continue...'
      read(*,*)
      write(*,'(/2x,a)') 'Test #1 - Full Fitting'
      do 14 i=1,MA
        ia(i)=1
14    continue
      call covsrt(covar,MA,MA,ia,MA)
      do 15 i=1,MA
        write(*,'(1x,10f4.1)') (covar(i,j),j=1,MA)
15    continue
      write(*,*) ' press RETURN to continue...'
      read(*,*)
      write(*,'(/2x,a)') 'Test #2 - Spread'
      do 17 i=1,MA
        do 16 j=1,MA
          covar(i,j)=0.0
          if (i.le.MFIT .and. j.le.MFIT) then
            covar(i,j)=i+j-1
          endif
16      continue
17    continue
      do 18 i=1,MA,2
        ia(i)=0
18    continue
      call covsrt(covar,MA,MA,ia,MFIT)
      do 19 i=1,MA
        write(*,'(1x,10f4.1)') (covar(i,j),j=1,MA)
19    continue
      END
