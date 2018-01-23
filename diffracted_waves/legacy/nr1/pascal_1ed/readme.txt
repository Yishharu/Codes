               NUMERICAL RECIPES PASCAL DISKETTE V1.9
               --------- ------- ------ -------- ----
              The entire contents of this diskette are
       Copyright (C) 1986,1989 by Numerical Recipes Software
                 P.O. Box 243, Cambridge, MA  02238
         Unauthorized reproduction is strictly prohibited.

Please read this document completely before attempting to use the
NUMERICAL RECIPES PASCAL DISKETTE.  Your use of any programs on this
diskette constitutes acceptance of the terms of the DISCLAIMER OF
WARRANTY, which is given in full at the end of this document.

WHAT IS THIS DISKETTE?
     This diskette contains machine-readable PASCAL procedures from
the book "Numerical Recipes in Pascal: The Art of Scientific
Computing" published by Cambridge University Press (1989).  If you do
not have the book, this diskette will not be very useful to you, since
the procedure versions on this diskette do not repeat the book's
explanations or line-by-line program comments.  Details on how to
order the book and other items are given at the end of this document.
     This diskette is NOT compatible with the PASCAL translations that
were listed in an Appendix of earlier printings of the FORTRAN version
of "Numerical Recipes: The Art of Scientific Computing" (Cambridge
University Press, 1986).  Those translations were superseded by
publication of "Numerical Recipes in Pascal: The Art of Scientific
Computing", and they are no longer supported.

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
     All 195 procedures listed in "Numerical Recipes in Pascal: The
Art of Scientific Computing" are included as PASCAL source code on
this diskette.  They are concatenated into a single "omnibus" file
RECIPES.OMB. (See below for how to list their names or unpack them.) 
Also included are 4 data files used by certain procedures, a file
MODFILE.PAS (see below), and the utility UNPACK.EXE.

WHAT VERSION OF PASCAL IS USED?
     The procedures on this diskette have been validated to work with
several different versions of PASCAL.  The recommended implementation
for IBM PC and compatibles is TURBO PASCAL, version 5.5 or later, by
Borland International.  However, the procedures will in general run
with earlier versions of TURBO PASCAL, and (sometimes with minor
modification) on many other Pascal compilers.
     For compatibility with other versions of PASCAL, some procedures
on this diskette assume that the TYPEs double, longint, and string10,
and the PROCEDURE NROpen(infile, filename) have been globally defined
in any program that you write.  The file MODFILE.PAS contains
definitions of these objects for TURBO PASCAL.  For further details,
consult Section 1.2 of the book "Numerical Recipes in Pascal: The Art
of Scientific Computing".

HOW DO YOU ACCESS THE PROGRAMS?
     Before proceeding, we recommend that you make a backup copy of
this diskette.  You should then create a directory to receive the
program files, using a DOS command like
> MKDIR C:\NRPAS
(or some other choice of directory name).  Next, copy the 4 data
files, and MODFILE.PAS, by DOS commands like
> COPY A:*.DAT C:\NRPAS\
> COPY A:MODFILE.PAS C:\NRPAS\
(where this diskette is assumed to be in drive A:).  Finally, run the
UNPACK program by the DOS command
> A:UNPACK A:RECIPES.OMB C:\NRPAS\
You will see a succession of messages reporting each file that is
unpacked.  The omnibus file RECIPES.OMB is an ordinary ascii file;
however, you should NEVER modify it:  if you do, then the UNPACK
program may not be able to function correctly with that file.  UNPACK
will detect and report a modified file as having an invalid checksum.
     If you want only to list the names of the files contained in an
omnibus file, not to unpack it, you do this with a trailing -L switch,
for example,
> A:UNPACK A:RECIPES.OMB -L


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

     "Numerical Recipes in Pascal: The Art of Scientific Computing"
     "Numerical Recipes: The Art of Scientific Computing" (FORTRAN)
     "Numerical Recipes in C: The Art of Scientific Computing"
         by William H. Press, Brian P. Flannery, Saul A. Teukolsky,
         and William T. Vetterling
          (text and reference books containing all explanations
          of the Recipes in one of three computer languages.)

     "Numerical Recipes Pascal Diskette"
     "Numerical Recipes FORTRAN Diskette"
     "Numerical Recipes C Diskette"
          (contains the Numerical Recipes procedures as printed in the
          above books; available for IBM PC compatibles and for the
          Apple Macintosh -- please specify)

     "Numerical Recipes Example Book (Pascal), Revised"
     "Numerical Recipes Example Book (FORTRAN)"
     "Numerical Recipes Example Book (C)"
         by William T. Vetterling, Saul A. Teukolsky, William H.
         Press, and Brian P. Flannery
          (sample program listings in one of three languages,
          demonstrating the use of each Numerical Recipes procedure)

     "Numerical Recipes Example Diskette (Pascal)"
     "Numerical Recipes Example Diskette (FORTRAN)"
     "Numerical Recipes Example Diskette (C)"
          (contains the sample programs as printed in the above
          Example Books; available for IBM PC compatibles and for
          the Apple Macintosh -- please specify)

To order the above items, write or call Cambridge University Press,
510 North Avenue, New Rochelle, New York 10801, Tel. (800) 872-7423
(outside of Canada and New York), (914) 235-0300 (in Canada and New
York); or contact your local bookstore.  Outside of North America,
write to Cambridge University Press, Edinburgh Building, Shaftesbury
Road, Cambridge CB2 2RU, U.K.

                       DISCLAIMER OF WARRANTY
                       ---------- -- --------
     THE PROGRAMS AND PROCEDURES ON THIS DISKETTE ARE PROVIDED "AS IS"
WITHOUT WARRANTY OF ANY KIND.  WE MAKE NO WARRANTIES, EXPRESS OR
IMPLIED, THAT THE PROGRAMS AND PROCEDURES ARE FREE OF ERROR, OR ARE
CONSISTENT WITH ANY PARTICULAR STANDARD OF MERCHANTABILITY, OR THAT
THEY WILL MEET YOUR REQUIREMENTS FOR ANY PARTICULAR APPLICATION.  THEY
SHOULD NOT BE RELIED ON FOR SOLVING A PROBLEM WHOSE INCORRECT SOLUTION
COULD RESULT IN INJURY TO A PERSON OR LOSS OF PROPERTY.  IF YOU DO USE
THE PROGRAMS OR PROCEDURES IN SUCH A MANNER, IT IS AT YOUR OWN RISK. 
THE AUTHORS AND PUBLISHER DISCLAIM ALL LIABILITY FOR DIRECT,
INCIDENTAL, OR CONSEQUENTIAL DAMAGES RESULTING FROM YOUR USE OF THE
PROGRAMS OR PROCEDURES ON THIS DISKETTE.  ANY LIABILITY OF SELLER OR
MANUFACTURER WILL BE LIMITED EXCLUSIVELY TO PRODUCT REPLACEMENT OF
DISKETTES WITH MANUFACTURING DEFECTS.
