FUNCTION bessk0(x: real): real;
VAR
   y,ans: double;
BEGIN
   IF x <= 2.0 THEN BEGIN
      y := x*x/4.0;
      ans := (-ln(x/2.0)*bessi0(x))+(-0.57721566+y*(0.42278420+y*(0.23069756
               +y*(0.3488590e-1+y*(0.262698e-2+y*(0.10750e-3+y*0.74e-5))))))
   END
   ELSE BEGIN
      y := (2.0/x);
      ans := (exp(-x)/sqrt(x))*(1.25331414+y*(-0.7832358e-1+y*(0.2189568e-1
            +y*(-0.1062446e-1+y*(0.587872e-2+y*(-0.251540e-2+y*0.53208e-3))))))
   END;
   bessk0 := ans
END;
