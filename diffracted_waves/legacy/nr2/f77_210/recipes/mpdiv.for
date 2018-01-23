      SUBROUTINE mpdiv(q,r,u,v,n,m)
      INTEGER m,n,NMAX,MACC
      CHARACTER*1 q(n-m+1),r(m),u(n),v(m)
      PARAMETER (NMAX=8192,MACC=6)
CU    USES mpinv,mpmov,mpmul,mpsad,mpsub
      INTEGER is
      CHARACTER*1 rr(2*NMAX),s(2*NMAX)
      if(n+MACC.gt.NMAX)pause 'NMAX too small in mpdiv'
      call mpinv(s,v,n+MACC,m)
      call mpmul(rr,s,u,n+MACC,n)
      call mpsad(s,rr,n+MACC-1,1)
      call mpmov(q,s(3),n-m+1)
      call mpmul(rr,q,v,n-m+1,m)
      call mpsub(is,rr(2),u,rr(2),n)
      if (is.ne.0) pause 'MACC too small in mpdiv'
      call mpmov(r,rr(n-m+2),m)
      return
      END
