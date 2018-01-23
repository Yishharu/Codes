FUNCTION bessi1(x: real): real;
VAR
   ax: real;
   y,ans: double;
BEGIN
   IF abs(x) < 3.75 THEN BEGIN
      y := sqr(x/3.75);
      ans := x*(0.5+y*(0.87890594+y*(0.51498869+y*(0.15084934
               +y*(0.2658733e-1+y*(0.301532e-2+y*0.32411e-3))))))
   END
   ELSE BEGIN
      ax := abs(x);
      y := 3.75/ax;
      ans := 0.2282967e-1+y*(-0.2895312e-1+y*(0.1787654e-1-y*0.420059e-2));
      ans := 0.39894228+y*(-0.3988024e-1+y*(-0.362018e-2
               +y*(0.163801e-2+y*(-0.1031555e-1+y*ans))));
      ans := (exp(ax)/sqrt(ax))*ans;
      IF x < 0.0 THEN ans := -ans
   END;
   bessi1 := ans
END;
