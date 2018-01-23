      PROGRAM xdftint
C     driver for routine dftint
      REAL a,b,c,cans,cosint,d,sans,sinint,w
      COMMON /parms/ c,d
      EXTERNAL coscxd
      write(*,'(2x,a,t10,a,t37,a,t44,a,t70,a)') 'Omega',
     * 'Integral cosine*test func','Err','Integral sine*test func','Err'
3     write(*,*) 'INPUT C,D: '
      read(*,*) c,d
1     write(*,*) 'INPUT A,B: '
      read(*,*) a,b
      if (a.eq.b) goto 3
2     write(*,*) 'INPUT W: '
      read(*,*,END=999) w
      if (w.lt.0.) goto 1
      call dftint(coscxd,a,b,w,cosint,sinint)
      call getans(w,a,b,cans,sans)
      write(*,100) w,cans,cosint-cans,sans,sinint-sans
100   format(1p5e15.6)
      goto 2
999   write(*,*) 'NORMAL COMPLETION'
      STOP
      END

      REAL FUNCTION coscxd(x)
      REAL c,d,x
      COMMON /parms/ c,d
      coscxd=cos(c*x+d)
      return
      END

      SUBROUTINE getans(w,a,b,cans,sans)
      REAL a,b,c,cans,ci,d,sans,si,w,x
      COMMON /parms/ c,d
      ci(x)=sin((w-c)*x-d)/(2.*(w-c))+sin((w+c)*x+d)/(2.*(w+c))
      si(x)=-cos((w-c)*x-d)/(2.*(w-c))-cos((w+c)*x+d)/(2.*(w+c))
      cans=ci(b)-ci(a)
      sans=si(b)-si(a)
      return
      END
