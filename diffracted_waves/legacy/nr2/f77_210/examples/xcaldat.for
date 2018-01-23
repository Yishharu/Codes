      PROGRAM xcaldat
C     driver for routine caldat
      INTEGER i,im,imm,id,idd,iy,iyy,iycopy,j,julday,n
      CHARACTER name(12)*10
C     check whether CALDAT properly undoes the operation of JULDAY
      DATA name/'January','February','March','April','May',
     *     'June','July','August','September','October',
     *     'November','December'/
      open(7,file='DATES.DAT',status='OLD')
      read(7,*)
      read(7,*) n
      write(*,'(/1x,a,t40,a)') 'Original Date:','Reconstructed Date:'
      write(*,'(1x,a,t12,a,t17,a,t25,a,t40,a,t50,a,t55,a/)')
     *     'Month','Day','Year','Julian Day','Month','Day','Year'
      do 11 i=1,n
        read(7,'(i2,i3,i5)') im,id,iy
        iycopy=iy
        j=julday(im,id,iycopy)
        call caldat(j,imm,idd,iyy)
        write(*,'(1x,a,i3,i6,4x,i9,6x,a,i3,i6)') name(im),id,
     *       iy,j,name(imm),idd,iyy
11    continue
      END
