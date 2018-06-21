;--------------------------------------------------------------------
; PP_Auto_Drivers.S   Creating auto driver trips by occupant level (1,2,3+)
;                     from the pump prime trip distribution output
;                     using pre-existing NL model modal targets by market area
;                     (This process substitutes for a mode choice model run)
;                      in the initial 4-step iteration
; The 5 output matrix files will be:
;
;        1    <iter>_HBW_adr.mat
;        2    <iter>_HBS_adr.mat
;        3    <iter>_HBO_adr.mat
;        4    <iter>_NHW_adr.mat
;        5    <iter>_NHO_adr.mat
;;                 ... each file with 3 tabs: 1occ,2occ,3+occ auto drivers
; Milone:- 1/5/11
;--------------------------------------------------------------------

; First, establish Input/Output filenames:
LOOP PURP=1,5   ;  We'll Loop 5 times, for each purpose
;---------------------------------------------------------------------------
; write out zonal person trip table that reflects
; Auto Person trips, based on HTS Auto drivers (nonHBW trip factored by 1.75)
; and transit trips adjusted to match the targets
;---------------------------------------------------------------------------
;; global auto occs from HTS and estimated occupancies by occ. group
;; Purp avg_occ   1-occShr    2-occShr  3+occShr
;; HBW   1.06     0.943806    0.054412  0.001782
;; HBS   1.45     0.674235    0.239570  0.086195
;; HBO   1.63     0.559809    0.307970  0.132221
;; NHW   1.11     0.893861    0.104172  0.001967
;; NHO   1.50     0.642450    0.258570  0.098980
;;-------------------------------------------------------
                ;

IF (PURP=1)    ; HBW Loop
 MCFILE     = 'INPUTS\HBW_NL_MC.MTT'   ;AECOM Mode Choice file           (Input)
 TDFILE     = '%_iter_%_hbw.ptt'            ;Trip distibution output          (Input)
 MC123OCC   = '%_iter_%_HBW_adr.mat'        ;HBW Auto Drv trips- 1,2,3+ Occ.  (Output)
 PURPOSE    = 'HBW'                    ;
 Avg3P_Occ  =  3.50                    ; Avg Auto Occupancy for autos w/ 3+ person
 CarOcc     =  1.06                    ; Avg External Auto Occ.
 adroccshr1 =  0.943806                ; assumed share of adrs that are 1 occ
 adroccshr2 =  0.054412                ;                                2 occ
 adroccshr3 =  0.001782                ;                                3+ occ
 TDTab      =  '6'                     ; Total Psn Trip tab no. in Trip Dist. output file

ELSEIF (PURP=2) ; HBS Loop
 MCFILE     = 'INPUTS\HBS_NL_MC.MTT'   ;AECOM Mode Choice file           (Input)
 TDFILE     = '%_iter_%_hbs.ptt'            ;Trip distibution output          (Input)
 MC123OCC   = '%_iter_%_HBS_adr.mat'        ;HBS Auto Drv trips- 1,2,3+ Occ.  (Output)
 PURPOSE    = 'HBS'                    ;
 Avg3P_Occ  =  3.50                    ; Avg Auto Occupancy for autos w/ 3+ person
 CarOcc     =  1.45                    ; Avg External Auto Occ.
 adroccshr1 =  0.674235                ; assumed share of adrs that are 1 occ
 adroccshr2 =  0.239570                ;                                2 occ
 adroccshr3 =  0.086195                ;                                3+ occ
 TDTab      =  '6'                     ; Total Psn Trip tab no. in Trip Dist. output file

