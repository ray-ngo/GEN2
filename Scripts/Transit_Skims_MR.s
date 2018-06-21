;---------------------------------------------------------------------------
;Transit_Skims_MR.s
;MWCOG Version 2.2 Model
;                        - PATHSTYLE changed from 1 to 0 on 3.9.04 (RM)
;                        - iteration (_iter_) global variables used
;Build Transit Skims by Time Period and Access Mode
; Input Files:
;  TP+ Highway Network          = ZONEHWY.NET
;  Transit Line Files           = MODE?_pp.TB
;  Transit Network Data         = MET_*.TB, COM_*.TB, BUS_*.TB
;  Walk and Drive Access        = WALKACC.TB, *_PNR_pp.TB
;  Walk Sidewalk Network        = SIDEWALK.ASC
; Output Files:
;  Walk and Drive Access Skims  = pp_aa_mo.SKM
;  Walk and Drive Station Data  = pp_aa_mo.STA
;
; Step 1: AM Peak Walk Skims
;  Input Files: ZONEHWY.NET, MODE?_AM.TB, *.TB
;  Output Files: transit.temp.mr.skm
; Step 2: Condition & Split Skims into Multiple Files
;  Input Files: transit.temp.mr.skm
;  Output Files: %_iter_%_AM_WK_MR.SKM, %_iter_%_AM_WK_MR.STA,
; Step 3: AM Peak Drive Skims
;  Input Files: ZONEHWY.NET, MODE?_AM.TB, *.TB
;  Output Files: transit.temp.mr.skm
; Step 4: Condition & Split Skims into Multiple Files
;  Input Files: transit.temp.mr.skm
;  Output Files: %_iter_%_AM_DR_MR.SKM, %_iter_%_AM_DR_MR.STA,
; Step 5: AM Peak K/R Skims
;  Input Files: ZONEHWY.NET, MODE?_AM.TB, *.TB
;  Output Files: transit.temp.mr.skm
; Step 6: Condition & Split Skims into Multiple Files
;  Input Files: transit.temp.mr.skm
;  Output Files: %_iter_%_AM_KR_MR.SKM, %_iter_%_AM_KR_MR.STA,
; Step 7: Off Peak Walk Skims
;  Input Files: ZONEHWY.NET, MODE?_OP.TB, *.TB
;  Output Files: transit.temp.mr.skm
; Step 8: Condition & Split Skims into Multiple Files
;  Input Files: transit.temp.mr.skm
;  Output Files: %_iter_%_OP_WK_MR.SKM, %_iter_%_OP_WK_MR.STA,
; Step 9: Off Peak Drive Skims
;  Input Files: ZONEHWY.NET, MODE?_OP.TB, *.TB
;  Output Files: transit.temp.mr.skm
; Step 10: Condition & Split Skims into Multiple Files
;  Input Files: transit.temp.mr.skm
;  Output Files: %_iter_%_OP_DR_MR.SKM, %_iter_%_OP_DR_MR.STA
; Step 11: Off Peak K/R Skims
;  Input Files: ZONEHWY.NET, MODE?_OP.TB, *.TB
;  Output Files: transit.temp.mr.skm
; Step 12: Condition & Split Skims into Multiple Files
;  Input Files: transit.temp.mr.skm
;  Output Files: %_iter_%_OP_KR_MR.SKM, %_iter_%_OP_KR_MR.STA,
;
;---------------------------------------------------------------------------
; rm  4/7/08                      ;
; Added  table #19 (Total Transit time in min.) to output transit.temp.mr.skm file
; create total transit time skims named:                                  
;         %_iter_%_@TIME_PERIOD@_@ACCESS_MODE@_MR.ttt                   

;
;  useIdp = t (true) or f (false);  this is set in the wrapper batch file
distribute intrastep=%useIdp% multistep=%useMdp%
;
;  Read in time factors to increase local bus times
;  based on increasing arterial hwy congestion


;---------------------------------------------------------------------------
;	Loop through each period and access mode
;---------------------------------------------------------------------------
pageheight=32767  ; Preclude header breaks
LOOP PERIOD=1,2

 IF (PERIOD = 1)
  TIME_PERIOD = 'AM'
  COMBINE = 5.0
 ELSE
  TIME_PERIOD = 'OP'
  COMBINE = 10.0
 ENDIF

