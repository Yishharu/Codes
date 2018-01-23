MODULE XProbks; (* driver for routine ProbKS *) 
 
   FROM Tests2   IMPORT ProbKS;
   FROM NRMath   IMPORT Round;
   FROM NRSystem IMPORT Float;
   FROM NRIO     IMPORT ReadLn, WriteLn, WriteInt, WriteReal, WriteString,
                        Error;

   CONST 
      npts = 20; 
      eps = 0.1; 
      iscal = 40; 
   TYPE 
      CharArrayISCAL = ARRAY [1..iscal] OF CHAR; 
   VAR 
      alam, aval: REAL; 
      i, j: INTEGER; 
      text: CharArrayISCAL; 
       
BEGIN 
   WriteString('probability function for kolmogorov-smirnov statistic'); 
   WriteLn; 
   WriteLn; 
   WriteString(' lambda    value:       graph:'); WriteLn; 
   FOR i := 1 TO npts DO 
      alam := Float(i)*eps; 
      aval := ProbKS(alam); 
      FOR j := 1 TO iscal DO 
         IF j <= Round(Float(iscal)*aval) THEN 
            text[j] := '*'
         ELSE 
            text[j] := ' '
         END
      END; 
      WriteReal(alam, 8, 6); 
      WriteReal(aval, 10, 6); 
      WriteString('     '); 
      WriteString(text); 
      WriteLn;
   END;
   ReadLn;
END XProbks.
