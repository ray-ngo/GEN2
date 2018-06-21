*del voya*.prn



; Trip_Distribution_External.s  - Version 2.3 Trip Distribution for External Trips
;
ZONESIZE  =  3722                 ; Max. TAZ No.            (Param)
LSTITAZ   =  3675                 ; Last Internal Zone No.  (Param)

;; itr = '%_iter_%'   ;;
;;  IF (itr = 'pp')
;;     AMSOVSKM = 'inputs\SOVppam.skm'      ;  AM  HWY TIME SKIMS (Initial iteration)
;;     MDSOVSKM = 'inputs\SOVppmd.skm'      ;  MD  HWY TIME SKIMS (Initial iteration)
;;   ELSE
;;     AMSOVSKM = 'SOV%_prev_%am.skm'             ;  AM  HWY TIME SKIMS
;;     MDSOVSKM = 'SOV%_prev_%md.skm'             ;  MD  HWY TIME SKIMS
;;  ENDIF

AMSOVSKM = '%_prev_%_am_sov.skm'             ;  AM  HWY TIME SKIMS
MDSOVSKM = '%_prev_%_md_sov.skm'             ;  MD  HWY TIME SKIMS


ATYPFILE = 'AreaType_File.dbf'             ; Zonal Area Type file    (I/P file)
HWYTERM  = 'ztermtm.asc'                   ;  Zonal HWY TERMINAL TIME file (created in THIS script)


AWTRNSKM = '%_iter_%_am_wk_MR.ttt'         ;  AM WK (Metrorail only) ACC TRN TIME SKIMS
ADTRNSKM = '%_iter_%_am_dr_MR.ttt'         ;  AM DR (Metrorail Only) ACC TRN TIME SKIMS

MWTRNSKM = '%_iter_%_op_wk_MR.ttt'         ;  OP WK (Metrorail only) ACC TRN TIME SKIMS
MDTRNSKM = '%_iter_%_op_dr_MR.ttt'         ;  OP DR (Metrorail Only) ACC TRN TIME SKIMS

; -------------------------------------------------------------------
; Equivalent minutes (min/'07$) by income level (for toll modeling)
toll_inc = '..\support\equiv_toll_min_by_inc.s'    ; Equivalent minutes (min/'07$) by period & income level (for toll modeling)

; Zonal K-factor Files
;
HBWK     = 'hbw_k.mat'    ;
HBSK     = 'hbs_k.mat'    ;
HBOK     = 'hbo_k.mat'    ;
NHWK     = 'nhw_k.mat'    ;
NHOK     = 'nho_k.mat'    ;
;
;-------------------------------------------------------------------
;
;
FFsFile   = '..\SUPPORT\ver23_f_factors.dbf'  ; F-Factors for all modeled purposes
;;Variables in the dbf file:
; IMP     HBWINC1 HBWINC2 HBWINC3 HBWINC4 HBWEI HBWEA    ;
;         HBSINC1 HBSINC2 HBSINC3 HBSINC4 HBSEI HBSEA    ;
;         HBOINC1 HBOINC2 HBOINC3 HBOINC4 HBOEI HBOEA    ;
;         NHW     NHO     NHBEI   NHBEA                  ;
;         ICOM    IMTK    IHTK    EXTCOM  EXTMTK  EXTHTK ;
;
; Trip-End (P/A) Input Files:
;
AutoProds = '%_iter_%_Trip_Gen_Productions_Comp.dbf'       ; Intl/Extl Auto Productions
;;Variables in dbf file:
; TAZ     HBW_MTR_PS  HBW_NMT_PS  HBW_ALL_PS  HBWMTRP_I1  HBWMTRP_I2  HBWMTRP_I3  HBWMTRP_I4
;         HBS_MTR_PS  HBS_NMT_PS  HBS_ALL_PS  HBSMTRP_I1  HBSMTRP_I2  HBSMTRP_I3  HBSMTRP_I4
;         HBO_MTR_PS  HBO_NMT_PS  HBO_ALL_PS  HBOMTRP_I1  HBOMTRP_I2  HBOMTRP_I3  HBOMTRP_I4
;         NHW_MTR_PS  NHW_NMT_PS  NHW_ALL_PS  NHO_MTR_PS  NHO_NMT_PS  NHO_ALL_PS
;

AutoAttrs = '%_iter_%_Trip_Gen_Attractions_Comp.dbf' ; Intl/Extl Auto Attractions
;;Variables in dbf file:
; TAZ     HBW_MTR_AS  HBW_NMT_AS  HBW_ALL_AS  HBWMTRA_I1  HBWMTRA_I2  HBWMTRA_I3  HBWMTRA_I4
;         HBS_MTR_AS  HBS_NMT_AS  HBS_ALL_AS  HBSMTRA_I1  HBSMTRA_I2  HBSMTRA_I3  HBSMTRA_I4
;         HBO_/TR_AS  HBO_NMT_AS  HBO_ALL_AS  HBOMTRA_I1  HBOMTRA_I2  HBOMTRA_I3  HBOMTRA_I4
;         NHW_MTR_AS  NHW_NMT_AS  NHW_ALL_AS  NHO_MTR_AS  NHO_NMT_AS  NHO_ALL_AS


ExtPsAs   = '%_iter_%_Ext_Trip_Gen_PsAs.dbf' ; Extl Auto Ps, As
;;Variables in dbf file:
; TAZ     SHBW_Mtr_Ps  SHBS_Mtr_Ps  SHBO_Mtr_Ps  SNHW_Mtr_Ps  SNHO_Mtr_Ps
;         SHBW_Mtr_As  SHBS_Mtr_As  SHBO_Mtr_As  SNHW_Mtr_As  SNHO_Mtr_As
;
;
TruckEnds = '%_iter_%_ComVeh_Truck_Ends.dbf'          ; Intl Comm.Veh/Truck TripEnds
;;Variables in dbf file:
; TAZ    ICOMM_VEH  IMED_TRUCK  IHVY_TRUCK
;
;
Ext_TrkEnds = '%_iter_%_Ext_CVTruck_Gen_PsAs.dbf'
;;Variables in dbf file:
;  TAZ SCOM_VEHPS      SMED_TRKPS      SHVY_TRKPS      SCOM_VEHAS      SMED_TRKAS      SHVY_TRKAS
;
;; OUTPUT TRIP TABLES
HBWTDOUT  = '%_iter_%_HBWext.PTT';
HBSTDOUT  = '%_iter_%_HBSext.PTT';
HBOTDOUT  = '%_iter_%_HBOext.PTT';
NHWTDOUT  = '%_iter_%_NHWext.PTT';
NHOTDOUT  = '%_iter_%_NHOext.PTT';
COMTDOUT  = '%_iter_%_COMext.VTT';
MTKTDOUT  = '%_iter_%_MTKext.VTT';
HTKTDOUT  = '%_iter_%_HTKext.VTT';



; /////////////////////////////////////////////////////////////////////
; \\\\\\\\\    BEGIN Composite Impedance, terminal time development \\\
; /////////////////////////////////////////////////////////////////////

RUN PGM=MATRIX
zones=1

;
FileI LOOKUPI[1] ="@atypfile@"
LOOKUP LOOKUPI=1, NAME=ZNAT,
       LOOKUP[1] = TAZ, RESULT=AType,   ;
       INTERPOLATE=N, FAIL= 0,0,0, LIST=N
; CREATE ZONAL ARRAY FOR EMPLOYMENT DENSITY



Loop M= 1,@ZONESIZE@

     _AType    = ZNAT(1,M)         ;  Area Type
     if (_Atype = 1 ) Termtm= 5.0
     if (_Atype = 2 ) Termtm= 4.0
     if (_Atype = 3 ) Termtm= 3.0
     if (_Atype = 4 ) Termtm= 2.0
     if (_Atype = 5 ) Termtm= 1.0
     if (_Atype = 6 ) Termtm= 1.0
     if (_Atype = 7 ) Termtm= 1.0

     if (M > @LSTITAZ@)    Termtm = 0.0

;  WRITE OUT  ZONAL TERMINAL TIME FILE
        list = 'TAZ: ',M(4),' AT: ',_Atype(3),' Term. Time: ',
                termtm(3),file=@hwyterm@
ENDLOOP

ENDRUN

;
; /////////////////////////////////////////////////////////////////////
; \\\\\\\\\    1) Add Highway Terminal Times to AM, Off-peak     \\\\\\
; \\\\\\\\\       SOV Skims                                      \\\\\\
; /////////////////////////////////////////////////////////////////////



RUN PGM=MATRIX
Zones = 3722
;  READ Highway terminal time file

ZDATI[1]= @hwyterm@, Z=6-9,hterm=31-33

;  READ AM PEAK & Midday  SOV TIME SKIM FILE (IN WHOLE MIN)

  MATI[1] = @AMSOVSKM@   ;  INPUT AM PK  SKIM FILE
  MATI[2] = @MDSOVSKM@   ;  INPUT OFF-PK SKIM FILE

  MW[1]   = MI.1.1       ;  INPUT AM PK  Time (min) SKIM FILE
  MW[2]   = MI.2.1       ;  INPUT OFF-PK Time (min) SKIM FILE


;
; Now add the terminal times to the AM/MD travel times below
;   - terminal times added only to connected interchanges)
;   - terminal times are added to both the i and j ends of the trip
;
JLOOP
    IF  (MW[1] > 0)
         MW[3] = MW[1] + zi.1.hterm[I] + zi.1.hterm[J]
         ELSE
         MW[3] = MW[1]
    ENDIF
    IF  (MW[2] > 0)
         MW[4] = MW[2] + zi.1.hterm[I] + zi.1.hterm[J]
         ELSE
         MW[4] = MW[2]
    ENDIF
