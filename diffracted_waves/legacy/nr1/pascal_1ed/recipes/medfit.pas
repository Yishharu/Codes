(* BEGINENVIRON
CONST
   ndatap =
TYPE
   RealArrayNDATA = ARRAY [1..ndatap] OF real;
   RealArrayNP = RealArrayNDATA
ENDENVIRON *)
PROCEDURE medfit(VAR x,y: RealArrayNDATA;
                   ndata: integer;
           VAR a,b,abdev: real);
LABEL 99;
VAR
   j: integer;
   sy,sxy,sxx,sx,sigb,f2,f1,f: real;
   del,chisq,bb,b2,b1,abdevt: real;

FUNCTION rofunc(b: real): real;
VAR
   d,sum: real;
   j,n1,nmh,nml: integer;
   arr: RealArrayNDATA;
BEGIN
   n1 := ndata+1;
   nml := n1 DIV 2;
   nmh := n1-nml;
   FOR j := 1 TO ndata DO
      arr[j] := y[j]-b*x[j];
   sort(ndata,arr);
   a := 0.5*(arr[nml]+arr[nmh]);
   sum := 0.0;
   abdevt := 0.0;
   FOR j := 1 TO ndata DO BEGIN
      d := y[j]-(b*x[j]+a);
      abdevt := abdevt+abs(d);
      IF d > 0.0 THEN
         sum := sum+x[j]
      ELSE
         sum := sum-x[j]
   END;
   rofunc := sum
END;

BEGIN
   sx := 0.0;
   sy := 0.0;
   sxy := 0.0;
   sxx := 0.0;
   FOR j := 1 TO ndata DO BEGIN
      sx := sx+x[j];
      sy := sy+y[j];
      sxy := sxy+x[j]*y[j];
      sxx := sxx+sqr(x[j])
   END;
   del := ndata*sxx-sx*sx;
   a := (sxx*sy-sx*sxy)/del;
   bb := (ndata*sxy-sx*sy)/del;
   chisq := 0.0;
   FOR j := 1 TO ndata DO
      chisq := chisq+sqr(y[j]-(a+bb*x[j]));
   sigb := sqrt(chisq/del);
   b1 := bb;
   f1 := rofunc(b1);
   IF f1 >= 0.0 THEN
      b2 := bb+abs(3.0*sigb)
   ELSE
      b2 := bb-abs(3.0*sigb);
   f2 := rofunc(b2);
   WHILE f1*f2 > 0.0 DO BEGIN
      bb := 2.0*b2-b1;
      b1 := b2;
      f1 := f2;
      b2 := bb;
      f2 := rofunc(b2)
   END;
   sigb := 0.01*sigb;
   WHILE abs(b2-b1) > sigb DO BEGIN
      bb := 0.5*(b1+b2);
      IF (bb = b1) OR (bb = b2) THEN GOTO 99;
      f := rofunc(bb);
      IF f*f1 >= 0.0 THEN BEGIN
         f1 := f;
         b1 := bb
      END
      ELSE BEGIN
         f2 := f;
         b2 := bb
      END
   END;
99:
   b := bb;
   abdev := abdevt/ndata
END;
