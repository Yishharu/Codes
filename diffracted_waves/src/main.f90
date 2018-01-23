PROGRAM main

  USE nrtype
  USE nr, ONLY : bessj0, bessj1, bessj, bessy, bessy1, bessy0
  IMPLICIT NONE
  REAL(SP) :: x,y

  PRINT *, 'Input x:'
  READ(*,*) x
  PRINT *, 'Bessj0 ='
  WRITE(*,*) bessj0(x)
  PRINT *, 'Bessy ='
  WRITE(*,*) bessy(3,x)
  PRINT *, 'Bessj ='
  WRITE(*,*) bessj(3,x)
!  PRINT *, 'Bessy ='
!  WRITE(*,*) bessy(1,x)  
END PROGRAM main
