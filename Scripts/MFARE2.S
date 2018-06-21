;=================================================================
;  MFARE2.S
;   Version 2.3 Model
;   TP+ Script Version of MFARE2 Program
;   Walk and Drive Access Zonal Fares Developed for AM Peak and Off-Peak Periods
;
;   Programmer: Milone
;   Date:     12/11/10
;
;
; Update 2/21/07 to support nested logit work
; 01/03/08 JainM
; Update for including LRT in MR path. Use BUSFARAM.ASC and BUSFAROP.ASC in MR paths.
; Condition the fares for Metrorail only path. Zero out fare for i/j with no transit path.
;=================================================================
;
; Set up tokens to either use or comment out commands for Cube Cluster (distributed processing)
if ('%useIdp%'='t' || '%useIdp%'='T')
  dp_token = ' '
else
  dp_token = ';'
endif
; useIdp = t (true) or f (false);  this is set in the wrapper batch file
distribute intrastep=%useIdp% multistep=f

ZONESIZE        =  3722               ;  No. of TAZs
LastIZn         =  3675               ;  Last Internal TAZ No.
STATSIZE        =   150               ;  Max No. of Metrorail Stations
BFZ_Size        =    21               ;  No. of Bus Fare Zones
; ----------------------------------------------------------------------

MSTA_Tariff     = 'INPUTS\tariff.txt'
TRN_Defl        = 'TRN_Deflator.txt'
; LOOP Through the Time Period/Access Mode combinations
;      - define I/P & O/P files:
;
LOOP PRDACC = 1,22
                                                     ;; COMMUTER RAIL FARES =================================================
    IF (PRDACC = 1)                                  ;  ------ AM Walk Access cycle: ------
       USTOSFile       = '%_iter_%_AM_WK_CR.STA '    ;   Input:  Walk Acc. Station to Station Matrix (Brd Sta/T1, Ali Stat/T2)
       TRSkimFile      = '%_iter_%_AM_WK_CR.SKM '    ;           Walk Acc. CR Transit Skims
       MR_FareFile     = 'AM_Metrorail_Fares.TXT '   ;           Metrorail Fares in Current Year Cents
       BusFareMTX      = 'INPUTS\BUSFARAM.ASC'       ;           Bus Fare matrix 21x21 (Bus fares zones '1' to '21')
       MF2ZonalDeck    = 'FARE_A2.ASC'               ;           Zonal A2 Deck    (Bus fares zones referenced as '1' to '21')
       OutputMatrix    = '%_iter_%_AM_WK_CR.FAR '    ;   Output: Total Fare Matrix
       OutputMatrix5   = '%_iter_%_AM_WK_CR.FR5 '    ;           Fare Matrix (T1-5 Total,bus onlr, rail, acc, egr fare file)
       OutputText      = '%_iter_%_AM_WK_CR.TXT '    ;           Fare text file for checking fare components / selected ijs
    ELSEIF (PRDACC = 2)                              ;  ------ AM Drive Access cycle: ------
       USTOSFile       = '%_iter_%_AM_DR_CR.STA '    ;
       TRSkimFile      = '%_iter_%_AM_DR_CR.SKM '    ;
       MR_FareFile     = 'AM_Metrorail_Fares.TXT '   ;
       BusFareMTX      = 'INPUTS\BUSFARAM.ASC'       ;
       MF2ZonalDeck    = 'FARE_A2.ASC'               ;
       OutputMatrix    = '%_iter_%_AM_DR_CR.FAR '    ;
       OutputMatrix5   = '%_iter_%_AM_DR_CR.FR5 '    ;
       OutputText      = '%_iter_%_AM_DR_CR.TXT '    ;
    ELSEIF (PRDACC = 3)                              ;  ------ Off-Pk Walk  Access cycle: ------
       USTOSFile       = '%_iter_%_OP_WK_CR.STA '    ;
       TRSkimFile      = '%_iter_%_OP_WK_CR.SKM '    ;
       MR_FareFile     = 'OP_Metrorail_Fares.TXT '   ;
       BusFareMTX      = 'INPUTS\BUSFAROP.ASC'       ;
       MF2ZonalDeck    = 'FARE_A2.ASC'               ;
       OutputMatrix    = '%_iter_%_OP_WK_CR.FAR '    ;
       OutputMatrix5   = '%_iter_%_OP_WK_CR.FR5 '    ;
       OutputText      = '%_iter_%_OP_WK_CR.TXT '    ;
    ELSEIF (PRDACC = 4)                              ;  ------ Off-Pk Drive  Access cycle: ------
       USTOSFile       = '%_iter_%_OP_DR_CR.STA '    ;
       TRSkimFile      = '%_iter_%_OP_DR_CR.SKM '    ;
       MR_FareFile     = 'OP_Metrorail_Fares.TXT '   ;
       BusFareMTX      = 'INPUTS\BUSFAROP.ASC'       ;
       MF2ZonalDeck    = 'FARE_A2.ASC'               ;
       OutputMatrix    = '%_iter_%_OP_DR_CR.FAR '    ;
       OutputMatrix5   = '%_iter_%_OP_DR_CR.FR5 '    ;
       OutputText      = '%_iter_%_OP_DR_CR.TXT '    ;

                                                     ;; METRORAIL ONLY FARES  ==============
    ELSEIF (PRDACC = 5)                              ;  ------ AM Walk Access cycle: ------
       USTOSFile       = '%_iter_%_AM_WK_MR.STA '    ;
       TRSkimFile      = '%_iter_%_AM_WK_MR.SKM '    ;
       MR_FareFile     = 'AM_Metrorail_Fares.TXT '   ;
       BusFareMTX      = 'INPUTS\BUSFARAM.ASC'       ;
       MF2ZonalDeck    = 'FARE_A2.ASC'               ;
       OutputMatrix    = '%_iter_%_AM_WK_MR.FAR '    ;
       OutputMatrix5   = '%_iter_%_AM_WK_MR.FR5 '    ;
       OutputText      = '%_iter_%_AM_WK_MR.TXT '    ;
    ELSEIF (PRDACC = 6)                              ;  ------ AM Drive Access cycle: ------
       USTOSFile       = '%_iter_%_AM_DR_MR.STA '    ;
       TRSkimFile      = '%_iter_%_AM_DR_MR.SKM '    ;
       MR_FareFile     = 'AM_Metrorail_Fares.TXT '   ;
       BusFareMTX      = 'INPUTS\BUSFARAM.ASC'       ;
       MF2ZonalDeck    = 'FARE_A2.ASC'               ;
       OutputMatrix    = '%_iter_%_AM_DR_MR.FAR '    ;
       OutputMatrix5   = '%_iter_%_AM_DR_MR.FR5 '    ;
       OutputText      = '%_iter_%_AM_DR_MR.TXT '    ;
    ELSEIF (PRDACC = 7)                              ;  ------ AM KNR   Access cycle: ------
       USTOSFile       = '%_iter_%_AM_KR_MR.STA '    ;
       TRSkimFile      = '%_iter_%_AM_KR_MR.SKM '    ;
       MR_FareFile     = 'AM_Metrorail_Fares.TXT '   ;
       BusFareMTX      = 'INPUTS\BUSFARAM.ASC'       ;
       MF2ZonalDeck    = 'FARE_A2.ASC'               ;
       OutputMatrix    = '%_iter_%_AM_KR_MR.FAR '    ;
       OutputMatrix5   = '%_iter_%_AM_KR_MR.FR5 '    ;
       OutputText      = '%_iter_%_AM_KR_MR.TXT '    ;
    ELSEIF (PRDACC = 8)                              ;  ------ Off-Pk Walk  Access cycle: ------
       USTOSFile       = '%_iter_%_OP_WK_MR.STA '    ;
       TRSkimFile      = '%_iter_%_OP_WK_MR.SKM '    ;
       MR_FareFile     = 'OP_Metrorail_Fares.TXT '   ;
       BusFareMTX      = 'INPUTS\BUSFAROP.ASC'       ;
       MF2ZonalDeck    = 'FARE_A2.ASC'               ;
       OutputMatrix    = '%_iter_%_OP_WK_MR.FAR '    ;
       OutputMatrix5   = '%_iter_%_OP_WK_MR.FR5 '    ;
       OutputText      = '%_iter_%_OP_WK_MR.TXT '    ;
    ELSEIF (PRDACC = 9)                              ;  ------ Off-Pk Drive Access cycle: ------
       USTOSFile       = '%_iter_%_OP_DR_MR.STA '    ;
       TRSkimFile      = '%_iter_%_OP_DR_MR.SKM '    ;
       MR_FareFile     = 'OP_Metrorail_Fares.TXT '   ;
       BusFareMTX      = 'INPUTS\BUSFAROP.ASC'       ;
       MF2ZonalDeck    = 'FARE_A2.ASC'               ;
       OutputMatrix    = '%_iter_%_OP_DR_MR.FAR '    ;
       OutputMatrix5   = '%_iter_%_OP_DR_MR.FR5 '    ;
       OutputText      = '%_iter_%_OP_DR_MR.TXT '    ;
    ELSEIF (PRDACC =10)                              ;  ------ Off-Pk KNR   Access cycle: ------
       USTOSFile       = '%_iter_%_OP_KR_MR.STA '    ;
       TRSkimFile      = '%_iter_%_OP_KR_MR.SKM '    ;
       MR_FareFile     = 'OP_Metrorail_Fares.TXT '   ;
       BusFareMTX      = 'INPUTS\BUSFAROP.ASC'       ;
       MF2ZonalDeck    = 'FARE_A2.ASC'               ;
       OutputMatrix    = '%_iter_%_OP_KR_MR.FAR '    ;
       OutputMatrix5   = '%_iter_%_OP_KR_MR.FR5 '    ;
       OutputText      = '%_iter_%_OP_KR_MR.TXT '    ;

                                                     ;; ALL BUS FARES ========================================================
    ELSEIF (PRDACC =11)                              ;  ------ AM Walk Access cycle: ------
       USTOSFile       = '%_iter_%_AM_WK_AB.STA '    ;
       TRSkimFile      = '%_iter_%_AM_WK_AB.SKM '    ;
       MR_FareFile     = 'AM_Metrorail_Fares.TXT '   ;
       BusFareMTX      = 'INPUTS\BUSFARAM.ASC'       ;
       MF2ZonalDeck    = 'FARE_A2.ASC'               ;
       OutputMatrix    = '%_iter_%_AM_WK_AB.FAR '    ;
       OutputMatrix5   = '%_iter_%_AM_WK_AB.FR5 '    ;
       OutputText      = '%_iter_%_AM_WK_AB.TXT '    ;
    ELSEIF (PRDACC =12)                              ;  ------ AM Drive Access cycle: ------
       USTOSFile       = '%_iter_%_AM_DR_AB.STA '    ;
       TRSkimFile      = '%_iter_%_AM_DR_AB.SKM '    ;
       MR_FareFile     = 'AM_Metrorail_Fares.TXT '   ;
       BusFareMTX      = 'INPUTS\BUSFARAM.ASC'       ;
       MF2ZonalDeck    = 'FARE_A2.ASC'               ;
       OutputMatrix    = '%_iter_%_AM_DR_AB.FAR '    ;
       OutputMatrix5   = '%_iter_%_AM_DR_AB.FR5 '    ;
       OutputText      = '%_iter_%_AM_DR_AB.TXT '    ;
    ELSEIF (PRDACC =13)                              ;  ------ AM KNR   Access cycle: ------
       USTOSFile       = '%_iter_%_AM_KR_AB.STA '    ;
       TRSkimFile      = '%_iter_%_AM_KR_AB.SKM '    ;
       MR_FareFile     = 'AM_Metrorail_Fares.TXT '   ;
       BusFareMTX      = 'INPUTS\BUSFARAM.ASC'       ;
       MF2ZonalDeck    = 'FARE_A2.ASC'               ;
       OutputMatrix    = '%_iter_%_AM_KR_AB.FAR '    ;
       OutputMatrix5   = '%_iter_%_AM_KR_AB.FR5 '    ;
       OutputText      = '%_iter_%_AM_KR_AB.TXT '    ;
    ELSEIF (PRDACC =14)                              ;  ------ Off-Pk Walk  Access cycle: ------
       USTOSFile       = '%_iter_%_OP_WK_AB.STA '    ;
       TRSkimFile      = '%_iter_%_OP_WK_AB.SKM '    ;
       MR_FareFile     = 'OP_Metrorail_Fares.TXT '   ;
       BusFareMTX      = 'INPUTS\BUSFAROP.ASC'       ;
       MF2ZonalDeck    = 'FARE_A2.ASC'               ;
       OutputMatrix    = '%_iter_%_OP_WK_AB.FAR '    ;
       OutputMatrix5   = '%_iter_%_OP_WK_AB.FR5 '    ;
       OutputText      = '%_iter_%_OP_WK_AB.TXT '    ;
    ELSEIF (PRDACC =15)                              ;  ------ Off-Pk Drive Access cycle: ------
       USTOSFile       = '%_iter_%_OP_DR_AB.STA '    ;
       TRSkimFile      = '%_iter_%_OP_DR_AB.SKM '    ;
       MR_FareFile     = 'OP_Metrorail_Fares.TXT '   ;
       BusFareMTX      = 'INPUTS\BUSFAROP.ASC'       ;
       MF2ZonalDeck    = 'FARE_A2.ASC'               ;
       OutputMatrix    = '%_iter_%_OP_DR_AB.FAR '    ;
       OutputMatrix5   = '%_iter_%_OP_DR_AB.FR5 '    ;
       OutputText      = '%_iter_%_OP_DR_AB.TXT '    ;
    ELSEIF (PRDACC =16)                              ;  ------ Off-Pk KNR   Access cycle: ------
       USTOSFile       = '%_iter_%_OP_KR_AB.STA '    ;
       TRSkimFile      = '%_iter_%_OP_KR_AB.SKM '    ;
       MR_FareFile     = 'OP_Metrorail_Fares.TXT '   ;
       BusFareMTX      = 'INPUTS\BUSFAROP.ASC'       ;
       MF2ZonalDeck    = 'FARE_A2.ASC'               ;
       OutputMatrix    = '%_iter_%_OP_KR_AB.FAR '    ;
       OutputMatrix5   = '%_iter_%_OP_KR_AB.FR5 '    ;
       OutputText      = '%_iter_%_OP_KR_AB.TXT '    ;

                                                     ;; ALL BUS/METRORAIL FARES =============================================
    ELSEIF (PRDACC =17)                              ;  ------ AM Walk Access cycle: ------
       USTOSFile       = '%_iter_%_AM_WK_BM.STA '    ;
       TRSkimFile      = '%_iter_%_AM_WK_BM.SKM '    ;
       MR_FareFile     = 'AM_Metrorail_Fares.TXT '   ;
       BusFareMTX      = 'INPUTS\BUSFARAM.ASC'       ;
       MF2ZonalDeck    = 'FARE_A2.ASC'               ;
       OutputMatrix    = '%_iter_%_AM_WK_BM.FAR '    ;
       OutputMatrix5   = '%_iter_%_AM_WK_BM.FR5 '    ;
       OutputText      = '%_iter_%_AM_WK_BM.TXT '    ;
    ELSEIF (PRDACC =18)                              ;  ------ AM Drive Access cycle: ------
       USTOSFile       = '%_iter_%_AM_DR_BM.STA '    ;
       TRSkimFile      = '%_iter_%_AM_DR_BM.SKM '    ;
       MR_FareFile     = 'AM_Metrorail_Fares.TXT '   ;
       BusFareMTX      = 'INPUTS\BUSFARAM.ASC'       ;
       MF2ZonalDeck    = 'FARE_A2.ASC'               ;
       OutputMatrix    = '%_iter_%_AM_DR_BM.FAR '    ;
       OutputMatrix5   = '%_iter_%_AM_DR_BM.FR5 '    ;
       OutputText      = '%_iter_%_AM_DR_BM.TXT '    ;
    ELSEIF (PRDACC =19)                              ;  ------ AM KNR   Access cycle: ------
       USTOSFile       = '%_iter_%_AM_KR_BM.STA '    ;
       TRSkimFile      = '%_iter_%_AM_KR_BM.SKM '    ;
       MR_FareFile     = 'AM_Metrorail_Fares.TXT '   ;
       BusFareMTX      = 'INPUTS\BUSFARAM.ASC'       ;
       MF2ZonalDeck    = 'FARE_A2.ASC'               ;
       OutputMatrix    = '%_iter_%_AM_KR_BM.FAR '    ;
       OutputMatrix5   = '%_iter_%_AM_KR_BM.FR5 '    ;
       OutputText      = '%_iter_%_AM_KR_BM.TXT '    ;
    ELSEIF (PRDACC =20)                              ;  ------ Off-Pk Walk  Access cycle: ------
       USTOSFile       = '%_iter_%_OP_WK_BM.STA '    ;
       TRSkimFile      = '%_iter_%_OP_WK_BM.SKM '    ;
       MR_FareFile     = 'OP_Metrorail_Fares.TXT '   ;
       BusFareMTX      = 'INPUTS\BUSFAROP.ASC'       ;
       MF2ZonalDeck    = 'FARE_A2.ASC'               ;
       OutputMatrix    = '%_iter_%_OP_WK_BM.FAR '    ;
       OutputMatrix5   = '%_iter_%_OP_WK_BM.FR5 '    ;
       OutputText      = '%_iter_%_OP_WK_BM.TXT '    ;
    ELSEIF (PRDACC =21)                              ;  ------ Off-Pk Drive Access cycle: ------
       USTOSFile       = '%_iter_%_OP_DR_BM.STA '    ;
       TRSkimFile      = '%_iter_%_OP_DR_BM.SKM '    ;
       MR_FareFile     = 'OP_Metrorail_Fares.TXT '   ;
       BusFareMTX      = 'INPUTS\BUSFAROP.ASC'       ;
       MF2ZonalDeck    = 'FARE_A2.ASC'               ;
       OutputMatrix    = '%_iter_%_OP_DR_BM.FAR '    ;
       OutputMatrix5   = '%_iter_%_OP_DR_BM.FR5 '    ;
       OutputText      = '%_iter_%_OP_DR_BM.TXT '    ;
    ELSEIF (PRDACC =22)                              ;  ------ Off-Pk KR    Access cycle: ------
       USTOSFile       = '%_iter_%_OP_KR_BM.STA '    ;
       TRSkimFile      = '%_iter_%_OP_KR_BM.SKM '    ;
       MR_FareFile     = 'OP_Metrorail_Fares.TXT '   ;
       BusFareMTX      = 'INPUTS\BUSFAROP.ASC'       ;
       MF2ZonalDeck    = 'FARE_A2.ASC'               ;
       OutputMatrix    = '%_iter_%_OP_KR_BM.FAR '    ;
       OutputMatrix5   = '%_iter_%_OP_KR_BM.FR5 '    ;
       OutputText      = '%_iter_%_OP_KR_BM.TXT '    ;

    ENDIF


