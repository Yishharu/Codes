      SUBROUTINE simp2(a,m,n,mp,np,ip,kp)
      INTEGER ip,kp,m,mp,n,np
      REAL a(mp,np),EPS
      PARAMETER (EPS=1.e-6)
      INTEGER i,k
      REAL q,q0,q1,qp
      ip=0
      do 11 i=1,m
        if(a(i+1,kp+1).lt.-EPS)goto 1
11    continue
      return
1     q1=-a(i+1,1)/a(i+1,kp+1)
      ip=i
      do 13 i=ip+1,m
        if(a(i+1,kp+1).lt.-EPS)then
          q=-a(i+1,1)/a(i+1,kp+1)
          if(q.lt.q1)then
            ip=i
            q1=q
          else if (q.eq.q1) then
            do 12 k=1,n
              qp=-a(ip+1,k+1)/a(ip+1,kp+1)
              q0=-a(i+1,k+1)/a(i+1,kp+1)
              if(q0.ne.qp)goto 2
12          continue
2           if(q0.lt.qp)ip=i
          endif
        endif
13    continue
      return
      END
