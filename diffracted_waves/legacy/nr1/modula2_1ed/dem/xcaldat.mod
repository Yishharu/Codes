MODULE XCalDat; (* driver for routine CalDat *)
 
   FROM Pre      IMPORT CalDat, JulDay;
   FROM NRSystem IMPORT LongInt;
   FROM NRIO     IMPORT File, Open, GetEOL, GetInt,  ReadLn, WriteLn, WriteInt, 
                        WriteLongInt, WriteString, Error;

   TYPE 
      CharArray10 = ARRAY [1..10] OF CHAR; 
   VAR 
      i, id, idd, im, imm, iy, iyy, n: INTEGER; 
      j: LongInt; 
      name: ARRAY [1..12] OF CharArray10; 
      dataFile: File; 
       
BEGIN 
(* check whether CalDat properly undoes the operation of JulDay *) 
   name[1] := 'january   '; 
   name[2] := 'february  '; 
   name[3] := 'march     '; 
   name[4] := 'april     '; 
   name[5] := 'may       ';
   name[6] := 'june      '; 
   name[7] := 'july      '; 
   name[8] := 'august    '; 
   name[9] := 'september '; 
   name[10] := 'october   '; 
   name[11] := 'november  '; 
   name[12] := 'december  '; 
   Open('DATES1.dat', dataFile); 
   GetEOL(dataFile); 
   GetInt(dataFile, n); 
   GetEOL(dataFile); 
   WriteLn; 
   WriteString('original date:'); 
   WriteString('                       reconstructed date:'); 
   WriteLn; 
   WriteString('month     day  year    julian day'); 
   WriteString('    month     day  year'); 
   WriteLn; 
   FOR i := 1 TO n DO 
      GetInt(dataFile, im); 
      GetInt(dataFile, id);
      GetInt(dataFile, iy); 
      GetEOL(dataFile); 
      j := JulDay(im, id, iy); 
      CalDat(j, imm, idd, iyy); 
      WriteString(name[im]); 
      WriteInt(id, 3); 
      WriteInt(iy, 6); 
      WriteLongInt(j, 13);
      WriteString('     ');
      WriteString(name[imm]);
      WriteInt(idd, 3);
      WriteInt(iyy, 6);
      WriteLn;
   END;
END  XCalDat.
