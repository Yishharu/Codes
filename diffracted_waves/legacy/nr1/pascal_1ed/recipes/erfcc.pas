FUNCTION erfcc(x: real): real;
VAR
   t,z,ans: real;
BEGIN
   z := abs(x);
   t := 1.0/(1.0+0.5*z);
   ans := t*exp(-z*z-1.26551223+t*(1.00002368+t*(0.37409196+t*(0.09678418
            +t*(-0.18628806+t*(0.27886807+t*(-1.13520398+t*(1.48851587
            +t*(-0.82215223+t*0.17087277)))))))));
   IF x >= 0.0 THEN erfcc := ans
   ELSE erfcc := 2.0-ans
END;