RUN PGM=MATRIX
@dp_token@distributeIntrastep processId='mwcog', ProcessList=%subnode%
ZONES=@ZONESIZE@
;
read FILE=@MSTA_Tariff@
read FILE=@TRN_Defl@
;==============================================================
; Read Station-to-Station Metrorail Fares as lookups          =
; Fares read in based on IJ index                             =
;    e.g., '1001' means 1 to 1 and '150150' means 150 to 150  =
;                                                             =
;==============================================================
;
      LOOKUP Name=STA_Fares,
             LOOKUP[1]   = 4,Result = 3,   ;  station to station fares
             Interpolate = N, FAIL=0,0,0,list=N,file=@MR_FareFile@
;
;==============================================================
; Read Bus Fare zone to Bus fare zone matrix                  =
; Fares are indexed to origin-end bus fare zone 'row';lookup  =
; no. corresponds to a destin-end bus fare zone 'column'      =
;==============================================================
;
      LOOKUP Name=BusFrMTX,
             LOOKUP[01]   = 1,Result = 2,   ;
             LOOKUP[02]   = 1,Result = 3,   ;
             LOOKUP[03]   = 1,Result = 4,   ;
             LOOKUP[04]   = 1,Result = 5,   ;
             LOOKUP[05]   = 1,Result = 6,   ;
             LOOKUP[06]   = 1,Result = 7,   ;
             LOOKUP[07]   = 1,Result = 8,   ;
             LOOKUP[08]   = 1,Result = 9,   ;
             LOOKUP[09]   = 1,Result =10,   ;
             LOOKUP[10]   = 1,Result =11,   ;
             LOOKUP[11]   = 1,Result =12,   ;
             LOOKUP[12]   = 1,Result =13,   ;
             LOOKUP[13]   = 1,Result =14,   ;
             LOOKUP[14]   = 1,Result =15,   ;
             LOOKUP[15]   = 1,Result =16,   ;
             LOOKUP[16]   = 1,Result =17,   ;
             LOOKUP[17]   = 1,Result =18,   ;
             LOOKUP[18]   = 1,Result =19,   ;
             LOOKUP[19]   = 1,Result =20,   ;
             LOOKUP[20]   = 1,Result =21,   ;
             LOOKUP[21]   = 1,Result =22,   ;
             Interpolate  = N, FAIL=0,0,0,list=N,file=@BusFareMTX@


