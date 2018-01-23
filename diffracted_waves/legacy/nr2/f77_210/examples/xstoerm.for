      PROGRAM xstoerm
C     driver for routine stoerm
      INTEGER NVAR
      REAL HTOT,X1
      PARAMETER(NVAR=4,X1=0.,HTOT=1.570796)
      INTEGER i
      REAL a1,a2,x,xf,y(NVAR),yout(NVAR),d2y(NVAR),d2y1,d2y2
      EXTERNAL derivs
      d2y1(x)=x+sin(x)
      d2y2(x)=x**2+cos(x)-2
      y(1)=0.
      y(2)=-1.
      y(3)=2.
      y(4)=0.
      call derivs(X1,y,d2y)
      xf=X1+HTOT
      a1=d2y1(xf)
      a2=d2y2(xf)
      write(*,'(1x,a/)') 'Stoermer''s Rule:'
      do 11 i=5,45,10
        call stoerm(y,d2y,NVAR,X1,HTOT,i,yout,derivs)
        write(*,'(1x,a,f6.4,a,f6.4,a,i2,a)') 'X = ',X1,
     *       ' to ',X1+HTOT,' in ',i,' steps'
        write(*,'(1x,t5,a,t20,a)') 'Integration','Answer'
        write(*,'(1x,2f12.6)') yout(1),a1
        write(*,'(1x,2f12.6)') yout(2),a2
11    continue
      END

      SUBROUTINE derivs(x,y,d2y)
      REAL x,y(*),d2y(*)
      d2y(1)=x-y(1)
      d2y(2)=x*x-y(2)
      END