ENDJLOOP

;
; Establish Intrazonal Values for Network Time Skims
;  -  Values equal to 85% of lowest nonzero interzonal value
;     Up from 50% used in Version 2.2
JLOOP
 IF (I=J)
      MW[3]=ROUND(0.50 * LOWEST(3,1,0.0001,99999.9))
      MW[4]=ROUND(0.50 * LOWEST(4,1,0.0001,99999.9))

 ENDIF
ENDJLOOP
; WRITE OUT FINAL TIME SKIMS

 MATO[1] = am_sov_termIntraTime.skf, MO=3; output am sov time(min) w/ o&d term&intra times
 MATO[2] = md_sov_termIntraTime.skf, MO=4; output md sov time(min) w/ o&d term&intra times

; print row 1 of I/O matrices for checking

   IF  (I =699)
     PRINTROW MW=1-4
   ENDIF

ENDRUN

; /////////////////////////////////////////////////////////////////////
; \\\\\\\\\    2) Compute Composite Impedances to by used in        \\\
; \\\\\\\\\       Trip Distribution for HBW, HBS, HBO, NHB Purposes \\\
; /////////////////////////////////////////////////////////////////////


RUN PGM=MATRIX
Zones = 3722

; COMPUTATION OF COMPOSITE IMPEDANCES
;  READ AM PEAK & OFF-PEAK SOV TIME SKIM FILE (IN WHOLE MIN)

MATI[1] = am_sov_termIntraTime.skf  ;  AM  PK HWY TIME FILE W/ TERM&INTRAZNL VALUES
MATI[2] = md_sov_termIntraTime.skf  ;  OFF-PK HWY TIME FILE W/ TERM&INTRAZNL VALUES

MATI[3] = @AWTRNSKM@   ;  AM  PK WALK ACC TRN (Metrorail Only) SKIM FILE
MATI[4] = @ADTRNSKM@   ;  AM  PK AUTO ACC TRN (Metrorail Only) SKIM FILE
MATI[5] = @MWTRNSKM@   ;  Midday WALK ACC TRN (Metrorail Only) SKIM FILE
MATI[6] = @MDTRNSKM@   ;  Midday AUTO ACC TRN (Metrorail Only) SKIM FILE

;$
MATI[7] = @AMSOVSKM@   ;  INPUT AM PK  tolls in '07 cents (on table 3)
MATI[8] = @MDSOVSKM@   ;  INPUT Midday tolls in '07 cents (on table 3)
;
 READ FILE =@TOLL_INC@  ;  READ in equivalent min/07$ by income group
;
;$

; ESTABLISH WORK MATRICES:

MW[1]=MI.1.1            ; AM  PK HWY TIME FILE W/ TERM&INTRAZNL VALUES
MW[2]=MI.2.1            ; OFF-PK HWY TIME FILE W/ TERM&INTRAZNL VALUES
;
;-----------------------; Make Sure interzonal (conn.or disconn.)
JLOOP
  IF (MW[1] = 0.0)
      MW[1] = 1.0
  ENDIF
  IF (MW[2] = 0.0)
      MW[2] = 1.0
  ENDIF
ENDJLOOP
;-----------------------;
;

;$
;-
; add equivalent 'tolled' AM/OP highway time to normal times by income level
; AM pk normal + equivalent hwy time in work tables 61-64
; Offpk normal + equivalent hwy time in work tables 71-74

      MW[61] = Round(MW[1] + ((MI.7.3/100.0) * i1PKEQM)) ;i1 AM hwy time w/eqv
      MW[62] = Round(MW[1] + ((MI.7.3/100.0) * i2PKEQM)) ;i2 AM hwy time w/eqv
      MW[63] = Round(MW[1] + ((MI.7.3/100.0) * i3PKEQM)) ;i3 AM hwy time w/eqv
      MW[64] = Round(MW[1] + ((MI.7.3/100.0) * i4PKEQM)) ;i4 AM hwy time w/eqv

      MW[71] = Round(MW[2] + ((MI.8.3/100.0) * i1MDEQM)) ;i1 MD hwy time w/eqv
      MW[72] = Round(MW[2] + ((MI.8.3/100.0) * i2MDEQM)) ;i2 MD hwy time w/eqv
      MW[73] = Round(MW[2] + ((MI.8.3/100.0) * i3MDEQM)) ;i3 MD hwy time w/eqv
      MW[74] = Round(MW[2] + ((MI.8.3/100.0) * i4MDEQM)) ;i4 MD hwy time w/eqv
;
; Lines below convert tolls to time for distribution of external trips.
; Average factors from traffic assignment are used.
;
      MW[76] = Round(MW[1] + ((MI.7.3/100.0) * SVAMEQM)) ;X-I,I-X AM hwy time w/eqv - added by DV 2/6/09
      MW[77] = Round(MW[2] + ((MI.8.3/100.0) * SVMDEQM)) ;X-I,I-X OP hwy time w/eqv - added by DV 2/6/09
;
;
;
;
;
MW[3]=MI.3.1            ; AM  PK WALK ACC TOTAL TRN TIME FILE
MW[4]=MI.4.1            ; AM  PK AUTO ACC TOTAL TRN TIME FILE

