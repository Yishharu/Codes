      PROGRAM xmnewt
C     driver for routine mnewt
      INTEGER NTRIAL,N,NP
      REAL TOLX,TOLF
      PARAMETER(NTRIAL=5,TOLX=1.0E-6,N=4,TOLF=1.0E-6,NP=15)
      INTEGER i,j,k,kk
      REAL xx,fjac(NP,NP),fvec(NP),x(NP)
      do 15 kk=-1,1,2
        do 14 k=1,3
          xx=0.2001*k*kk
          write(*,'(/1x,a,i2)') 'Starting vector number',k
          do 11 i=1,N
            x(i)=xx+0.2*i
            write(*,'(1x,t5,a,i1,a,f5.2)') 'X(',i,') = ',x(i)
11        continue
          do 13 j=1,NTRIAL
            call mnewt(1,x,N,TOLX,TOLF)
            call usrfun(x,n,NP,fvec,fjac)
            write(*,'(/1x,t5,a,t14,a,t29,a/)') 'I','X(I)','F'
            do 12 i=1,N
              write(*,'(1x,i4,2e15.6)') i,x(i),fvec(i)
12          continue
            write(*,'(/1x,a)') 'press RETURN to continue...'
            read(*,*)
13        continue
14      continue
15    continue
      END

      SUBROUTINE usrfun(x,n,np,fvec,fjac)
      INTEGER i,n,np
      REAL fjac(np,np),fvec(np),x(np)
      fjac(1,1)=-2.0*x(1)
      fjac(1,2)=-2.0*x(2)
      fjac(1,3)=-2.0*x(3)
      fjac(1,4)=1.0
      do 11 i=1,n
        fjac(2,i)=2.0*x(i)
11    continue
      fjac(3,1)=1.0
      fjac(3,2)=-1.0
      fjac(3,3)=0.0
      fjac(3,4)=0.0
      fjac(4,1)=0.0
      fjac(4,2)=1.0
      fjac(4,3)=-1.0
      fjac(4,4)=0.0
      fvec(1)=-x(1)**2-x(2)**2-x(3)**2+x(4)
      fvec(2)=x(1)**2+x(2)**2+x(3)**2+x(4)**2-1.0
      fvec(3)=x(1)-x(2)
      fvec(4)=x(2)-x(3)
      END
