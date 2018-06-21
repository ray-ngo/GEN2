;---------------------------------------------------------------------------
;Transit_Assignment_BM.s
;TPB Version 2.3 travel model on the 3,722-TAZ area system
;                        - PATHSTYLE changed from 1 to 0 on 3.9.04 (RM)
;                        - iteration (_iter_) global variables used
;Assign Transit Trips by Time Period and Access Mode
; Input Files:
;  Cube Voyager Highway Network = ZONEHWY.NET
;  Transit Line Files           = MODE[1-10][AM|OP].TB
;  Transit Network Data         = MET_*.TB, COM_*.TB, BUS_*.TB
;  Walk and Drive Access        = WALKACC.TB, *_PNR_pp.TB
;  Walk Sidewalk Network        = SIDEWALK.ASC
;  Transit Trip Tables          = '%_iter_%_AMMS.TRP', '%_iter_%_OPMS.TRP'
; Output Files:
;  Transit Assignment Link and Node Files
;
; Step 1: AM Peak Walk Assignment
;  Input Files: ZONEHWY.NET, MODE?_AM.TB, *.TB, '%_iter_%_AMMS.TRP'
;  Output Files: WKBMAMnode.dbf; WKBMAMlink.dbf
; Step 2: AM Peak Drive Assignment
;  Input Files: ZONEHWY.NET, MODE?_AM.TB, *.TB, '%_iter_%_AMMS.TRP'
;  Output Files: DRBMAMnode.dbf; DRBMAMlink.dbf
; Step 3: AM Peak K/R Assignment
;  Input Files: ZONEHWY.NET, MODE?_AM.TB, *.TB, '%_iter_%_AMMS.TRP'
;  Output Files: KRBMAMnode.dbf; KRBMAMlink.dbf
; Step 4: Off Peak Walk Assignment
;  Input Files: ZONEHWY.NET, MODE?_OP.TB, *.TB, '%_iter_%_OPMS.TRP'
;  Output Files: WKBMOPnode.dbf; WKBMOPlink.dbf
; Step 5: Off Peak Drive Assignment
;  Input Files: ZONEHWY.NET, MODE?_OP.TB, *.TB, '%_iter_%_OPMS.TRP'
;  Output Files: DRBMOPnode.dbf; DRBMOPlink.dbf
; Step 6: Off Peak K/R Assignment
;  Input Files: ZONEHWY.NET, MODE?_OP.TB, *.TB, '%_iter_%_OPMS.TRP'
;  Output Files: KRBMOPnode.dbf; KRBMOPlink.dbf
;---------------------------------------------------------------------------

;  Read in time factors to increase local bus times
;  based on increasing arterial hwy congestion 

pageheight=32767  ; Preclude header breaks

;---------------------------------------------------------------------------
; Loop through each period and access mode
;---------------------------------------------------------------------------

LOOP PERIOD = 1, 2

 IF (PERIOD = 1)
  TIME_PERIOD = 'AM'
  COMBINE = 5.0

  MATIN='%_iter_%_AMMS.TRP'
  AM=' '
  OP=';'
 ELSE
  TIME_PERIOD = 'OP'
  COMBINE = 10.0

  MATIN='%_iter_%_OPMS.TRP'
  AM=';'
  OP=' '
 ENDIF

;---- start the access mode loop ----

LOOP ACCESS = 1,3

  IF (ACCESS = 1)
   ACCESS_MODE = 'WK'
   WALK_MODEL = ' '
   DRIVE_MODEL = ';'
   KR_MODEL = ';'
   TABIN = 'MI.1.3'
  ELSEIF (ACCESS = 2)
   ACCESS_MODE = 'DR'
   WALK_MODEL = ';'
   DRIVE_MODEL = ' '
   KR_MODEL = ';'
   TABIN = 'MI.1.8'
  ELSE
   ACCESS_MODE = 'KR'
   WALK_MODEL = ';'
   DRIVE_MODEL = ';'
   KR_MODEL = ' '
   TABIN = 'MI.1.9'
  ENDIF

;---------------------------------------------------------------------------
; Step 1, 2, 3 , 4, 5 & 6 Assign Bus/MR Transit Trips
;---------------------------------------------------------------------------

RUN PGM=TRNBUILD
 NETI = ZONEHWY.NET
 MATI = @MATIN@
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
fileo supporto = supl_BM_@access_mode@_@time_period@.asc modes=11-16 oneway=t fixed=y
;

;---- Rail Stations & Links (modes 3 & 4) ----

READ FILE = met_node.tb   ;---- Metrorail stations
READ FILE = met_link.tb   ;---- Metrorail links
;READ FILE = com_node.tb   ;---- Commuter Rail stations
;READ FILE = com_link.tb   ;---- Commuter Rail links
READ FILE = lrt_node.tb   ;---- LRT stations
READ FILE = lrt_link.tb   ;---- LRT links
READ FILE = new_node.tb   ;---- Mode10 Stations
READ FILE = new_link.tb   ;---- Mode10 links

;---- Park and Ride Lots (mode 15) ----

@DRIVE_MODEL@ READ FILE = bus_pnrn.tb  ;---- Bus PNR lots (nodes)
@DRIVE_MODEL@ READ FILE = met_pnrn.tb  ;---- Metro PNR lots (nodes)
;@DRIVE_MODEL@ READ FILE = com_pnrn.tb  ;---- Commuter Rail PNR lots (nodes)
@DRIVE_MODEL@ READ FILE = lrt_pnrn.tb  ;---- LRT PNR lots (nodes)
@DRIVE_MODEL@ READ FILE = new_pnrn.tb  ;---- Mode10 PNR lots (nodes)