MW[5]=MI.5.1            ; OFF-PK WALK ACC TOTAL TRN TIME FILE
MW[6]=MI.6.1            ; OFF-PK AUTO ACC TOTAL TRN TIME FILE

;FIRST, FIND 'BEST' WALK/AUTO TRANSIT TIME BOTH AM AND OFF-PK CONDITIONS
; BEST AM TRN TIME STORED IN MW11, BEST OP TRN TIME STORED IN MW12

  JLOOP
     IF (MW[3] > 0 && MW[4] > 0)      ; 'BEST' AM PK TRN TIME
        MW[11] = MIN(MW[3],MW[4])     ; WILL BE THE MINIMUM OF
     ELSE                             ; NON-ZERO WALK/AUTO TIMES OR
        MW[11] = MAX(MW[3],MW[4])     ; THE ONE THAT'S CONNECTED
     ENDIF

     IF (MW[5] > 0 && MW[6] > 0)      ;  SAME FOR OFF PEAK
        MW[12] = MIN(MW[5],MW[6])     ;
     ELSE                             ;
        MW[12] = MAX(MW[5],MW[6])     ;
     ENDIF
  ENDJLOOP

; NOW COMPUTE HBW,HBS,HBO,NHB COMPOSITE IMPEDANCES
;
JLOOP
 IF (MW[11] = 0 || I = J)
   MW[15] = MW[61]
   MW[16] = MW[62]
   MW[17] = MW[63]
   MW[18] = MW[64]
 ELSE
   MW[15] = 1.0/((1.0/MW[61])+(0.1851/MW[11]))  ; HBW -INC 1 CI MTX
   MW[16] = 1.0/((1.0/MW[62])+(0.1563/MW[11]))  ; HBW -INC 2 CI MTX
   MW[17] = 1.0/((1.0/MW[63])+(0.1682/MW[11]))  ; HBW -INC 3 CI MTX
   MW[18] = 1.0/((1.0/MW[64])+(0.1483/MW[11]))  ; HBW -INC 4 CI MTX
 ENDIF

 IF (MW[12] = 0 || I = J)
   MW[20] =  MW[71]
   MW[21] =  MW[72]
   MW[22] =  MW[73]
   MW[23] =  MW[74]

   MW[25] =  MW[71]
   MW[26] =  MW[72]
   MW[27] =  MW[73]
   MW[28] =  MW[74]

   MW[50] =  MW[72]
   MW[51] =  MW[72]

 ELSE
   MW[20] = 1.0/((1.0/MW[71])+(0.0805/MW[12])) ; HBS -INC 1 CI MTX
   MW[21] = 1.0/((1.0/MW[72])+(0.0184/MW[12])) ; HBS -INC 2 CI MTX
   MW[22] = 1.0/((1.0/MW[73])+(0.0117/MW[12])) ; HBS -INC 3 CI MTX
   MW[23] = 1.0/((1.0/MW[74])+(0.0104/MW[12])) ; HBS -INC 4 CI MTX

   MW[25] = 1.0/((1.0/MW[71])+(0.1239/MW[12])) ; HBO -INC 1 CI MTX
   MW[26] = 1.0/((1.0/MW[72])+(0.0231/MW[12])) ; HBO -INC 2 CI MTX
   MW[27] = 1.0/((1.0/MW[73])+(0.0188/MW[12])) ; HBO -INC 3 CI MTX
   MW[28] = 1.0/((1.0/MW[74])+(0.0158/MW[12])) ; HBO -INC 4 CI MTX

   MW[50] = 1.0/((1.0/MW[72])+(0.0866/MW[12])) ; NHW
   MW[51] = 1.0/((1.0/MW[72])+(0.0224/MW[12])) ; NHO
 ENDIF

ENDJLOOP

MATO[1] = HBWCI1_4.MAT, MO=15,16,17,18 ;HBW COMP.IMPEDANCES-INC.LEVELS 1-4
MATO[2] = HBSCI1_4.MAT, MO=20,21,22,23 ;HBS COMP.IMPEDANCES-INC.LEVELS 1-4
MATO[3] = HBOCI1_4.MAT, MO=25,26,27,28 ;HBO COMP.IMPEDANCES-INC.LEVELS 1-4
MATO[4] = NHBCI.MAT,    MO=50,51       ;NHW/NHO  COMP.IMPEDANCES
MATO[5] = am_sov_termIntraTime_x.skf, MO=76          ; AM Peak  X-I, I-X impedances with tolls
MATO[6] = md_sov_termIntraTime_x.skf, MO=77          ; Off Peak X-I, I-X impedances with tolls
;
;$
;
; NOW, WRITE OUT THE RESULTS OF SELECTED INTERCHANGES FOR CHECKING
;     AND COMPARING
JLOOP INCLUDE=1 ; WILL PROCESS ONLY FOR J=1
  PRINT LIST = I(4),' ',J(4),' ',mw[15](5),mw[16](5),mw[17](5),mw[18](5),
        FILE =ci_hbw.txt
  PRINT LIST = I(4),' ',J(4),' ',mw[20](5),mw[21](5),mw[22](5),mw[23](5),
        FILE =ci_hbs.txt
  PRINT LIST = I(4),' ',J(4),' ',mw[25](5),mw[26](5),mw[27](5),mw[28](5),
        FILE =ci_hbo.txt
  PRINT LIST = I(4),' ',J(4),' ',mw[72](5),MW[12](5),mw[50](5),MW[51](5),
        FILE =ci_nhb.txt
ENDJLOOP
ENDRUN

; /////////////////////////////////////////////////////////////////////
; \\\\\\\\\    3) Compute Impedance files to be used in the External \\
; \\\\\\\\\       Trip Distribution processing                       \\
; /////////////////////////////////////////////////////////////////////



RUN PGM=MATRIX
ZONES =3722
MATI[1] = am_sov_termIntraTime_x.skf  ;  AM  PK HWY TIME FILE W/ TERM&INTRAZNL VALUES
MATI[2] = md_sov_termIntraTime_x.skf  ;  Midday HWY TIME FILE W/ TERM&INTRAZNL VALUES

MW[1]=MI.1.1           ;  AM  PK HWY TIME FILE W/ TERM&INTRAZNL VALUES
MW[2]=MI.2.1           ;  Midday HWY TIME FILE W/ TERM&INTRAZNL VALUES

;  Development of Peak, Midday   SOV Travel times to be used
;  for External Trip distribution of Interstate and Arterial Trip Dist.
;
;  2 skim files will be written:
;  MW[11] - AM Time Period, External ij's
;  MW[12] - Midday  Period, External ij's
;
;   First, set work matrices equal to 'Full' AM, Off-peak time skims
;
 MW[11] = MW[1]    ; AM
 MW[12] = MW[2]    ; Midday

; next, put very large time value into all
; i-i and x-x ijs to preclude distributing externals in these cells

 IF  (I =    1-3675)
    MW[11] =   2000, INCLUDE=    1-3675 ; i-i ijs
    MW[12] =   2000, INCLUDE=    1-3675 ; i-i ijs
 ELSE
    MW[11] =   2000, INCLUDE= 3675-3722 ; x-x ijs
    MW[12] =   2000, INCLUDE= 3675-3722 ; x-x ijs
 ENDIF

; WRITE OUT EXTERNAL TRIP DISTRIBUTION IMPEDANCE TABLES

MATO[1] = am_sov_termIntraTime_e.skf, MO=11 ;  AM -PK Time skims for Extl trip dist.
MATO[2] = md_sov_termIntraTime_e.skf, MO=12 ;  Midday Time skims for Extl trip dist.
ENDRUN
;

