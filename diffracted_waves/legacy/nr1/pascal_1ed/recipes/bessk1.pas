FUNCTION bessk1(x: real): real;
VAR
   y,ans: double;
BEGIN
   IF x <= 2.0 THEN BEGIN
      y := x*x/4.0;
      ans := (ln(x/2.0)*bessi1(x))+(1.0/x)*(1.0+y*(0.15443144+y*(-0.67278579
          +y*(-0.18156897+y*(-0.1919402e-1+y*(-0.110404e-2+y*(-0.4686e-4)))))))
   END
   ELSE BEGIN
      y := 2.0/x;
      ans := (exp(-x)/sqrt(x))*(1.25331414+y*(0.23498619+y*(-0.3655620e-1
          +y*(0.1504268e-1+y*(-0.780353e-2+y*(0.325614e-2+y*(-0.68245e-3)))))))
   END;
   bessk1 := ans
END;
