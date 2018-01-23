      SUBROUTINE rebin(rc,nd,r,xin,xi)
      INTEGER nd
      REAL rc,r(*),xi(*),xin(*)
      INTEGER i,k
      REAL dr,xn,xo
      k=0
      xo=0.
      dr=0.
      do 11 i=1,nd-1
1       if(rc.gt.dr)then
          k=k+1
          dr=dr+r(k)
        goto 1
        endif
        if(k.gt.1) xo=xi(k-1)
        xn=xi(k)
        dr=dr-rc
        xin(i)=xn-(xn-xo)*dr/r(k)
11    continue
      do 12 i=1,nd-1
        xi(i)=xin(i)
12    continue
      xi(nd)=1.
      return
      END
