;///////////////////////////////////////////////////////////;
;  Highway_Skims.S                                        //;
;  MWCOG Version 2.3 Model                                //;
;                                                         //;
;  Build AM Peak/Off-Peak Highway Skims                   //;
;  the Current Iteration Asssignment                      //;
;  AM and Off-Pk Skims are built in 2 separate HWYLOAD    //;
;  programs.                                              //;
;  Three files are created, per SOV, HOV2, and HOV3 paths.//;
;                                                         //;
;          1) Time     (xx.xx minutes)                    //;
;          2) Distance (implied tenths of mi., xx.xx)     //;
;          3) Toll     (in 2007 cents, xx.xx)             //;
;
; 6/30/03 MODIFICATIONS FOR IMPROVED TOLL MODELING MADE  rjm
;
; 1/25/08 Changes made to create special changes to mode choice skims
; 1/31/08 generalized toll used in pathtracing changed to be mode-specific
;         e.g.       MW[3] =PATHTRACE(LI.@PRD@TOLL),       NOACCESS=0,
; ..was changed to>  MW[3] =PATHTRACE(LW.SOV@PRD@TOLL),    NOACCESS=0,
;
;                    MW[6] =PATHTRACE(LI.@PRD@TOLL),       NOACCESS=0, ;
; ..was changed to>  MW[6] =PATHTRACE(LW.HV2@PRD@TOLL),    NOACCESS=0, ;
;
;                    MW[9] =PATHTRACE(LI.@PRD@TOLL),       NOACCESS=0, ;
; ..was changed to>  MW[9] =PATHTRACE(LW.HV3@PRD@TOLL),    NOACCESS=0, ;
;
;  4/25/08  Modifications for Truck model wga/rm
;           Note Time is not rounded (to whole mintes) any more
; 02/22/13  Added 'timepen' (now a link attribute in the highway net) to the impedance calculation
; 02/22/13  Added 'timepen' (now a link attribute in the highway net) to both impedance * time skim calculation
;
;///////////////////////////////////////////////////////////;
;
;
;   Environment Variables:
;     _iter_  (Iteration indicator = 'pp','i1'-'i4')
;
;
pageheight=32767  ; Preclude header breaks
NETIN    = '%_iter_%_hwy.net'


; Output special truck skim only for off-peak conditions

LOOP Period=1,1         ;  We are looping through the skimming process
                        ;  twice: (1) for the AM Peak & (2) the Midday


 in_tmin = '..\support\toll_minutes.txt'                        ;; read in toll minutes equiv file
 in_AMTfac   = 'inputs\AM_Tfac.dbf'                             ;;  AM Toll Factors by Veh. Type
 in_MDTfac   = 'inputs\MD_Tfac.dbf'                             ;;  MD Toll Factors by Veh. Type

  IF (Period=1)          ; AM Highway Skim tokens
    PRD       = 'AM'
    MATOUT1   = '%_iter_%_am_sov.skm '
    MATOUT2   = '%_iter_%_am_hov2.skm'
    MATOUT3   = '%_iter_%_am_hov3.skm'

    MATOUTMC1 = '%_iter_%_am_sov_MC.skm '
    MATOUTMC2 = '%_iter_%_am_hov2_MC.skm'
    MATOUTMC3 = '%_iter_%_am_hov3_MC.skm'

    MYID      = '%_iter_% AM skims'

    TT        = ';'
    MATOUT4   = ' '
    SKMTOT    = ' '

  ELSEIF (Period=2)     ; MD Highway Skim tokens
    PRD       = 'MD'
    MATOUT1   = '%_iter_%_md_sov.skm '
    MATOUT2   = '%_iter_%_md_hov2.skm'
    MATOUT3   = '%_iter_%_md_hov3.skm'

    MATOUTMC1 = '%_iter_%_md_sov_MC.skm '
    MATOUTMC2 = '%_iter_%_md_hov2_MC.skm'
    MATOUTMC3 = '%_iter_%_md_hov3_MC.skm'

    TT        = ' '
    MATOUT4   = '%_iter_%_md_truck.skm'
    SKMTOT    = '%_iter_%_skimtot.txt'

    MYID    = '%_iter_% MD skims'
  ENDIF


RUN PGM=HIGHWAY
;
;
  NETI   =@NETIN@                          ; Pk Prd TP+ network
  MATO[1]=@MATOUT1@, MO=1,2,3,13  ; LOV   skims: time, dist, total tolls, VP tolls (default output precision is 2 decimal places)
  MATO[2]=@MATOUT2@, MO=4,5,6,16  ; HOV2  skims: time, dist, total tolls, VP tolls
  MATO[3]=@MATOUT3@, MO=7,8,9,19  ; HOV3+ skims: time, dist, total tolls, VP tolls
  @TT@ MATO[4]=@MATOUT4@, MO=10   ; Truck skims

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

  PHASE=LINKREAD
       SPEED        =  LI.%_iter_%@PRD@SPD ;Restrained speed (min)
       IF (SPEED = 0)
          T1 = 0
       ELSE
          T1 = (LI.DISTANCE / SPEED * 60.0) + LI.TIMEPEN
       ENDIF
