      PROGRAM xlaguer
C     driver for routine laguer
      INTEGER M,MP1,NTRY
      REAL EPS
      PARAMETER(M=4,MP1=M+1,NTRY=21,EPS=1.0E-6)
      INTEGER i,iflag,its,j,n
      COMPLEX a(MP1),y(NTRY),x
      DATA a/(0.0,2.0),(0.0,0.0),(-1.0,-2.0),(0.0,0.0),(1.0,0.0)/
      write(*,'(/1x,a)') 'Roots of polynomial x^4-(1+2i)*x^2+2i'
      write(*,'(/1x,t16,a4,t29,a7,t39,a5/)') 'Real','Complex','#iter'
      n=0
      do 12 i=1,NTRY
        x=cmplx((i-11.0)/10.0,(i-11.0)/10.0)
        call laguer(a,M,x,its)
        if (n.eq.0) then
          n=1
          y(1)=x
          write(*,'(1x,i5,2f15.6,i5)') n,x,its
        else
          iflag=0
          do 11 j=1,n
            if (abs(x-y(j)).le.EPS*abs(x)) iflag=1
11        continue
          if (iflag.eq.0) then
            n=n+1
            y(n)=x
            write(*,'(1x,i5,2f15.6,i5)') n,x,its
          endif
        endif
12    continue
      END
