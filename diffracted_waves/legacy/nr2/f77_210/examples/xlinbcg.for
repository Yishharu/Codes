      PROGRAM xlinbcg
C     driver for routine linbcg
      INTEGER NP,NMAX,ITOL,ITMAX
      DOUBLE PRECISION TOL
      PARAMETER (NP=20,NMAX=1000,ITOL=1,TOL=1.d-9,ITMAX=75)
      INTEGER i,iter,ija
      DOUBLE PRECISION b(NP),x(NP),bcmp(NP),sa,err
      COMMON /mat/ sa(NMAX),ija(NMAX)
      do 11 i=1,NP
        x(i)=0.d0
        b(i)=1.d0
11    continue
      b(1)=3.d0
      b(NP)=-1.d0
      call linbcg(NP,b,x,ITOL,TOL,ITMAX,iter,err)
      write(*,'(/1x,a,e15.6)') 'Estimated error:',err
      write(*,'(/1x,a,i6)') 'Iterations needed:',iter
      write(*,'(/1x,a)') 'Solution vector:'
      write(*,'(1x,5f12.6)') (x(i),i=1,NP)
      call dsprsax(sa,ija,x,bcmp,NP)
C     this is a double precision version of sprsax
      write(*,'(/1x,a)') 'press RETURN to continue...'
      read(*,*)
      write(*,'(1x,a/t8,a,t22,a)') 'Test of solution vector:','a*x','b'
      do 12 i=1,NP
        write(*,'(1x,2f12.6)') bcmp(i),b(i)
12    continue
      END

      BLOCK DATA
      INTEGER NMAX
      PARAMETER(NMAX=1000)
      DOUBLE PRECISION sa
      INTEGER ija
      COMMON /mat/ sa(NMAX),ija(NMAX)
C     logical length = 59
      DATA sa/3.d0,3.d0,3.d0,3.d0,3.d0,3.d0,3.d0,3.d0,
     *     3.d0,3.d0,3.d0,3.d0,3.d0,3.d0,3.d0,3.d0,
     *     3.d0,3.d0,3.d0,3.d0,0.d0,2.d0,-2.d0,2.d0,
     *     -2.d0,2.d0,-2.d0,2.d0,-2.d0,2.d0,-2.d0,
     *     2.d0,-2.d0,2.d0,-2.d0,2.d0,-2.d0,2.d0,-2.d0,
     *     2.d0,-2.d0,2.d0,-2.d0,2.d0,-2.d0,2.d0,
     *     -2.d0,2.d0,-2.d0,2.d0,-2.d0,2.d0,-2.d0,
     *     2.d0,-2.d0,2.d0,-2.d0,2.d0,-2.d0,941*0.d0/
      DATA ija/22,23,25,27,29,31,33,35,37,39,41,43,45,47,49,51,53,
     *     55,57,59,60,2,1,3,2,4,3,5,4,6,5,7,6,8,7,9,8,10,9,11,10,
     *     12,11,13,12,14,13,15,14,16,15,17,16,18,17,19,18,20,19,941*0/
      END
