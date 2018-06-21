;=================================================================
;  PREFAREV23.S
;   Program to read Zone File Used for MFARE2 Program (without walk pcts)
;       and to merge in walk pct. information
;      (Conversion of FORTRAN program Prefaretp.FOR)
;       Program also prepares the Z-file for the NL Mode Choice model (File 8)
;
;   Programmer: Milone
;   Date:        12/11/10
;
;    The program reads 3 files:
;               - a GIS-based walk area file containing short and
;                 long walk areas to all rail stations
;                 (rail includes metro & commuter rail).  The file also
;                 contains the sht,lng distances to the nearest metrorail
;                 station.  Note: the walk distance is based on 1.0 mile
;                 radius per the V2 models (NOT 7/10 mile per V1 models)
;               - a zone file containing bus fare zone/station equivs and
;                 jurisdiction code information.  This is essentially
;                 an A2 deck without walk percentages
;               - the 'final' zonal walk percentage file written
;                 by the wlklnktp.exe program.  This will suppress
;                 metrorail walk percentages to be consistent with
;                 the walk access links built previously
;    It writes out:
;               - A 'complete' A2 file for the MFARE2.S
;                  process
;    1/31/08 rm / a quality control check section added at the bottom
;    4/10/08 rm / added procedure to prepare the A1 file for the NL Mode choice
;                 application (Note: must use updated Ctl files)

;
ZONESIZE        =  3675                  ;  internal zones
ZNFILE_TrPcts   = 'NLwalkPct.txt' ;  Input Zonal Transit Walk Pcts
Fare_Zone_File  = 'INPUTS\tazfrzn.asc'   ;  from \INPUTS SD
ATYPFILE        = 'AreaType_File.dbf'    ;  Zonal Area Type file    (I/P file)

out_file        = 'fare_a2.asc'

RUN PGM=MATRIX
ZONES=@ZONESIZE@

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Initialize current metrorail walk pct and final pct walk
;;=======================================================
ZDATI[1] = @ZNFILE_TrPcts@ , Z            =  #1,
                             MetroShort   =  #2,
                             MetroLong    =  #3,
                             AMShort      =  #4,
                             AMLong       =  #5,
                             OPShort      =  #6,
                             OPLong       =  #7
                   ;; Convert Metrorail Long walk proportion to 1/10s of pcts (i.e., 1.00 will be 1000.)
                   ;; as expected in the MFARE process

                            Metwkpct     =  Round(zi.1.MetroLong[I]   * 1000.0)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;  Lets double check that the computed metrorail walk pct (in tenths)
;  is within the expected range, if not then abort and write msg.

      if ((metwkpct <  0) || (metwkpct  > 1000.0)) ABORT

;;  print list = I(5),' ', larea(10.7),' ',swrarea(10.7),' ',lwrarea(10.7),' ',
;;                 smetdst(10.3),' ',lmetdst(10.3),
;;                       ' ',metwkpct(6.2)

ZDATI[3] = @Fare_Zone_File@,
           Z        =   4- 8,
           bfz1     =   9-16,
           bfz2     =  17-24,
           rfz1     =  41-48,
           rfz2     =  49-56,
           jur      =  57-64,
           pdsc     =  65-72,
           adsc     =  73-80


;
;  Print Out zonal data
;  -- Only if input bus fare zone 1 is nonzero
;     -this ensures that a consistent record count will be maintained w/ I&O
  IF (zi.3.bfz1 > 0)


       Print list = i(8), zi.3.bfz1(8),zi.3.bfz2(8),
                          metwkpct(8),metwkpct(8),
                          zi.3.rfz1(8),zi.3.rfz2(8),
                          zi.3.JUR(8),zi.3.pdsc(8),zi.3.adsc(8),file=@out_file@

  ENDIF

ENDRUN


;=================================================================
;  Prepare_MC_Zfile.S
;
;
;
;
;   Programmer: Milone
;   Date:       4/08/08
;
;=================================================================
;
;=================================================================
; Set Parameters:
;=================================================================

ZONESIZE    =       3722                  ;  No. of TAZs
LastIZN     =       3675                  ;  Last Internal TAZ no.
PCostRng    =       51                    ;  No. of ranges in the parking cost Model
TTimeRng    =       5                     ;  No. of ranges in the terminal time Model


