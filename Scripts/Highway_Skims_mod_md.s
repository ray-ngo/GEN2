
;///////////////////////////////////////////////////////////;
;  Highway_Skims_Mod_md.S                                 //;
;  MWCOG Version 2.3 Model                                //;
;                                                         //;
;  Build AM Peak/Midday   Highway Skims                   //;
;  the Current Iteration Assignment                       //;
;  AM and Midday Skims are built in 2 separate HWYLOAD    //;
;  programs.                                              //;
;  Three files are created, per SOV, HOV2, and HOV3 paths.//;
;  Each file will contain 3 Tables (in Voyager fmt, 2 dec.//;
;          1) Time     (whole minutes)                    //;
;          2) Distance (implied tenths of mi.)            //;
;          3) Toll     (in 2007 cents)                    //;
;
; 6/30/03 MODIFICATIONS FOR IMPROVED TOLL MODELING MADE  rjm
; 2/14/08 generalized toll skimming changed to mode specific  skimming
;         (See  HIGHWAY_SKIMS.S change made on 1/31/08)
; 6/25/10 max zones increased to 7000 per V2.3
; 4/16/11 max zones increased to 7999
; 4/16/11 'PRD=' corrected for period 1 (Set to 'AM' instead of 'MD')
;
; 02/22/13  Added 'timepen' (now a link attribute in the highway net) to the impedance calculation
; 02/22/13  Added 'timepen' (now a link attribute in the highway net) to both impedance * time skim calculation
;///////////////////////////////////////////////////////////;
;
;
;   Environment Variables:
;     _iter_  (Iteration indicator = 'pp','i1'-'i4')
;
;
pageheight=32767  ; Preclude header breaks
NETIN    = '%_iter_%_hwymod.net'

;**************************************************************************
;*** Midday "loop"
;**************************************************************************

LOOP Period=2,2         ;  We are looping through the skimming process
                        ;  twice: (1) for the AM Peak & (2) the Off-Peak

 in_tmin = '..\support\toll_minutes.txt'          ; read in toll minutes equiv file
 in_AMTfac   = 'inputs\AM_Tfac.dbf'                             ;;  AM Toll Factors by Veh. Type
 in_MDTfac   = 'inputs\MD_Tfac.dbf'                             ;;  MD Toll Factors by Veh. Type


  IF (Period=1)          ; AM Highway Skim tokens
    PRD     = 'AM'
    MATOUT1 = '%_iter_%_am_sov_mod.skm'
    MATOUT2 = '%_iter_%_am_hov2_mod.skm'
    MATOUT3 = '%_iter_%_am_hov3_mod.skm'
    MYID    = '%_iter_% AM skims'
  ELSE                  ; MD Highway Skim tokens
    PRD     = 'MD'
    MATOUT1 = '%_iter_%_md_sov_mod.skm'
    MATOUT2 = '%_iter_%_md_hov2_mod.skm'
    MATOUT3 = '%_iter_%_md_hov3_mod.skm'
    MYID    = '%_iter_% MD skims'
  ENDIF

RUN PGM=HIGHWAY
zones=7999
;
;
  NETI   =@NETIN@                          ; Pk Prd TP+ network
  MATO[1]=@MATOUT1@, MO=1-3;;, LOV   skims
  MATO[2]=@MATOUT2@, MO=4-6;;, HOV2  skims
  MATO[3]=@MATOUT3@, MO=7-9;;, HOV3+ skims
  ID=@MYID@
;-
  READ FILE = @in_tmin@

  FileI  LOOKUPI[1] =         "@in_AMtfac@"
  LOOKUP LOOKUPI=1,           NAME=AM_Tfac,
        LOOKUP[1]= TOLLGrp, result=AMSOVTFTR,    ;
        LOOKUP[2]= TOLLGrp, result=AMHV2TFTR,    ;
        LOOKUP[3]= TOLLGrp, result=AMHV3TFTR,    ;
        LOOKUP[4]= TOLLGrp, result=AMTRKTFTR,    ;
        LOOKUP[5]= TOLLGrp, result=AMAPXTFTR,    ;
        INTERPOLATE=N, FAIL= 0,0,0, LIST=N


  FileI  LOOKUPI[2] =         "@in_MDtfac@"
  LOOKUP LOOKUPI=2,           NAME=MD_Tfac,
        LOOKUP[1]= TOLLGrp, result=MDSOVTFTR,    ;
        LOOKUP[2]= TOLLGrp, result=MDHV2TFTR,    ;
        LOOKUP[3]= TOLLGrp, result=MDHV3TFTR,    ;
        LOOKUP[4]= TOLLGrp, result=MDTRKTFTR,    ;
        LOOKUP[5]= TOLLGrp, result=MDAPXTFTR,    ;
        INTERPOLATE=N, FAIL= 0,0,0, LIST=N
;-

;-

  PHASE=LINKREAD
       SPEED        =  LI.%_iter_%@PRD@SPD ;Restrained speed (min)
       IF (SPEED = 0)
          T1 = 0
       ELSE
          T1 = (LI.DISTANCE / SPEED * 60.0) + LI.timepen
       ENDIF