; End of Composite Impedance Development

;-------------------------------------------------------------------------------
; Trip Distribution Model Calibration Process
;-------------------------------------------------------------------------------
;

; |\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\|
; |//////      Start HBW Trip Distribution Here:             /////|
; |\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\|



RUN PGM=DISTRIBUTION
  zones= 3722
  MATI= HBWCI1_4.MAT,   ; Composite Time Impedances HBW Inc.Levels 1-4  #1
        @HBWK@,         ; HBW Kfactors (Scaled by 1000.0)               #2
        am_sov_termIntraTime_e.skf,   ; AM -PK Time skims for Extl trip dist.         #3
        md_sov_termIntraTime_e.skf    ; Midday Time skims for Extl trip dist.         #4

; Put income based impedance matrices in work tables 11-14
; tabs 11-14 are comp.time for inc.levels 1,2,3,4
; Put am, midday external impedances (hwy time) 21,31 respectively

  FILLMW MW[11]  = MI.1.1,2,3,4
         MW[21]  = MI.3.1
         MW[31]  = MI.4.1

; Put K-factor matrix in work table 20
;   - K-factors are scaled by 1000s (eg, a mtx value of '1000'=1.0)
;   - K-factors are applied across all HBW distributions

  FILLMW MW[20] = MI.2.1
  DUMMY = ROWFAC(20,0.001) ; scale k-factor's to 'true' units

ZDATI[1]     = @AutoProds@ ;  internal auto  productions file
ZDATI[2]     = @AutoAttrs@ ;  internal auto  attractions file
ZDATI[3]     = @ExtPsAs@   ;  External Ps,As attractions file

; read friction factors file as lookup table
FileI LOOKUPI[1] = "@FFsFile@"
LOOKUP LOOKUPI=1, NAME=FF,
       LOOKUP[1]  = IMP, RESULT=HBWEI,     ;
       LOOKUP[2]  = IMP, RESULT=HBWEA,     ;
       INTERPOLATE=N,SETUPPER=T,FAIL=0,0,0

;  Establish production and attraction vectors here:

SETPA P[1]=ZI.3.SHBW_MtrPs, P[2]=ZI.3.SHBW_MtrPs
SETPA A[1]=ZI.3.SHBW_MtrAs, A[2]=ZI.3.SHBW_MtrAs

MAXITERS = 15    ; specify GM iterations
MAXRMSE  = 0.0001


;  Establish gravity model run files & parameters
GRAVITY  PURPOSE  = 1, LOS=MW[21], FFACTORS= FF, KFACTORS = MW[20],LOSRANGE=2-250.       ;;21-am-HBW 31-md/nonHBW
GRAVITY  PURPOSE  = 2, LOS=MW[21], FFACTORS= FF, KFACTORS = MW[20],LOSRANGE=2-250.       ;;21/am-HBW 31-op/nonHBW

;REPORT ZDAT = Y
;REPORT ACOMP=1-2

MATO = HBWext.TEM,MO=1-2   ;   Final Ext HBW  trip table(s)
                         ;       T1 - externals/ using interstate facility FFactors
                         ;       T2 - externals/ using arterial   facility FFactors
ENDRUN

;; --ENB HBW Trip Dist---;;
; |\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\|
; |//////      Start HBS Trip Distribution Here:             /////|
; |\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\|



RUN PGM=DISTRIBUTION
  zones= 3722
  MATI= HBSCI1_4.MAT,   ; Composite Time Impedances HBW Inc.Levels 1-4  #1
        @HBSK@,         ; HBW Kfactors (Scaled by 1000.0)               #2
        am_sov_termIntraTime_e.skf,   ; AM -PK Time skims for Extl trip dist.         #3
        md_sov_termIntraTime_e.skf    ; Midday Time skims for Extl trip dist.         #4

; Put income based impedance matrices in work tables 11-14
; tabs 11-14 are comp.time for inc.levels 1,2,3,4
; Put am, midday external impedances (hwy time) 21,31 respectively

  FILLMW MW[11]  = MI.1.1,2,3,4
         MW[21]  = MI.3.1
         MW[31]  = MI.4.1

; Put K-factor matrix in work table 20
;   - K-factors are scaled by 1000s (eg, a mtx value of '1000'=1.0)
;   - K-factors are applied across all HBW distributions

  FILLMW MW[20] = MI.2.1
  DUMMY = ROWFAC(20,0.001) ; scale k-factor's to 'true' units

ZDATI[1]     = @AutoProds@ ;  internal auto  productions file
ZDATI[2]     = @AutoAttrs@ ;  internal auto  attractions file
ZDATI[3]     = @ExtPsAs@   ;  External Ps,As attractions file

; read friction factors file as lookup table
FileI LOOKUPI[1] = "@FFsFile@"
LOOKUP LOOKUPI=1, NAME=FF,
       LOOKUP[1]  = IMP, RESULT=HBSEI,     ;
       LOOKUP[2]  = IMP, RESULT=HBSEA,     ;
       INTERPOLATE=N,SETUPPER=T,FAIL=0,0,0

;  Establish production and attraction vectors here:

SETPA P[1]=ZI.3.SHBS_MtrPs, P[2]=ZI.3.SHBS_MtrPs
SETPA A[1]=ZI.3.SHBS_MtrAs, A[2]=ZI.3.SHBS_MtrAs

MAXITERS = 27    ; specify GM iterations
MAXRMSE  = 0.0001


;  Establish gravity model run files & parameters
GRAVITY  PURPOSE  = 1, LOS=MW[31], FFACTORS= FF, KFACTORS = MW[20],LOSRANGE=2-250.       ;;21-am-HBW 31-md/nonHBW
GRAVITY  PURPOSE  = 2, LOS=MW[31], FFACTORS= FF, KFACTORS = MW[20],LOSRANGE=2-250.       ;;21/am-HBW 31-op/nonHBW

;REPORT ZDAT = Y
;REPORT ACOMP=1-2

MATO = HBSext.TEM,MO=1-2   ;   Final HBS  trip table(s)
                         ;       T1 - externals/ using interstate facility FFactors
                         ;       T2 - externals/ using arterial   facility FFactors
ENDRUN

;; --ENB HBS Trip Dist---;;
;

; |\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\|
; |//////      Start HBO Trip Distribution Here:             /////|
; |\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\|


RUN PGM=DISTRIBUTION
  zones= 3722
  MATI= HBOCI1_4.MAT,   ; Composite Time Impedances HBW Inc.Levels 1-4  #1
        @HBOK@,         ; HBW Kfactors (Scaled by 1000.0)               #2
        am_sov_termIntraTime_e.skf,   ; AM -PK Time skims for Extl trip dist.         #3
        md_sov_termIntraTime_e.skf    ; Midday Time skims for Extl trip dist.         #4

; Put income based impedance matrices in work tables 11-14
; tabs 11-14 are comp.time for inc.levels 1,2,3,4
; Put am, midday external impedances (hwy time) 21,31 respectively

  FILLMW MW[11]  = MI.1.1,2,3,4   ; comp. imp mw tabs 11-14
         MW[21]  = MI.3.1         ;
         MW[31]  = MI.4.1         ;

; Put K-factor matrix in work table 20
;   - K-factors are scaled by 1000s (eg, a mtx value of '1000'=1.0)
;   - K-factors are applied across all HBW distributions

  FILLMW MW[20] = MI.2.1
  DUMMY = ROWFAC(20,0.001) ; scale k-factor's to 'true' units

