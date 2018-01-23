      PROGRAM xratlsq
C     driver for routine ratlsq
      INTEGER NMAX
      PARAMETER(NMAX=100)
      INTEGER j,kk,mm
      DOUBLE PRECISION a,b,cof(NMAX),dev,eee,fit,fn,ratval,xs
      EXTERNAL fn
1     write(*,*) 'enter a,b,mm,kk'
      read(*,*,END=999) a,b,mm,kk
      call ratlsq(fn,a,b,mm,kk,cof,dev)
      do 11 j=1,mm+kk+1
        write(*,'(1x,a4,i3,a2,e27.15)') 'cof(',j,')=',cof(j)
11    continue
      write(*,*) 'maximum absolute deviation=',dev
      write(*,*) '    x        error        exact'
      write(*,*) '--------- ------------ ---------'
      do 12 j=1,50
        xs=a+(b-a)*(j-1.)/49.
        fit=ratval(xs,cof,mm,kk)
        eee=fn(xs)
        write(*,'(1x,f10.5,2e15.7)') xs,fit-eee,eee
12    continue
      goto 1
999   END

      FUNCTION fn(t)
      DOUBLE PRECISION fn,t
      fn=atan(t)
      return
      END
