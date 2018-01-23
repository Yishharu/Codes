DECLARE SUB CRANK (N!, W!(), S!)
DECLARE SUB SORT2 (N!, RA!(), RB!())
DECLARE FUNCTION ERFCC! (X!)
DECLARE FUNCTION BETAI! (A!, B!, X!)

SUB SPEAR (DATA1(), DATA2(), N, WKSP1(), WKSP2(), D, ZD, PROBD, RS, PROBRS)
FOR J = 1 TO N
  WKSP1(J) = DATA1(J)
  WKSP2(J) = DATA2(J)
NEXT J
CALL SORT2(N, WKSP1(), WKSP2())
CALL CRANK(N, WKSP1(), SF)
CALL SORT2(N, WKSP2(), WKSP1())
CALL CRANK(N, WKSP2(), SG)
D = 0!
FOR J = 1 TO N
  D = D + (WKSP1(J) - WKSP2(J)) ^ 2
NEXT J
EN = INT(N)
EN3N = EN ^ 3 - EN
AVED = EN3N / 6! - (SF + SG) / 12!
FAC = (1! - SF / EN3N) * (1! - SG / EN3N)
VARD = ((EN - 1!) * EN ^ 2 * (EN + 1!) ^ 2 / 36!) * FAC
ZD = (D - AVED) / SQR(VARD)
PROBD = ERFCC(ABS(ZD) / 1.4142136#)
RS = (1! - (6! / EN3N) * (D + (SF + SG) / 12!)) / SQR(FAC)
FAC = (1! + RS) * (1! - RS)
IF FAC > 0! THEN
  T = RS * SQR((EN - 2!) / FAC)
  DF = EN - 2!
  PROBRS = BETAI(.5 * DF, .5, DF / (DF + T ^ 2))
ELSE
  PROBRS = 0!
END IF
END SUB

