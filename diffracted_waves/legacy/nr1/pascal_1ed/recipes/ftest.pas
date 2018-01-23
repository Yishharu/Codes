(* BEGINENVIRON
CONST
   n12 =
TYPE
   RealArrayN12 = ARRAY [1..n12] OF real;
   RealArrayNP = RealArrayN12;
ENDENVIRON *)
PROCEDURE ftest(VAR data1: RealArrayN12;
                       n1: integer;
                VAR data2: RealArrayN12;
                       n2: integer;
               VAR f,prob: real);
VAR
   i: integer;
   var1,var2,df1,df2,ave1,ave2: real;
BEGIN
   avevar(data1,n1,ave1,var1);
   avevar(data2,n2,ave2,var2);
   IF var1 > var2 THEN BEGIN
      f := var1/var2;
      df1 := n1-1;
      df2 := n2-1
   END
   ELSE BEGIN
      f := var2/var1;
      df1 := n2-1;
      df2 := n1-1
   END;
   prob := 2.0*betai(0.5*df2,0.5*df1,df2/(df2+df1*f));
   IF prob > 1.0 THEN prob := 2.0-prob;
END;
