(* BEGINENVIRON
CONST
   np =
TYPE
   RealArrayNP = ARRAY [1..np] OF real;
ENDENVIRON *)
PROCEDURE qromb(a,b: real;
             VAR ss: real);
LABEL 99;
CONST
   eps = 1.0e-6;
   jmax = 20;
   jmaxp = 21;
   k = 5;
TYPE
   RealArrayJMAXP = ARRAY [1..jmaxp] OF real;
VAR
   i,j: integer;
   dss: real;
   h,s: ^RealArrayJMAXP;
   c,d: ^RealArrayNP;
BEGIN
   new(h);
   new(s);
   new(c);
   new(d);
   h^[1] := 1.0;
   FOR j := 1 TO jmax DO BEGIN
      trapzd(a,b,s^[j],j);
      IF j >= k THEN BEGIN
         FOR i := 1 TO k DO BEGIN
            c^[i] := h^[j-k+i];
            d^[i] := s^[j-k+i]
         END;
         polint(c^,d^,k,0.0,ss,dss);
         IF abs(dss) < eps*abs(ss) THEN GOTO 99
      END;
      s^[j+1] := s^[j];
      h^[j+1] := 0.25*h^[j]
   END;
   writeln('pause in QROMB - too many steps');
   readln;
99:
   dispose(d);
   dispose(c);
   dispose(s);
   dispose(h)
END;
