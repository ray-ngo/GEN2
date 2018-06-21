;---------------------------------------------------------------------------
;Assemble_Skims_CR.s
;MWCOG Version 2.3  Model
;Assemble Transit Skims by Time Period
; Input Files:
;   iteration (%_iter_%) = 'i1',..,'i4'
;   period    (@period@) = 'am'/'op'
;
;  Transit Skim Files           = <iteration>_<period>_CR.skm
;  Transit Fare Files           = <iteration>_<period>_CR.FAR
; Output File:
;  Combined Transit Skims       = <iteration>TRN<Period>_CR.SKM, MO = 1-32,
;---------------------------------------------------------------------------

;---------------------------------------------------------------------------
;Loop through each period
;---------------------------------------------------------------------------
; Read Deflation Factor
READ FILE=TRN_Deflator.txt

LOOP PERIOD=1,2

 IF (PERIOD = 1)
  TIME_PERIOD = 'AM'
 ELSE
  TIME_PERIOD = 'OP'
 ENDIF

;---------------------------------------------------------------------------
;Assemble Skims & Fares into Files for Mode Choice
;---------------------------------------------------------------------------
RUN PGM=MATRIX
 MATI[1]=%_iter_%_@TIME_PERIOD@_WK_CR.SKM
 MATI[2]=%_iter_%_@TIME_PERIOD@_WK_CR.FAR
 MATI[3]=%_iter_%_@TIME_PERIOD@_DR_CR.SKM
 MATI[4]=%_iter_%_@TIME_PERIOD@_DR_CR.FAR
 MATO[1]=%_iter_%_TRN@TIME_PERIOD@_CR.SKM, MO = 1-32,
  NAME = WWAET, WWLKT, WINIT, WXFRT, WIVTT, WIVCR, WIVXB, WIVMR, WIVN1,
  WIVN2, WIVLB, WNXFR, WFARE, WXPEN,
         DWAET, DWLKT, DINIT, DXFRT, DIVTT, DIVCR, DIVXB, DIVMR, DIVN1,
  DIVN2, DIVLB, DNXFR, DFARE, DXPEN, DACCT, DACCD, DPRKC, DPRKT

MW[1] = MI.1.9    ;---- wlk walk acc time    (0.01 min)
MW[2] = MI.1.10   ;---- wlk other walk time  (0.01 min)
MW[3] = MI.1.7    ;---- wlk ini.wait time    (0.01 min)
MW[4] = MI.1.8    ;---- wlk xfr wait time    (0.01 min)
MW[5] = MI.1.3    ;---- wlk ivt-total        (0.01 min)
MW[6] = MI.1.4    ;---- wlk ivt-commuter rail(0.01 min)
MW[7] = MI.1.2    ;---- wlk ivt-exp bus      (0.01 min)
MW[8] = MI.1.3    ;---- wlk ivt-metrorail    (0.01 min)
MW[9] = MI.1.5    ;---- wlk ivt-new rail mode(0.01 min)
MW[10] = MI.1.6   ;---- wlk ivt-new bus mode (0.01 min)
MW[11] = MI.1.1   ;---- wlk ivt-local bus    (0.01 min)
MW[12] = MI.1.12  ;---- wlk transfers        (0+)
MW[13] = MI.2.1   ;---- wlk fare             (2007 cents)
MW[14] = MI.1.11  ;---- wlk added board time (0.01 min)
MW[15] = MI.3.9   ;---- drv walk acc time    (0.01 min)
MW[16] = MI.3.10  ;---- drv other walk time  (0.01 min)
MW[17] = MI.3.7   ;---- drv ini.wait time    (0.01 min)
MW[18] = MI.3.8   ;---- drv xfr wait time    (0.01 min)
MW[19] = MI.3.3   ;---- drv ivt-total        (0.01 min)
MW[20] = MI.3.4   ;---- drv ivt-commuter rail(0.01 min)
MW[21] = MI.3.2   ;---- drv ivt-exp bus      (0.01 min)
MW[22] = MI.3.3   ;---- drv ivt-metrorail    (0.01 min)
MW[23] = MI.3.5   ;---- drv ivt-new rail mode(0.01 min)
MW[24] = MI.3.6   ;---- drv ivt-new bus mode (0.01 min)
MW[25] = MI.3.1   ;---- drv ivt-local bus    (0.01 min)
MW[26] = MI.3.12  ;---- drv transfers        (0+)
MW[27] = MI.4.1   ;---- drv fare             (2007 cents)
MW[28] = MI.3.11  ;---- drv added board time (0.01 min)
MW[29] = MI.3.13  ;---- drv acc time         (0.01 min)
MW[30] = MI.3.14  ;---- drv acc distance     (0.01 mile)
MW[31] = MI.3.16  ;---- drv park cost        (2007 cents)
MW[32] = MI.3.15  ;---- drv park time        (0.01 min)
JLOOP

; assemble total IVTT

  MW[05] = MW[06]+MW[07]+MW[08]+MW[09]+MW[10]+MW[11]
  MW[19] = MW[20]+MW[21]+MW[22]+MW[23]+MW[24]+MW[25]

; zero-out fares for IVTT=0

  IF (MW[05]=0 ) MW[13]=0
  IF (MW[19]=0 ) MW[27]=0

; deflate parking costs to 2007

  MW[31] = @DEFLATIONFTR@*MW[31]

ENDJLOOP

ENDRUN

ENDLOOP ;---- PERIOD ----