;;   read Zone data file
      LOOKUP Name=TAZLook,
             LOOKUP[01]   = 1,Result = 2,   ;  BusFare Zn 1 (1-21)
             LOOKUP[02]   = 1,Result = 3,   ;  BusFare Zn 2 (1-21)
             LOOKUP[03]   = 1,Result = 4,   ;  Orig Walk Pct in 10ths of pcts ('1000'=100%)
             LOOKUP[04]   = 1,Result = 5,   ;  Dest Walk Pct in 10ths of pcts ('1000'=100%)
             LOOKUP[05]   = 1,Result = 6,   ;  BusFare Zn 1 associated w/ Metro station  (1-21)
             LOOKUP[06]   = 1,Result = 7,   ;  BusFare Zn 2 associated w/ Metro station  (1-21)
             LOOKUP[07]   = 1,Result = 8,   ;  Jurcode: 0/DC, 1/MD, 2/VA Area1, 3/VA Area2
             LOOKUP[08]   = 1,Result = 9,   ;  Origin-end Bus Fare Override value (in current yr cents)
             LOOKUP[09]   = 1,Result =10,   ;  Destin-end Bus Fare Override value (in current yr cents
             Interpolate  = N, FAIL=0,0,0,list=N,file=@MF2ZonalDeck@

           ;
           ; Establish Discount Array
           ;
             ARRAY RB_Disc = 4

                   RB_Disc[1] = DC_RailBus_Disc
                   RB_Disc[2] = MD_RailBus_Disc
                   RB_Disc[3] = VA1_RailBusDisc
                   RB_Disc[4] = VA2_RailBusDisc

             IF (TAZLook(7,I) > 3 || TAZLook(7,I) < 0)
                LIST = 'Jurisdiction Code NOT within convention values; I Quit'
                ABORT
             ENDIF

             IF (TAZLook(3,I) < 0  || TAZLook(3,I) > 1000.0  )
                LIST = 'Orig. Walk Pcts NOT within tolerances(0.0 to 1000.0) ; I Quit'
                ABORT
             ENDIF

             IF (TAZLook(4,I) < 0  || TAZLook(4,I) > 1000.0  )
                LIST = 'Destin. Walk Pcts NOT within tolerances(0.0 to 1000.0) ; I Quit'
                ABORT
             ENDIF


             IF (TAZLook(1,I) > @BFZ_SIZE@ || TAZLook(2,I) > @BFZ_SIZE@ ||
                 TAZLook(5,I) > @BFZ_SIZE@ || TAZLook(6,I) > @BFZ_SIZE@)
                LIST = 'Zonal / Metrorail Bus Fare Zn No. equivalence exceeds: ','@BFZ_SIZE@',': I Quit'
                ABORT
             ENDIF

;==============================================================
; Read in the USTOS files here & Declare output matrix        =
;==============================================================

           MATI[01] = @USTOSFile@
             MW[11] = MI.1.1    ;  On-Station
             MW[12] = MI.1.2    ;  Off-Station

           MATI[02] = @TRSkimFile@
             MW[13] = MI.2.1    ;---- ivt-local bus    (0.01 min)
             MW[14] = MI.2.2    ;---- ivt-exp bus      (0.01 min)
             MW[15] = MI.2.3    ;---- ivt-metrorail    (0.01 min)
             MW[16] = MI.2.4    ;---- ivt-commuter rail(0.01 min)
             MW[17] = MI.2.5    ;---- ivt-light rail   (0.01 min)
             MW[18] = MI.2.6    ;---- ivt-new mode     (0.01 min)



             MATO[1]= @OutputMatrix@,MO=21,FORMAT=MINUTP; total deflated fare/t1)

             MATO[2]= @OutputMatrix5@,MO=41-45    ; total deflated fare/t1,
                                                  ; busonly(undefl)    /t2,
                                                  ; rail(undef)        /t3,
                                                  ; acc(undef)         /t4,
                                                  ; egr(undef)         /t5

