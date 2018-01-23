MODULE XRan4; (* driver for routine Ran4 *) 
 
   FROM DataEnc  IMPORT Ran4;
   FROM Tests1   IMPORT AveVar;
   FROM NRSystem IMPORT LongInt;
   FROM NRIO     IMPORT File,  Open, Close, ReadLn, WriteLn, WriteInt, WriteReal, 
                        WriteString;
   FROM NRVect   IMPORT Vector, NilVector, PtrToReals, CreateVector, DisposeVector;
   FROM SYSTEM   IMPORT BYTE, WORD;

   CONST 
      npt = 49; 
   TYPE 
      ByteArray32 = ARRAY [1..32] OF BYTE; 
      ByteArray48 = ARRAY [1..48] OF BYTE; 
      ByteArray56 = ARRAY [1..56] OF BYTE; 
      ByteArray64 = ARRAY [1..64] OF BYTE; 
      Immense = RECORD l, r: LongInt END; 
      Great = RECORD l, c, r: WORD END; 
      RealArray65 = ARRAY [1..65] OF REAL; 
      RealArrayNP = ARRAY [0..npt] OF REAL; 
   VAR 
      DesBit: ARRAY [1..32] OF LongInt; 
      DesIp, DesIpm: ByteArray64; 
      DesKns: ARRAY [1..16] OF Great; 
      DesFlg: BOOLEAN; 
      CyfunIet: ByteArray48; 
      CyfunIpp: ByteArray32; 
      CyfunIs: ARRAY [1..16], [1..4], [1..8] OF INTEGER; 
      CyfunIbin: ARRAY [0..15] OF LongInt; 
      CyfunFlg: BOOLEAN; 
      KsIcd: Immense; 
      KsIpc1: ByteArray56; 
      KsIpc2: ByteArray48; 
      KsFlg: BOOLEAN; 
      Ran4Newkey: BOOLEAN; 
      Ran4Inp, Ran4Key: Immense; 
      Ran4Pow: RealArray65; 
      infile: File; 
      ave, vrnce: REAL; 
      idum, j: INTEGER; 
      Y: Vector;
      y: PtrToReals; 
       
BEGIN 
   CreateVector(npt, Y, y);
   IF Y # NilVector THEN 
	   KsFlg := TRUE; 
	   CyfunFlg := TRUE; 
	   DesFlg := TRUE; 
	   idum := -123; 
	   ave := 0.0; 
	   WriteString('First 10 Random Numbers with idum = '); 
	   WriteInt(idum, 5); 
	   WriteLn; 
	   WriteLn; 
	   WriteString('   #       Ran4'); 
	   WriteLn; 
	   FOR j := 0 TO 9 DO 
	      y^[j] := Ran4(idum)
	   END; 
	   FOR j := 0 TO 9 DO 
	      WriteInt(j, 4); 
	      WriteReal(y^[j], 12, 6); 
	      WriteLn
	   END; 
	   WriteLn; 
	   WriteString('Average and Variance of Next '); 
	   WriteInt(npt, 3); 
	   WriteLn; 
	   FOR j := 0 TO npt-1 DO 
	      y^[j] := Ran4(idum)
	   END; 
	   AveVar(Y, ave, vrnce); 
	   WriteLn; 
	   WriteString('Average: '); 
	   WriteReal(ave, 10, 4); 
	   WriteLn; 
	   WriteString('Variance:'); 
	   WriteReal(vrnce, 10, 4); 
	   WriteLn; 
	   WriteLn; 
	   WriteString('Expected Result for an Infinite Sample:'); 
	   WriteLn; 
	   WriteLn; 
	   WriteString('Average: '); 
	   WriteReal(0.5, 10, 4); 
	   WriteLn; 
	   WriteString('Variance:'); 
	   WriteReal(1.0/12.0, 10, 4); 
	   WriteLn;
	   ReadLn;
	   DisposeVector(Y);
	END;
END XRan4.
