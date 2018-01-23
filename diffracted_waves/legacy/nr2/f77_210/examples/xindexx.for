      PROGRAM xindexx
C     driver for routine indexx
      INTEGER i,j,indx(100)
      REAL a(100)
      open(7,file='TARRAY.DAT',status='OLD')
      read(7,*) (a(i),i=1,100)
      close(7)
C     generate index for sorted array
      call indexx(100,a,indx)
C     print original array
      write(*,*) 'Original array:'
      do 11 i=1,10
        write(*,'(1x,10f7.2)') (a(10*(i-1)+j),j=1,10)
11    continue
C     print sorted array
      write(*,*) 'Sorted array:'
      do 12 i=1,10
        write(*,'(1x,10f7.2)') (a(indx(10*(i-1)+j)),j=1,10)
12    continue
      END
