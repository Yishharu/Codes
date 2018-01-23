      PROGRAM xelmhes
C     driver for routine elmhes
      INTEGER NP
      PARAMETER(NP=5)
      INTEGER i,j
      REAL a(NP,NP)
      DATA a/1.0,2.0,3.0,4.0,5.0,2.0,3.0,4.0,5.0,6.0,
     *     300.0,400.0,5.0,600.0,700.0,4.0,5.0,6.0,7.0,8.0,
     *     5.0,6.0,7.0,8.0,9.0/
      write(*,'(/1x,a/)') '***** Original Matrix *****'
      do 11 i=1,NP
        write(*,'(1x,5f12.2)') (a(i,j),j=1,NP)
11    continue
      write(*,'(/1x,a/)') '***** Balance Matrix *****'
      call balanc(a,NP,NP)
      do 12 i=1,NP
        write(*,'(1x,5f12.2)') (a(i,j),j=1,NP)
12    continue
      write(*,'(/1x,a/)') '***** Reduce to Hessenberg Form *****'
      call elmhes(a,NP,NP)
      do 14 j=1,NP-2
        do 13 i=j+2,NP
          a(i,j)=0.0
13      continue
14    continue
      do 15 i=1,NP
        write(*,'(1x,5e12.4)') (a(i,j),j=1,NP)
15    continue
      END