;---- start the access mode loop ----

LOOP ACCESS=1,3

  IF (ACCESS = 1)
   ACCESS_MODE = 'WK'
   WALK_MODEL = ' '
   DRIVE_MODEL = ';'
   KR_MODEL = ';'
  ELSEIF (ACCESS = 2)
   ACCESS_MODE = 'DR'
   WALK_MODEL = ';'
   DRIVE_MODEL = ' '
   KR_MODEL = ';'
  ELSE
   ACCESS_MODE = 'KR'
   WALK_MODEL = ';'
   DRIVE_MODEL = ';'
   KR_MODEL = ' '
  ENDIF

;---------------------------------------------------------------------------
; Step 1, 3, 5 & 7 Build Transit Path
;---------------------------------------------------------------------------

RUN PGM=TRNBUILD
 NETI = ZONEHWY.NET
 MATO = transit.temp.mr.skm
 maxnode = 60000

 HWYTIME = @TIME_PERIOD@HTIME

;--- set default zone access and line parameters ----

ZONEACCESS  GENERATE=N

@WALK_MODEL@ACCESSMODES = 14,16
@DRIVE_MODEL@ACCESSMODES = 11
@KR_MODEL@ACCESSMODES = 11

@WALK_MODEL@SKIPMODES = 11,15

PATHSTYLE  = 0
USERUNTIME = Y

;---- rules for combining multiple line and headways ----

COMBINE MAXDIFF[1] = 0.0, IF[1] = ((RUN - MINRUN) < @COMBINE@)
COMBINE MAXDIFF[2] = 0.0, IF[2] = ((RUN - MINRUN) < @COMBINE@)
COMBINE MAXDIFF[3] = 0.0, IF[3] = ((RUN - MINRUN) < @COMBINE@)
COMBINE MAXDIFF[4] = 0.0, IF[4] = ((RUN - MINRUN) < @COMBINE@)
COMBINE MAXDIFF[5] = 0.0, IF[5] = ((RUN - MINRUN) < @COMBINE@)
COMBINE MAXDIFF[6] = 0.0, IF[6] = ((RUN - MINRUN) < @COMBINE@)
COMBINE MAXDIFF[7] = 0.0, IF[7] = ((RUN - MINRUN) < @COMBINE@)
COMBINE MAXDIFF[8] = 0.0, IF[8] = ((RUN - MINRUN) < @COMBINE@)
COMBINE MAXDIFF[9] = 0.0, IF[9] = ((RUN - MINRUN) < @COMBINE@)
COMBINE MAXDIFF[10] = 0.0, IF[10] = ((RUN - MINRUN) < @COMBINE@)

;---- factors to convert actual time to perceived time ----

MODEFAC[1]  = 10*1.0  ;---- in-vehicle time
MODEFAC[11] = 1.50    ;---- drive access time
MODEFAC[12] = 2.00    ;---- transit transfer time
MODEFAC[13] = 2.00    ;---- walk network time
MODEFAC[14] = 2.00    ;---- unused (used to be dummy link to station)
MODEFAC[15] = 2.50    ;---- park-&-ride transfer time
MODEFAC[16] = 2.00    ;---- walk access time

;---- initial and transfer wait factors ----

IWAITFAC[1] = 10*2.50
XWAITFAC[1] = 10*2.50
IWAITMAX[1] = 10*60.0
XWAITMIN[1] = 2*4.0,0.0,4.0,0.0,3*4.0,10.0,4.0

;---- boarding and transfer penalties ----

