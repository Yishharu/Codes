      PROGRAM xpolcof
C     driver for routine polcof
      INTEGER NP
      REAL PI
      PARAMETER(NP=5,PI=3.141593)
      INTEGER i,j,nfunc
      REAL f,sum,x,xa(NP),ya(NP),coeff(NP)
      do 15 nfunc=1,2
        if (nfunc.eq.1) then
          write(*,*) 'Sine function from 0 to PI'
          do 11 i=1,NP
            xa(i)=i*PI/NP
            ya(i)=sin(xa(i))
11        continue
        else if (nfunc.eq.2) then
          write(*,*) 'Exponential function from 0 to 1'
          do 12 i=1,NP
            xa(i)=1.0*i/NP
            ya(i)=exp(xa(i))
12        continue
        else
          stop
        endif
        call polcof(xa,ya,NP,coeff)
        write(*,*) '    coefficients'
        write(*,'(1x,6f12.6)') (coeff(i),i=1,NP)
        write(*,'(1x,t10,a1,t20,a4,t29,a10)')
     *       'x','f(x)','polynomial'
        do 14 i=1,10
          if (nfunc.eq.1) then
            x=(-0.05+i/10.0)*PI
            f=sin(x)
          else if (nfunc.eq.2) then
            x=-0.05+i/10.0
            f=exp(x)
          endif
          sum=coeff(NP)
          do 13 j=NP-1,1,-1
            sum=coeff(j)+sum*x
13        continue
          write(*,'(1x,3f12.6)') x,f,sum
14      continue
        write(*,*) '***********************************'
        write(*,*) 'Press RETURN'
        read(*,*)
15    continue
      END