ZDATI[1]     = @AutoProds@ ;  internal auto  productions file
ZDATI[2]     = @AutoAttrs@ ;  internal auto  attractions file
ZDATI[3]     = @ExtPsAs@   ;  External Ps,As attractions file

; read friction factors file as lookup table
FileI LOOKUPI[1] = "@FFsFile@"
LOOKUP LOOKUPI=1, NAME=FF,
       LOOKUP[1]  = IMP, RESULT=HBOEI,     ;
       LOOKUP[2]  = IMP, RESULT=HBOEA,     ;
       INTERPOLATE=N,SETUPPER=T,FAIL=0,0,0

;  Establish production and attraction vectors here:

SETPA P[1]=ZI.3.SHBO_MtrPs, P[2]=ZI.3.SHBO_MtrPs
SETPA A[1]=ZI.3.SHBO_MtrAs, A[2]=ZI.3.SHBO_MtrAs

MAXITERS = 27    ; specify GM iterations
MAXRMSE  = 0.0001


;  Establish gravity model run files & parameters
GRAVITY  PURPOSE  = 1, LOS=MW[31], FFACTORS= FF, KFACTORS = MW[20],LOSRANGE=2-250.       ;;21-am-HBW 31-md/nonHBW
GRAVITY  PURPOSE  = 2, LOS=MW[31], FFACTORS= FF, KFACTORS = MW[20],LOSRANGE=2-250.       ;;21/am-HBW 31-op/nonHBW

;REPORT ZDAT = Y
;REPORT ACOMP=1-6

MATO = HBOext.TEM,MO=1-2   ;   Final HBO  trip table(s)
                         ;       T1 - HBO Inc. Level 1 (i-i)
                         ;       T2 - HBO Inc. Level 2 (i-i)
                         ;       T3 - HBO Inc. Level 3 (i-i)
                         ;       T4 - HBO Inc. Level 4 (i-i)
                         ;       T5 - externals/ using interstate facility FFactors
                         ;       T6 - externals/ using arterial   facility FFactors
ENDRUN

;; --ENB HBO Trip Dist---;;
;

; |\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\|
; |//////      Start NHW/NHO Trip Distribution Here:         /////|
; |\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\|

RUN PGM=DISTRIBUTION
  zones= 3722
  MATI=   NHBCI.MAT,      ; Composite Time Impedances NHW/NHO T1&2   file 1
          md_sov_termIntraTime_e.skf,   ; Midday Time skims for Extl trip dist.    file 2
          @NHWK@,         ; NHW Kfactors (Scaled by 1000.0)          file 3
          @NHOK@          ; NHO Kfactors (Scaled by 1000.0)          file 4

; Put nhw, nho impedance matrices in work tables 11-12
  FILLMW MW[11]  = MI.1.1,2
; Put extl     impedance matrices in work tables 31
  mw[31] = mi.2.1

; Put K-factor matrix in work table 20
;   - K-factors are scaled by 1000s (eg, a mtx value of '1000'=1.0)
;   - K-factors are applied across all HBS distributions

  FILLMW MW[20] = MI.3.1
  FILLMW MW[21] = MI.4.1
  DUMMY = ROWFAC(20,0.001) ; scale k-factor's to 'true' units
  DUMMY = ROWFAC(21,0.001) ; scale k-factor's to 'true' units
                                                 ; Variables in the ZDATI files:
ZDATI[1]     = @ExtPsAs@   ;  External Ps,As attractions file

;  read friction factors file as lookup table
FileI LOOKUPI[1] = "@FFsFile@"
LOOKUP LOOKUPI=1, NAME=FF,
       LOOKUP[1]  = IMP, RESULT=NHBEI,     ;
       LOOKUP[2]  = IMP, RESULT=NHBEA,     ;
       LOOKUP[3]  = IMP, RESULT=NHBEI,     ;
       LOOKUP[4]  = IMP, RESULT=NHBEA,     ;
       INTERPOLATE=N,SETUPPER=T,FAIL=0,0,0

;  Establish production and attraction vectors here:

SETPA P[1]=ZI.1.SNHW_MtrAs, P[2]=ZI.1.SNHW_MtrAs, P[3]=ZI.1.SNHO_MtrAs, P[4]=ZI.1.SNHO_MtrAs
SETPA A[1]=ZI.1.SNHW_MtrAs, A[2]=ZI.1.SNHW_MtrAs, A[3]=ZI.1.SNHO_MtrAs, A[4]=ZI.1.SNHO_MtrAs

MAXITERS = 9     ; specify GM iterations
MAXRMSE  = 0.0001


;  Establish gravity model run files & parameters
GRAVITY  PURPOSE  = 1, LOS=MW[31], FFACTORS= FF, KFACTORS = MW[20],LOSRANGE=2-250.       ;;NHW /INTERSTATE FFS
GRAVITY  PURPOSE  = 2, LOS=MW[31], FFACTORS= FF, KFACTORS = MW[21],LOSRANGE=2-250.       ;;NHW /ARTERIAL   FFS
GRAVITY  PURPOSE  = 3, LOS=MW[31], FFACTORS= FF, KFACTORS = MW[20],LOSRANGE=2-250.       ;;NHO /INTERSTATE FFS
GRAVITY  PURPOSE  = 4, LOS=MW[31], FFACTORS= FF, KFACTORS = MW[21],LOSRANGE=2-250.       ;;NHO /ARTERIAL   FFS

;REPORT ZDAT = Y
;REPORT ACOMP=1-4

MATO = NHBExt.TEM,MO=1-4   ;   Final NHB  trip table(s)
                         ;       T1 - NHW    EXTL      interstate facility FFactors
                         ;       T2 - NHW    EXTL      arterial   facility FFactors
                         ;       T3 - NHO    EXTL      interstate facility FFactors
                         ;       T4 - NHO    EXTL      arterial   facility FFactors
ENDRUN
;; --ENB NHB Trip Dist---;;
; |\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\|
; |//////      Start COM/TRK Trip Distribution Here:               /////|
; |\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\|

RUN PGM=TRIPDIST
  MATI[1] = %_prev_%_MD_SOV.SKM       ; Off-Pk Time Imped. for COM
  MATI[2] = %_prev_%_MD_TRUCK.skm       ; Off-Pk Truck Time for MTK/HTK
  MATI[3] = md_sov_termIntraTime_e.skf            ; Midday Time skims for Extl trip dist.

; Put impedance matrices in work tables 11-12.  Tab 11 is for COM
; trips; tab 12 is for MTK and HTK trips.  All time values are in minutes.

 MW[11]  = MI.1.1  ; com veh los  matix
 MW[12]  = MI.2.1  ; trk     los  matrix
 MW[13]  = MI.3.1  ; extl    los  matrix

ZDATI[1]  = @TruckEnds@
ZDATI[2]  = @Ext_TrkEnds@

;  FFactors
FileI LOOKUPI[1] = "@FFsFile@"
LOOKUP LOOKUPI=1, NAME=FF,
       LOOKUP[1]  = IMP, RESULT=EXTCOM,     ; Ext CV
       LOOKUP[2]  = IMP, RESULT=EXTMTK,     ; Ext Mtk
       LOOKUP[3]  = IMP, RESULT=EXTHTK,     ; Ext Htk
       INTERPOLATE=N,SETUPPER=T,FAIL=0,0,0

;  Establish production and attraction vectors here:

SETPA P[1]=ZI.2.SCOM_VEHPS, P[2]=ZI.2.SMED_TRKPS, P[3]=ZI.2.SHVY_TRKPS
SETPA A[1]=ZI.2.SCOM_VEHAS, A[2]=ZI.2.SMED_TRKAS, A[3]=ZI.2.SHVY_TRKAS