Rept         = 'Prepare_MC_Zfile.txt'  ; Summary Reports
OFilem       = ' ZONEV2.A2F  '         ; Output ZFile for the NL Mode Choice Model


;=================================================================
; Set Input Files:
;=================================================================

ZNFILE_LU      = 'inputs\zone.dbf'          ;  Input Zonal Land Use File
ZNFILE_MCMrkts = 'inputs\areadef3722.prn'   ;  Input Zonal TAZ-Mode choice district equiv.

;==================================================================
;/////////////////////////////////////////////////////////////////=
;==================================================================
;          Begin TP+ Matrix Routine :                             =
;==================================================================
;\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\=
;==================================================================

RUN PGM=MATRIX
ZONES=@ZONESIZE@
ARRAY MetroShortA=101,   ;; Arrays for counting TAZs in pct walk bins of 0-100
      MetroLongA=101,
      AMShortA=101,
      AMLongA=101,
      OPShortA=101,
      OPLongA=101,

      MetroShortj=24,    ;; Arrays for counting TAZs in juris bins
      MetroLongj=24,
      AMShortj=24,
      AMLongj=24,
      OPShortj=24,
      OPLongj=24,
      Total_Area=24



;==========================================
; Read Zonal Area Type Lookup file        =
;=========================================
;
;
FileI LOOKUPI[1] ="@atypfile@"
LOOKUP LOOKUPI=1, NAME=ZNAT,
       LOOKUP[1] = TAZ, RESULT=AType,   ;
       LOOKUP[2] = TAZ, RESULT=EMPDEN,   ;
       INTERPOLATE=N, FAIL= 0,0,0, LIST=N


;=====================================================================================================
; End of LookUps  Now read the input files                                                           =
;=====================================================================================================

;; First initialize all current values to zero:

         HBWParkCost = 0
         HBSParkCost = 0
         HBOParkCost = 0
         NHBParkCost = 0
         HB_TermTime = 0
         NHB_TermTime= 0
         MetroShort  = 0
         MetroLong   = 0
         AMShort     = 0
         AMLong      = 0
         OPShort     = 0
         OPLong      = 0
         EMP         = 0
         jur         = 0
         area        = 0
         AMMELONG    = 0

; read Zonal land use files  into Z-File
ZDATI[1] = @ZNFILE_LU@;Z
                      ;EMP         TOTEMP  INDEMP  RETEMP  OFFEMP  OTHEMP  JURCODE LANDAREA
                      ;jur
                      ;Area

      ; Current Zonal Totals:
                             EMP          = zi.1.TOTEMP[I]
                             jur          = zi.1.jurcode[I] + 1 ; convert 0-23 jur codes to 1 to 24 for indexing
                             Area         = zi.1.LandArea[I]
                             IF (Area > 0)
                                 EMPDENSITY = ROUND(EMP/AREA)
                               ELSE
                                 EMPDENSITY = 0
                             ENDIF

      ; Accumulate Regional Totals:
                             TOTEMP       = TOTEMP  +  zi.1.TOTEMP[I]
                             TOTArea      = TOTArea +  zi.1.LandArea[I]


; Zonal MC TAZ -District Equiv. File
ZDATI[2] = @ZNFILE_MCMrkts@, Z            =  #1,
                             MCDistrict   =  #2
                             MCDistrict   =  zi.2.MCDistrict[I]

