DECLARE SUB FLMOON (N!, NPH!, JD&, FRAC!)
DECLARE FUNCTION JULDAY& (IM!, ID!, IY!)

'PROGRAM BADLUK
CLS
TIMZON = -5! / 24
READ IYBEG, IYEND
DATA 1900,2000
PRINT "Full moons on Friday the 13th from"; IYBEG; "to"; IYEND
PRINT
FOR IYYY = IYBEG TO IYEND
  FOR IM = 1 TO 12
    JDAY& = JULDAY&(IM, 13, IYYY)
    IDWK = (JDAY& + 1) - 7 * INT((JDAY& + 1) / 7)
    IF IDWK = 5 THEN
      N = INT(12.37 * (IYYY - 1900 + (IM - .5) / 12!))
      ICON = 0
      DO
        CALL FLMOON(N, 2, JD&, FRAC)
        IFRAC = CINT(24! * (FRAC + TIMZON))
        IF IFRAC < 0 THEN
          JD& = JD& - 1
          IFRAC = IFRAC + 24
        END IF
        IF IFRAC > 12 THEN
          JD& = JD& + 1
          IFRAC = IFRAC - 12
        ELSE
          IFRAC = IFRAC + 12
        END IF
        IF JD& = JDAY& THEN
          PRINT IM; "/"; 13; "/"; IYYY
          PRINT "Full moon"; IFRAC; "hrs after midnight (EST)."
          PRINT
          EXIT DO
        ELSE
          IC = SGN(JDAY& - JD&)
          IF IC = -ICON THEN EXIT DO
          ICON = IC
          N = N + IC
        END IF
      LOOP
    END IF
  NEXT IM
NEXT IYYY
END

