      PROGRAM xpolint
C     driver for routine polint
      INTEGER NP
      REAL PI
      PARAMETER(NP=10,PI=3.1415926)
      INTEGER i,n,nfunc
      REAL dy,f,x,y,xa(NP),ya(NP)
      write(*,*) 'Generation of interpolation tables'
      write(*,*) ' ... sin(x)    0<x<PI'
      write(*,*) ' ... exp(x)    0<x<1 '
      write(*,*) 'How many entries go in these tables? (note: N<10)'
      read(*,*) n
      do 14 nfunc=1,2
        if (nfunc.eq.1) then
          write(*,*) 'sine function from 0 to PI'
          do 11 i=1,n
            xa(i)=i*PI/n
            ya(i)=sin(xa(i))
11        continue
        else if (nfunc.eq.2) then
          write(*,*) 'exponential function from 0 to 1'
          do 12 i=1,n
            xa(i)=i*1.0/n
            ya(i)=exp(xa(i))
12        continue
        else
          stop
        endif
        write(*,'(t10,a1,t20,a4,t28,a12,t46,a5)')
     *       'x','f(x)','interpolated','error'
        do 13 i=1,10
          if (nfunc.eq.1) then
            x=(-0.05+i/10.0)*PI
            f=sin(x)
          else if (nfunc.eq.2) then
            x=(-0.05+i/10.0)
            f=exp(x)
          endif
          call polint(xa,ya,n,x,y,dy)
          write(*,'(1x,3f12.6,e15.4)') x,f,y,dy
13      continue
        write(*,*) '***********************************'
        write(*,*) 'Press RETURN'
        read(*,*)
14    continue
      END
