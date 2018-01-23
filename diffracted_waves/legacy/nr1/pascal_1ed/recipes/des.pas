(* BEGINENVIRON
TYPE
   ByteArray32 = ARRAY [1..32] OF byte;
   ByteArray48 = ARRAY [1..48] OF byte;
   ByteArray56 = ARRAY [1..56] OF byte;
   ByteArray64 = ARRAY [1..64] OF byte;
   Immense = RECORD
                l,r: longint
             END;
   Great = RECORD
              l,c,r: word
           END;
VAR
   infile: text;
   CyfunIet: ByteArray48;
   CyfunIpp: ByteArray32;
   CyfunIs: Array [1..16,1..4,1..8] OF integer;
   CyfunIbin: Array [0..15] OF longint;
   CyfunFlg: boolean;
   KsIcd: Immense;
   KsIpc1: ByteArray56;
   KsIpc2: ByteArray48;
   KsFlg: boolean;
   DesBit : ARRAY [1..32] OF longint;
   DesFlg: integer;
   DesIp,DesIpm: ByteArray64;
   DesKns: ARRAY [1..16] OF Great;
   DesFlg: boolean;
BEGIN
   CyfunFlg := true;
   KsFlg := true;
   DesFlg := true;
ENDENVIRON *)
PROCEDURE des(inp,key: Immense;
           VAR newkey: boolean;
                  isw: integer;
              VAR out: Immense);
VAR
   ii,i,j,k: integer;
   ic: longint;
   itmp: Immense;

FUNCTION getbit(source: Immense;
                 bitno: byte;
                 nbits: integer): longint;
BEGIN
   IF bitno <= nbits THEN
      IF DesBit[bitno] AND source.r <> 0 THEN
         getbit := 1
      ELSE
         getbit := 0
   ELSE
      IF DesBit[bitno-nbits] AND source.l <> 0 THEN
         getbit := 1
      ELSE
         getbit := 0
END;

PROCEDURE cyfun(ir: longint;
                 k: Great;
          VAR iout: longint);
VAR
   ie: Great;
   itmp1,itmp2,ietmp1,ietmp2: longint;
   iec: ARRAY [1..8] OF byte;
   jj,ki,irow,icol,iss,j,l,m: integer;
BEGIN
   IF CyfunFlg THEN BEGIN
      CyfunFlg := false;
      NROpen(infile,'cyfuni.dat');
      FOR j := 1 to 48 DO read(infile,CyfunIet[j]);
      FOR j := 1 to 32 DO read(infile,CyfunIpp[j]);
      FOR jj := 1 to 8 DO
         FOR ki := 1 to 4 DO
            FOR j := 1 to 16 DO read(infile,CyfunIs[j,ki,jj]);
      FOR j := 0 to 15 DO read(infile,CyfunIbin[j]);
      close(infile)
   END;
   ie.r := 0;
   ie.c := 0;
   ie.l := 0;
   FOR j := 16 DOWNTO 1 DO BEGIN
      l := j+16;
      m := l+16;
      ie.r := ie.r SHL 1;
      IF DesBit[CyfunIet[j]] AND ir <> 0 THEN ie.r := ie.r OR 1;
      ie.c := ie.c SHL 1;
      IF DesBit[CyfunIet[l]] AND ir <> 0 THEN ie.c := ie.c OR 1;
      ie.l := ie.l SHL 1;
      IF DesBit[CyfunIet[m]] AND ir <> 0 THEN ie.l := ie.l OR 1
   END;
   ie.r := ie.r XOR k.r;
   ie.c := ie.c XOR k.c;
   ie.l := ie.l XOR k.l;
   itmp1 := ie.c;
   itmp2 := ie.r;
   ietmp1 := (itmp1 SHL 16) + itmp2;
   itmp2 := ie.l;
   ietmp2 := (itmp2 SHL 8) + (itmp1 SHR 8);
   FOR j := 1 to 4 DO BEGIN
      m := j+4;
      iec[j] := ietmp1 AND $3F;
      iec[m] := ietmp2 AND $3F;
      ietmp1 := ietmp1 SHR 6;
      ietmp2 := ietmp2 SHR 6
   END;
   itmp1 := 0;
   FOR jj := 8 DOWNTO 1 DO BEGIN
      j := iec[jj];
      irow := ((j AND $1) SHL 1) + ((j AND $20) SHR 5);
      icol := ((j AND $2) SHL 2) + (j AND $4)
         + ((j AND $8) SHR 2) + ((j AND $10) SHR 4);
      iss := CyfunIs[icol+1][irow+1][jj];
      itmp1 := (itmp1 SHL 4) OR CyfunIbin[iss]
   END;
   iout := 0;
   FOR j := 32 DOWNTO 1 DO BEGIN
      iout := iout SHL 1;
      IF DesBit[CyfunIpp[j]] AND itmp1 <> 0 THEN
         iout := iout OR 1
   END
