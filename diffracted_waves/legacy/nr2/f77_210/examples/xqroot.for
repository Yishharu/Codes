      PROGRAM xqroot
C     driver for routine qroot
      INTEGER N,NTRY
      REAL EPS,TINY
      PARAMETER(N=7,EPS=1.0e-6,NTRY=10,TINY=1.0e-5)
      INTEGER i,j,nflag,nroot
      REAL p(N),b(NTRY),c(NTRY)
      DATA p/10.0,-18.0,25.0,-24.0,16.0,-6.0,1.0/
      write(*,'(/1x,a)') 'P(x)=x^6-6x^5+16x^4-24x^3+25x^2-18x+10'
      write(*,'(1x,a)') 'Quadratic factors x^2+Bx+C'
      write(*,'(/1x,a,t15,a,t27,a/)') 'Factor','B','C'
      nroot=0
      do 12 i=1,NTRY
        c(i)=0.5*i
        b(i)=-0.5*i
        call qroot(p,N,b(i),c(i),EPS)
        if (nroot.eq.0) then
          write(*,'(1x,i3,2x,2f12.6)') nroot,b(i),c(i)
          nroot=1
        else
          nflag=0
          do 11 j=1,nroot
            if (abs(b(i)-b(j)).lt.TINY.and.abs(c(i)-c(j)).lt.TINY)
     *           nflag=1
11        continue
          if (nflag.eq.0) then
            write(*,'(1x,i3,2x,2f12.6)') nroot,b(i),c(i)
            nroot=nroot+1
          endif
        endif
12    continue
      END