;-
   ; Define AM /MD link level TOTAL tolls by vehicle type here:
       LW.SOV@PRD@TOLL    = LI.@PRD@TOLL    * @PRD@_TFAC(1,LI.TOLLGRP)           ;  SOV       TOTAL TOLLS in 2007 cents
       LW.HV2@PRD@TOLL    = LI.@PRD@TOLL    * @PRD@_TFAC(2,LI.TOLLGRP)           ;  HOV 2 occ TOTAL TOLLS in 2007 cents
       LW.HV3@PRD@TOLL    = LI.@PRD@TOLL    * @PRD@_TFAC(3,LI.TOLLGRP)           ;  HOV 3+occ TOTAL TOLLS in 2007 cents
       LW.TRK@PRD@TOLL    = LI.@PRD@TOLL    * @PRD@_TFAC(4,LI.TOLLGRP)           ;  Truck     TOTAL TOLLS in 2007 cents
       LW.APX@PRD@TOLL    = LI.@PRD@TOLL    * @PRD@_TFAC(5,LI.TOLLGRP)           ;  AP Pax    TOTAL TOLLS in 2007 cents

       LW.SOV@PRD@TOLL_VP = LI.@PRD@TOLL_VP * @PRD@_TFAC(1,LI.TOLLGRP)           ;  SOV       VarPr TOLLS in 2007 cents
       LW.HV2@PRD@TOLL_VP = LI.@PRD@TOLL_VP * @PRD@_TFAC(2,LI.TOLLGRP)           ;  HOV 2 occ VarPr TOLLS in 2007 cents
       LW.HV3@PRD@TOLL_VP = LI.@PRD@TOLL_VP * @PRD@_TFAC(3,LI.TOLLGRP)           ;  HOV 3+occ VarPr TOLLS in 2007 cents
       LW.TRK@PRD@TOLL_VP = LI.@PRD@TOLL_VP * @PRD@_TFAC(4,LI.TOLLGRP)           ;  Truck     VarPr TOLLS in 2007 cents
       LW.APX@PRD@TOLL_VP = LI.@PRD@TOLL_VP * @PRD@_TFAC(5,LI.TOLLGRP)           ;  AP Pax    VarPr TOLLS in 2007 cents

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
    IF (LI.@PRD@LIMIT = 4)       ADDTOGROUP=4 ; Truck prohibited links

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
; 1/25/08 added skim tabs created:
;        (t13,t16,t19) tolls on variably priced facilities only

  PHASE=ILOOP



     PATHLOAD PATH=LW.SOV@PRD@IMP, EXCLUDEGRP=1,                ; SOV   paths
              MW[1] =PATHTRACE(TIME),               NOACCESS=0, ; -excluding links
              MW[2] =PATHTRACE(DIST),               NOACCESS=0, ; w/LIMIT=2,3,5-9
              MW[3] =PATHTRACE(LW.SOV@PRD@TOLL),    NOACCESS=0, ;
              MW[13]=PATHTRACE(LW.SOV@PRD@TOLL_VP), NOACCESS=0 ;

     PATHLOAD PATH=LW.HV2@PRD@IMP, EXCLUDEGRP=2,                ; HOV2  paths
              MW[4] =PATHTRACE(TIME),               NOACCESS=0, ; -excluding links
              MW[5] =PATHTRACE(DIST),               NOACCESS=0, ; w/LIMIT=3,5-9
              MW[6] =PATHTRACE(LW.HV2@PRD@TOLL),    NOACCESS=0, ;
              MW[16]=PATHTRACE(LW.HV2@PRD@TOLL_VP), NOACCESS=0  ;

     PATHLOAD PATH=LW.HV3@PRD@IMP, EXCLUDEGRP=3,                ; HOV3+ paths
              MW[7] =PATHTRACE(TIME),               NOACCESS=0, ; -excluding links
              MW[8] =PATHTRACE(DIST),               NOACCESS=0, ; w/LIMIT=5-9
              MW[9] =PATHTRACE(LW.HV3@PRD@TOLL),    NOACCESS=0, ;
              MW[19]=PATHTRACE(LW.HV3@PRD@TOLL_VP), NOACCESS=0  ;

  @TT@ PATHLOAD PATH=LW.TRK@PRD@IMP, EXCLUDEGRP=1,4,            ; Truck paths
  @TT@          MW[10]=PATHTRACE(TIME),   NOACCESS=0


