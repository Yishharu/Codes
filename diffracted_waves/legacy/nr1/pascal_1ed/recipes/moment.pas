(* BEGINENVIRON
CONST
   np =
TYPE
   RealArrayNP = ARRAY [1..np] OF real;
ENDENVIRON *)
PROCEDURE moment(VAR data: RealArrayNP;
                        n: integer;
        VAR ave,adev,sdev: real;
       VAR svar,skew,curt: real);
VAR
   j: integer;
   s,p: real;
BEGIN
   IF n <= 1 THEN BEGIN
      writeln('pause in MOMENT - n must be at least 2');
      readln
   END;
   s := 0.0;
   FOR j := 1 TO n DO
      s := s+data[j];
   ave := s/n;
   adev := 0.0;
   svar := 0.0;
   skew := 0.0;
   curt := 0.0;
   FOR j := 1 TO n DO BEGIN
      s := data[j]-ave;
      adev := adev+abs(s);
      p := s*s;
      svar := svar+p;
      p := p*s;
      skew := skew+p;
      p := p*s;
      curt := curt+p
   END;
   adev := adev/n;
   svar := svar/(n-1);
   sdev := sqrt(svar);
   IF svar <> 0.0 THEN BEGIN
      skew := skew/(n*sdev*sdev*sdev);
      curt := curt/(n*sqr(svar))-3.0
   END
   ELSE BEGIN
      writeln('pause in MOMENT - no skew/kurtosis when variance = 0');
      readln
   END
END;
