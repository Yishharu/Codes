      PROGRAM xhqr
C     driver for routine hqr
      INTEGER NP
      PARAMETER(NP=5)
      INTEGER i,j
      REAL a(NP,NP),wr(NP),wi(NP)
      DATA a/1.0,-2.0,3.0,-4.0,-5.0,2.0,3.0,4.0,5.0,6.0,
     *     0.0,0.0,50.0,-60.0,-70.0,0.0,0.0,0.0,7.0,8.0,
     *     0.0,0.0,0.0,0.0,-9.0/
      write(*,'(/1x,a)') 'Matrix:'
      do 11 i=1,NP
        write(*,'(1x,5f12.2)') (a(i,j),j=1,NP)
11    continue
      call balanc(a,NP,NP)
      call elmhes(a,NP,NP)
      call hqr(a,NP,NP,wr,wi)
      write(*,'(/1x,a)') 'Eigenvalues:'
      write(*,'(/1x,t9,a,t24,a/)') 'Real','Imag.'
      do 12 i=1,NP
        write(*,'(1x,2e15.6)') wr(i),wi(i)
12    continue
      END
