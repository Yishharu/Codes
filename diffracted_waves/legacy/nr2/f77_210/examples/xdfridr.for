      PROGRAM xdfridr
C     driver for routine dfridr
      REAL dfridr,dx,err,func,h,x
      EXTERNAL func
1     write(*,*) 'input x,h '
      read(*,*,END=999) x,h
      dx=dfridr(func,x,h,err)
      write(*,*) 'DFRIDR=',dx,1./cos(x)**2,err
      goto 1
999   END

      REAL FUNCTION func(x)
      REAL x
      func=tan(x)
      return
      END
