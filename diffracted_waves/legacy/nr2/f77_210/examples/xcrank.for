      PROGRAM xcrank
C     driver for routine crank
      INTEGER NDAT,NMON
      PARAMETER(NDAT=20,NMON=12)
      INTEGER i,j
      REAL s,data(NDAT),rays(NDAT,NMON),order(NDAT),ave(NDAT),zlat(NDAT)
      CHARACTER city(NDAT)*15,mon(NMON)*4,text*64
      open(7,file='TABLE2.DAT',status='OLD')
      read(7,*)
      read(7,'(a)') text
      read(7,'(15x,12a4/)') (mon(i),i=1,NMON)
      do 11 i=1,NDAT
        read(7,'(a15,12f4.0,f6.0,f6.1)')
     *       city(i),(rays(i,j),j=1,NMON),ave(i),zlat(i)
11    continue
      close(7)
      write(*,'(1x,a)') text
      write(*,'(1x,15x,12a4)') (mon(i),i=1,NMON)
      do 12 i=1,NDAT
        write(*,'(1x,a,12i4)')
     *       city(i),(nint(rays(i,j)),j=1,NMON)
12    continue
      write(*,'(/1x,a)') 'press RETURN to continue...'
      read(*,*)
C     Replace solar flux in each column by rank order
      do 15 j=1,NMON
        do 13 i=1,NDAT
          data(i)=rays(i,j)
          order(i)=i
13      continue
        call sort2(NDAT,data,order)
        call crank(NDAT,data,s)
        do 14 i=1,NDAT
          rays(nint(order(i)),j)=data(i)
14      continue
15    continue
      write(*,'(1x,t17,12a4)') (mon(i),i=1,NMON)
      do 16 i=1,NDAT
      write(*,'(1x,a,12i4)') city(i),(nint(rays(i,j)),j=1,NMON)
16    continue
      END
