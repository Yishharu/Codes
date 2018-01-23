PROGRAM U_cal

  USE global
  USE nrtype; USE nrutil, ONLY : poly
  USE nr
 ! IMPLICIT NONE
  REAL :: r,omega
  COMPLEX(SPC), external :: disp
  COMPLEX(SPC) :: U
  print *,'r='
  READ(*,*) r
  print *,'omega='
  read(*,*) omega
  !y = bessj0_v(x)
  print *,'U_cal is:  '
  U = disp(r,omega,1)
  WRITE(*,*) U
END PROGRAM U_cal

!SUBROUTINE cal(x,ans)
!    USE bessel_function
!    USE nrtype; USE nrutil, ONLY : poly
!    IMPLICIT NONE
!    REAL, INTENT(IN) :: x
!    REAL, INTENT(OUT) :: ans
!    ans = bessj0_s(x)
!END SUBROUTINE cal

FUNCTION disp(r,omega,m)
  USE global
!  USE bessel_function
  USE nrtype; USE nrutil, ONLY : poly
  USE nr
  REAL(SP), INTENT(IN) :: r
  REAL(SP), INTENT(IN) :: omega
  INTEGER(I4B), INTENT(IN) :: m
  COMPLEX(SPC) :: disp
  COMPLEX(SPC), external :: hankel1

  IF (rs>r .AND. r>a) THEN
     disp = bbeta/(4*mu*omega)*(bessj_s(m,omega*rs/bbeta)-(0,1)*bessy_s(m,omega*rs/bbeta))*bessy_s(m,omega*r/bbeta)
  ELSE IF (r>rs) THEN
    disp = bbeta/(4*mu*omega)*bessy_s(m,omega*rs/bbeta)*hankel1(m,omega*r/bbeta)
  END IF
END FUNCTION disp



 
  FUNCTION hankel1(n,x)
!    USE bessel_function
    USE nrtype; USE nrutil, ONLY : assert
    USE nr
    IMPLICIT NONE
    INTEGER(I4B), INTENT(IN) :: n
    REAL(SP), INTENT(IN) :: x
    COMPLEX(SPC) :: hankel1

    hankel1=bessj_s(n,x)+(0,1)*bessy_s(n,x)

  END FUNCTION hankel1

  FUNCTION hankel2(n,x)
!    USE bessel_function
    USE nrtype; USE nrutil, ONLY : assert
    USE nr
    IMPLICIT NONE
    INTEGER(I4B), INTENT(IN) :: n
    REAL(SP), INTENT(IN) :: x
    COMPLEX(SPC) :: hankel2

    hankel2=bessj_s(n,x)-(0,1)*bessy_s(n,x)

  END FUNCTION hankel2
