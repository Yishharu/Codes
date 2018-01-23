      PROGRAM xfgauss
C     driver for routine fgauss
      INTEGER NA,NLIN,NPT
      PARAMETER(NPT=3,NLIN=2,NA=3*NLIN)
      INTEGER i,j
      REAL e1,e2,f,x,y,a(NA),dyda(NA),df(NA)
      DATA a/3.0,0.2,0.5,1.0,0.7,0.3/
      write(*,'(/1x,t6,a,t14,a,t19,a,t27,a,t35,a,t43,a,t51,a,t59,a)')
     *     'X','Y','DYDA1','DYDA2','DYDA3','DYDA4','DYDA5','DYDA6'
      do 11 i=1,NPT
        x=0.3*i
        call fgauss(x,a,y,dyda,NA)
        e1=exp(-((x-a(2))/a(3))**2)
        e2=exp(-((x-a(5))/a(6))**2)
        f=a(1)*e1+a(4)*e2
        df(1)=e1
        df(4)=e2
        df(2)=a(1)*e1*2.0*(x-a(2))/(a(3)**2)
        df(5)=a(4)*e2*2.0*(x-a(5))/(a(6)**2)
        df(3)=a(1)*e1*2.0*((x-a(2))**2)/(a(3)**3)
        df(6)=a(4)*e2*2.0*((x-a(5))**2)/(a(6)**3)
        write(*,'(1x,a/,8f8.4)') 'from FGAUSS',x,y,(dyda(j),j=1,6)
        write(*,'(1x,a/,8f8.4/)') 'independent calc.',x,f,(df(j),j=1,6)
11    continue
      END