MAXITERS = 9     ; specify GM iterations
MAXRMSE  = 0.0001

;  Establish gravity model run files & parameters
GRAVITY  PURPOSE  = 1, LOS=MW[13], FFACTORS= FF,losrange=2-250     ; COM External
GRAVITY  PURPOSE  = 2, LOS=MW[13], FFACTORS= FF,losrange=2-250     ; MTK External
GRAVITY  PURPOSE  = 3, LOS=MW[13], FFACTORS= FF,losrange=2-250     ; HTK External

MATO[1] = COMext.TEM,MO=1   ; Final COM trip tables: 1 = Extl
MATO[2] = MTKext.TEM,MO=2   ; Final MTK trip tables: 1 = Extl
MATO[3] = HTKext.TEM,MO=3   ; Final HTK trip tables: 1 = Extl

ENDRUN

; End COM/TRK Trip Distribution  ---
;;-------------------------------------------------------------------------------------------------------
;;Now splice the external interstate/ external arterial matrices by purpose into single external table  -
;;-------------------------------------------------------------------------------------------------------

RUN PGM=MATRIX
ZONES = @ZONESIZE@

MATI[1] = HBWext.TEM    ;    2 HBW  trip tables:  Ext/InterstFFs, Extls/ArterFFs
MATI[2] = HBSext.TEM    ;    2 HBS  trip tables:  Ext/InterstFFs, Extls/ArterFFs
MATI[3] = HBOext.TEM    ;    2 HBO  trip tables:  Ext/InterstFFs, Extls/ArterFFs
MATI[4] = NHBext.TEM    ;    4 NHB  trip tables:  NHW Extl/IntFFs,NHW Extl/ArtFFs, NHO Extl/IntFFs,NHO Extl/ArtFFs
MATI[5] = COMext.TEM    ;    1 Com  trip tables:  Extl
MATI[6] = MTKext.TEM    ;    1 Mtk  trip tables:  Extl
MATI[7] = HTKext.TEM    ;    1 Htk  trip tables:  Extl

FillMW MW[101]=mi.1.1,2          ; HBW     external tabs in mw 101-102
FillMW MW[201]=mi.2.1,2          ; HBS     external tabs in mw 201-202
FillMW MW[301]=mi.3.1,2          ; HBO     external tabs in mw 301-302
FillMW MW[401]=mi.4.1,2,3,4      ; NHW,NHO external tabs in mw 401-404


FillMW MW[601]=mi.5.1            ; Com     external tabs in mw 501
FillMW MW[701]=mi.6.1            ; Mtk     external tabs in mw 601
FillMW MW[801]=mi.7.1            ; Htk     external tabs in mw 701

;; define external interstate, and external arterial station interchanges
;;  in mws 11, 22
MW[11]=0.0
MW[22]=0.0


;; define External /Interstate rows, columns
if  (I >= 1 && I <= @LstITaz@)  mw[11] = 1.0, include = 3677,3680,3685,3687,3697,3702,3711,3713,3714,3715,3718,3722
if  (I=3677 || I=3680  || I=3685  || I=3687  || I=3697  || I=3702 || I=3711  || I=3713  || I=3714  || I=3715  || I=3718  || I=3722)
                               mw[11] = 1.0
 endif

;; define External /Arterial rows, columns
if  (I >= 1 && I <= @LstITaz@)  mw[22] = 1.0, include = 3676,3678,3679,3681,3682,3683,3684,3686,3688,3689,3690,3691,3692,3693,3694,3695,
                                                        3696,3698,3699,3700,3701,3703,3704,3705,3706,3707,3708,3709,3710,3712,3716,3717,3719,3720,3721
if  (I=3676 || I=3678 || I=3679 || I=3681 || I=3682 || I=3683 || I=3684 || I=3686 || I=3688 || I=3689 || I=3690 || I=3691 || I=3692 ||
     I=3693 || I=3694 || I=3695 || I=3696 || I=3698 || I=3699 || I=3700 || I=3701 || I=3703 || I=3704 || I=3705 || I=3706 || I=3707 ||
     I=3708 || I=3709 || I=3710 || I=3712 || I=3716 || I=3717 || I=3719 || I=3720 || I=3721)
                               mw[22] = 1.0
endif

;;
;;Apply 'screen' matrices to separate external Int/Art matrices and combine in one matrix
MW[107] =   (MW[101] * mw[11]) + (MW[102] * mw[22])  ; Final HBW External trip tables
MW[207] =   (MW[201] * mw[11]) + (MW[202] * mw[22])  ;       HBS External trip tables
MW[307] =   (MW[301] * mw[11]) + (MW[302] * mw[22])  ;       HBO External trip tables

MW[407] =   (MW[401] * mw[11]) + (MW[402] * mw[22])  ;       NHW External trip tables
MW[507] =   (MW[403] * mw[11]) + (MW[404] * mw[22])  ;       NHO External trip tables

;;
;;Compute Total ExtPsn Trips matrix
MW[108] =     MW[107]    ; Total external HBW Motorized Person Trip tabs
MW[208] =     MW[207]    ; Final external HBS Motorized Person Trip tabs
MW[308] =     MW[307]    ; Final external HBO Motorized Person Trip tabs
MW[408] =     MW[407]    ; Final external NHW Motorized Person Trip tabs
MW[508] =     MW[507]    ; Final external NHO Motorized Person Trip tabs
MW[608] =     MW[601]    ; Final external Commercial Vehicle Trips
MW[708] =     MW[701]    ; Final external Medium Truck Trips
MW[808] =     MW[801]    ; Final external Heavy  Truck Trips

 ;; write out final matrices comprehensive tabs
MATO[1] = @HBWTDOUT@ , MO=108,name=HBWExtpsn
MATO[2] = @HBSTDOUT@ , MO=208,name=HBSExtpsn
MATO[3] = @HBOTDOUT@ , MO=308,name=HBOExtpsn
MATO[4] = @NHWTDOUT@ , MO=408,name=NHWExtpsn
MATO[5] = @NHOTDOUT@ , MO=508,name=NHOExtpsn
MATO[6] = @COMTDOUT@ , MO=608,name=COMExt
MATO[7] = @MTKTDOUT@ , MO=708,name=MTKExt
MATO[8] = @HTKTDOUT@ , MO=808,name=HTKExt


ENDRUN
;
;===================================================================
;
;----------------------------------------------------------
;
; Standard 23x23 Summaries
; Trip Distribution (HBW,HBS,HBO,NHB,COM,MTK,HTK) and formats
; them in neat jurisdictional summaries (23x23)
;
;
;----------------------------------------------------------
;----------------------------------------------------------