@DRIVE_MODEL@ READ FILE = bus_@TIME_PERIOD@_pnr.tb  ;---- Bus-PNR connectors (links)
@DRIVE_MODEL@ READ FILE = met_@TIME_PERIOD@_pnr.tb  ;---- Metro-PNR connectors (links)
;@DRIVE_MODEL@ READ FILE = com_@TIME_PERIOD@.tb  ;---- Commuter Rail-PNR connectors (links)
@DRIVE_MODEL@ READ FILE = lrt_@TIME_PERIOD@_pnr.tb  ;---- LRT-PNR connectors (links)
@DRIVE_MODEL@ READ FILE = new_@TIME_PERIOD@_pnr.tb  ;---- Mode10-PNR connectors (links)

;---- Access Links (modes 11, 12 and 16) ----

READ FILE = met_bus.tb   ;--- bus-metro links&xfer cards
;READ FILE = com_bus.tb   ;--- bus-commuter rail links&xfer car
READ FILE = lrt_bus.tb   ;--- bus-LRT links&xfer car
READ FILE = new_bus.tb   ;--- Mode10 bus-LRT links&xfer car

READ FILE = walkacc.asc ;--- walk to local transit

@DRIVE_MODEL@READ FILE = met_@TIME_PERIOD@_pnr.asc;--- drive to metrorail
;@DRIVE_MODEL@READ FILE = com_@TIME_PERIOD@.asc;--- drive to Commuter rail
@DRIVE_MODEL@READ FILE = bus_@TIME_PERIOD@_pnr.asc;--- drive to bus
@DRIVE_MODEL@READ FILE = lrt_@TIME_PERIOD@_pnr.asc;--- drive to LRT
@DRIVE_MODEL@READ FILE = new_@TIME_PERIOD@_pnr.asc;--- drive to Mode10

@KR_MODEL@READ FILE = met_@TIME_PERIOD@_knr.asc;--- k/r to metrorail
@KR_MODEL@READ FILE = bus_@TIME_PERIOD@_knr.asc;--- k/r to bus
@KR_MODEL@READ FILE = lrt_@TIME_PERIOD@_knr.asc;--- k/r to LRT
@KR_MODEL@READ FILE = new_@TIME_PERIOD@_knr.asc;--- k/r to Mode10

@KR_MODEL@ READ FILE = lrt_@TIME_PERIOD@_pnr.tb  ;---- LRT-PNR connectors (links)
@KR_MODEL@ READ FILE = new_@TIME_PERIOD@_pnr.tb  ;---- Mode10-PNR connectors (links)
@KR_MODEL@ READ FILE = bus_@TIME_PERIOD@_pnr.tb  ;---- Bus-PNR connectors (links)

;---- Dummy Centroid Access Links (mode 14) ----

;---- Sidewalk Network (mode 13) ----

READ FILE = sidewalk.asc;--- walk network for transfers

;---- Transit Line Cards (modes 1-10) ----

READ FILE = MODE1@TIME_PERIOD@.TB  ;---- M1- metrobus local
READ FILE = MODE2@TIME_PERIOD@.TB  ;---- M2- metrobus express
READ FILE = MODE3@TIME_PERIOD@.TB  ;---- M3- metrorail
;READ FILE = MODE4@TIME_PERIOD@.TB  ;---- M4- commuter rail
READ FILE = MODE5@TIME_PERIOD@.TB  ;---- M5- other rail (future)
READ FILE = MODE6@TIME_PERIOD@.TB  ;---- M6- other local bus
READ FILE = MODE7@TIME_PERIOD@.TB  ;---- M7- other express bus
READ FILE = MODE8@TIME_PERIOD@.TB  ;---- M8- other local bus
READ FILE = MODE9@TIME_PERIOD@.TB  ;---- M9- other express bus
READ FILE = MODE10@TIME_PERIOD@.TB  ;---- M10- other bus (future)

; output files
@WALK_MODEL@@AM@FILEO NODEO  = %_iter_%_WKBMAMnode.dbf ; output node file
@WALK_MODEL@@OP@FILEO NODEO  = %_iter_%_WKBMOPnode.dbf ; output node file
@DRIVE_MODEL@@AM@FILEO NODEO = %_iter_%_DRBMAMnode.dbf ; output node file
@DRIVE_MODEL@@OP@FILEO NODEO = %_iter_%_DRBMOPnode.dbf ; output node file
@KR_MODEL@@AM@FILEO NODEO    = %_iter_%_KRBMAMnode.dbf ; output node file
@KR_MODEL@@OP@FILEO NODEO    = %_iter_%_KRBMOPnode.dbf ; output node file ; Added "O" to filename

@WALK_MODEL@@AM@FILEO LINKO  = %_iter_%_WKBMAMlink.dbf ; output link file
@WALK_MODEL@@OP@FILEO LINKO  = %_iter_%_WKBMOPlink.dbf ; output link file
@DRIVE_MODEL@@AM@FILEO LINKO = %_iter_%_DRBMAMlink.dbf ; output link file
@DRIVE_MODEL@@OP@FILEO LINKO = %_iter_%_DRBMOPlink.dbf ; output link file
@KR_MODEL@@AM@FILEO LINKO    = %_iter_%_KRBMAMlink.dbf ; output link file
@KR_MODEL@@OP@FILEO LINKO    = %_iter_%_KRBMOPlink.dbf ; output link file

TRIPS MATRIX=@TABIN@, ASSIGN=Y, VOLUMES=Y, BOARDS=Y, EXITS=Y
REPORT LINKVOL=Y,LINEVOL=Y

ENDRUN

ENDLOOP ;---- ACCESS ----
ENDLOOP ;---- PERIOD ----
