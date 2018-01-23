      PROGRAM xpiksr2
C     driver for routine piksr2
      INTEGER i,j
      REAL a(100),b(100)
      open(7,file='TARRAY.DAT',status='OLD')
      read(7,*) (a(i),i=1,100)
      close(7)
C     generate B-array
      do 11 i=1,100
        b(i)=i
11    continue
C     sort A and mix B
      call piksr2(100,a,b)
      write(*,*) 'After sorting A and mixing B, array A is:'
      do 12 i=1,10
        write(*,'(1x,10f7.2)') (a(10*(i-1)+j), j=1,10)
12    continue
      write(*,*) '...and array B is:'
      do 13 i=1,10
        write(*,'(1x,10f7.2)') (b(10*(i-1)+j), j=1,10)
13    continue
      write(*,*) 'press RETURN to continue...'
      read(*,*)
C     sort B and mix A
      call piksr2(100,b,a)
      write(*,*) 'After sorting B and mixing A, array A is:'
      do 14 i=1,10
        write(*,'(1x,10f7.2)') (a(10*(i-1)+j), j=1,10)
14    continue
      write(*,*) '...and array B is:'
      do 15 i=1,10
        write(*,'(1x,10f7.2)') (b(10*(i-1)+j), j=1,10)
15    continue
      END
