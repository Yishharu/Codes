      PROGRAM xmnbrak
C     driver for routine mnbrak
      INTEGER i
      REAL ax,bx,cx,fa,fb,fc
      EXTERNAL bessj0
      do 11 i=1,10
        ax=i*0.5
        bx=(i+1.0)*0.5
        call mnbrak(ax,bx,cx,fa,fb,fc,bessj0)
        write(*,'(1x,t13,a,t25,a,t37,a)') 'A','B','C'
        write(*,'(1x,a3,t5,3f12.6)') 'X',ax,bx,cx
        write(*,'(1x,a3,t5,3f12.6)') 'F',fa,fb,fc
11    continue
      END