ELSEIF (PURP=3) ; HBO Loop
 MCFILE     = 'INPUTS\HBO_NL_MC.MTT'   ;AECOM Mode Choice file           (Input)
 TDFILE     = '%_iter_%_hbo.ptt'            ;Trip distibution output          (Input)
 MC123OCC   = '%_iter_%_HBO_adr.mat'        ;HBO Auto Drv trips- 1,2,3+ Occ.  (Output)
 PURPOSE    = 'HBO'                    ;
 Avg3P_Occ  =  3.50                    ; Avg Auto Occupancy for autos w/ 3+ person
 CarOcc     =  1.63                       ; Avg External Auto Occ.
 adroccshr1 =  0.559809                ; assumed share of adrs that are 1 occ
 adroccshr2 =  0.307970                ;                                2 occ
 adroccshr3 =  0.132221                ;                                3+ occ
 TDTab      =  '6'                     ; Total Psn Trip tab no. in Trip Dist. output file

ELSEIF (PURP=4) ; NHW Loop
 MCFILE     = 'INPUTS\NHW_NL_MC.MTT'   ;AECOM Mode Choice file           (Input)
 TDFILE     = '%_iter_%_nhw.ptt'            ;Trip distibution output          (Input)
 MC123OCC   = '%_iter_%_NHW_adr.mat'        ;NHW Auto Drv trips- 1,2,3+ Occ.  (Output)
 PURPOSE    = 'NHW'                    ;
 Avg3P_Occ  =  3.50                    ; Avg Auto Occupancy for autos w/ 3+ person
 CarOcc     =  1.11                       ; Avg External Auto Occ.
 adroccshr1 =  0.893861                ; assumed share of adrs that are 1 occ
 adroccshr2 =  0.104172                ;                                2 occ
 adroccshr3 =  0.001967                ;                                3+ occ
 TDTab      =  '3'                     ; Total Psn Trip tab no. in Trip Dist. output file

ELSEIF (PURP=5) ; NHO Loop
 MCFILE     = 'INPUTS\NHO_NL_MC.MTT'   ;AECOM Mode Choice file           (Input)
 TDFILE     = '%_iter_%_nho.ptt'            ;Trip distibution output          (Input)
 MC123OCC   = '%_iter_%_NHO_adr.mat'        ;NHO Auto Drv trips- 1,2,3+ Occ.  (Output)
 PURPOSE    = 'NHO'                    ;
 Avg3P_Occ  =  3.50                    ; Avg Auto Occupancy for autos w/ 3+ person
 CarOcc     =  1.50                       ; Avg External Auto Occ.
 adroccshr1 =  0.642450                ; assumed share of adrs that are 1 occ
 adroccshr2 =  0.258570                ;                                2 occ
 adroccshr3 =  0.098980                ;                                3+ occ
 TDTab      =  '3'                     ; Total Psn Trip tab no. in Trip Dist. output file

ENDIF
;
;//////////////////////////////////////////////////////////////////
; Step 1:
;  - First read trip distribution person trips (from which auto drivers aree to be estimated) and
;  - read a pre-existing nested logit mode choice model output.
;  - Summarize both to the 20 market segments (seg. 21 refers to external areas)
;  - computed auto person shares for each market area based on the NL output file
;  - apply market level 'seed' auto person shares to the trip dist. person trips
;  - write out the computed 'target' auto person trips at the market level.
;    (these will be used in step 2 to apportion zone level trip dist person trips among auto psn/drv by occ level)
RUN PGM=MATRIX
  PAGEHEIGHT= 32767
  array  NLmkt_trips=5,21        ;  array to summarize NL seed trips by mode (1,2,3+occ apsn transit, psn) and market area 1-21 (21 is external)
  array  TDmkt_trips=5,21        ;  array to summarize computed TD est. trips  by mode, based on seed shares
  array  TDmkt_share=5,21        ;  array to summarize computed TD est. shares by mode, based on seed shares

  MATI[1]=@TDfILE@           ;  TRIP DISTRIBUTION OUTPUT FILE
  MATI[2]=@MCFILE@           ;  NL MODE CHOICE MODEL OUTPUT FILE (INTL TRIPS)