END;

PROCEDURE ks(key: Immense;
               n: Integer;
          VAR kn: Great);
VAR
   it,i,j,k,l: integer;
BEGIN
   IF KsFlg THEN BEGIN
      KsFlg := false;
      NROPEN(infile,'ksinpu.dat');
      FOR i := 1 to 56 DO read(infile,KsIpc1[i]);
      FOR i := 1 to 48 DO read(infile,KsIpc2[i]);
      close(infile)
   END;
   IF n = 1 THEN BEGIN
      KsIcd.r := 0;
      KsIcd.l := 0;
      FOR j := 28 DOWNTO 1 DO BEGIN
         k := j+28;
         KsIcd.r := (KsIcd.r SHL 1) OR getbit(key,KsIpc1[j],32);
         KsIcd.l := (KsIcd.l SHL 1) OR getbit(key,KsIpc1[k],32)
      END
   END;
   IF (n = 1) OR (n = 2) OR (n = 9) OR (n = 16) THEN
      it := 1
   ELSE
      it := 2;
   FOR i := 1 to it DO BEGIN
      KsIcd.r := (KsIcd.r OR ((KsIcd.r AND 1) SHL 28)) SHR 1;
      KsIcd.l := (KsIcd.l OR ((KsIcd.l AND 1) SHL 28)) SHR 1
   END;
   kn.r := 0;
   kn.c := 0;
   kn.l := 0;
   FOR j := 16 DOWNTO 1 DO BEGIN
      k := j+16;
      l := k+16;
      kn.r := (kn.r SHL 1) OR getbit(KsIcd,KsIpc2[j],28);
      kn.c := (kn.c SHL 1) OR getbit(KsIcd,KsIpc2[k],28);
      kn.l := (kn.l SHL 1) OR getbit(KsIcd,KsIpc2[l],28)
   END
END;

BEGIN
   IF DesFlg THEN BEGIN
      DesFlg := false;
      DesBit[1] := 1;
      FOR j := 2 to 32 DO
         DesBit[j] := DesBit[j-1] SHL 1;
      NROpen(infile,'desinp.dat');
      FOR i := 1 to 64 DO read(infile,DesIp[i]);
      FOR i := 1 to 64 DO read(infile,DesIpm[i]);
      close(infile)
   END;
   IF newkey THEN BEGIN
      newkey := false;
      FOR i := 1 to 16 DO ks(key,i,DesKns[i])
   END;
   itmp.r := 0;
   itmp.l := 0;
   FOR j := 32 DOWNTO 1 DO BEGIN
      k := j+32;
      itmp.r := (itmp.r SHL 1) OR getbit(inp,DesIp[j],32);
      itmp.l := (itmp.l SHL 1) OR getbit(inp,DesIp[k],32)
   END;
   FOR i := 1 to 16 DO BEGIN
      IF isw = 1 THEN ii := 17-i ELSE ii := i;
      cyfun(itmp.l,DesKns[ii],ic);
      ic := ic XOR itmp.r;
      itmp.r := itmp.l;
      itmp.l := ic
   END;
   ic := itmp.r;
   itmp.r := itmp.l;
   itmp.l := ic;
   out.r := 0;
   out.l := 0;
   FOR j := 32 DOWNTO 1 DO BEGIN
      k := j+32;
      out.r := (out.r SHL 1) OR getbit(itmp,DesIpm[j],32);
      out.l := (out.l SHL 1) OR getbit(itmp,DesIpm[k],32)
   END
END;
