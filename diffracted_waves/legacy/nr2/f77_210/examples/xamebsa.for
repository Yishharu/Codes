      PROGRAM xamebsa
C     driver for routine amebsa
      INTEGER NP,MP,MPNP
      REAL FTOL
      PARAMETER(NP=4,MP=5,MPNP=20,FTOL=1.0E-6)
      INTEGER i,idum,iiter,iter,j,jiter,ndim,nit
      REAL temptr,tt,yb,ybb
      COMMON /ambsa/ tt,idum
      REAL p(MP,NP),x(NP),y(MP),xoff(NP),pb(NP),tfunk
      EXTERNAL tfunk
      DATA xoff/4*10./
      DATA p/MPNP*0.0/
      idum=-64
1     continue
      ndim=NP
      do 11 j=2,MP
        p(j,j-1)=1.
11    continue
      do 13 i=1,MP
        do 12 j=1,NP
          p(i,j)=p(i,j)+xoff(j)
          x(j)=p(i,j)
12      continue
        y(i)=tfunk(x)
13    continue
      yb=1.e30
      write(*,*) 'Input T, IITER:'
      read(*,*,END=999) temptr,iiter
      ybb=1.e30
      nit=0
      do 14 jiter=1,100
        iter=iiter
        temptr=temptr*0.8
        call amebsa(p,y,MP,NP,ndim,pb,yb,FTOL,tfunk,iter,temptr)
        nit=nit+iiter-iter
        if (yb.lt.ybb) then
          ybb=yb
          write(*,'(1x,i6,e10.3,4f11.5,e15.7)')
     *         nit,temptr,(pb(j),j=1,NP),yb
        endif
        if (iter.gt.0) goto 80
14    continue
80    write(*,'(/1x,a)') 'Vertices of final 3-D simplex and'
      write(*,'(1x,a)') 'function values at the vertices:'
      write(*,'(/3x,a,t11,a,t23,a,t35,a,t45,a/)') 'I',
     *     'X(I)','Y(I)','Z(I)','FUNCTION'
      do 15 i=1,MP
        write(*,'(1x,i3,4f12.6,e15.7)') i,(p(i,j),j=1,NP),y(i)
15    continue
      write(*,'(1x,i3,4f12.6,e15.7)') 99,(pb(j),j=1,NP),yb
      goto 1
999   write(*,*) 'NORMAL COMPLETION'
      STOP
      END

      REAL FUNCTION tfunk(p)
      INTEGER N
      REAL RAD,AUG
      PARAMETER (N=4,RAD=0.3,AUG=2.0)
      INTEGER j
      REAL q,r,sumd,sumr,p(N),wid(N)
      DATA wid /1.,3.,10.,30./
      sumd=0.
      sumr=0.
      do 11 j=1,N
        q=p(j)*wid(j)
        r=nint(q)
        sumr=sumr+q**2
        sumd=sumd+(q-r)**2
11    continue
      if (sumd.gt.RAD**2) then
        tfunk=sumr*(1.+AUG)+1.
      else
        tfunk=sumr*(1.+AUG*sumd/RAD**2)+1.
      endif
      return
      END
