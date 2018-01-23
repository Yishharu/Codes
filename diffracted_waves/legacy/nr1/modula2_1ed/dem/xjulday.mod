MODULE XJulDay; (* driver for JULDAY *)

   FROM Pre  IMPORT JulDay;
   FROM NRIO IMPORT File, Open, Close, GetLine, GetEOL, GetInt,
                    ReadLn,  ReadIntegers, WriteLn, WriteInt, WriteLongInt,
                    WriteString, Error;

   TYPE
      StrArray10 = ARRAY [0..10-1] OF CHAR;
      StrArray40 = ARRAY [0..40-1] OF CHAR;
   VAR
      i, id, im, iy, n: INTEGER;
      text: StrArray40;
      name: ARRAY [1..12] OF StrArray10;
      dataFile: File;

BEGIN
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
   Open('DATES1.DAT', dataFile);
   GetLine(dataFile, text);
   GetInt(dataFile, n);
   GetEOL(dataFile);
   WriteLn;
   WriteString('month');
   WriteString('     day');
   WriteString('  year');
   WriteString('  julian day');
   WriteString('   event');
   WriteLn;
   WriteLn;
   FOR i := 1 TO n DO
      GetInt(dataFile, im);
      GetInt(dataFile, id);
      GetInt(dataFile, iy);
      GetLine(dataFile, text);
      WriteString(name[im]);
      WriteInt(id, 3);
      WriteInt(iy, 6);
      WriteLongInt(JulDay(im, id, iy), 10);
      WriteString('    ');
      WriteString(text);
      WriteLn;
   END;
   Close(dataFile);
   WriteLn;
   WriteString('your choices:');
   WriteLn;
   WriteString('month day year (e.g. 1 13 1905)');
   WriteLn;
   im := 0;
   WHILE (im >= 0) DO
      WriteLn;
	   ReadIntegers('mm dd yyyy', im, id, iy);
	   IF (im >= 0) THEN
	      WriteString('julian day:  ');
         WriteLongInt(JulDay(im, id, iy), 10);
         WriteLn;
	   END;
   END;
END XJulDay.
