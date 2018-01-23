      PROGRAM xsphbes
C     driver for routine sphbes
      INTEGER i,n,nval
      REAL sj,sy,sjp,syp,x,xsj,xsy,xsjp,xsyp
      CHARACTER text*26
      open(7,file='FNCVAL.DAT',status='OLD')
10    read(7,'(a)') text
      if (text.ne.'Spherical Bessel Functions') goto 10
      read(7,*) nval
      write(*,*) text
      write(*,'(1x,t3,a1,t6,a1)') 'N','X'
      write(*,'(1x,t5,a2,t21,a2,t37,a3,t53,a3)') 'SJ','SY','SJP','SYP'
      write(*,'(1x,t5,a3,t21,a3,t37,a4,t53,a4)')
     *     'XSJ','XSY','XSJP','XSYP'
      do 11 i=1,nval
        read(7,*) n,x,sj,sy,sjp,syp
        call sphbes(n,x,xsj,xsy,xsjp,xsyp)
        write(*,'(i3,f6.2/1p4e16.6/1p4e16.6)')
     *       n,x,sj,sy,sjp,syp,xsj,xsy,xsjp,xsyp
11    continue
      close(7)
      END
