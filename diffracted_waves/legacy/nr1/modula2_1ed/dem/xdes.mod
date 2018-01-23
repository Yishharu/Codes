MODULE XDES; (* driver for routine DES, Turbo Pascal version *)

   FROM DataEnc  IMPORT DES, Immense, SHL, SHR, And, Or;
   FROM NRSystem IMPORT LongInt, DI;
   FROM NRIO     IMPORT File, Open, Close, GetLine, GetEOL, GetInt, GetChars, EOF,   
                        ReadLn, WriteLn, WriteInt, WriteReal, WriteString;
   FROM NRBase IMPORT Equal;
   FROM SYSTEM IMPORT BYTE, WORD;

   TYPE 
      ByteArray32 = ARRAY [1..32] OF BYTE; 
      ByteArray48 = ARRAY [1..48] OF BYTE; 
      ByteArray56 = ARRAY [1..56] OF BYTE; 
      ByteArray64 = ARRAY [1..64] OF BYTE; 
      Great = RECORD l, c, r: WORD END; 
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
      idirec, i, j, m, mm, nciphr: INTEGER;
      newkey: BOOLEAN;
      iin, iout, key: Immense;
      hin, hkey, hout, hcmp: ARRAY [1..17] OF CHAR;
      verdct: ARRAY [1..8] OF CHAR;
      text: ARRAY [1..60] OF CHAR;
      txt2: ARRAY [1..6] OF CHAR;
      dataFile, infile: File;

   (* Coverts character representing hexadecimal number to its
   long INTEGER value in a machine-independent way. *)

   PROCEDURE hex2longint(ch: CHAR): LongInt;
   BEGIN
      IF (ch >= '0') AND (ch <= '9') THEN 
         RETURN VAL(LongInt, ORD(ch)-ORD('0'))
      ELSE
         RETURN VAL(LongInt, ORD(ch)-ORD('A'))+10
      END; 
   END hex2longint; 

   (* Inverse of hex2int *) 
   PROCEDURE longint2hex(i: LongInt): CHAR; 
   BEGIN 
      IF i <= 9 THEN
         RETURN CHR(VAL(INTEGER, i)+ORD('0'))
      ELSE 
         RETURN CHR(VAL(INTEGER, i)-10+ORD('A'))
      END; 
   END longint2hex; 

   (* Reverse bits of type Immense *) 
   PROCEDURE reverse(VAR input: Immense); 
      VAR
         temp: Immense;
         i: INTEGER; 
   BEGIN 
      temp.r := 0; 
      temp.l := 0; 
      FOR i := 1 TO 32 DO 
         temp.r := Or(SHL(temp.r, 1), And(input.l, 01H)); 
         temp.l := Or(SHL(temp.l, 1), And(input.r, 01H)); 
         input.r := SHR(input.r, 1); 
         input.l := SHR(input.l, 1)
      END; 
      input.r := temp.r; 
      input.l := temp.l
   END reverse; 

BEGIN 
   DesFlg := TRUE; 
   CyfunFlg := TRUE; 
   KsFlg := TRUE; 
   Open('destst.dat', dataFile);
   GetLine(dataFile, text);
   WriteString(text);
   WriteLn;
   LOOP
      GetLine(dataFile, text);
      IF EOF(dataFile) THEN EXIT END;
      WriteString(text);
      WriteLn;
      GetInt(dataFile, nciphr);
      GetEOL(dataFile);
      GetLine(dataFile, txt2);
      IF Equal(txt2, 'encode') THEN idirec := 0 END;
      IF Equal(txt2, 'decode') THEN idirec := 1 END;
      REPEAT
         WriteString('       key           plaintext'); 
         WriteString('      expected cipher  actual cipher'); 
         WriteLn; 
         mm := 16; 
         IF nciphr < 16 THEN mm := nciphr END; 
         DEC(nciphr, 16); 
         FOR m := 1 TO mm DO 
            GetChars(dataFile, 17, hkey); 
            GetChars(dataFile, 17, hin);
            GetChars(dataFile, 17, hcmp);
            GetEOL(dataFile);
            iin.l := 0; 
            iin.r := 0; 
            key.l := 0; 
            key.r := 0; 
            FOR i := 2 TO 9 DO 
               j := i+8; 
               iin.l := Or(SHL(iin.l, 4), hex2longint(hin[i])); 
               key.l := Or(SHL(key.l, 4), hex2longint(hkey[i])); 
               iin.r := Or(SHL(iin.r, 4), hex2longint(hin[j])); 
               key.r := Or(SHL(key.r, 4), hex2longint(hkey[j]))
            END; 
            newkey := TRUE; 
            reverse(iin); 
            reverse(key); 
            DES(iin, key, newkey, idirec, iout); 
            reverse(iout); 
            hout := '                 '; 
            FOR i := 9 TO 2 BY -1 DO 
               j := i+8; 
               hout[i] := longint2hex(And(iout.l, 0FH)); 
               hout[j] := longint2hex(And(iout.r, 0FH)); 
               iout.l := SHR(iout.l, 4); 
               iout.r := SHR(iout.r, 4)
            END; 
            verdct := 'wrong   '; 
            IF Equal(hcmp, hout) THEN verdct := 'o.k.    ' END; 
            WriteString(hkey); 
            WriteString(hin); 
            WriteString(hcmp); 
            WriteString(hout); 
            WriteString('          ');
            WriteString(verdct); 
            WriteLn
         END; 
         WriteString('press RETURN to continue ...'); 
         WriteLn; 
         ReadLn
      UNTIL nciphr <= 0
   END; 
END XDES.