COPY FILE=DJ.EQV
;   -- Start of Jurisiction-to-TAZ equivalency --
D 1=1-4,6-47,49-50,52-63,65,181-209,282-287,374-381     ;  0    DC Core
D 2=5,48,51,64,66-180,210-281,288-373,382-393           ;  0    DC Noncore
D 3=394-769                                             ;  1    Montgomery
D 4=771-776,778-1404                                    ;  2    Prince George
D 5=1471-1476, 1486-1489, 1495-1497                     ;  3    ArlCore
D 6=1405-1470,1477-1485,1490-1494,1498-1545             ;  3    ArlNCore
D 7=1546-1610                                           ;  4    Alex
D 8=1611-2159                                           ;  5    FFx
D 9=2160-2441                                           ;  6    LDn
D 10=2442-2554,2556-2628,2630-2819                      ;  7    PW
D 11=2820-2949                                          ;  9    Frd
D 12=3230-3265,3268-3287                                ; 14    Car.
D 13=2950-3017                                          ; 10    How.
D 14=3018-3102,3104-3116                                ; 11    AnnAr
D 15=3288-3334                                          ; 15    Calv
D 16=3335-3409                                          ; 16    StM
D 17=3117-3229                                          ; 12    Chs.
D 18=3604-3653                                          ; 21    Fau
D 19=3449-3477,3479-3481,3483-3494,3496-3541            ; 19    Stf.
D 20=3654-3662,3663-3675                                ; 22/23 Clk,Jeff.
D 21=3435-3448,3542-3543,3545-3603                      ; 18/20 Fbg,Spots
D 22=3410-3434                                          ; 17    KG.
D 23=3676-3722                                          ;       Externals
;   -- end of Jurisiction-to-TAZ equivalency --
ENDCOPY


RUN PGM=MATRIX
  ZONES=@ZONESIZE@
  MATI[1]= @HBWTDOUT@
  MATI[2]= @HBSTDOUT@
  MATI[3]= @HBOTDOUT@
  MATI[4]= @NHWTDOUT@
  MATI[5]= @NHOTDOUT@
  MATI[6]= @COMTDOUT@
  MATI[7]= @MTKTDOUT@
  MATI[8]= @HTKTDOUT@

  MW[1] = MI.1.1          ; HBW TRIP TABLE/TAZ-LEVEL
  MW[2] = MI.2.1          ; HBS TRIP TABLE/TAZ-LEVEL
  MW[3] = MI.3.1          ; HBO TRIP TABLE/TAZ-LEVEL
  MW[4] = MI.4.1          ; NHW TRIP TABLE/TAZ-LEVEL
  MW[5] = MI.5.1          ; NHO TRIP TABLE/TAZ-LEVEL
  MW[6] = MI.6.1          ; COM TRIP TABLE/TAZ-LEVEL
  MW[7] = MI.7.1          ; MTK TRIP TABLE/TAZ-LEVEL
  MW[8] = MI.8.1          ; HTK TRIP TABLE/TAZ-LEVEL

 ; -- PLACEMARKER TABLES - FUTURE WORK
  MW[11] = 0 ;                 HBW TRIP TABLE/TAZ-LEVEL
  MW[12] = 0 ;                 HBS TRIP TABLE/TAZ-LEVEL
  MW[13] = 0 ;                 HBO TRIP TABLE/TAZ-LEVEL
  MW[14] = 0 ;                 NHB TRIP TABLE/TAZ-LEVEL
  MW[15] = 0 ;                 NHB TRIP TABLE/TAZ-LEVEL
  MW[16] = 0 ;                 COM TRIP TABLE/TAZ-LEVEL
  MW[17] = 0 ;                 MTK TRIP TABLE/TAZ-LEVEL
  MW[18] = 0 ;                 HTK TRIP TABLE/TAZ-LEVEL

  FILEO MATO[1]  = HBW.SQZ MO=1,11 ; OUTPUT HBW TABLE(S), SQUEEZED
        MATO[2]  = HBS.SQZ MO=2,12 ; OUTPUT HBS TABLE(S), SQUEEZED
        MATO[3]  = HBO.SQZ MO=3,13 ; OUTPUT HBO TABLE(S), SQUEEZED
        MATO[4]  = NHW.SQZ MO=4,14 ; OUTPUT NHW TABLE(S), SQUEEZED
        MATO[5]  = NHO.SQZ MO=5,15 ; OUTPUT NHO TABLE(S), SQUEEZED
        MATO[6]  = COM.SQZ MO=6,16 ; OUTPUT COM TABLE(S), SQUEEZED
        MATO[7]  = MTK.SQZ MO=7,17 ; OUTPUT MTK TABLE(S), SQUEEZED
        MATO[8]  = HTK.SQZ MO=8,18 ; OUTPUT HTK TABLE(S), SQUEEZED

  ; renumber OUT.MAT according to DJ.EQV
  RENUMBER FILE=DJ.EQV, MISSINGZI=M, MISSINGZO=W
ENDRUN

;
LOOP PURP=1,8 ; Loop for Each Purpose
;
; Global Variables:
;   SQFNAME    Name of squeezed modal trip table(s)
;   DESCRIPT   Description
;   PURPOSE    Purpose
;   MODE       Mode
;   DCML       Decimal specification
;   TABTYPE    Table type(1/2), i.e.,-involves 1 or 2 trip tables
;   SCALE=1    Scale factor to be applied (if desired)
;   OPER='+'   Operation(if tabtype=2) Tab1(?)Tab2=Result
;
;
DESCRIPT    = 'SIMULATION-%_iter_% Itr Year: %_year_% Alt: %_alt_%'
IF (PURP=1)
  SQFNAME     = 'HBW.SQZ'
  PURPOSE     = 'HBW'
  MODE        = 'External PERSON'
  DCML        = 0
  TABTYPE     = 1
  SCALE       = 1
  OPER        = '+'
ELSEIF (PURP=2)
  SQFNAME     = 'HBS.SQZ'
  PURPOSE     = 'HBS'
  MODE        = 'External PERSON'
  DCML        = 0
  TABTYPE     = 1
  SCALE       = 1
  OPER        = '+'
ELSEIF (PURP=3)
  SQFNAME     = 'HBO.SQZ'
  PURPOSE     = 'HBO'
  MODE        = 'External PERSON'
  DCML        = 0
  TABTYPE     = 1
  SCALE       = 1
  OPER        = '+'
ELSEIF (PURP=4)
  SQFNAME     = 'NHW.SQZ'
  PURPOSE     = 'NHW'
  MODE        = 'External PERSON'
  DCML        = 0
  TABTYPE     = 1
  SCALE       = 1
  OPER        = '+'
ELSEIF (PURP=5)
  SQFNAME     = 'NHO.SQZ'
  PURPOSE     = 'NHO'
  MODE        = 'External PERSON'
  DCML        = 0
  TABTYPE     = 1
  SCALE       = 1
  OPER        = '+'
ELSEIF (PURP=6)
  SQFNAME     = 'COM.SQZ'
  PURPOSE     = 'COM'
  MODE        = 'External Comm. Veh.'
  DCML        = 0
  TABTYPE     = 1
  SCALE       = 1
  OPER        = '+'
ELSEIF (PURP=7)
  SQFNAME     = 'MTK.SQZ'
  PURPOSE     = 'MTK'
  MODE        = 'External Medium TRUCKS'
  DCML        = 0
  TABTYPE     = 1
  SCALE       = 1
  OPER        = '+'
ELSEIF (PURP=8)
  SQFNAME     = 'HTK.SQZ'
  PURPOSE     = 'HTK'
  MODE        = 'External Heavy TRUCKS'
  DCML        = 0
  TABTYPE     = 1
  SCALE       = 1
  OPER        = '+'
ENDIF
;
RUN PGM=MATRIX
  PAGEheight=32000
  ZONES=23
  FILEI MATI=@SQFNAME@
  ARRAY CSUM=23,CSUM1=23,CSUM2=23