XPEN[1]= 2*5.0,3*2.0,5*5.0, 6*0.0
XPEN[2]= 2*5.0,3*2.0,5*5.0, 6*0.0
XPEN[3]= 2*5.0, 0.0, 2*2.0,5*5.0, 6*0.0
XPEN[4]= 2*5.0,3*2.0,5*5.0, 6*0.0
XPEN[5]= 2*5.0,3*2.0,5*5.0, 6*0.0
XPEN[6]= 2*5.0,3*2.0,5*5.0, 6*0.0
XPEN[7]= 2*5.0,3*2.0,5*5.0, 6*0.0
XPEN[8]= 2*5.0,3*2.0,5*5.0, 6*0.0
XPEN[9]= 2*5.0,3*2.0,5*5.0, 6*0.0
XPEN[10]= 2*5.0,3*2.0,5*5.0, 6*0.0
XPEN[11]= 2*5.0,3*2.0,5*5.0, 6*0.0
XPEN[12]= 2*8.0,3*2.0,4*8.0,5.0, 6*0.0
XPEN[13]= 2*5.0,3*2.0,5*5.0, 6*0.0
XPEN[14]= 2*5.0,3*2.0,5*5.0, 6*0.0
XPEN[15]= 2*5.0,3*2.0,5*5.0, 6*0.0
XPEN[16]= 2*5.0,3*2.0,5*5.0, 6*0.0

XPENFAC[1]= 16*2.50
XPENFAC[2]= 16*2.50
XPENFAC[3]= 16*2.50
XPENFAC[4]= 16*2.50
XPENFAC[5]= 16*2.50
XPENFAC[6]= 16*2.50
XPENFAC[7]= 16*2.50
XPENFAC[8]= 16*2.50
XPENFAC[9]= 16*2.50
XPENFAC[10]= 16*2.50
XPENFAC[11]= 16*2.50
XPENFAC[12]= 16*2.50
XPENFAC[13]= 16*2.50
XPENFAC[14]= 16*2.50
XPENFAC[15]= 16*2.50
XPENFAC[16]= 16*2.50


;---- transfer prohibitions ----

;--- mode  1,  2,  3,  4,  5,  6,  7,  8,  9, 10, 11, 12, 13, 14, 15, 16
NOX[1]  =  n,  n,  n,  n,  n,  n,  n,  Y,  Y,  n,  Y,  n,  n,  n,  Y,  n
NOX[2]  =  n,  n,  n,  n,  n,  n,  n,  Y,  Y,  n,  Y,  n,  n,  n,  Y,  n
NOX[3]  =  n,  n,  n,  n,  n,  n,  n,  Y,  Y,  n,  Y,  n,  n,  n,  Y,  n
NOX[4]  =  n,  n,  n,  n,  n,  n,  n,  Y,  Y,  n,  Y,  n,  n,  n,  Y,  n
NOX[5]  =  n,  n,  n,  n,  n,  n,  n,  Y,  Y,  n,  Y,  n,  n,  n,  Y,  n
NOX[6]  =  n,  n,  n,  n,  n,  n,  n,  Y,  Y,  n,  Y,  n,  n,  n,  Y,  n
NOX[7]  =  n,  n,  n,  n,  n,  n,  n,  Y,  Y,  n,  Y,  n,  n,  n,  Y,  n
NOX[8]  =  n,  n,  n,  n,  n,  n,  n,  n,  n,  n,  Y,  n,  n,  n,  Y,  n
NOX[9]  =  n,  n,  n,  n,  n,  n,  n,  n,  n,  n,  Y,  n,  n,  n,  Y,  n
NOX[10] =  n,  n,  n,  n,  n,  n,  n,  Y,  Y,  n,  Y,  n,  n,  n,  Y,  n
NOX[11] =  n,  n,  n,  n,  n,  n,  n,  n,  n,  n,  Y,  Y,  n,  Y,  n,  n
NOX[12] =  n,  n,  n,  n,  n,  n,  n,  n,  n,  n,  Y,  Y,  n,  n,  Y,  n
NOX[13] =  n,  n,  n,  n,  n,  n,  n,  n,  n,  n,  Y,  n,  n,  n,  Y,  n
NOX[14] =  n,  n,  n,  n,  n,  n,  n,  n,  n,  n,  Y,  n,  n,  n,  Y,  n
NOX[15] =  n,  n,  n,  n,  n,  n,  n,  n,  n,  n,  Y,  Y,  Y,  Y,  Y,  Y
NOX[16] =  n,  n,  n,  n,  n,  n,  n,  n,  n,  n,  Y,  n,  n,  n,  Y,  Y

