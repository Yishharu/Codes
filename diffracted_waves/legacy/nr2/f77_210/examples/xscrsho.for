      PROGRAM xscrsho
C     driver for routine scrsho
      REAL bessj0
      EXTERNAL bessj0
      write(*,*) 'Graph of the Bessel Function J0:'
      call scrsho(bessj0)
      END