;; read in Trip Dist. person trips and NL model output seed trips, by mode

    MW[101]  = MI.1.@TDtab@                                        ; put TOTAL PP motorized person trips in mtx 101

    MW[201]  = MI.2.1  + MI.2.2  + MI.2.3  + MI.2.4 + MI.2.5  +
               MI.2.6  + MI.2.7  + MI.2.8  + MI.2.9 + MI.2.10 +
               MI.2.11 + MI.2.12 + MI.2.13 + MI.2.14               ; put 'seed' NL MC psn trips by mode in mats 201-214       (I-I only)

    MW[211]  = MI.2.1                                 ;seed 1occ  auto psn
    MW[212]  = MI.2.2                                 ;seed 2occ  auto psn
    MW[213]  = MI.2.3                                 ;seed 3+occ auto psn
    MW[214]  = MW[201] - (MW[211] + MW[212] +MW[213]) ; seed transit

;; now summarize TD psn trips and seed trips by mode (transit, adr psn by 1,2,3+ occ)

  LOOKUP Name=TAZ_NLMkt,
          LOOKUP[1]   = 1,Result = 2, ; Market no 1 to 7
          Interpolate = N, FAIL=0,0,0,list=n,
          file= ..\support\TAZ3722_to_7Mrkts.txt

 jloop
     IM    = TAZ_NLMkt(1,I)
     JM    = TAZ_NLMkt(1,J)

     Mkt    = 21 ; default/external area
    ;; define zonal market idex no. 1 through 7-- put value in matrix 99
     if ((IM= 1 || IM= 3) && (JM=  1                    )) mkt= 1
     if ((IM= 1 || IM= 3) && (JM=  2                    )) mkt= 2
     if ((IM= 1 || IM= 3) && (JM=  3 || JM= 4 || JM=  5 )) mkt= 3
     if ((IM= 1 || IM= 3) && (JM=  6 || JM= 7           )) mkt= 4

     if ((IM=          4) && (JM=  1                    )) mkt= 5
     if ((IM=          4) && (JM=  2                    )) mkt= 6
     if ((IM=          4) && (JM=  3 || JM= 4 || JM=5   )) mkt= 7
     if ((IM=          4) && (JM=  6 || JM= 7           )) mkt= 8

     if ((IM= 2 || IM= 5) && (JM=  1                    )) mkt= 9
     if ((IM= 2 || IM= 5) && (JM=  2                    )) mkt=10
     if ((IM= 2 || IM= 5) && (JM=  3 || JM= 4  || JM=5  )) mkt=11
     if ((IM= 2 || IM= 5) && (JM=  6 || JM= 7           )) mkt=12

     if ((IM=          6) && (JM=  1                    )) mkt=13
     if ((IM=          6) && (JM=  2                    )) mkt=14
     if ((IM=          6) && (JM=  3 || JM= 4  || JM= 5 )) mkt=15
     if ((IM=          6) && (JM=  6 || JM= 7           )) mkt=16

     if ((IM=          7) && (JM=  1                    )) mkt=17
     if ((IM=          7) && (JM=  2                    )) mkt=18
     if ((IM=          7) && (JM=  3 || JM= 4  || JM=5  )) mkt=19
     if ((IM=          7) && (JM=  6 || JM= 7           )) mkt=20


     MW[99] = mkt

     ;; summarize seed trips by mode, mkt

    IF (Mkt > 0)

       NLmkt_trips[1][mkt] =  NLmkt_trips[1][mkt] + MW[211]    ;  NL seed 1-occ apsn
       NLmkt_trips[2][mkt] =  NLmkt_trips[2][mkt] + MW[212]    ;  NL seed 2-occ apsn
       NLmkt_trips[3][mkt] =  NLmkt_trips[3][mkt] + MW[213]    ;  NL seed 3+occ apsn
       NLmkt_trips[4][mkt] =  NLmkt_trips[4][mkt] + MW[214]    ;  NL seed transit
       NLmkt_trips[5][mkt] =  NLmkt_trips[5][mkt] + MW[211] + MW[212]+ MW[213]+ MW[214]   ;  NL seed person

       TDmkt_trips[5][mkt] =  TDmkt_trips[5][mkt] + MW[101]       ;  Trip Dist Psn trips
    ENDIF
 endjloop

