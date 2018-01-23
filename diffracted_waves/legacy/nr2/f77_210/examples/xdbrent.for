      PROGRAM xdbrent
C     driver for routine dbrent
      REAL EQL,TOL
      PARAMETER(TOL=1.0E-6,EQL=1.E-4)
      INTEGER i,iflag,j,nmin
      REAL amin(20),ax,bx,cx,dbr,fa,fb,fc,xmin
      REAL bessj0,dbrent,deriv
      EXTERNAL bessj0,deriv
      nmin=0
      write(*,'(/1x,a)') 'Minima of the function BESSJ0'
      write(*,'(/1x,t6,a,t19,a,t27,a,t39,a,t53,a/)') 'Min. #','X',
     *     'BESSJ0(X)','BESSJ1(X)','DBRENT'
      do 12 i=1,100
        ax=i
        bx=i+1.0
        call mnbrak(ax,bx,cx,fa,fb,fc,bessj0)
        dbr=dbrent(ax,bx,cx,bessj0,deriv,TOL,xmin)
        if (nmin.eq.0) then
          amin(1)=xmin
          nmin=1
          write(*,'(1x,5x,i2,3x,4f12.6)') nmin,xmin,
     *         bessj0(xmin),deriv(xmin),dbr
        else
          iflag=0
          do 11 j=1,nmin
            if (abs(xmin-amin(j)).le.EQL*xmin) iflag=1
11        continue
          if (iflag.eq.0) then
            nmin=nmin+1
            amin(nmin)=xmin
            write(*,'(1x,5x,i2,3x,4f12.6)') nmin,xmin,
     *           bessj0(xmin),deriv(xmin),dbr
          endif
        endif
12    continue
      END

      REAL FUNCTION deriv(x)
      REAL bessj1,x
      deriv=-bessj1(x)
      END
