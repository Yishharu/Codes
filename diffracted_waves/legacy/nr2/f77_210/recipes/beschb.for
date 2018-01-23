      SUBROUTINE beschb(x,gam1,gam2,gampl,gammi)
      INTEGER NUSE1,NUSE2
      DOUBLE PRECISION gam1,gam2,gammi,gampl,x
      PARAMETER (NUSE1=5,NUSE2=5)
CU    USES chebev
      REAL xx,c1(7),c2(8),chebev
      SAVE c1,c2
      DATA c1/-1.142022680371168d0,6.5165112670737d-3,3.087090173086d-4,
     *-3.4706269649d-6,6.9437664d-9,3.67795d-11,-1.356d-13/
      DATA c2/1.843740587300905d0,-7.68528408447867d-2,
     *1.2719271366546d-3,-4.9717367042d-6,-3.31261198d-8,2.423096d-10,
     *-1.702d-13,-1.49d-15/
      xx=8.d0*x*x-1.d0
      gam1=chebev(-1.,1.,c1,NUSE1,xx)
      gam2=chebev(-1.,1.,c2,NUSE2,xx)
      gampl=gam2-x*gam1
      gammi=gam2+x*gam1
      return
      END
