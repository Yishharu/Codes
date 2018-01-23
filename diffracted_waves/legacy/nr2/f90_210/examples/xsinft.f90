	PROGRAM xsinft
!	driver for routine sinft
	USE nrtype; USE nrutil
	USE nr
	IMPLICIT NONE
	INTEGER(I4B), PARAMETER :: NP=16
	REAL(SP), PARAMETER :: EPS=1.0e-3_sp,WIDTH=30.0
	INTEGER(I4B) :: i,j,nlim
	REAL(SP) :: big,per,scal,small
	REAL(SP), DIMENSION(NP) :: data
	do
		write(*,'(1x,a,i2,a)') 'Period of sinusoid in channels (2-',NP,')'
		read(*,*) per
		if (per <= 0.0) exit
		data(1:NP)=sin(2.0_sp*PI*(arth(0,1,NP))/per)
		call sinft(data)
		big=maxval(data)
		small=minval(data)
		scal=WIDTH/(big-small)
		do i=1,NP
			nlim=scal*(data(i)-small)+EPS
			write(*,'(1x,i4,1x,60a1)') i,('*',j=1,nlim+1)
		end do
		write(*,*) 'press continue ...'
		read(*,*)
		call sinft(data)
		big=maxval(data)
		small=minval(data)
		scal=WIDTH/(big-small)
		do i=1,NP
			nlim=scal*(data(i)-small)+EPS
			write(*,'(1x,i4,1x,60a1)') i,('*',j=1,nlim+1)
		end do
	end do
	END PROGRAM xsinft