;---- Parameters ----

LISTINPUT = N         ;--- echo input files

MAXPATHTIME = 360.0   ;--- Kill any path with preceived time > 240 min.
FREQPERIOD = 1        ;--- Use the First Headway value 		
USERUNTIME = Y        ;--- Ignore any RUNTIME or RT parameters on lines.
MAXRUNTIME = 240.0    ;--- Report lines with run times > 240 min.
;ONLINE = 100          ;--- Display every 100 lines

;WALKSPEED = 3.0       ;--- Set default walk speed to 3.0 mph
;XYFACTOR = 0.84401    ;--- Replicate MINUTP value
;WALKSPEED = 2.0       ;--- Added on 09/25
;XYFACTOR = 1.97       ;--- Added on 09/25

;--------------------------
;  write out support links for later viewing in VIPER
fileo supporto = supl_@time_period@_@access_mode@_mr.asc modes=11-16 oneway=t fixed=y
fileo nodeo    = supn_@time_period@_@access_mode@_mr.dbf
fileo linko    = trnl_@time_period@_@access_mode@_mr.dbf   ; Can be used to create transit shapefile
;

;---- specify output skims ----

MATRICES NAME = IVT_LBUS, IVT_XBUS, IVT_MET, IVT_CR, IVT_LRT, IVT_BRT, IWAIT, 
                XWAIT, WK_AC_T, OTH_WK_T, X_PEN, BOARDS, DR_AC_T, DR_AC_D, 
                PNR_IMP, PNR_CST, I_STA, J_STA,
 MW[1] = TIME(1,6,8),                        ;---- ivt-local bus    (0.01 min)
 MW[2] = TIME(2,7,9),                        ;---- ivt-exp bus      (0.01 min)
 MW[3] = TIME(3),                            ;---- ivt-metrorail    (0.01 min)
 MW[4] = TIME(4),                            ;---- ivt-commuter rail(0.01 min)
 MW[5] = TIME(5),                            ;---- ivt-new rail mode(0.01 min)
 MW[6] = TIME(10),                           ;---- ivt-new bus mode (0.01 min)
 MW[7] = IWAIT,                              ;---- ini.wait time    (0.01 min)
 MW[8] = XWAIT(1,2,3,4,5,6,7,8,9,10),        ;---- xfr wait time    (0.01 min)
 MW[9] = TIME(14,16),                        ;---- walk acc time    (0.01 min)
 MW[10] = TIME(12,13),                       ;---- other walk time  (0.01 min)
 MW[11] = XPEN,                              ;---- added xfer time  (0.01 min)
 MW[12] = BOARDS,                            ;---- boardings        (1+)
 MW[13] = TIME(11),                          ;---- drv acc time     (0.01 min)
 MW[14] = DIST(11),                          ;---- drv acc distance (0.01 mile)
 MW[15] = TIME(15),                          ;---- pnr impedance    (0.01 min)
 MW[16] = DIST(15),                          ;---- pnr cost         (cents)
 MW[17] = NODE0(3) - 8000.0,                 ;---- metro board  sta (1-150)
 MW[18] = NODEL(3) - 8000.0                  ;---- metro alight sta (1-150)



;---- Rail Stations & Links (modes 3 & 4) ----

READ FILE = met_node.tb   ;---- Metrorail stations
READ FILE = met_link.tb   ;---- Metrorail links
;READ FILE = com_node.tb   ;---- Commuter Rail stations
;READ FILE = com_link.tb   ;---- Commuter Rail links
READ FILE = lrt_node.tb   ;---- LRT stations
READ FILE = lrt_link.tb   ;---- LRT links
;READ FILE = new_node.tb   ;---- Mode10 Stations
;READ FILE = new_link.tb   ;---- Mode10 links
;---- Park and Ride Lots (mode 15) ----