IF (I=zones)  ;; if at the end of program, write out dbf file with market shares

;; estimate TD trips based on NL model shares
Loop Mkt= 1,21
      IF (NLmkt_Trips[5][mkt] > 0)
          TDmkt_trips[1][mkt] = TDmkt_trips[5][mkt] *  NLmkt_trips[1][mkt] / NLmkt_trips[5][mkt]; est 1 occapsn Trip Dist Psn trips
          TDmkt_trips[2][mkt] = TDmkt_trips[5][mkt] *  NLmkt_trips[2][mkt] / NLmkt_trips[5][mkt]; est 2 occapsn Trip Dist Psn trips
          TDmkt_trips[3][mkt] = TDmkt_trips[5][mkt] *  NLmkt_trips[3][mkt] / NLmkt_trips[5][mkt]; est 3+occpsn  Trip Dist Psn trips
          TDmkt_trips[4][mkt] = TDmkt_trips[5][mkt] *  NLmkt_trips[4][mkt] / NLmkt_trips[5][mkt]; est Transit   Trip Dist Psn trips
       ELSE
          TDmkt_trips[1][mkt] = TDmkt_trips[5][mkt] * @adroccshr1@
          TDmkt_trips[2][mkt] = TDmkt_trips[5][mkt] * @adroccshr2@
          TDmkt_trips[3][mkt] = TDmkt_trips[5][mkt] * @adroccshr3@
      ENDIF
ENDLOOP


;; compute TD auto driver shares
loop Mkt= 1,21
     IF ( TDmkt_trips[5][mkt] > 0)
        TDmkt_share[1][mkt] =  TDmkt_trips[1][mkt] /TDmkt_trips[5][mkt]
        TDmkt_share[2][mkt] =  TDmkt_trips[2][mkt] /TDmkt_trips[5][mkt]
        TDmkt_share[3][mkt] =  TDmkt_trips[3][mkt] /TDmkt_trips[5][mkt]
        TDmkt_share[4][mkt] =  TDmkt_trips[4][mkt] /TDmkt_trips[5][mkt]
     ENDIF

   FILEO reco[1] =  TD_Shares@Purpose@.dbf, fields= mkt(5),
                    TDPsn1(12.2),    TDPsn2(12.2),   TDPsn3(12.2),   TDtrn(12.2),  TDpsn(12.2),
                    TDPsn1Shr(12.6), TDPsn2Shr(12.6),TDPsn3Shr(12.6),TDtrnShr(12.6)

                    ro.mkt       = mkt
                    ro.TDPsn1    = TDmkt_trips[1][mkt]  ; auto psn 1 occ trips
                    ro.TDPsn2    = TDmkt_trips[2][mkt]  ; auto psn 2 occ trips
                    ro.TDPsn3    = TDmkt_trips[3][mkt]  ; auto psn 3+occ trips
                    ro.TDTrn     = TDmkt_trips[4][mkt]  ; transit        trips
                    ro.TDPsn     = TDmkt_trips[5][mkt]  ; person         trips

                    ro.TDPsn1shr = TDmkt_share[1][mkt]  ; auto psn 1 occ trips share
                    ro.TDPsn2shr = TDmkt_share[2][mkt]  ; auto psn 2 occ trips share
                    ro.TDPsn3shr = TDmkt_share[3][mkt]  ; auto psn 3+occ trips share
                    ro.TDTrnshr  = TDmkt_share[4][mkt]  ; transit trip         share

   WRITE RECO=1
ENDLOOP
endif

  FILEO MATO[1]  = Market1_21.Mtx, MO=99
ENDRUN
;

