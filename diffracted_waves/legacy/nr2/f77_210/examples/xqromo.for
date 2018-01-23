      PROGRAM xqromo
C     driver for routine qromo
      REAL AINF,X1,X2,X3
      PARAMETER(X1=0.0,X2=1.5707963,X3=3.1415926,AINF=1.0E20)
      REAL res1,res2,result
      EXTERNAL funcl,midsql,funcu,midsqu,fncinf,midinf,fncend,midexp
      write(*,'(/1x,a)') 'Improper integrals:'
      call qromo(funcl,X1,X2,result,midsql)
      write(*,'(/1x,a)')
     *     'Function: SQRT(x)/SIN(x)       Interval: (0,pi/2)'
      write(*,'(1x,a,f8.4)')
     *     'Using: MIDSQL                  Result:',result
      call qromo(funcu,X2,X3,result,midsqu)
      write(*,'(/1x,a)')
     *     'Function: SQRT(pi-x)/SIN(x)    Interval: (pi/2,pi)'
      write(*,'(1x,a,f8.4)')
     *     'Using: MIDSQU                  Result:',result
      call qromo(fncinf,X2,AINF,result,midinf)
      write(*,'(/1x,a)')
     *     'Function: SIN(x)/x**2          Interval: (pi/2,infty)'
      write(*,'(1x,a,f8.4)')
     *     'Using: MIDINF                  Result:',result
      call qromo(fncinf,-AINF,-X2,result,midinf)
      write(*,'(/1x,a)')
     *     'Function: SIN(x)/x**2          Interval: (-infty,-pi/2)'
      write(*,'(1x,a,f8.4)')
     *     'Using: MIDINF                  Result:',result
      call qromo(fncend,X1,X2,res1,midsql)
      call qromo(fncend,X2,AINF,res2,midinf)
      write(*,'(/1x,a)')
     *     'Function: EXP(-x)/SQRT(x)      Interval: (0.0,infty)'
      write(*,'(1x,a,f8.4)')
     *     'Using: MIDSQL,MIDINF           Result:',res1+res2
      call qromo(fncend,X2,AINF,res2,midexp)
      write(*,'(/1x,a)')
     *     'Function: EXP(-x)/SQRT(x)      Interval: (0.0,infty)'
      write(*,'(1x,a,f8.4/)')
     *     'Using: MIDSQL,MIDEXP           Result:',res1+res2
      END

      REAL FUNCTION funcl(x)
      REAL x
      funcl=sqrt(x)/sin(x)
      END

      REAL FUNCTION funcu(x)
      REAL PI
      PARAMETER(PI=3.1415926)
      REAL x
      funcu=sqrt(PI-x)/sin(x)
      END

      REAL FUNCTION fncinf(x)
      REAL x
      fncinf=sin(dble(x))/(x**2)
      END

      REAL FUNCTION fncend(x)
      REAL x
      fncend=exp(-x)/sqrt(x)
      END