; ---------------------------------------------------------------
; --  Table Cell Value decalaration or computation (in MW[1])
; ---------------------------------------------------------------

  FILLMW MW[1]=MI.1.1,2     ;    read input tables in MW 2,3

 IF (@TABTYPE@ = 2)
  FILLMW MW[2]=MI.1.1,2     ;    read input tables in MW 2,3
 ENDIF

  IF (@TABTYPE@=2)                                ; Cell Value
     JLOOP                                        ; computed for
      IF (MW[3][J]>0) MW[1]=MW[2]*@SCALE@@OPER@MW[3]; special summaries-
     ENDJLOOP                                     ; calculation in MW[1]
  ENDIF

; -----------------------------------------------------
; ---- ROW Marginal declaration or computation --------
; -----------------------------------------------------
  RSUM   =     ROWSUM(1)            ; 'normal' table- row summary value

  IF (@TABTYPE@=2)
         RSUM = @SCALE@*ROWSUM(2)@OPER@ROWSUM(3)  ; non-'normal' table
  ENDIF                                    ; compute the row marginal(%)

; -------------------------------------------------------
; ---- COLUMN/Total Marginal Accumulation            ----
; ---- The computation (if necessary) is done below  ----
; -------------------------------------------------------

  JLOOP                            ; COL/Total Accumulation
    CSUM[J] = CSUM[J] +  MW[1][J]  ; for 'normal' table
    TOTAL   = TOTAL   +  MW[1]     ;
  ENDJLOOP

IF (@TABTYPE@=2)
  JLOOP                              ; COL/Total Accumulation
    CSUM1[J] = CSUM1[J] +  MW[2][J]  ; for non-'normal' Table
    TOTAL1   = TOTAL1   +  MW[2]     ;
    CSUM2[J] = CSUM2[J] +  MW[3][J]  ;
    TOTAL2   = TOTAL2   +  MW[3]     ;
  ENDJLOOP
ENDIF

  IF (I==1)      ; print header

  PRINT LIST='/bt   ','@DESCRIPT@'
  PRINT LIST='      ','Purpose: ','@PURPOSE@','   MODE: ','@MODE@'
  PRINT LIST='      '

   PRINT LIST='           DESTINATION'
   PRINT LIST=' ORIGIN |',
              '      1','      2','      3','      4',
              '      5','      6','      7','      8','      9',
              '     10','     11','     12','     13','     14',
              '     15','     16','     17','     18','     19',
              '     20','     21','     22','     23',' |  TOTAL'



   PRINT LIST='==============',
              '==========================================',
              '==========================================',
              '==========================================',
              '======================================='


  ENDIF

  IF (I=1)
   CURDIST=STR(I,2,1)+' DC CR'+ '|' ; Make row header
  ELSEIF (I=2)
   CURDIST=STR(I,2,1)+' DC NC'+ '|' ; Make row header
  ELSEIF (I=3)
   CURDIST=STR(I,2,1)+' MTG  '+ '|' ; Make row header
  ELSEIF (I=4)
   CURDIST=STR(I,2,1)+' PG   '+ '|' ; Make row header
  ELSEIF (I=5)
   CURDIST=STR(I,2,1)+' ARLCR'+ '|' ; Make row header
  ELSEIF (I=6)
   CURDIST=STR(I,2,1)+' ARNCR'+ '|' ; Make row header
  ELSEIF (I=7)
   CURDIST=STR(I,2,1)+' ALX  '+ '|'; Make row header
  ELSEIF (I=8)
   CURDIST=STR(I,2,1)+' FFX  '+ '|' ; Make row header
  ELSEIF (I=9)
   CURDIST=STR(I,2,1)+' LDN  '+ '|' ; Make row header
  ELSEIF (I=10)
   CURDIST=STR(I,2,1)+' PW   '+ '|' ; Make row header
  ELSEIF (I=11)
   CURDIST=STR(I,2,1)+' FRD  '+ '|' ; Make row header
  ELSEIF (I=12)
   CURDIST=STR(I,2,1)+' CAR  '+ '|' ; Make row header
  ELSEIF (I=13)
   CURDIST=STR(I,2,1)+' HOW  '+ '|' ; Make row header
  ELSEIF (I=14)
   CURDIST=STR(I,2,1)+' AAR  '+ '|' ; Make row header
  ELSEIF (I=15)
   CURDIST=STR(I,2,1)+' CAL  '+ '|' ; Make row header
  ELSEIF (I=16)
   CURDIST=STR(I,2,1)+' STM  '+ '|' ; Make row header
  ELSEIF (I=17)
   CURDIST=STR(I,2,1)+' CHS  '+ '|' ; Make row header
  ELSEIF (I=18)
   CURDIST=STR(I,2,1)+' FAU  '+ '|' ; Make row header
  ELSEIF (I=19)
   CURDIST=STR(I,2,1)+' STA  '+ '|' ; Make row header
  ELSEIF (I=20)
   CURDIST=STR(I,2,1)+' CL/JF'+ '|' ; Make row header
  ELSEIF (I=21)
   CURDIST=STR(I,2,1)+' SP/FB'+ '|' ; Make row header
  ELSEIF (I=22)
   CURDIST=STR(I,2,1)+' KGEO '+ '|' ; Make row header
  ELSEIF (I=23)
   CURDIST=STR(I,2,1)+' EXTL '+ '|' ; Make row header
  ELSE  ; (I=24)
   CURDIST=STR(I,2,1)+' TOTAL'+ '|' ; Make row header
  ENDIF

  PRINT FORM=7.@DCML@ LIST=CURDIST, MW[1][1],MW[1][2],MW[1][3],MW[1][4],MW[1][5],
                    MW[1][6],MW[1][7],MW[1][8],MW[1][9],MW[1][10],
                    MW[1][11],MW[1][12],MW[1][13],MW[1][14],MW[1][15],
                    MW[1][16],MW[1][17],MW[1][18],MW[1][19],MW[1][20],
                    MW[1][21],MW[1][22],MW[1][23],' |',RSUM

  IF (I==ZONES)
; Now at the end of Processed zone matrix
;  Do final Column/Grand Total Computations
     IF (@TABTYPE@=2)
       LOOP IDX = 1,ZONES
            IF (CSUM2[IDX] = 0)
                 CSUM[IDX] = 0
            ELSE
                 CSUM[IDX] = @SCALE@* CSUM1[IDX] @OPER@ CSUM2[IDX]
            ENDIF
       ENDLOOP
     ENDIF
     IF (@TABTYPE@=2 )
            IF (TOTAL2 = 0)
                TOTAL  = 0
            ELSE
                TOTAL  = @SCALE@ *TOTAL1 @OPER@ TOTAL2
            ENDIF
     ENDIF

;  End of final Column/Grand Total Computations

   PRINT LIST='==============',
              '==========================================',
              '==========================================',
              '==========================================',
              '======================================='


    PRINT FORM=8.@DCML@,
    LIST=' TOTAL ',' ',CSUM[1],'      ' ,CSUM[3],
    '      ',CSUM[5],'      ',CSUM[7],'      ',CSUM[9],
    '      ',CSUM[11],'      ',CSUM[13],'      ',CSUM[15],
    '      ',CSUM[17],'      ',CSUM[19],'      ',CSUM[21],
    '      ',CSUM[23],' |'
    PRINT FORM=8.@DCML@,
    LIST='/et            ',CSUM[2],
    '      ' ,CSUM[4],'      ',CSUM[6],'      ',CSUM[8],
    '      ',CSUM[10],'      ',CSUM[12],'      ',CSUM[14],
    '      ',CSUM[16],'      ',CSUM[18],'      ',CSUM[20],
    '      ',CSUM[22],'       ',TOTAL(9.@DCML@)


 ENDIF
ENDRUN

ENDLOOP ; End Loop
