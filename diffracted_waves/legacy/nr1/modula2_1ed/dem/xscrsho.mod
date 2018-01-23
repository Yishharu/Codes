MODULE XSCRSHO; (* driver for routine SCRSHO *) 
 
   FROM SCRSHOM IMPORT SCRSHO;
   FROM Bessel  IMPORT BessJ0;

BEGIN 
   SCRSHO(BessJ0);
END XSCRSHO.
