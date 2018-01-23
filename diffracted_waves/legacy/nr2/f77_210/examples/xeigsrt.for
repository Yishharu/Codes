      PROGRAM xeigsrt
C     driver for routine eigsrt
      INTEGER NP
      PARAMETER(NP=10)
      INTEGER i,j,nrot
      REAL d(NP),v(NP,NP),c(NP,NP)
      DATA c /5.0,4.3,3.0,2.0,1.0,0.0,-1.0,-2.0,-3.0,-4.0,
     *     4.3,5.1,4.0,3.0,2.0,1.0,0.0,-1.0,-2.0,-3.0,
     *     3.0,4.0,5.0,4.0,3.0,2.0,1.0,0.0,-1.0,-2.0,
     *     2.0,3.0,4.0,5.0,4.0,3.0,2.0,1.0,0.0,-1.0,
     *     1.0,2.0,3.0,4.0,5.0,4.0,3.0,2.0,1.0,0.0,
     *     0.0,1.0,2.0,3.0,4.0,5.0,4.0,3.0,2.0,1.0,
     *     -1.0,0.0,1.0,2.0,3.0,4.0,5.0,4.0,3.0,2.0,
     *     -2.0,-1.0,0.0,1.0,2.0,3.0,4.0,5.0,4.0,3.0,
     *     -3.0,-2.0,-1.0,0.0,1.0,2.0,3.0,4.0,5.0,4.0,
     *     -4.0,-3.0,-2.0,-1.0,0.0,1.0,2.0,3.0,4.0,5.0/
      call jacobi(c,NP,NP,d,v,nrot)
      write(*,*) 'Unsorted Eigenvectors:'
      do 11 i=1,NP
        write(*,'(/1x,a,i3,a,f12.6)') 'Eigenvalue',i,' =',d(i)
        write(*,*) 'Eigenvector:'
        write(*,'(10x,5f12.6)') (v(j,i),j=1,NP)
11    continue
      write(*,'(//,1x,a,//)') '****** sorting ******'
      call eigsrt(d,v,NP,NP)
      write(*,*) 'Sorted Eigenvectors:'
      do 12 i=1,NP
        write(*,'(/1x,a,i3,a,f12.6)') 'Eigenvalue',i,' =',d(i)
        write(*,*) 'Eigenvector:'
        write(*,'(10x,5f12.6)') (v(j,i),j=1,NP)
12    continue
      END