;//////////////////////////////////////////////////////////////////
; Step 2:
;  - read the computed 'target' auto person trips (developed above) at the market level.
;  - compute auto person shares from these targets at market level
;  - apply shares to TD person trips, compute auto person/driver trips by occ. level (1,2,3+)
;; - write out the PP auto driver trips
;;  Note: There may be a small loss in the conservation of auto driver trips in applying shares to trips at zone level
;         (particularly for the higher auto occ. levels).  This is acceptable for the pump prime iteration
RUN PGM=MATRIX
  ZONES=3722
  MATI[1]       = @TDfILE@                ;  TRIP DISTRIBUTION OUTPUT FILE
  MATI[2]       = Market1_21.Mtx          ;  zone file containing mkt index no (21 = extl)
  FILEI DBI[1]  ="TD_Shares@Purpose@.dbf" ;  mkt level shares and target trips by mode, computed above

  MW[101]  = MI.1.@TDtab@                                        ; put TOTAL PP motorized person trips in mtx 101
  MW[201]  = MI.2.1                                              ; put zonal mkt index                 in mtx 201

  array  TDmkt_share = 9,21        ;  array to summarize computed TD est. shares by mode, based on seed shares
                                   ;  and target INPUT trips from above

  array  OTDmkt_trips= 8,21        ;  array to summarize OUTPUT zone level TD est. trips  by mode, based on mkt level seed shares
                                   ;  8 modes:1/ Apsn1occ,2/Apsn2occ,3/Apsn3+occ,4/TRn,5/ADr1occ,6/ADr2occ,7/ADr3+occ,8/Psn
  ;
  ;;  read share file into array
  IF (I=1)
      LOOP K = 1,dbi.1.NUMRECORDS
            x = DBIReadRecord(1,k)
              mkt                 =  di.1.mkt
              TDmkt_share[1][mkt] =  di.1.TDPsn1shr
              TDmkt_share[2][mkt] =  di.1.TDPsn2shr
              TDmkt_share[3][mkt] =  di.1.TDPsn3shr
              TDmkt_share[4][mkt] =  di.1.TDTrnshr
              TDmkt_share[5][mkt] =  di.1.TDPsn1
              TDmkt_share[6][mkt] =  di.1.TDPsn2
              TDmkt_share[7][mkt] =  di.1.TDPsn3
              TDmkt_share[8][mkt] =  di.1.TDtrn
              TDmkt_share[9][mkt] =  di.1.TDpsn



             ;; echo print
             ;; print form=12.6 list = mkt(5),
             ;;                        TDmkt_share[1][mkt],
             ;;                        TDmkt_share[2][mkt],
             ;;                        TDmkt_share[3][mkt],
             ;;                        TDmkt_share[4][mkt], file=Share_@purpose@_Chk.txt
      ENDLOOP
  ENDIF


