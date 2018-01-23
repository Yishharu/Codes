IMPLEMENTATION MODULE Tests1;

   FROM IncBeta  IMPORT BetaI;
   FROM NRMath   IMPORT Sqrt, Ln;
   FROM NRSystem IMPORT Float;
   FROM NRIO     IMPORT Error;
   FROM NRVect   IMPORT Vector, CreateVector, DisposeVector, PtrToReals, GetVectorAttr, 
                        NilVector;

   PROCEDURE AveVar(    DATA: Vector; 
                    VAR ave, svar: REAL); 
      VAR 
         j, n: INTEGER; 
         s: REAL; 
         data: PtrToReals;
   BEGIN 
      GetVectorAttr(DATA, n, data);
      ave := 0.0; 
      svar := 0.0; 
      FOR j := 0 TO n-1 DO 
         ave := ave+data^[j]
      END; 
      ave := ave/Float(n); 
      FOR j := 0 TO n-1 DO 
         s := data^[j]-ave; 
         svar := svar+s*s
      END; 
      svar := svar/Float(n-1)
   END AveVar; 

   PROCEDURE FTest(    DATA1, DATA2: Vector; 
                   VAR f, prob: REAL); 
      VAR 
         i, n1, n2: INTEGER; 
         var1, var2, df1, df2, ave1, ave2: REAL; 
         data1, data2: PtrToReals;
   BEGIN 
      GetVectorAttr(DATA1, n1, data1);
      GetVectorAttr(DATA2, n2, data2);
      AveVar(DATA1, ave1, var1); 
      AveVar(DATA2, ave2, var2); 
      IF var1 > var2 THEN (* Make f the ratio of the larger
                             variance to the smaller one. *)
         f := var1/var2; 
         df1 := Float(n1-1); 
         df2 := Float(n2-1)
      ELSE 
         f := var2/var1; 
         df1 := Float(n2-1); 
         df2 := Float(n1-1)
      END; 
      prob := 2.0*BetaI(0.5*df2, 0.5*df1, df2/(df2+df1*f)); 
      IF prob > 1.0 THEN 
         prob := 2.0-prob
      END; 
   END FTest; 

   PROCEDURE TPTest(    DATA1, DATA2: Vector; 
                    VAR t, prob: REAL); 
      VAR 
         j, n, n2: INTEGER; 
         var2, var1, sd, df, cov, ave2, ave1: REAL; 
         data1, data2: PtrToReals;
   BEGIN 
      GetVectorAttr(DATA1, n, data1);
      GetVectorAttr(DATA2, n2, data2);
      AveVar(DATA1, ave1, var1); 
      AveVar(DATA2, ave2, var2); 
      cov := 0.0; 
      FOR j := 0 TO n-1 DO 
         cov := cov+(data1^[j]-ave1)*(data2^[j]-ave2)
      END; 
      df := Float(n-1); 
      cov := cov/df; 
      sd := Sqrt((var1+var2-2.0*cov)/Float(n)); 
      t := (ave1-ave2)/sd; 
      prob := BetaI(0.5*df, 0.5, df/(df+(t*t)))
   END TPTest; 

   PROCEDURE TTest(    DATA1, DATA2: Vector; 
                   VAR t, prob: REAL); 
      VAR 
         i, n1, n2: INTEGER; 
         var1, var2, svar, df, ave1, ave2: REAL; 
         data1, data2: PtrToReals;
   BEGIN 
      GetVectorAttr(DATA1, n1, data1);
      GetVectorAttr(DATA2, n2, data2);
      AveVar(DATA1, ave1, var1); 
      AveVar(DATA2, ave2, var2); 
      df := Float(n1+n2-2); (* Degrees of freedom. *)
      svar := (Float(n1-1)*var1+Float(n2-1)*var2)/df; (* Pooled variance. *)
      t := (ave1-ave2)/Sqrt(svar*(1.0/Float(n1)+1.0/Float(n2))); 
      prob := BetaI(0.5*df, 0.5, df/(df+t*t))
	   (*
	     See equation (6.3.9).
	   *)
   END TTest; 

   PROCEDURE TUTest(    DATA1, DATA2: Vector; 
                    VAR t, prob: REAL);
      VAR 
         var1, var2, df, ave1, ave2, work1, work2, work3: REAL; 
         i, n1, n2: INTEGER; 
         data1, data2: PtrToReals;
   BEGIN 
      GetVectorAttr(DATA1, n1, data1);
      GetVectorAttr(DATA2, n2, data2);
      AveVar(DATA1, ave1, var1); 
      AveVar(DATA2, ave2, var2); 
      work1 := var1/Float(n1)+var2/Float(n2);
      t := (ave1-ave2)/Sqrt(work1); 
      work2 := var1/Float(n1);
      work3 := var2/Float(n2);
      df := (work1*work1)/((work2*work2)/Float(n1-1)+
            (work3*work3)/Float(n2-1)); 
      prob := BetaI(0.5*df, 0.5, df/(df+t*t))
   END TUTest; 

END Tests1.
