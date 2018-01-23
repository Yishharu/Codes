                  NUMERICAL RECIPES BASIC DISKETTE
                  --------- ------- ----- --------
              The entire contents of this diskette are
        Copyright (C) 1986,1991 by Numerical Recipes Software
                 P.O. Box 243, Cambridge, MA  02238
          Unauthorized reproduction is strictly prohibited.

Please read this document completely before attempting to use the 
NUMERICAL RECIPES BASIC DISKETTE.  Your use of any programs on this 
diskette constitutes acceptance of the terms of the DISCLAIMER OF 
WARRANTY, which is given in full at the end of this file. 

WHAT IS THIS DISKETTE?
     This diskette contains machine-readable translations into the 
BASIC language of all the procedures in the book "Numerical Recipes: 
The Art of Scientific Computing" as well as BASIC translations of the 
example programs in the book "Numerical Recipes: Example Book" 
published by Cambridge University Press.  Thus, to use this diskette, 
you will also need a version of the book "Numerical Recipes: The Art 
of Scientific Computing."  Details on how to order this book and other 
items are given at the end of this document. 

WHAT USE OF THIS DISKETTE IS AUTHORIZED?
     For each copy of the diskette purchased, you are entitled to use 
the procedures on exactly one IBM-compatible personal computer running 
MS-DOS or PC-DOS.  You may make as many copies of the programs as you 
wish for backup purposes.  However, it is a copyright violation to 
transfer the procedures to any other type of computer or operating 
system, or to more than one IBM-compatible computer at a time.  Such 
unlicensed transfers are strictly prohibited.  Licenses for authorized 
transfer to other computers are available from Numerical Recipes 
Software, P.O. Box 243, Cambridge, MA  02238, with license fees 
depending on type of computer. 

WHAT PROCEDURES ARE ON THIS DISKETTE?
     There are 205 BASIC procedures, all concatenated into a single 
"ZIP" file 
     -- RECIPES.ZIP
In addition there are 189 BASIC example programs on this diskette, 
concatenated into a single ZIP file 
     -- DEMOS.ZIP
The example programs make use of 10 data files, which are concatenated 
into the ZIP file 
     -- DATA.ZIP
Each procedure also has an associated "Make" file that tells the 
compiler which procedures need to be linked together to run the  
corresponding example program.  There are 191 of these concatenated 
into the ZIP file 
     -- MAK.ZIP
(See below for how to unpack these four files.)  The following 
supplementary files are also included on this diskette: 
     -- README.DOC this file
     -- README.EXE a utility for reading the README.DOC file
     -- PKUNZIP.EXE utility for unpacking the "ZIP" files

WHAT VERSION OF BASIC IS USED?
     The programs on this diskette are written to run without 
modification under Microsoft Corp.'s QuickBASIC 4.5 or later versions, 
and (with minor modifications) under Borland International's Turbo 
BASIC and its compatible successors.  The programs will not run under 
older, or more elementary, implementations of the BASIC language such 
as the BASIC interpreter that is supplied with IBM's PC-DOS, nor under 
Microsoft Corp.'s GW-BASIC (often supplied with PC clones.)  The 
programs were translated from the FORTRAN version whose notation and 
style are followed rather closely. 

HOW DO YOU ACCESS THE PROGRAMS?
     Before proceeding, we recommend that you make a backup copy of 
this diskette.  You should then create a directory to receive the 
programs and data files, using a DOS command like 
     > MKDIR C:\NRBAS (or some other choice of directory names).  
Next, run the PKUNZIP program by the DOS command 
     > A:PKUNZIP A:*.ZIP C:\NRBAS\
You will see a succession of messages reporting each file that is 
unpacked.  
     If you want only to list the names of the files contained in a 
ZIP file, not to unpack them, you do this with a trailing -V switch, 
for example, 
     > A:PKUNZIP A:DEMOS.ZIP -V 
     If you are using the QuickBASIC compiler, you can change to the 
directory into which the programs were unpacked and run one of the 
example programs such as FLMOON with the commands
     > CHDIR \NRBAS
     > QB /RUN FLMOON

WHAT DO YOU DO IF YOU NEED HELP?
     If you believe that this diskette is defective in manufacture, 
