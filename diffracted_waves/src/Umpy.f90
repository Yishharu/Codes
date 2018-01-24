PROGRAM Umpy

  USE global
  USE nrtype
 ! IMPLICIT NONE
  REAL :: r,omega,phi
  COMPLEX(SPC), external :: disp
  COMPLEX(SPC), external :: USUM
  print *,'r='
  READ(*,*) r
  print *,'omega='
  read(*,*) omega
  print *,'phi='
  read(*,*) phi
  !y = bessj0_v(x)
  print *,'SUM of U is:  '
  WRITE(*,*) USUM(r,omega,phi)
END PROGRAM Umpy

!SUBROUTINE cal(x,ans)
!    USE bessel_function
!    USE nrtype; USE nrutil, ONLY : poly
!    IMPLICIT NONE
!    REAL, INTENT(IN) :: x
!    REAL, INTENT(OUT) :: ans
!    ans = bessj0_s(x)
!END SUBROUTINE cal

FUNCTION USUM(r,omega,phi)
  USE global
  USE nrtype
  INTEGER :: i,N
  REAL :: r,omega,phi
  COMPLEX(SPC) :: USUM, SUM
  COMPLEX(SPC), external :: disp
  
  N = 20
  SUM = (0,0)
  DO i = 0, N
     SUM = SUM + disp(r,omega,i)*exp((0,1)*omega*phi)
  END DO
  USUM = SUM
END FUNCTION USUM


FUNCTION disp(r,omega,m)
  USE global
!  USE bessel_function
  USE nrtype; USE nrutil, ONLY : poly
  USE nr, ONLY : bessj, bessy, bessj0, bessj1, bessy0, bessy1

  REAL(SP), INTENT(IN) :: r
  REAL(SP), INTENT(IN) :: omega
  INTEGER(I4B), INTENT(IN) :: m
  COMPLEX(SPC) :: disp
  COMPLEX(SPC), external :: hankel1

  IF (m == 0) THEN
     IF (rs>r .AND. r>a) THEN
        disp = bbeta/(4*mu*omega)*(bessj0(omega*rs/bbeta)-(0,1)*bessy0(omega*rs/bbeta))*bessy0(omega*r/bbeta)
     ELSE IF (r>rs) THEN
        disp = bbeta/(4*mu*omega)*bessy0(omega*rs/bbeta)*hankel1(0,omega*r/bbeta)
     ELSE
        disp = (0,0)
     END IF
  ELSE IF (m == 1) THEN
      IF (rs>r .AND. r>a) THEN
        disp = bbeta/(4*mu*omega)*(bessj1(omega*rs/bbeta)-(0,1)*bessy1(omega*rs/bbeta))*bessy1(omega*r/bbeta)
     ELSE IF (r>rs) THEN
        disp = bbeta/(4*mu*omega)*bessy1(omega*rs/bbeta)*hankel1(1,omega*r/bbeta)
     ELSE
        disp = (0,0)
     END IF
  ELSE
     IF (rs>r .AND. r>a) THEN
        disp = bbeta/(4*mu*omega)*(bessj(m,omega*rs/bbeta)-(0,1)*bessy(m,omega*rs/bbeta))*bessy(m,omega*r/bbeta)
     ELSE IF (r>rs) THEN
        disp = bbeta/(4*mu*omega)*bessy(m,omega*rs/bbeta)*hankel1(m,omega*r/bbeta)
     END IF
  END IF

END FUNCTION disp



 
  FUNCTION hankel1(n,x)
!    USE bessel_function
    USE nrtype;
    USE nr, ONLY : bessj, bessy, bessj0, bessj1, bessy0, bessy1
   
    IMPLICIT NONE
    INTEGER(I4B), INTENT(IN) :: n
    REAL(SP), INTENT(IN) :: x
    COMPLEX(SPC) :: hankel1

    IF (n == 0) THEN
       hankel1=bessj0(x)+(0,1)*bessy0(x)
    ELSE IF (n ==1) THEN
       hankel1=bessj1(x)+(0,1)*bessy1(x)
    ELSE
       hankel1=bessj(n,x)+(0,1)*bessy(n,x)
    END IF
  END FUNCTION hankel1

  FUNCTION hankel2(n,x)
!    USE bessel_function
    USE nrtype;
    USE nr, ONLY : bessj, bessy, bessj0, bessj1, bessy0, bessy1
    IMPLICIT NONE
    INTEGER(I4B), INTENT(IN) :: n
    REAL(SP), INTENT(IN) :: x
    COMPLEX(SPC) :: hankel2

    IF (n == 0) THEN
       hankel2=bessj0(x)-(0,1)*bessy0(x)
    ELSE IF (n == 1) THEN
       hankel2=bessj1(x)-(0,1)*bessy1(x)
    ELSE
       hankel2=bessj(n,x)-(0,1)*bessy(n,x)
    END IF
    

  END FUNCTION hankel2
