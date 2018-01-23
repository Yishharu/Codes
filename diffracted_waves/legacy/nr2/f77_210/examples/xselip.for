      PROGRAM xselip
C     driver for routine selip
      INTEGER i,j,k
      REAL q,selip,arr(100),brr(100)
      open(7,file='TARRAY.DAT',status='OLD')
      read(7,*) (arr(i),i=1,100)
      close(7)
C     print original array
      write(*,*) 'Original array:'
      do 11 i=1,10
        write(*,'(1x,10f7.2)') (arr(10*(i-1)+j),j=1,10)
11    continue
C     sort array - inefficiently, but shows use and verifies routine
      do 12 i=1,100
        brr(i)=selip(i,100,arr)
12    continue
C     print sorted array
      write(*,*) 'Sorted array:'
      do 13 i=1,10
        write(*,'(1x,10f7.2)') (brr(10*(i-1)+j),j=1,10)
13    continue
1     write(*,*) 'INPUT K'
      read(*,*,END=999) k
      q=selip(k,100,arr)
      write(*,*) 'Element in sort position',k,' is',q
      goto 1
999   write(*,*) 'NORMAL COMPLETION'
      STOP
      END
