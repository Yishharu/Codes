      PROGRAM xrank
C     driver for routine rank
      INTEGER i,j,k,l,indx(100),irank(100)
      REAL a(100),b(10)
      open(7,file='TARRAY.DAT',status='OLD')
      read(7,*) (a(i),i=1,100)
      close(7)
      call indexx(100,a,indx)
      call rank(100,indx,irank)
      write(*,*) 'Original array is:'
      do 11 i=1,10
        write(*,'(1x,10f7.2)') (a(10*(i-1)+j), j=1,10)
11    continue
      write(*,*) 'Table of ranks is:'
      do 12 i=1,10
        write(*,'(1x,10i6)') (irank(10*(i-1)+j), j=1,10)
12    continue
      write(*,*) 'press RETURN to continue...'
      read(*,*)
      write(*,*) 'Array sorted according to rank table:'
      do 15 i=1,10
        do 14 j=1,10
          k=10*(i-1)+j
          do 13 l=1,100
            if (irank(l).eq.k) b(j)=a(l)
13        continue
14      continue
        write(*,'(1x,10f7.2)') (b(j),j=1,10)
15    continue
      END