; Zonal Transit Walk Shares
ZDATI[3] = @ZNFILE_TrPcts@ , Z            =  #1,  ; TAZ
                             MetroShort   =  #2,  ; % of TAZ that is w/in short walk distance (0.5mi) to Metrorail
                             MetroLong    =  #3,  ; % of TAZ that is w/in long  walk distance (1.0mi) to Metrorail
                             AMShort      =  #4,  ; % of TAZ that is w/in short walk distance (0.5mi) to AM Transit
                             AMLong       =  #5,  ; % of TAZ that is w/in long  walk distance (1.0mi) to AM Transit
                             OPShort      =  #6,  ; % of TAZ that is w/in short walk distance (0.5mi) to OP Transit
                             OPLong       =  #7   ; % of TAZ that is w/in long  walk distance (1.0mi) to OP Transit
                   ;; Convert walk shares to percents (i.e., 1.00 will be 100)
                             MetroShort   =  Round(zi.3.MetroShort[I]  * 100.0)
                             MetroLong    =  Round(zi.3.MetroLong[I]   * 100.0)
                             AMShort      =  Round(zi.3.AMShort[I]     * 100.0)
                             AMLong       =  Round(zi.3.AMLong[I]      * 100.0)
                             OPShort      =  Round(zi.3.OPShort[I]     * 100.0)
                             OPLong       =  Round(zi.3.OPLong[I]      * 100.0)

                             AMMELON = 0.0 ; AM Long-mutually exclusive of AM Short area
                             IF (AMSHORT = 100.0 )                                    AMMELONG = 0.0
                             IF (AMSHORT >   0.0 && AMSHORT < 100.0  &&  AMLONG > 0)  AMMELONG = AMLONG - AMShort
                             IF (AMSHORT =   0.0 && AMLONG  >   0.0)                  AMMELONG = AMLONG














 ;; Do some QC checks on the Percent walk data
  IF (MetroShort < 0 || MetroShort > 100)
                List =' MetroShort  value: ', Metroshort,' out of expected range at TAZ:',I
                Abort
  ENDIF
  IF (MetroLong  < 0 || MetroLong  > 100)
                List =' MetroLong   value: ', MetroLong ,' out of expected range at TAZ:',I
                Abort
  ENDIF
  IF (AMShort    < 0 || AMShort    > 100)
                List =' AMShort     value: ', AMShort   ,' out of expected range at TAZ:',I
                Abort
  ENDIF
  IF (AMLong     < 0 || AMLong     > 100)
                List =' AMLong      value: ', AMLong    ,' out of expected range at TAZ:',I
                Abort
  ENDIF
  IF (OPShort    < 0 || OPShort    > 100)
                List =' OPShort     value: ', OPShort   ,' out of expected range at TAZ:',I
                Abort
  ENDIF
  IF (OPLong     < 0 || OPLong     > 100)
                List =' OPLong      value: ', OPLong    ,' out of expected range at TAZ:',I
                Abort
  ENDIF

; Accumulate the count of TAZs in pct walk bins (0 to 100) for reporting
 IF (Area > 0)
  LOOP Idx  = 1, 101  ;; indexs 1-101 refer to  values 0 to 100

       IF (MetroShort = (idx-1)) MetroShortA[idx] = MetroShortA[idx] + 1
       IF (MetroLong  = (idx-1)) MetroLongA[idx]  = MetroLongA[idx]  + 1
       IF (AMShort    = (idx-1)) AMShortA[idx]    = AMShortA[idx]    + 1
       IF (AMLong     = (idx-1)) AMLongA[idx]     = AMLongA[idx]     + 1
       IF (OPShort    = (idx-1)) OPShortA[idx]    = OPShortA[idx]    + 1
       IF (OPLong     = (idx-1)) OPLongA[idx]     = OPLongA[idx]     + 1
  ENDLOOP
       ActiveTAZCnt = ActiveTAZCnt + 1
 ENDIF
; Accumulate the Area of each walk shed for reporting
           MetroShortArea = MetroShortArea + (MetroShort/100.00 * Area)
           MetroLongArea  = MetroLongArea  + (MetroLong /100.00 * Area)
           AMShortArea    = AMShortArea    + (AMShort   /100.00 * Area)
           AMLongArea     = AMLongArea     + (AMLong    /100.00 * Area)
           OPShortArea    = OPShortArea    + (OPShort   /100.00 * Area)
           OPLongArea     = OPLongArea     + (OPLong    /100.00 * Area)


; Accumulate the area of TAZs in juris. bins for reporting
 IF (Area > 0)
  LOOP Idx  = 1, 24   ;; indexs 1-101 refer to  values 0 to 100

       IF (jur =  idx ) MetroShortj[idx] = MetroShortj[idx] + (MetroShort/100.00 * Area)
       IF (jur =  idx ) MetroLongj[idx]  = MetroLongj[idx]  + (MetroLong /100.00 * Area)
       IF (jur =  idx ) AMShortj[idx]    = AMShortj[idx]    + (AMShort   /100.00 * Area)
       IF (jur =  idx ) AMLongj[idx]     = AMLongj[idx]     + (AMLong    /100.00 * Area)
       IF (jur =  idx ) OPShortj[idx]    = OPShortj[idx]    + (OPShort   /100.00 * Area)
       IF (jur =  idx ) OPLongj[idx]     = OPLongj[idx]     + (OPLong    /100.00 * Area)
       IF (jur =  idx ) Total_Area[idx]  = Total_Area[idx]  +  Area
  ENDLOOP
