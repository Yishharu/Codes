      PROGRAM xhpsel
C     driver for routine hpsel
      INTEGER NP
      PARAMETER(NP=100)
      REAL arr(NP),heap(NP)
      INTEGER i,k
      REAL check,select
      open(7,file='TARRAY.DAT',status='OLD')
      read(7,*) (arr(i),i=1,NP)
      close(7)
1     write(*,*) 'enter K'
      read(*,*,END=999) k
      call hpsel(k,NP,arr,heap)
      check=select(NP+1-k,NP,arr)
      write(*,*) 'heap(1),check=',heap(1),check
      write(*,*) 'heap of numbers of size',k
      do 11 i=1,k
        write(*,*) i,heap(i)
11    continue
      goto 1
999   write(*,*) 'NORMAL COMPLETION'
      STOP
      END
