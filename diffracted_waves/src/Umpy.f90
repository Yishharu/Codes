PROGRAM Umpy
  !IMPLICIT NONE
  USE global
  USE nrtype
  REAL :: r,omega,phi
  COMPLEX(SPC), external :: disp_s
  REAL, external :: USUM
  print *,'r='
  READ(*,*) r
  print *,'omega='
  read(*,*) omega
  print *,'phi='
  read(*,*) phi
  !y = bessj0_v(x)
  print *,'SUM of U is:  '
  N = 40
  WRITE(*,*) USUM(r,omega,phi,N)
END PROGRAM Umpy

!SUBROUTINE cal(x,ans)
!    USE bessel_function
!    USE nrtype; USE nrutil, ONLY : poly
!    IMPLICIT NONE
!    REAL, INTENT(IN) :: x
!    REAL, INTENT(OUT) :: ans
!    ans = bessj0_s(x)
!END SUBROUTINE cal

FUNCTION USUM(r,omega,phi,N)
  !IMPLICIT NONE
  USE global
  USE nrtype
  INTEGER :: m,N
  REAL :: r,omega,phi
  COMPLEX(SPC) :: SUM
  REAL :: USUM
  COMPLEX(SPC), external :: disp_s
  
  SUM = 0
  DO m = -N, N
     SUM = SUM + disp_s(r,omega,m)*exp((0,1)*m*phi)!disp_s(r,omega,m)*exp((0,1)*m*phi)
  END DO
  USUM = abs(SUM)
END FUNCTION USUM

!FUNCTION USUM_V(r,omega,phi)
!  USE global
!  USE nrtype
!  REAL, INTENT(IN) :: omega
!  REAL, DIMENSION(:,:), INTENT(IN) :: r,phi
!  COMPLEX(SPC), DIMENSION(size(r,dim=1),size(r,dim=2)) :: SUM
!  REAL, DIMENSION(size(r,dim=1),size(r,dim=2)) :: USUM_V
!  COMPLEX(SPC), external :: disp_s
!  INTEGER :: i,j,m,N
  
!  N = 20

! SUM(:,:) = (0,0)
  
!  Do i = 1, size(r,dim=1)
!     Do j = 1, size(r,dim=2)
!        DO m = 0, N
!           SUM(i,j) = SUM(i,j) + disp_s(r(i,j),omega,m)*exp((0,1)*omega*phi(i,j))
!        END DO
!        USUM_V(a,b) = abs(SUM(a,b))
!     END DO
!  END DO
  
!END FUNCTION USUM_V


FUNCTION disp_s(r,omega,m)
 ! IMPLICIT NONE  
  USE global
!  USE bessel_function
  USE nrtype; USE nrutil, ONLY : poly
  USE nr, ONLY : bessj, bessy, bessj0, bessj1, bessy0, bessy1

  REAL(SP), INTENT(IN) :: r
  REAL(SP), INTENT(IN) :: omega
  INTEGER(I4B), INTENT(IN) :: m
  COMPLEX(SPC) :: disp_s
  COMPLEX(SPC), external :: hankel1_s,hankel2_s


     IF (rs>r .AND. r>a) THEN
        disp_s = 1./(16*mu)*(0,1)*hankel1_s(m,omega*rs/bbeta)*(2*hankel2_s(m,omega*r/bbeta)+&
             &omega*a*hankel1_s(m,omega*r/bbeta)*(hankel2_s(m+1,omega*a/bbeta)-hankel2_s(m-1,omega*r/bbeta))/&
             &(omega*a*hankel1_s(m-1,omega*a/bbeta)-m*bbeta*hankel1_s(m,omega*a/bbeta)))

     ELSE IF (r>=rs) THEN
        disp_s = -1/(16*mu)*(0,1)*a*omega*hankel1_s(m,omega*r/bbeta)*((-hankel1_s(m-1,a*omega/bbeta)+hankel1_s(m+1,a*omega/bbeta))&
             &*hankel2_s(m,rs*omega/bbeta)+hankel1_s(m,rs*omega/bbeta)*(hankel2_s(m-1,a*omega/bbeta)-hankel2_s(m+1,a*omega/bbeta)))&
             &/(a*omega*hankel1_s(m-1,omega*a/bbeta)-m*bbeta*hankel1_s(m,a*omega/bbeta))
        
     ELSE IF (r<=a) THEN
        disp_s = 0
        
     END IF

   

END FUNCTION disp_s



 
  FUNCTION hankel1_s(n,x)
!    USE bessel_function
    USE nrtype;
    USE nr, ONLY : bessj, bessy, bessj0, bessj1, bessy0, bessy1
   
    IMPLICIT NONE
    INTEGER(I4B), INTENT(IN) :: n
    INTEGER :: sign,k
    REAL(SP), INTENT(IN) :: x
    COMPLEX(SPC) :: hankel1_s

    hankel1_s=bessj(n,x)+(0,1)*bessy(n,x)
    
  END FUNCTION hankel1_s

  FUNCTION hankel2_s(n,x)
!    USE bessel_function
    USE nrtype;
    USE nr, ONLY : bessj, bessy, bessj0, bessj1, bessy0, bessy1
    IMPLICIT NONE
    INTEGER(I4B), INTENT(IN) :: n
    INTEGER :: sign,k
    REAL(SP), INTENT(IN) :: x
    COMPLEX(SPC) :: hankel2_s


    hankel2_s=bessj(k,x)-(0,1)*bessy(n,x)
    
    
  END FUNCTION hankel2_s