;; Apply mkt level shares to zonal person trips
  Jloop

     IF       (mw[201] > 0                  )                   ;;
               mkt=   mw[201]                                ; Est:
         mw[301] = MW[101] * TDmkt_share[1][mkt]                 ; zonal 1-occ auto persons
         mw[302] = MW[101] * TDmkt_share[2][mkt]                 ; zonal 2-occ auto persons
         mw[303] = MW[101] * TDmkt_share[3][mkt]                 ; zonal 3-occ auto person
         mw[304] = MW[101] * TDmkt_share[4][mkt]                 ; zonal TRANSIT
         mw[305] = MW[101] * TDmkt_share[1][mkt] / 1.0           ; zonal 1-occ auto drivers
         mw[306] = MW[101] * TDmkt_share[2][mkt] / 2.0           ; zonal 2-occ auto drivers
         mw[307] = MW[101] * TDmkt_share[3][mkt] / @Avg3P_Occ@   ; zonal 3-occ auto drivers


                                            ;; otherwise
      ELSE                                  ;; apply external default pcts
         mw[301] = MW[101] * @adroccshr1@                  ; zonal 1-occ auto persons
         mw[302] = MW[101] * @adroccshr2@                  ; zonal 2-occ auto persons
         mw[303] = MW[101] * @adroccshr3@                  ; zonal 3-occ auto persons

         mw[305] = MW[101] * @adroccshr1@ / 1.0           ; zonal 1-occ auto drivers
         mw[306] = MW[101] * @adroccshr2@ / 2.0           ; zonal 2-occ auto drivers
         mw[307] = MW[101] * @adroccshr3@ / @Avg3P_Occ@   ; zonal 3-occ auto drivers
    ENDIF

    ;; Accumulate computed trips by mode

      OTDmkt_trips[1][mkt] = OTDmkt_trips[1][mkt] + MW[301]                             ;  TD est. 1-occ psn
      OTDmkt_trips[2][mkt] = OTDmkt_trips[2][mkt] + MW[302]                             ;  TD est. 2-occ psn
      OTDmkt_trips[3][mkt] = OTDmkt_trips[3][mkt] + MW[303]                             ;  TD est. 3+occ psn
      OTDmkt_trips[4][mkt] = OTDmkt_trips[4][mkt] + MW[304]                             ;  TD est. transit
      OTDmkt_trips[5][mkt] = OTDmkt_trips[5][mkt] + MW[305]                             ;  TD est. 1-occ adr
      OTDmkt_trips[6][mkt] = OTDmkt_trips[6][mkt] + MW[306]                             ;  TD est. 2-occ adr
      OTDmkt_trips[7][mkt] = OTDmkt_trips[7][mkt] + MW[307]                             ;  TD est. 3+occ adr
      OTDmkt_trips[8][mkt] = OTDmkt_trips[8][mkt] + MW[301] + MW[302]+ MW[303]+ MW[304] ;  TD est. Person


  ENDJLOOP

  FILEO MATO[1] = @MC123OCC@,mo=305,306,307   ;; output auto driver matrix - 3tabs (1,2,3+occ adrs)

  ;; At the end of processing, write out the OUTPUT trips by mode along with INPUT trips by mode for checking
  IF (I=zones)
     loop Mkt= 1,21
         FILEO reco[1] = PP_Auto_Drivers_@Purpose@.dbf, fields= mkt(5),
                       OTDpsn1(12.2),OTDpsn2(12.2),  OTDpsn3(12.2),OTDTrn(12.2),
                       OTDadr1(12.2),OTDadr2(12.2),  OTDadr3(12.2),OTDPsn(12.2),
                       ITDPsn1(12.2), ITDPsn2(12.2), ITDPsn3(12.2),ITDtrn(12.2),  ITDpsn(12.2)

                    ro.mkt        = mkt
                    ro.OTDpsn1    = OTDmkt_trips[1][mkt]  ; OUTPUT  auto drv 1 occ trips
                    ro.OTDpsn2    = OTDmkt_trips[2][mkt]  ; OUTPUT  auto drv 2 occ trips
                    ro.OTDpsn3    = OTDmkt_trips[3][mkt]  ; OUTPUT  auto drv 3+occ trips
                    ro.OTDTrn     = OTDmkt_trips[4][mkt]  ; OUTPUT  transit        trips
                    ro.OTDadr1    = OTDmkt_trips[5][mkt]  ; OUTPUT  auto drv 1 occ trips
                    ro.OTDadr2    = OTDmkt_trips[6][mkt]  ; OUTPUT  auto drv 2 occ trips
                    ro.OTDadr3    = OTDmkt_trips[7][mkt]  ; OUTPUT  auto drv 3+occ trips
                    ro.OTDPsn     = OTDmkt_trips[8][mkt]  ; Output  person         trips

                    ro.ITDPsn1    = TDmkt_share[5][mkt]  ; INPUT auto Psn1occ
                    ro.ITDPsn2    = TDmkt_share[6][mkt]  ; INPUT auto Psn2occ
                    ro.ITDPsn3    = TDmkt_share[7][mkt]  ; INPUT auto Psn3+occ
                    ro.ITDtrn     = TDmkt_share[8][mkt]  ; INPUT transit
                    ro.ITDpsn     = TDmkt_share[9][mkt]  ; INPUT person


         WRITE RECO=1
     ENDLOOP
  ENDIF
ENDRUN
ENDLOOP