;@DRIVE_MODEL@ READ FILE = bus_pnrn.tb  ;---- Bus PNR lots (nodes)
@DRIVE_MODEL@ READ FILE = met_pnrn.tb  ;---- Metro PNR lots (nodes)
;@DRIVE_MODEL@ READ FILE = com_pnrn.tb  ;---- Commuter Rail PNR lots (nodes)
@DRIVE_MODEL@ READ FILE = lrt_pnrn.tb  ;---- LRT PNR lots (nodes)
;@DRIVE_MODEL@ READ FILE = new_pnrn.tb  ;---- Mode10 PNR lots (nodes)

;@DRIVE_MODEL@ READ FILE = bus_@TIME_PERIOD@_pnr.tb  ;---- Bus-PNR connectors (links)
@DRIVE_MODEL@ READ FILE = met_@TIME_PERIOD@_pnr.tb  ;---- Metro-PNR connectors (links)
;@DRIVE_MODEL@ READ FILE = com_@TIME_PERIOD@_pnr.tb  ;---- Commuter Rail-PNR connectors (links)
@DRIVE_MODEL@ READ FILE = lrt_@TIME_PERIOD@_pnr.tb  ;---- LRT-PNR connectors (links)
;@DRIVE_MODEL@ READ FILE = new_@TIME_PERIOD@_pnr.tb  ;---- Mode10-PNR connectors (links)

;---- Access Links (modes 11, 12 and 16) ----

READ FILE = met_bus.tb   ;--- bus-metro links&xfer cards
;READ FILE = com_bus.tb   ;--- bus-commuter rail links&xfer car
READ FILE = lrt_bus.tb   ;--- bus-LRT links&xfer car
;READ FILE = new_bus.tb   ;--- Mode10 bus-LRT links&xfer car

READ FILE = walkacc.asc ;--- walk to local transit

@DRIVE_MODEL@READ FILE = met_@TIME_PERIOD@_pnr.asc;--- drive to metrorail
;@DRIVE_MODEL@READ FILE = com_@TIME_PERIOD@.asc;--- drive to Commuter rail
;@DRIVE_MODEL@READ FILE = bus_@TIME_PERIOD@_pnr.asc;--- drive to bus
@DRIVE_MODEL@READ FILE = lrt_@TIME_PERIOD@_pnr.asc;--- drive to LRT
;@DRIVE_MODEL@READ FILE = new@TIME_PERIOD@.asc;--- drive to Mode10

@KR_MODEL@READ FILE = met_@TIME_PERIOD@_knr.asc;--- k/r to metrorail
;KR_MODEL@READ FILE = bus_@TIME_PERIOD@_knr.asc;--- k/r to bus
@KR_MODEL@READ FILE = lrt_@TIME_PERIOD@_knr.asc;--- k/r to LRT
;@KR_MODEL@READ FILE = new_@TIME_PERIOD@_knr.asc;--- k/r to Mode10

@KR_MODEL@ READ FILE = lrt_@TIME_PERIOD@_pnr.tb  ;---- LRT-PNR connectors (links)

;---- Dummy Centroid Access Links (mode 14) ----

;---- Sidewalk Network (mode 13) ----

READ FILE = sidewalk.asc;--- walk network for transfers

;---- Transit Line Cards (modes 1-10) ----

;READ FILE = MODE1@TIME_PERIOD@.TB  ;---- M1- metrobus local
;READ FILE = MODE2@TIME_PERIOD@.TB  ;---- M2- metrobus express
READ FILE = MODE3@TIME_PERIOD@.TB  ;---- M3- metrorail
;READ FILE = MODE4@TIME_PERIOD@.TB  ;---- M4- commuter rail
READ FILE = MODE5@TIME_PERIOD@.TB  ;---- M5- other rail (future)
;READ FILE = MODE6@TIME_PERIOD@.TB  ;---- M6- other local bus
;READ FILE = MODE7@TIME_PERIOD@.TB  ;---- M7- other express bus
;READ FILE = MODE8@TIME_PERIOD@.TB  ;---- M8- other local bus
;READ FILE = MODE9@TIME_PERIOD@.TB  ;---- M9- other express bus
;READ FILE = MODE10@TIME_PERIOD@.TB  ;---- M10- other bus (future)

/* Transit path traces for select i/j pairs */
read file = ..\scripts\pathTrace.s