ENDIF

 ;;-----------------------------------------------
 ;; Define hwy terminal times based on Area Type
 ;;-----------------------------------------------

     _AType      = ZNAT(1,I)         ;  Area Type
     _FEmpDen    = ZNAT(2,I)         ;  Floating 1-mi zonal Employment density
     if (_Atype = 1 ) Termtm= 5.0
     if (_Atype = 2 ) Termtm= 4.0
     if (_Atype = 3 ) Termtm= 3.0
     if (_Atype = 4 ) Termtm= 2.0
     if (_Atype = 5 ) Termtm= 1.0
     if (_Atype = 6 ) Termtm= 1.0

     if (I > @LastIZN@)    Termtm = 0.0

     HB_TermTime   =  TermTm
     NHB_TermTime  =  TermTm


 ;;-------------------------------------------------------------------
 ;; Define hwy Parking costs based on Area Type --ALL IN 2007 CENTS
 ;;-------------------------------------------------------------------
     ;; HBW 8-Hour Parking Cost
      IF (_Atype >0 && _Atype <= 3)
            HBWParkCost    = MAX( (217.24  * (Ln(_FEmpDen)) - 1553.3), 0.0 )
         ELSE
            HBWParkCost    = 0.0
      ENDIF

     ;; non-HBW 1-Hour Parking Cost
            IF (_Atype = 1)
                  HrNonWkPkCost =  200.0
               ELSEIF (_Atype = 2)
                  HrNonWkPkCost =  100.0
               ELSEIF (_Atype = 3)
                  HrNonWkPkCost =   25.0
               ELSE
                  HrNonWkPkCost =    0.0
            ENDIF


            HBSParkCost = HrNonWkPkCost        ; Assume 1-Hour parking duration for HBS trips
            HBOParkCost = HrNonWkPkCost * 2.0  ; Assume 2-Hour parking duration for HBO trips
            NHBParkCost = HrNonWkPkCost * 2.0  ; Assume 2-Hour parking duration for NHB trips


;-----------------------------------------------------------------------
;Write out zonal files here  ...
;-----------------------------------------------------------------------

 Print file=@ofilem@, form = 5 List=  I,
                                     HBWParkCost,
                                     HBSParkCost,
                                     HBOParkCost,
                                     NHBParkCost,
                                     HB_TermTime,
                                     NHB_TermTime,
                                     MetroShort,
                                     MetroLong,
                                     AMShort,
                                     AMLong,
                                     OPShort,
                                     OPLong,
                                     MCDistrict


IF (I=@Zonesize@)
     Print form=10.5csv file=@Rept@ list = '    Total Employment:  ', totemp(10.0csv) ,'\n','\n'