;-
   ; Define AM /MD link level tolls by vehicle type here:
       LW.SOV@PRD@TOLL = LI.@PRD@TOLL * @PRD@_TFAC(1,LI.TOLLGRP)           ;  SOV       TOLLS in 2007 cents
       LW.HV2@PRD@TOLL = LI.@PRD@TOLL * @PRD@_TFAC(2,LI.TOLLGRP)           ;  HOV 2 occ TOLLS in 2007 cents
       LW.HV3@PRD@TOLL = LI.@PRD@TOLL * @PRD@_TFAC(3,LI.TOLLGRP)           ;  HOV 3+occ TOLLS in 2007 cents
       LW.TRK@PRD@TOLL = LI.@PRD@TOLL * @PRD@_TFAC(4,LI.TOLLGRP)           ;  Truck     TOLLS in 2007 cents
       LW.APX@PRD@TOLL = LI.@PRD@TOLL * @PRD@_TFAC(5,LI.TOLLGRP)           ;  AP Pax    TOLLS in 2007 cents

   ; Define AM /MD IMPEDANCE by vehicle type here:
      LW.SOV@PRD@IMP= T1 + ((LW.SOV@PRD@TOLL/100.0)*   SV@PRD@EQM);SOV   IMP
      LW.HV2@PRD@IMP= T1 + ((LW.HV2@PRD@TOLL/100.0)*   H2@PRD@EQM);HOV 2 IMP
      LW.HV3@PRD@IMP= T1 + ((LW.HV3@PRD@TOLL/100.0)*   H3@PRD@EQM);HOV 3+IMP
      LW.TRK@PRD@IMP= T1 + ((LW.TRK@PRD@TOLL/100.0)*   TK@PRD@EQM);Truck IMP
      LW.APX@PRD@IMP= T1 + ((LW.APX@PRD@TOLL/100.0)*   AP@PRD@EQM);APAX  IMP

;
;  Define the three path types here:
;
;
; limit codes used:
;  1=no prohibitions
;  2=prohibit  1/occ autos,trucks
;  3=prohibit  1&2occ autos,trucks
;  4=prohibit  trucks
;  5=prohibit non-airport access trips
;  6-8=unused
;  9=prohibit all traffic use

    IF (LI.@PRD@LIMIT = 2,3,5-9) ADDTOGROUP=1 ; SOV   prohibited links
    IF (LI.@PRD@LIMIT = 3,5-9)   ADDTOGROUP=2 ; HOV2  prohibited links
    IF (LI.@PRD@LIMIT = 5-9)     ADDTOGROUP=3 ; HOV3+ prohibited links
;
  ENDPHASE
;
; Now do the path skimming, per the three path types.  Time, distance,
; and Toll skims created.  Scaling to the desired specified below.
; All skims are based on minimum time paths.
;
; Note that override values of 0 will be inserted for disconnected ijs
; (i.e. cells associated with 'unused' zones and intrazonal cells).
; I don't like the TP+ default value of 1,000,000 for these situations
;
  PHASE=ILOOP

    PATHLOAD PATH=LW.SOV@PRD@IMP, EXCLUDEGRP=1,    ; SOV   paths
             MW[1]=PATHTRACE(TIME),    NOACCESS=0, ; -excluding links
             MW[2]=PATHTRACE(DIST),    NOACCESS=0, ;   w/ LIMIT=2,3,5-9
             MW[3]=PATHTRACE(LW.SOV@PRD@TOLL),    NOACCESS=0 ;
    PATHLOAD PATH=LW.HV2@PRD@IMP, EXCLUDEGRP=2,    ; HOV2  paths
             MW[4]=PATHTRACE(TIME),    NOACCESS=0, ; -excluding links
             MW[5]=PATHTRACE(DIST),    NOACCESS=0, ;   w/ LIMIT=3,5-9
             MW[6]=PATHTRACE(LW.HV2@PRD@TOLL),    NOACCESS=0 ;
    PATHLOAD PATH=LW.HV3@PRD@IMP, EXCLUDEGRP=3,    ; HOV3+ paths
             MW[7]=PATHTRACE(TIME),    NOACCESS=0, ; -excluding links
             MW[8]=PATHTRACE(DIST),    NOACCESS=0, ;   w/ LIMIT=5-9
             MW[9]=PATHTRACE(LW.HV3@PRD@TOLL),    NOACCESS=0 ;

;----------------------------------------------------------------------
; scaling, rounding of skim tables done here!!
;----------------------------------------------------------------------

     mw[1] = ROUND(MW[1])                      ; ROUND TIME SKIMS
     mw[4] = ROUND(MW[4])                      ; TO WHOLE MINUTES
     mw[7] = ROUND(MW[7])                      ;
     mw[1] = MIN(MW[1],326.0)  ; Impose Max TIME
     mw[4] = MIN(MW[4],326.0)  ; Impose Max TIME
     mw[7] = MIN(MW[7],326.0)  ; Impose Max TIME
                               ;  ...just in case
     mw[2] = ROUND(MW[2]*10)                   ; FACTOR/ROUND DIST.
     mw[5] = ROUND(MW[5]*10)                   ; SKIMS TO IMPLICIT
     mw[8] = ROUND(MW[8]*10)                   ; 1/10THS OF MILES

     mw[3] = ROUND(MW[3])                      ; ROUND TOLL
     mw[6] = ROUND(MW[6])                      ; SKIMS TO 2007
     mw[9] = ROUND(MW[9])                      ; WHOLE CENTS

;----------------------------------------------------------------------
; Print selected rows of skim files
; for checking.
;----------------------------------------------------------------------


     IF (i = 1-2)                        ;  for select rows (Is)
         printrow MW=1-3, j=1-7999       ;  print work matrices 1-3
     ENDIF                               ;  row value to all Js.
  ENDPHASE
ENDRUN
ENDLOOP