;==============================================================
;==============================================================
; Now begin  i/j level fare calculation process               =
;==============================================================
;==============================================================


  JLOOP

    MW[19] = MW[13]+MW[14]+MW[15]+MW[16]+MW[17]+MW[18]   ; total transit in-vehicle time
    MW[20] = MW[13]+MW[14]+MW[16]+MW[17]+MW[18]          ; Non-Metrorail in-vehicle time

    IF (I > @LastIZN@ || J > @LastIZN@)  Continue                  ; Skip current i/j if either is external
     ; Start afresh all fare related variables at the current i/j

          BusFare        = 0.0
          RailFare       = 0.0
          RailAccFare    = 0.0
          RailEgrFare    = 0.0
          TotalFare      = 0.0
          TotalFareDef   = 0.0
          IBFZ1          = 0.0
          IBFZ2          = 0.0
          JBFZ1          = 0.0
          JBFZ2          = 0.0
          Acc_NoWlk_Prop = 0.0
          Egr_NoWlk_Prop = 0.0
          ISTA           = 0.0
          JSTA           = 0.0
          IJIDX          = 0.0
          RailFare       = 0.0
          RIBFZ1         = 0.0
          RIBFZ2         = 0.0
          RJBFZ1         = 0.0
          RJBFZ2         = 0.0
          _AccFare1      = 0.0
          _AccFare2      = 0.0
          _AccFare12     = 0.0
          _EgrFare1      = 0.0
          _EgrFare2      = 0.0
          _EgrFare12     = 0.0
          RailAccFare    = 0.0
          RailEgrFare    = 0.0
          Acc_Discount   = 0.0
          Egr_Discount   = 0.0
          I_FareOvr      = 0.0
          J_FareOvr      = 0.0

     ; Make sure station numbers are appropriate:
          IF (MW[11] > @STATSIZE@ ||  MW[12] > @STATSIZE@ )
                LIST = 'USTOS Station number(s) are out of range; I Quit'
              ABORT
          ENDIF

      ;
      ; Define Rail-to-bus fare discount.  The discount will be applied
      ; at the acces end and egress - end on a 50/50 basis (per MFARE2)
      ;
        AccRBDx     =  TAZLook(7,I) + 1         ; convert JurCode 0-3 to Rail/Bus discount array index 1-4
        EgrRBDx     =  TAZLook(7,J) + 1         ;
        Acc_Discount  =  RB_Disc[AccRBDx] * 0.50
        Egr_Discount  =  RB_Disc[EgrRBDx] * 0.50


     ; Lookup Bus Fares
     ;
     IBFZ1 = TAZLOOK(1,I)
     IBFZ2 = TAZLOOK(2,I)
     IF (IBFZ2 = 0) IBFZ2 = IBFZ1


     JBFZ1 = TAZLOOK(1,J)
     JBFZ2 = TAZLOOK(2,J)
     IF (JBFZ2 = 0) JBFZ2 = JBFZ1

     ;
     ;  Define Zonal Non-walk area percentages at
     ;  Access end and egress end:
     Acc_NoWlk_Prop = 1.0 - (TAZLOOK(3,I)/1000.0)    ; Zonal non-walk proportion to station (Access-end)
     Egr_NoWlk_Prop = 1.0 - (TAZLOOK(4,J)/1000.0)    ; Zonal non-walk proportion to station (Egress-end)


    ;---------------------------------------------------------------------
    ; If no transit path exists for i/j then zero-out fares
    ;---------------------------------------------------------------------
    IF (MW[19][j] = 0 )

         TotalFare      = 0.0
         TotalFareDef   = 0.0
         BusFare        = 0.0
         RailFare       = 0.0
         _AccFare12     = 0.0
         _EgrFare12     = 0.0

          MW[21][j]     = TotalFareDef

          MW[41][j]     = TotalFareDef
          MW[42][j]     = BusFare
          MW[43][j]     = RailFare
          MW[44][j]     = _AccFare12
          MW[45][j]     = _EgrFare12


    ELSEIF (MW[11][j] = 0  && MW[12][j] = 0)  ;
    ;---------------------------------------------------------------------
    ; ..ElseIf no rail stations used, compute Bus fare (BUSFARE)
    ;---------------------------------------------------------------------
          BusFare = (BusFrMTX(JBFZ1,IBFZ1)  +
                     BusFrMTX(JBFZ2,IBFZ1)  +
                     BusFrMTX(JBFZ1,IBFZ2)  +
                     BusFrMTX(JBFZ2,IBFZ2))   * 0.250

         TotalFare     =  BusFare + RailFare + RailAccFare + RailEgrFare  ; undeflated transit fare, Bus-Only paths
         TotalFareDef  =  Round(TotalFare * DeflationFTR)
         MW[21][j]     =  TotalFareDef

         MW[41][j]     = TotalFareDef
         MW[42][j]     = BusFare
         MW[43][j]     = RailFare
         MW[44][j]     = _AccFare12
         MW[45][j]     = _EgrFare12

    ELSE
    ;--------------------------------------------------------------------
    ; ... Else compute rail related fares                               -
    ; if USTOS stations exist for current I/J                           -
    ;--------------------------------------------------------------------

       ISTA     =  MW[11][J]                               ; Origin Metrorail Station No.
       JSTA     =  MW[12][J]                               ; Destin Metrorail Station No.
       IJIDX    =  ISTA*1000.0 + JSTA                      ; Sta I/J index, ('0001001' means from sta# 1 to sta#1)
       RailFare =  Sta_Fares(1,IJIDX)                      ; Fare from current Sta.I to Sta.J

      ;
      ;  Define Station-related Bus Fare Zones
      ;  Access-End:

      RIBFZ1 = TAZLOOK(5,ISTA)
      RIBFZ2 = TAZLOOK(6,ISTA)
      IF (RIBFZ2 = 0) RIBFZ2 = RIBFZ1

      ;  Egress-End:

      RJBFZ1 = TAZLOOK(5,JSTA)
      RJBFZ2 = TAZLOOK(6,JSTA)
      IF (RJBFZ2 = 0) RJBFZ2 = RJBFZ1

       _AccFare1 = MIN(BusFrMTX(RIBFZ1,IBFZ1),BusFrMTX(RIBFZ2,IBFZ1))
       _AccFare2 = MIN(BusFrMTX(RIBFZ1,IBFZ2),BusFrMTX(RIBFZ2,IBFZ2))
       _AccFare12= ((_AccFare1 + _AccFare2) * 0.50) - Acc_Discount

       _EgrFare1 = MIN(BusFrMTX(JBFZ1,RJBFZ1),BusFrMTX(JBFZ1,RJBFZ2))
       _EgrFare2 = MIN(BusFrMTX(JBFZ2,RJBFZ1),BusFrMTX(JBFZ2,RJBFZ2))
       _EgrFare12= ((_EgrFare1 + _EgrFare2) * 0.50) - Egr_Discount

        RailAccFare = _AccFare12 *  Acc_NoWlk_Prop
        RailEgrFare = _EgrFare12 *  Egr_NoWlk_Prop


    ; If Only Metrorail is used then TotalFare equals RailFare

         IF (MW[20][j] = 0)

            TotalFare  = RailFare                                       ; undeflated transit fare, Metrorail Only-Related paths

            BusFare    = 0.0
            _AccFare12 = 0.0
            _EgrFare12 = 0.0
           RailAccFare = 0.0
           RailEgrFare = 0.0

         ELSE

            TotalFare = BusFare + RailFare + RailAccFare + RailEgrFare ; undeflated transit fare, Metrorail-Related paths

         ENDIF

    ; If an I/J override value exists use it instead of the total computed fare value

         IF ( TAZLOOK(8,I) > 0.0 )
              I_FareOvr = TAZLOOK(8,I)
              TotalFare = I_FareOvr
         ENDIF
         IF ( TAZLOOK(9,J) > 0.0 )
             J_FareOvr = TAZLOOK(9,J)
             TotalFare = J_FareOvr
         ENDIF

    ; Apply Deflator to Total fare to write out constant dollars

        TotalFareDef   =  Round(TotalFare * DeflationFTR)
         MW[21][j]     =  TotalFareDef

         MW[41][j]     =  TotalFareDef
         MW[42][j]     =  BusFare
         MW[43][j]     =  RailFare
         MW[44][j]     =  _AccFare12
         MW[45][j]     =  _EgrFare12

    ENDIF


    ; write out the results of sample IJs here:
    IF (i = 8, 64, 345, 362, 464, 578, 829, 927, 1043, 1231, 1236, 1337,
         1537, 1554, 1619, 1698, 1716, 1842, 1942, 1967 &
         j = 8, 64, 345, 362, 1231, 1236, 1337, 1537)

         print Form=7.1 list= i(6),j(6),TotalFareDef(6), TotalFare, BusFare, RailFare, _AccFare12,_EgrFare12,
                              I_FareOvr,J_FareOvr,
           ' <<- I/J/DefFare/UnDefFare/BusFare/RailFare/AccFare/EgrFare/IOvrFare/JOvrFare/', file=@Outputtext@
    ENDIF

  ENDJLOOP


ENDRUN

ENDLOOP
