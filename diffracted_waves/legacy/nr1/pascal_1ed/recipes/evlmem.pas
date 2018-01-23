(* BEGINENVIRON
CONST
   mp =
TYPE
   RealArrayMP = ARRAY [1..mp] OF real;
ENDENVIRON *)
FUNCTION evlmem(fdt: real;
            VAR cof: RealArrayMP;
                  m: integer;
                 pm: real): real;
VAR
   wr,wi,wpr,wpi,wtemp,theta: double;
   sumi,sumr,wrs,wis: real;
   i: integer;
BEGIN
   theta := 6.28318530717959*fdt;
   wpr := cos(theta);
   wpi := sin(theta);
   wr := 1.0;
   wi := 0.0;
   sumr := 1.0;
   sumi := 0.0;
   FOR i := 1 TO m DO BEGIN
      wtemp := wr;
      wr := wr*wpr-wi*wpi;
      wi := wi*wpr+wtemp*wpi;
      wrs := wr;
      wis := wi;
      sumr := sumr-cof[i]*wrs;
      sumi := sumi-cof[i]*wis
   END;
   evlmem := pm/(sqr(sumr)+sqr(sumi))
END;
