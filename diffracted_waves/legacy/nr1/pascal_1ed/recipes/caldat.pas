PROCEDURE caldat(julian: longint;
         VAR mm,id,iyyy: integer);
CONST
   igreg = 2299161;
VAR
   je,jd,jc,jb,jalpha,ja: longint;
BEGIN
   IF julian >= igreg THEN BEGIN
      jalpha := trunc(((julian-1867216)-0.25)/36524.25);
      ja := julian+1+jalpha-trunc(0.25*jalpha)
   END
   ELSE
      ja := julian;
   jb := ja+1524;
   jc := trunc(6680.0+((jb-2439870)-122.1)/365.25);
   jd := 365*jc+trunc(0.25*jc);
   je := trunc((jb-jd)/30.6001);
   id := jb-jd-trunc(30.6001*je);
   mm := je-1;
   IF mm > 12 THEN mm := mm-12;
   iyyy := jc-4715;
   IF mm > 2 THEN iyyy := iyyy-1;
   IF iyyy <= 0 THEN iyyy := iyyy-1
END;
