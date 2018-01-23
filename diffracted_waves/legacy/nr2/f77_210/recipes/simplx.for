      SUBROUTINE simplx(a,m,n,mp,np,m1,m2,m3,icase,izrov,iposv)
      INTEGER icase,m,m1,m2,m3,mp,n,np,iposv(m),izrov(n),MMAX,NMAX
      REAL a(mp,np),EPS
      PARAMETER (MMAX=100,NMAX=100,EPS=1.e-6)
CU    USES simp1,simp2,simp3
      INTEGER i,ip,is,k,kh,kp,nl1,l1(NMAX),l3(MMAX)
      REAL bmax,q1
      if(m.ne.m1+m2+m3)pause 'bad input constraint counts in simplx'
      nl1=n
      do 11 k=1,n
        l1(k)=k
        izrov(k)=k
11    continue
      do 12 i=1,m
        if(a(i+1,1).lt.0.)pause 'bad input tableau in simplx'
        iposv(i)=n+i
12    continue
      if(m2+m3.eq.0)goto 30
      do 13 i=1,m2
        l3(i)=1
13    continue
      do 15 k=1,n+1
        q1=0.
        do 14 i=m1+1,m
          q1=q1+a(i+1,k)
14      continue
        a(m+2,k)=-q1
15    continue
10    call simp1(a,mp,np,m+1,l1,nl1,0,kp,bmax)
      if(bmax.le.EPS.and.a(m+2,1).lt.-EPS)then
        icase=-1
        return
      else if(bmax.le.EPS.and.a(m+2,1).le.EPS)then
        do 16 ip=m1+m2+1,m
          if(iposv(ip).eq.ip+n)then
            call simp1(a,mp,np,ip,l1,nl1,1,kp,bmax)
            if(bmax.gt.EPS)goto 1
          endif
16      continue
        do 18 i=m1+1,m1+m2
          if(l3(i-m1).eq.1)then
            do 17 k=1,n+1
              a(i+1,k)=-a(i+1,k)
17          continue
          endif
18      continue
        goto 30
      endif
      call simp2(a,m,n,mp,np,ip,kp)
      if(ip.eq.0)then
        icase=-1
        return
      endif
1     call simp3(a,mp,np,m+1,n,ip,kp)
      if(iposv(ip).ge.n+m1+m2+1)then
        do 19 k=1,nl1
          if(l1(k).eq.kp)goto 2
19      continue
2       nl1=nl1-1
        do 21 is=k,nl1
          l1(is)=l1(is+1)
21      continue
      else
        kh=iposv(ip)-m1-n
        if(kh.ge.1)then
          if(l3(kh).ne.0)then
            l3(kh)=0
            a(m+2,kp+1)=a(m+2,kp+1)+1.
            do 22 i=1,m+2
              a(i,kp+1)=-a(i,kp+1)
22          continue
          endif
        endif
      endif
      is=izrov(kp)
      izrov(kp)=iposv(ip)
      iposv(ip)=is
      goto 10
30    call simp1(a,mp,np,0,l1,nl1,0,kp,bmax)
      if(bmax.le.EPS)then
        icase=0
        return
      endif
      call simp2(a,m,n,mp,np,ip,kp)
      if(ip.eq.0)then
        icase=1
        return
      endif
      call simp3(a,mp,np,m,n,ip,kp)
      is=izrov(kp)
      izrov(kp)=iposv(ip)
      iposv(ip)=is
      goto 30
      END