return it to the place of purchase for replacement, or contact 
Cambridge University Press at the address given below. 
     For technical questions or assistance, write to Numerical Recipes 
Software, P.O. Box 243, Cambridge, MA  02238.  Please note, however, 
that the programs on this diskette are sold "as is" (see DISCLAIMER OF 
WARRANTY below).  The authors of NUMERICAL RECIPES are interested in 
receiving reports of bugs, but they cannot guarantee to correct them 
on any fixed schedule.  User satisfaction is important to authors and 
publisher, however, so you should not hesitate to make your comments 
or problems known. 

RELATED PRODUCTS AND HOW TO ORDER THEM:

Published by Cambridge University Press:

     "Numerical Recipes: The Art of Scientific Computing" (FORTRAN)
     "Numerical Recipes in C: The Art of Scientific Computing"
     "Numerical Recipes in Pascal: The Art of Scientific Computing"
         by William H. Press, Brian P. Flannery, Saul A. Teukolsky,
         and William T. Vetterling
          (text and reference books containing all explanations
          of the Recipes in one of three computer languages.)

     "Numerical Recipes BASIC Diskette"
     "Numerical Recipes FORTRAN Diskette"
     "Numerical Recipes C Diskette"
     "Numerical Recipes Pascal Diskette V2.0"
          (contains the Numerical Recipes procedures as printed in the
          above books; available for IBM PC compatibles and for the
          Apple Macintosh -- please specify)

     "Numerical Recipes Routines and Examples in BASIC"
         by Julien C. Sprott
     "Numerical Recipes Example Book (FORTRAN)"
     "Numerical Recipes Example Book (C)"
     "Numerical Recipes Example Book (Pascal), Revised"
         by William T. Vetterling, Saul A. Teukolsky, William H.
         Press, and Brian P. Flannery
          (sample program listings in one of three languages,
          demonstrating the use of each Numerical Recipes procedure)

     "Numerical Recipes Example Diskette (Pascal) V2.0"
     "Numerical Recipes Example Diskette (FORTRAN)"
     "Numerical Recipes Example Diskette (C)"
          (contains the sample programs as printed in the above
          Example Books; available for IBM PC compatibles and for
          the Apple Macintosh -- please specify)

To order the above items, write or call Cambridge University Press, 
110 Midland Avenue, Port Chester, New York 10573, Tel. (800) 872-7423 
(outside of Canada and New York), (914) 937-9600 (in Canada and New 
York); or contact your local bookstore.  Outside of North America, 
write to Cambridge University Press, Edinburgh Building, Shaftesbury 
Road, Cambridge CB2 2RU, U.K. 

                       DISCLAIMER OF WARRANTY

THE PROGRAMS ON THIS DISKETTE ARE PROVIDED "AS IS" WITHOUT WARRANTY OF 
ANY KIND.  WE MAKE NO WARRANTIES, EXPRESS OR IMPLIED, THAT THE 
PROGRAMS ARE FREE OF ERROR, OR ARE CONSISTENT WITH ANY PARTICULAR 
STANDARD OF MERCHANTABILITY, OR THAT THEY WILL MEET YOUR REQUIREMENTS 
FOR ANY PARTICULAR APPLICATION.  THEY SHOULD NOT BE RELIED ON FOR 
SOLVING A PROBLEM WHOSE INCORRECT SOLUTION COULD RESULT IN INJURY TO A 
PERSON OR LOSS OF PROPERTY.  IF YOU DO USE THE PROGRAMS OR PROCEDURES 
IN SUCH A MANNER, IT IS AT YOUR OWN RISK.  THE AUTHORS OF THIS 
DISKETTE OR OTHER NUMERICAL RECIPES BOOKS OR DISKETTES, THE PUBLISHER, 
AND NUMERICAL RECIPES SOFTWARE DISCLAIM LIABILITY FOR DIRECT, 
INCIDENTAL, OR CONSEQUENTIAL DAMAGES RESULTING FROM YOUR USE OF THE 
PROGRAMS, SUBROUTINES, OR PROCEDURES IN THIS DISKETTE OR IN ANY 
VERSION OF "NUMERICAL RECIPES: THE ART OF SCIENTIFIC COMPUTING". 

