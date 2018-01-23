(* BEGINENVIRON
CONST
   np =
TYPE
   RealArrayNP = ARRAY [1..np] OF real;
VAR
   LinminNcom: integer;
   LinminPcom,LinminXicom: RealArrayNP;
PROCEDURE dfnc(VAR x,df: RealArrayNP);
ENDENVIRON *)
FUNCTION df1dim(x: real): real;
VAR
   df1: real;
   j: integer;
   xt,df: ^RealArrayNP;
BEGIN
   new(xt);
   new(df);
   FOR j := 1 TO LinminNcom DO
      xt^[j] := LinminPcom[j]+x*LinminXicom[j];
   dfnc(xt^,df^);
   df1 := 0.0;
   FOR j := 1 TO LinminNcom DO
      df1 := df1+df^[j]*LinminXicom[j];
   df1dim := df1;
   dispose(df);
   dispose(xt)
END;

FUNCTION dfunc(x: real): real;
BEGIN
   dfunc := df1dim(x)
END;
