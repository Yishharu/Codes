      PROGRAM xbeschb
C     driver for routine beschb
      DOUBLE PRECISION gam1,gam2,gamp1,gammi,x,xgam1,xgam2,xgamp1,xgammi
      REAL gammln
1     write(*,*) 'Enter X'
      read(*,*,END=999) x
      call beschb(x,xgam1,xgam2,xgamp1,xgammi)
      write(*,'(1x,t3,a1)') 'X'
      write(*,'(1x,t5,a4,t21,a4,t37,a5,t53,a5)')
     *     'GAM1','GAM2','GAMP1','GAMMI'
      write(*,'(1x,t5,a4,t21,a4,t37,a5,t53,a5)')
     *     'XGAM1','XGAM2','XGAMP1','XGAMMI'
      gamp1=1/exp(gammln(1+sngl(x)))
      gammi=1/exp(gammln(1-sngl(x)))
      gam1=(gammi-gamp1)/(2*x)
      gam2=(gammi+gamp1)/2
      write(*,'(f6.2/1p4e16.6/1p4e16.6)')
     *     x,gam1,gam2,gamp1,gammi,xgam1,xgam2,xgamp1,xgammi
      go to 1
999   END
