DECLARE SUB LUBKSB (A!(), N!, NP!, INDX!(), B!())

SUB MPROVE (A(), ALUD(), N, NP, INDX(), B(), X())
DIM R(N)
FOR I = 1 TO N
  SDP# = -B(I)
  FOR J = 1 TO N
    SDP# = SDP# + CDBL(A(I, J)) * CDBL(X(J))
  NEXT J
  R(I) = SDP#
NEXT I
CALL LUBKSB(ALUD(), N, NP, INDX(), R())
FOR I = 1 TO N
  X(I) = X(I) - R(I)
NEXT I
ERASE R
END SUB

