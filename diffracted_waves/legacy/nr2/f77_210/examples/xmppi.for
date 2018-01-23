      PROGRAM xmppi
C     driver for mp routines
      INTEGER n
3     write(*,*) 'INPUT N'
      read(*,*,END=999) n
      call mpinit
      call mpsqr2(n)
      call mppi(n)
      goto 3
999   write(*,*) 'NORMAL COMPLETION'
      STOP
      END

      SUBROUTINE mpsqr2(n)
      INTEGER IAOFF,NMAX
      PARAMETER (IAOFF=48,NMAX=8192)
      INTEGER j,n,m
      CHARACTER*1 x(NMAX),y(NMAX),t(NMAX),s(3*NMAX),q(NMAX),r(NMAX)
      t(1)=char(2)
      do 11 j=2,n
        t(j)=char(0)
11    continue
      call mpsqrt(x,x,t,n,n)
      call mpmov(y,x,n)
      write(*,*) 'SQRT(2)='
      s(1)=char(ichar(y(1))+IAOFF)
      s(2)='.'
C     caution: next step is N**2! omit it for large N
      call mp2dfr(y(2),s(3),n-1,m)
      write(*,'(1x,64a1)') (s(j),j=1,m+2)
      write(*,*) 'Result rounded to 1 less base-256 place:'
C     use s as scratch space
      call mpsad(s,x,n,128)
      call mpmov(y,s(2),n-1)
      s(1)=char(ichar(y(1))+IAOFF)
      s(2)='.'
C     caution: next step is N**2! omit it for large N
      call mp2dfr(y(2),s(3),n-2,m)
      write(*,'(1x,64a1)') (s(j),j=1,m+2)
      write(*,*) '2-SQRT(2)='
C     calculate this the hard way to exercise the mpdiv function
      call mpdiv(q,r,t,x,n,n)
      s(1)=char(ichar(r(1))+IAOFF)
      s(2)='.'
C     caution: next step is N**2! omit it for large N
      call mp2dfr(r(2),s(3),n-1,m)
      write(*,'(1x,64a1)') (s(j),j=1,m+2)
      return
      END
