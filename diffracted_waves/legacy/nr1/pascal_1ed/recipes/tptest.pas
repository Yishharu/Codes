(* BEGINENVIRON
CONST
   np =
TYPE
   RealArrayNP := ARRAY [1..np] OF real;
ENDENVIRON *)
PROCEDURE tptest(VAR data1,data2: RealArrayNP;
                               n: integer;
                      VAR t,prob: real);
VAR
   j: integer;
   var2,var1,sd,df,cov,ave2,ave1: real;
BEGIN
   avevar(data1,n,ave1,var1);
   avevar(data2,n,ave2,var2);
   cov := 0.0;
   FOR j := 1 TO n DO
      cov := cov+(data1[j]-ave1)*(data2[j]-ave2);
   df := n-1;
   cov := cov/df;
   sd := sqrt((var1+var2-2.0*cov)/n);
   t := (ave1-ave2)/sd;
   prob := betai(0.5*df,0.5,df/(df+sqr(t)))
END;
