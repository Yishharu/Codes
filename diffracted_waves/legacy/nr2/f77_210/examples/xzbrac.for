      PROGRAM xzbrac
C     driver for routine zbrac
      LOGICAL succes
      INTEGER i
      REAL bessj0,x1,x2
      EXTERNAL bessj0
      write(*,'(/1x,t4,a,t29,a/)') 'Bracketing values:',
     *     'Function values:'
      write(*,'(1x,t6,a,t16,a,t29,a,t41,a/)') 'X1','X2',
     *     'BESSJ0(X1)','BESSJ0(X2)'
      do 11 i=1,10
        x1=i
        x2=x1+1.0
        call zbrac(bessj0,x1,x2,succes)
        if (succes) then
          write(*,'(1x,f7.2,f10.2,7x,2f12.6)') x1,x2,
     *         bessj0(x1),bessj0(x2)
        endif
11    continue
      END
