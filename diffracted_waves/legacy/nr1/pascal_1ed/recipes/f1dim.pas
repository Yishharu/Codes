FUNCTION f1dim(x: real): real;
VAR
   j: integer;
   xt: ^RealArrayNP;
BEGIN
   new(xt);
   FOR j := 1 TO LinminNcom DO
      xt^[j] := LinminPcom[j]+x*LinminXicom[j];
   f1dim := fnc(xt^);
   dispose(xt)
END;

FUNCTION func(x: real): real;
BEGIN
   func := f1dim(x)
END;