;----------------------------------------------------------------------
; scaling, rounding of skim tables done here!!
;----------------------------------------------------------------------

     mw[2] = ROUND(MW[2]*10)                   ; FACTOR/ROUND DIST.
     mw[5] = ROUND(MW[5]*10)                   ; SKIMS TO IMPLICIT
     mw[8] = ROUND(MW[8]*10)                   ; 1/10THS OF MILES

     mw[3] = ROUND(MW[3])                      ; ROUND Total TOLL
     mw[6] = ROUND(MW[6])                      ; SKIMS TO 2007
     mw[9] = ROUND(MW[9])                      ; WHOLE CENTS

     mw[13] = ROUND(MW[13])                    ; ROUND Variable priced TOLL
     mw[16] = ROUND(MW[16])                    ; SKIMS TO 2007
     mw[19] = ROUND(MW[19])                    ; WHOLE CENTS

;;
;----------------------------------------------------------------------
; Print selected rows of skim files
; for checking.
;----------------------------------------------------------------------


     IF (i = 1-2)                        ;  for select rows (Is)
         printrow MW=1-3, j=1-3722       ;  print work matrices 1-3
     ENDIF                               ;  row value to all Js.
  ENDPHASE
ENDRUN

;----------------------------------------------------------------------
; Finally create special Mode Choice skims here
; The mode choice skims will be the same as the above skims unless VP toll lanes
;  are used; in that case time will include the VP toll time equivalent
;  and the toll value will be the toll on non-VP toll lanes ONLY
;
; Also create zonal truck access file per the @TT@ statements for the OP per. only
;----------------------------------------------------------------------

RUN PGM=MATRIX

     READ FILE = @in_tmin@     ; read toll time eqv param file
                                                       ; -- INPUT SKIMS --
      MATI[1] = @MATOUT1@                                ; SOV  skims (tm,dst,total toll, VP toll)
      MATI[2] = @MATOUT2@                                ; HOV2 skims (tm,dst,total toll, VP toll)
      MATI[3] = @MATOUT3@                                ; HOV3+skims (tm,dst,total toll, VP toll)

 @TT@ MATI[4] = @MATOUT4@                                ; read in trk skim (op per only)
 @TT@  MW[99] = MI.4.1
 ; For the skim total, put a large value in unconnected O/D pairs
 @TT@  JLOOP
 @TT@     IF (MW[99] = 0) MW[99] = 100000
 @TT@  ENDJLOOP
 @TT@  REPORT MARGINREC = Y, FILE = @SKMTOT@, FORM=15, LIST=J(5),R99,C99

                                                       ; -- OUTPUT SKIMS --
    MATO[1] = @MATOUTMC1@,MO=101,12,103  ; SOV  skims (tm&toll tm eqv,dst,non-VP toll component)
    MATO[2] = @MATOUTMC2@,MO=201,22,203  ; HOV2 skims (tm&toll tm eqv,dst,non-VP toll component)
    MATO[3] = @MATOUTMC3@,MO=301,32,303  ; HOV3+skims (tm&toll tm eqv,dst,non-VP toll component)


 ;; read in input skims from above
    MW[11] = MI.1.1  ; SOV   time
    MW[12] = MI.1.2  ; SOV   distance
    MW[13] = MI.1.3  ; SOV   total toll
    MW[14] = MI.1.4  ; SOV   Var.priced toll component (if VP toll facility used)

    MW[21] = MI.2.1  ; HOV2  time
    MW[22] = MI.2.2  ; HOV2  distance
    MW[23] = MI.2.3  ; HOV2  total toll
    MW[24] = MI.2.4  ; HOV2  Var.priced toll component (if VP toll facility used)

    MW[31] = MI.3.1  ; HOV3+ time
    MW[32] = MI.3.2  ; HOV3+ distance
    MW[33] = MI.3.3  ; HOV3+ total toll
    MW[34] = MI.3.4  ; HOV3+ Var.priced toll component (if VP toll facility used)

 ;; now compute special time and toll values to be used in the mode choice process
 ;; which are normally 1/time, 2/distance, and 3/tolls; the new skims will be:
 ;; 1/ time + the toll time_equivalent on VP facilities only
 ;; 2/ distance (as before)
 ;; 3/ tolls on non-VP tolled facilities ONLY

 ;Mode Choice model Hwy time:
      MW[101] = MW[11] + ((MW[14]/100.0) * SV@PRD@EQM);
      MW[201] = MW[21] + ((MW[24]/100.0) * H2@PRD@EQM);
      MW[301] = MW[31] + ((MW[34]/100.0) * H3@PRD@EQM);

 ;Mode Choice model Hwy TOLL:
      MW[103] = MW[13] - MW[14]
      MW[203] = MW[23] - MW[24]
      MW[303] = MW[33] - MW[34]

      MW[103] = MAX(0,MW[103])
      MW[203] = MAX(0,MW[203])
      MW[303] = MAX(0,MW[303])
 ENDRUN

;*ping -n 11 127.0.0.1 > nul

; end of truck access section
ENDLOOP
