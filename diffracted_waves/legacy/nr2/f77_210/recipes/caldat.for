      SUBROUTINE caldat(julian,mm,id,iyyy)
      INTEGER id,iyyy,julian,mm,IGREG
      PARAMETER (IGREG=2299161)
      INTEGER ja,jalpha,jb,jc,jd,je
      if(julian.ge.IGREG)then
        jalpha=int(((julian-1867216)-0.25d0)/36524.25d0)
        ja=julian+1+jalpha-int(0.25d0*jalpha)
      else if(julian.lt.0)then
        ja=julian+36525*(1-julian/36525)
      else
        ja=julian
      endif
      jb=ja+1524
      jc=int(6680.0d0+((jb-2439870)-122.1d0)/365.25d0)
      jd=365*jc+int(0.25d0*jc)
      je=int((jb-jd)/30.6001d0)
      id=jb-jd-int(30.6001d0*je)
      mm=je-1
      if(mm.gt.12)mm=mm-12
      iyyy=jc-4715
      if(mm.gt.2)iyyy=iyyy-1
      if(iyyy.le.0)iyyy=iyyy-1
      if(julian.lt.0)iyyy=iyyy-100*(1-julian/36525)
      return
      END
