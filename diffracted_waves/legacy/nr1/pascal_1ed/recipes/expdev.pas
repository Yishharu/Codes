FUNCTION expdev(VAR idum: integer): real;
VAR
   dum: real;
BEGIN
   REPEAT
      dum := ran3(idum);
   UNTIL dum <> 0.0;
   expdev := -ln(dum)
END;