ENDRUN
;---------------------------------------------------------------------------
;Step 2, 4, 6 & 8 Condition & Split Skims into Multiple Files
;---------------------------------------------------------------------------
RUN PGM=MATRIX
; If we keep IDP here, we will need 16 cores, so we have commented it out
;@dp_token@distributeIntrastep processId='mwcog', ProcessList=%subnode%
 MATI[1]=transit.temp.mr.skm
 MATO[1]=%_iter_%_@TIME_PERIOD@_@ACCESS_MODE@_MR.SKM, MO = 1-16,
  NAME = IVT_LBUS, IVT_XBUS, IVT_MET, IVT_CR, IVT_LRT, IVT_BRT, IWAIT, XWAIT, 
         WK_AC_T, OTH_WK_T, X_PEN, BOARDS, DR_AC_T, DR_AC_D, PNR_IMP, PNR_CST

 MATO[2]=%_iter_%_@TIME_PERIOD@_@ACCESS_MODE@_MR.STA, MO = 17-18,
  NAME = I_STA, J_STA

 MATO[3]=%_iter_%_@TIME_PERIOD@_@ACCESS_MODE@_MR.ttt, MO = 100,                ;
  NAME = sumtrntm

MW[1] = MI.1.1    ;---- ivt-local bus    (0.01 min)
MW[2] = MI.1.2    ;---- ivt-exp bus      (0.01 min)
MW[3] = MI.1.3    ;---- ivt-metrorail    (0.01 min)
MW[4] = MI.1.4    ;---- ivt-commuter rail(0.01 min)
MW[5] = MI.1.5    ;---- ivt-new rail mode(0.01 min)
MW[6] = MI.1.6    ;---- ivt-new bus mode (0.01 min)
MW[7] = MI.1.7    ;---- ini.wait time    (0.01 min)
MW[8] = MI.1.8    ;---- xfr wait time    (0.01 min)
MW[9] = MI.1.9    ;---- walk acc time    (0.01 min)
MW[10] = MI.1.10  ;---- other walk time  (0.01 min)
MW[11] = MI.1.11  ;---- added xfer time  (0.01 min)
MW[12] = MI.1.12  ;---- transfers        (0+)
MW[13] = MI.1.13  ;---- drv acc time     (0.01 min)
MW[14] = MI.1.14  ;---- drv acc distance (0.01 mile)
MW[15] = MI.1.15  ;---- pnr time         (0.01 min)
MW[16] = MI.1.16  ;---- pnr cost         (cents)

MW[17] = MI.1.17  ;---- metro board  sta (1-150)
MW[18] = MI.1.18  ;---- metro alight sta (1-150)
                                                                               ;4
                                                                               ;
                                                                               ;

JLOOP
 IF ((MW[3]+MW[5] = 0) || (MW[1]+MW[2]+MW[6] > 0))
  MW[1] = 0
  MW[2] = 0
  MW[3] = 0
  MW[4] = 0
  MW[5] = 0
  MW[6] = 0
  MW[7] = 0
  MW[8] = 0
  MW[9] = 0
  MW[10] = 0
  MW[11] = 0
  MW[12] = 0
  MW[13] = 0
  MW[14] = 0
  MW[15] = 0
  MW[16] = 0
  MW[17] = 0
  MW[18] = 0
 ELSE
  MW[12] = MW[12] - 1
  IF (MW[16] = 1 ) MW[16] = 0
  MW[15] = MW[15] - MW[16] * 6.0
  IF (MW[17] < 0 || MW[17] > 150 ) MW[17] = 0
  IF (MW[18] < 0 || MW[18] > 150 ) MW[18] = 0
 ENDIF
ENDJLOOP

MW[100] =(MW[1]  +  MW[2]  +  MW[3]  +  MW[4] +  MW[5]   +
          MW[6]  +  MW[7]  +  MW[8]  +  MW[9] +  MW[10]  +
          MW[11] +  MW[13]) * 0.01   ;; Total Real Transit Time  in Whole Minutes (not incl. PNR 'impedance')


ENDRUN

ENDLOOP ;---- ACCESS ----
ENDLOOP ;---- PERIOD ----
