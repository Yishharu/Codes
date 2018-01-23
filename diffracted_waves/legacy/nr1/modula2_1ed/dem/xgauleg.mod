MODULE XGauLeg; (* driver for routine GauLeg *) 
 
   FROM GaussQdr IMPORT GauLeg;
   FROM NRMath   IMPORT Exp, ExpDD;
   FROM NRSystem IMPORT LongReal, S;
   FROM NRIO     IMPORT ReadLn, WriteLn, WriteInt, WriteReal,
                        WriteLongReal, WriteString;
   FROM NRLVect  IMPORT LVector, DisposeLVector, PtrToLongReals, CreateLVector,
                        NilLVector;

   CONST
      npoint = 10;
      x1 = 0.0;
      x2 = 1.0;
      x3 = 10.0;
      nValue = 10;
   VAR
      i, j: INTEGER;
      xx: LongReal; 
      X, W: LVector;
      x, w: PtrToLongReals; (* npoint *)

   PROCEDURE func(x: LongReal): LongReal; 
   BEGIN 
      RETURN x*ExpDD(-x); 
   END func; 
    
BEGIN 
   CreateLVector(npoint, X, x);
   CreateLVector(npoint, W, w);
   GauLeg(x1, x2, X, W); 
   WriteLn; 
   WriteString(' #'); 
   WriteString('      x^[i]'); 
   WriteString('       w^[i]'); 
   WriteLn; 
   FOR i := 0 TO npoint-1 DO 
      WriteInt(i, 2); 
      WriteLongReal(x^[i], 12, 6);
      WriteLongReal(w^[i], 12, 6);
      WriteLn;
   END; (* demonstrate the use of GauLeg for an integral *) 
   GauLeg(x1, x3, X, W); 
   xx := 0.0; 
   FOR i := 0 TO npoint-1 DO 
      xx := xx+w^[i]*func(x^[i])
   END; 
   WriteLn; 
   WriteString('Integral from GAULEG: '); 
   WriteReal(S(xx), 12, 6); 
   WriteLn;
   WriteString('Actual value: ');
   WriteReal((1.0+x1)*Exp(-x1)-(1.0+x3)*Exp(-x3), 12, 6);
   ReadLn;
END XGauLeg.
