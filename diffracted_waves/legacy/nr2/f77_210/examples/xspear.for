      PROGRAM xspear
C     driver for routine spear
      INTEGER NDAT,NMON
      PARAMETER(NDAT=20,NMON=12)
      INTEGER i,j
      REAL d,probd,probrs,rs,zd
      REAL data1(NDAT),data2(NDAT),rays(NDAT,NMON)
      REAL wksp1(NDAT),wksp2(NDAT),ave(NDAT),zlat(NDAT)
      CHARACTER city(NDAT)*15,mon(NMON)*4,text*64
      open(7,file='TABLE2.DAT',status='OLD')
      read(7,*)
      read(7,'(a)') text
      read(7,'(15x,12a4/)') (mon(i),i=1,12)
      do 11 i=1,NDAT
        read(7,'(a15,12f4.0,f6.0,f6.1)')
     *       city(i),(rays(i,j),j=1,12),ave(i),zlat(i)
11    continue
      close(7)
      write(*,*) text
      write(*,'(1x,15x,12a4)') (mon(i),i=1,12)
      do 12 i=1,NDAT
        write(*,'(1x,a,12i4,i6,f6.1)') city(i),
     *       (nint(rays(i,j)),j=1,12)
12    continue
C     check temperature correlations between different months
      write(*,'(/1x,a)')
     *     'Are sunny summer places also sunny winter places?'
      write(*,'(1x,2a)') 'Check correlation of sampled U.S. solar ',
     *     'radiation (july with other months)'
      write(*,'(/1x,a,t16,a,t23,a,t37,a,t49,a,t63,a/)')
     *     'Month','D','St. Dev.','PROBD',
     *     'Spearman R','PROBRS'
      do 13 i=1,NDAT
        data1(i)=rays(i,1)
13    continue
      do 15 j=1,12
        do 14 i=1,NDAT
          data2(i)=rays(i,j)
14      continue
        call spear(data1,data2,NDAT,wksp1,wksp2,d,zd,probd,rs,probrs)
        write(*,'(1x,a,f13.2,2f12.6,3x,2f12.6)')
     *       mon(j),d,zd,probd,rs,probrs
15    continue
      END
