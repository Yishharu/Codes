      PROGRAM xran4
C     driver for routine ran4
      INTEGER i,idum(4)
      REAL random(4),ran4,ansiee(4),ansvax(4)
      DATA ansvax /0.275898,0.208204,0.034307,0.838676/
      DATA ansiee /0.219120,0.849246,0.375290,0.457334/
      DATA idum /-1,99,-99,99/
      do 11 i=1,4
        random(i)=ran4(idum(i))
11    continue
      write(*,*) 'ran4 gets values: ',(random(i),i=1,4)
      write(*,*) '    IEEE answers: ',(ansiee(i),i=1,4)
      write(*,*) '     VAX answers: ',(ansvax(i),i=1,4)
      END
