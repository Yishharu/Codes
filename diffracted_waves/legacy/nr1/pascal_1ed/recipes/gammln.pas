FUNCTION gammln(xx: real): real;
CONST
   stp  =  2.50662827465;
VAR
   x,tmp,ser: double;
BEGIN
   x := xx-1.0;
   tmp := x+5.5;
   tmp := (x+0.5)*ln(tmp)-tmp;
   ser := 1.0+76.18009173/(x+1.0)-86.50532033/(x+2.0)+24.01409822/(x+3.0)
            -1.231739516/(x+4.0)+0.120858003e-2/(x+5.0)-0.536382e-5/(x+6.0);
   gammln := tmp+ln(stp*ser)
END;
