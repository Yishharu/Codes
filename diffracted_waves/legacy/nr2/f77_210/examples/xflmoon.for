      PROGRAM xflmoon
C     driver for routine flmoon
      REAL TZONE
      PARAMETER(TZONE=-5.0)
      REAL frac,timzon
      INTEGER i,im,id,iy,ifrac,istr,j1,j2,julday,n,nph
      CHARACTER phase(4)*15,timstr(2)*3
      DATA phase/'new moon','first quarter',
     *     'full moon','last quarter'/
      DATA timstr/' AM',' PM'/
      write(*,*) 'Date of the next few phases of the moon'
      write(*,*) 'Enter today''s date (e.g. 12,15,1992)'
      timzon=TZONE/24.0
      read(*,*) im,id,iy
C     approximate number of full moons since January 1900
      n=12.37*(iy-1900+(im-0.5)/12.0)
      nph=2
      j1=julday(im,id,iy)
      call flmoon(n,nph,j2,frac)
      n=n+nint((j1-j2)/29.53)
      write(*,'(/1x,t6,a,t19,a,t32,a)') 'Date','Time(EST)','Phase'
      do 11 i=1,20
        call flmoon(n,nph,j2,frac)
        ifrac=nint(24.*(frac+timzon))
        if (ifrac.lt.0) then
          j2=j2-1
          ifrac=ifrac+24
        endif
        if (ifrac.ge.12) then
          j2=j2+1
          ifrac=ifrac-12
        else
          ifrac=ifrac+12
        endif
        if (ifrac.gt.12) then
          ifrac=ifrac-12
          istr=2
        else
          istr=1
        endif
        call caldat(j2,im,id,iy)
        write(*,'(1x,2i3,i5,t20,i2,a,5x,a)') im,id,iy,
     *       ifrac,timstr(istr),phase(nph+1)
        if (nph.eq.3) then
          nph=0
          n=n+1
        else
          nph=nph+1
        endif
11    continue
      END
