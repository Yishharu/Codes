      PROGRAM xspctrm
C     driver for routine spctrm
      INTEGER M,M4
      PARAMETER(M=16,M4=4*M)
      INTEGER j,k
      REAL p(M),q(M),w1(M4),w2(M)
      LOGICAL ovrlap
      open(9,file='SPCTRL.DAT',status='OLD')
      k=8
      ovrlap=.true.
      call spctrm(p,M,k,ovrlap,w1,w2)
      rewind(9)
      k=16
      ovrlap=.false.
      call spctrm(q,M,k,ovrlap,w1,w2)
      close(9)
      write(*,*) 'Spectrum of DATA in file SPCTRL.DAT'
      write(*,'(1x,t14,a,t29,a)') 'Overlapped','Non-Overlapped'
      do 11 j=1,M
        write(*,'(1x,i4,2f17.6)') j,p(j),q(j)
11    continue
      END
