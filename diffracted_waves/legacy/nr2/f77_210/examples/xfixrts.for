      PROGRAM xfixrts
C     driver for routine fixrts
      INTEGER NPOL,NPOLES
      PARAMETER(NPOLES=6,NPOL=NPOLES+1)
      INTEGER i
      REAL d(NPOLES)
      COMPLEX zcoef(NPOL),zeros(NPOLES),z
      LOGICAL polish
      DATA d/6.0,-15.0,20.0,-15.0,6.0,0.0/
C     finding roots of (z-1.0)**6=1.0
C     first print roots
      zcoef(NPOLES+1)=cmplx(1.0,0.0)
      do 11 i=NPOLES,1,-1
        zcoef(i)=cmplx(-d(NPOLES+1-i),0.0)
11    continue
      polish=.true.
      call zroots(zcoef,NPOLES,zeros,polish)
      write(*,'(/1x,a)') 'Roots of (z-1.0)^6 = 1.0'
      write(*,'(1x,t20,a,t42,a)') 'Root','(z-1.0)^6'
      do 12 i=1,NPOLES
        z=(zeros(i)-1.0)**6
        write(*,'(1x,i6,4f12.6)') i,zeros(i),z
12    continue
C     now fix them to lie within unit circle
      call fixrts(d,NPOLES)
C     check results
      zcoef(NPOLES+1)=cmplx(1.0,0.0)
      do 13 i=NPOLES,1,-1
        zcoef(i)=cmplx(-d(NPOLES+1-i),0.0)
13    continue
      call zroots(zcoef,NPOLES,zeros,polish)
      write(*,'(/1x,a)') 'Roots reflected in unit circle'
      write(*,'(1x,t20,a,t42,a)') 'Root','(z-1.0)^6'
      do 14 i=1,NPOLES
        z=(zeros(i)-1.0)**6
        write(*,'(1x,i6,4f12.6)') i,zeros(i),z
14    continue
      END
