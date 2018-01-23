      PROGRAM xselect
C     driver for routine select
      INTEGER NP
      PARAMETER(NP=100)
      INTEGER i,k
      REAL q,s,select,selip,arr(NP),brr(NP)
      open(7,file='TARRAY.DAT',status='OLD')
      read(7,*) (arr(i),i=1,NP)
      close(7)
1     write(*,*) 'INPUT K'
      read(*,*,END=999) k
      do 11 i=1,NP
        brr(i)=arr(i)
11    continue
      s=selip(k,NP,brr)
      q=select(k,NP,brr)
      write(*,*) 'Element in sort position',k,' is',q
      write(*,*) 'Cross-check from SELIP routine',s
      goto 1
999   write(*,*) 'NORMAL COMPLETION'
      STOP
      END
