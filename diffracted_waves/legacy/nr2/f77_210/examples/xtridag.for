      PROGRAM xtridag
C     driver for routine tridag
      INTEGER NP
      PARAMETER (NP=20)
      INTEGER k,n
      REAL diag(NP),superd(NP),subd(NP),rhs(NP),u(NP)
      CHARACTER txt*3
      open(7,file='MATRX2.DAT',status='old')
10    read(7,'(a3)') txt
      if (txt.eq.'END') goto 99
      read(7,*)
      read(7,*) n
      read(7,*)
      read(7,*) (diag(k), k=1,n)
      read(7,*)
      read(7,*) (superd(k), k=1,n-1)
      read(7,*)
      read(7,*) (subd(k), k=2,n)
      read(7,*)
      read(7,*) (rhs(k), k=1,n)
C     carry out solution
      call tridag(subd,diag,superd,rhs,u,n)
      write(*,*) 'The solution vector is:'
      write(*,'(1x,6f12.6)') (u(k), k=1,n)
C     test solution
      write(*,*) '(matrix)*(sol''n vector) should be:'
      write(*,'(1x,6f12.6)') (rhs(k), k=1,n)
      write(*,*) 'Actual result is:'
      do 11 k=1,n
        if (k.eq.1) then
          rhs(k)=diag(1)*u(1) + superd(1)*u(2)
        else if (k.eq.n) then
          rhs(k)=subd(n)*u(n-1) + diag(n)*u(n)
        else
          rhs(k)=subd(k)*u(k-1) + diag(k)*u(k)
     *         + superd(k)*u(k+1)
        endif
11    continue
      write(*,'(1x,6f12.6)') (rhs(k), k=1,n)
      write(*,*) '***********************************'
      write(*,*) 'Press RETURN for next problem:'
      read(*,*)
      goto 10
99    close(7)
      END