;;--------------------------------------------------------------------------------------------------------------
     Print file=@Rept@ list = ' Jurisdictional Summary of Walk Shed Area (sq mi) by Shed Type ','\n','\n',
                              '  Walk_Pct  MetroSh   MetroLg   AMShort   AMLong    OPShort   OPLong     TOTAL  ','\n',
                              ' --------- --------- --------- --------- --------- --------- --------- ---------','\n'
 LOOP Idx   = 1, 24
  IF (Idx=1)
   CURDIST=STR(Idx,2,1)+' DC   '+ '|' ; Make row header
  ELSEIF (Idx=2)
   CURDIST=STR(Idx,2,1)+' MTG  '+ '|' ; Make row header
  ELSEIF (Idx=3)
   CURDIST=STR(Idx,2,1)+' PG   '+ '|' ; Make row header
  ELSEIF (Idx=4)
   CURDIST=STR(Idx,2,1)+' ARL  '+ '|' ; Make row header
  ELSEIF (Idx=5)
   CURDIST=STR(Idx,2,1)+' ALX  '+ '|' ; Make row header
  ELSEIF (Idx=6)
   CURDIST=STR(Idx,2,1)+' FFX  '+ '|' ; Make row header
  ELSEIF (Idx=7)
   CURDIST=STR(Idx,2,1)+' LDN  '+ '|'; Make row header
  ELSEIF (Idx=8)
   CURDIST=STR(Idx,2,1)+' PW   '+ '|' ; Make row header
  ELSEIF (Idx=9)
   CURDIST=STR(Idx,2,1)+' --   '+ '|' ; Make row header
  ELSEIF (Idx=10)
   CURDIST=STR(Idx,2,1)+' FRD  '+ '|' ; Make row header
  ELSEIF (Idx=11)
   CURDIST=STR(Idx,2,1)+' HOW  '+ '|' ; Make row header
  ELSEIF (Idx=12)
   CURDIST=STR(Idx,2,1)+' AAR  '+ '|' ; Make row header
  ELSEIF (Idx=13)
   CURDIST=STR(Idx,2,1)+' CHS  '+ '|' ; Make row header
  ELSEIF (Idx=14)
   CURDIST=STR(Idx,2,1)+' --   '+ '|' ; Make row header
  ELSEIF (Idx=15)
   CURDIST=STR(Idx,2,1)+' CAR  '+ '|' ; Make row header
  ELSEIF (Idx=16)
   CURDIST=STR(Idx,2,1)+' CAL  '+ '|' ; Make row header
  ELSEIF (Idx=17)
   CURDIST=STR(Idx,2,1)+' STM  '+ '|' ; Make row header
  ELSEIF (Idx=18)
   CURDIST=STR(Idx,2,1)+' KG   '+ '|' ; Make row header
  ELSEIF (Idx=19)
   CURDIST=STR(Idx,2,1)+' FBG  '+ '|' ; Make row header
  ELSEIF (Idx=20)
   CURDIST=STR(Idx,2,1)+' STF  '+ '|' ; Make row header
  ELSEIF (Idx=21)
   CURDIST=STR(Idx,2,1)+' SPTS '+ '|' ; Make row header
  ELSEIF (Idx=22)
   CURDIST=STR(Idx,2,1)+' FAUQ '+ '|' ; Make row header
  ELSEIF (Idx=23)
   CURDIST=STR(Idx,2,1)+' CLK  '+ '|' ; Make row header
  ELSE
   CURDIST=STR(Idx,2,1)+' JEFF '+ '|' ; Make row header
  ENDIF
     Print form=10.2csv, file=@Rept@,  list = CURDIST,
       MetroShortj[idx],
       MetroLongj[idx],
       AMShortj[idx],
       AMLongj[idx],
       OPShortj[idx],
       OPLongj[idx],
       TOTAL_Area[idx]
 ENDLOOP
     Print form=10.2csv, file=@Rept@ list = '\n', '\n',
                              ' --------- --------- --------- --------- --------- ---------  --------- ---------','\n',
                              '     Total',MetroShortArea,MetroLongArea, AMShortArea  , AMLongArea,
                                           OPShortArea, OPLongArea, totarea,'\n','\n','\n'
;;--------------------------------------------------------------------------------------------------------------


;;--------------------------------------------------------------------------------------------------------------
     Print file=@Rept@ list = ' # of "Active"  TAZs by Shed Type and Walk Percentage (0% to 100%) ','\n','\n',
                              '  Walk_Pct  MetroSh   MetroLg   AMShort   AMLong    OPShort   OPLong  ','\n',
                              ' --------- --------- --------- --------- --------- --------- ---------','\n'
 LOOP Idx  = 1, 101
     value = idx - 1
     Print form=10, file=@Rept@,  list = value,
       MetroShortA[idx],
       MetroLongA[idx],
       AMShortA[idx],
       AMLongA[idx],
       OPShortA[idx],
       OPLongA[idx]
 ENDLOOP
     Print form=10, file=@Rept@ list = '\n', '\n',
                              ' --------- --------- --------- --------- --------- --------- ---------','\n',
                              '     Total', ActiveTAZCnt, ActiveTAZCnt,ActiveTAZCnt,ActiveTAZCnt,
                                            ActiveTAZCnt, ActiveTAZCnt
;;--------------------------------------------------------------------------------------------------------------
ENDIF

ENDRUN

;;opy TPPL*.prn Prepare_MC_ZFile.RPT