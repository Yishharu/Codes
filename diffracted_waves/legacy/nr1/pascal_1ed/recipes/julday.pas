FUNCTION julday(mm,id,iyyy: integer): longint;
CONST
   igreg = 588829;
VAR
   ja,jm,jy: integer;
   jul,jyyy: longint;
BEGIN
   IF iyyy = 0 THEN BEGIN
      writeln('there is no year zero.');
      readln;
   END;
   IF iyyy < 0 THEN iyyy := iyyy+1;
   IF mm > 2 THEN BEGIN
      jy := iyyy;
      jm := mm+1
   END
   ELSE BEGIN
      jy := iyyy-1;
      jm := mm+13
   END;
   jul := trunc(365.25*jy)+trunc(30.6001*jm)+id+1720995;
   jyyy := iyyy;
   IF id+31*(mm+12*jyyy) >= igreg THEN BEGIN
      ja := trunc(0.01*jy);
      jul := jul+2-ja+trunc(0.25*ja)
   END;
   julday := jul
END;
