; ====================================================================
;  Version 2.3
;  MC_Auto_Drivers.s
;  This program is used to develop 1-occ, 2-occ, and 3+occ auto driver
;  trip tables, by purpose (HBW, HBS, HBO, and NHB).  The script reads two files:
;  1) Internal Auto Person Trips - The AECOM NL Mode choice output, each file
;     contains auto person trips by occupancy group (1,2,and 3+ Occupant Vehicles).
;  2) External Auto Person trips - the trip distibution output containing
;     total auto person trips.
; ====================================================================
;
;
;//////////////////////////////////////////////////////////////////
;

Zonesize   = 3722
FstExtZn   = 3676

; First, establish Input/Output filenames:
LOOP PURP=1,5   ;  We'll Loop 5 times, for each purpose
                ;
IF (PURP=1)    ; HBW Loop
 MCFILE   = '%_iter_%_HBW_NL_MC.MTT' ;AECOM Mode Choice file           (Input)
 TDFILE   = '%_iter_%_HBW.PTT'      ;Trip distibution output          (Input)
 MC123OCC = '%_iter_%_HBW_adr.mat'        ;HBW Auto Drv trips- 1,2,3+ Occ.  (Output)
 PURPOSE  = 'HBW'                    ;
 Avg3P_Occ=  3.50                    ; Avg Auto Occupancy for autos w/ 3+ person
 ExtCarOcc=  1.15                    ; Avg External Auto Occ.
 TDTab    =  '6'                     ; Total Psn Trip tab no. in Trip Dist. output file

ELSEIF (PURP=2) ; HBS Loop
 MCFILE   = '%_iter_%_HBS_NL_MC.MTT' ;AECOM Mode Choice file           (Input)
 TDFILE   = '%_iter_%_HBS.PTT'     ;Trip distibution output          (Input)
 MC123OCC = '%_iter_%_HBS_adr.mat'        ;HBW Auto Drv trips- 1,2,3+ Occ.  (Output)
 PURPOSE  = 'HBS'                    ;
 Avg3P_Occ=  3.50                    ; Avg Auto Occupancy for autos w/ 3+ person
 ExtCarOcc=  1.64                    ; Avg External Auto Occ.
 TDTab    =  '6'                     ; Total Psn Trip tab no. in Trip Dist. output file

ELSEIF (PURP=3) ; HBO Loop
 MCFILE   = '%_iter_%_HBO_NL_MC.MTT' ;AECOM Mode Choice file           (Input)
 TDFILE   = '%_iter_%_HBO.PTT'     ;Trip distibution output          (Input)
 MC123OCC = '%_iter_%_HBO_adr.mat'        ;HBW Auto Drv trips- 1,2,3+ Occ.  (Output)
 PURPOSE  = 'HBO'                    ;
 Avg3P_Occ=  3.50                    ; Avg Auto Occupancy for autos w/ 3+ person
 ExtCarOcc=  1.61                    ; Avg External Auto Occ.
 TDTab    =  '6'                     ; Total Psn Trip tab no. in Trip Dist. output file

ELSEIF (PURP=4) ; NHW Loop
 MCFILE   = '%_iter_%_NHW_NL_MC.MTT' ;AECOM Mode Choice file           (Input)
 TDFILE   = '%_iter_%_NHW.PTT'     ;Trip distibution output          (Input)
 MC123OCC = '%_iter_%_NHW_adr.mat'        ;HBW Auto Drv trips- 1,2,3+ Occ.  (Output)
 PURPOSE  = 'NHW'                    ;
 Avg3P_Occ=  3.50                    ; Avg Auto Occupancy for autos w/ 3+ person
 ExtCarOcc=  1.28                    ; Avg External Auto Occ.
 TDTab    =  '3'                     ; Total Psn Trip tab no. in Trip Dist. output file


ELSEIF (PURP=5) ; NHO Loop
 MCFILE   = '%_iter_%_NHO_NL_MC.MTT' ;AECOM Mode Choice file           (Input)
 TDFILE   = '%_iter_%_NHO.PTT'     ;Trip distibution output           (Input)
 MC123OCC = '%_iter_%_NHO_adr.mat'        ;HBW Auto Drv trips- 1,2,3+ Occ.  (Output)
 PURPOSE  = 'NHO'                    ;
 Avg3P_Occ=  3.50                    ; Avg Auto Occupancy for autos w/ 3+ person
 ExtCarOcc=  1.28                    ; Avg External Auto Occ.
 TDTab    =  '3'                     ; Total Psn Trip tab no. in Trip Dist. output file

ENDIF
;
;//////////////////////////////////////////////////////////////////

RUN PGM=MATRIX
  PAGEHEIGHT= 32767

    MATI[1]=@MCFILE@           ;  MODE CHOICE MODEL OUTPUT FILE (for INTL TRIPS)
    MATI[2]=@TDfILE@           ;  TRIP DISTRIBUTION OUTPUT FILE (for EXTL TRIPS)

    ; put INTERNAL 1,2,3+ OCC AUTO PERSON TRIPS IN MTX 1,2,3
        FILLMW MW[1]  = MI.1.1,2,3

    ; compute internal auto driver trips, by occ group in mtx 11,12,13
        MW[11]  = MW[1] / 1.0               ;;  intl 1-occ. auto drivers
        MW[12]  = MW[2] / 2.0               ;;  intl 2-occ. auto drivers
        MW[13]  = MW[3] / @Avg3P_Occ@       ;;  intl 3+occ. auto drivers

    ; put TOTAL motorized person trips in mtx 20.
        MW[20] = MI.2.@TDtab@

    ; the external portion(auto person trips) will be extracted from mtx 20, and put into 30
    ; .
        IF (I <  @FstExtZn@)  MW[22]  = 1.0, include = @FstExtZn@-@Zonesize@ ;
        IF (I >= @FstExtZn@)  MW[22]  = 1.0, exclude = @FstExtZn@-@Zonesize@ ;

        MW[30] = MW[20] * MW[22]         ;; Extl auto person trips

    ; compute external auto driver trips in mtx 40, and apportion among occ groups
    ; using standard occ. curves

        MW[40] = MW[30] / @ExtCarOcc@    ;; Extl Auto driver trips

JLOOP
  XCarOcc =@ExtCarOcc@
; Determine LOV Vehicles in 1,2,3&4+ occupant groups using model
; COG's disaggrgegation model.

        IF     (XCarOcc  < 1.0050) ;  Make sure the computed Car Occ.
                XCarOcc  = 1.0050  ;  is between 1.005 and 2.500
        ELSEIF (XCarOcc  > 2.5000) ;  -- if not establish boundary
                XCarOcc  = 2.5000  ;      conditions
        ENDIF
;
; Apply Car Occ. Pct Model-Computes Pct Vehs.in Occ groups as function
; of avg auto occ.  The function is continuous  but piecewise.
;
        IF     (XCarOcc = 1.0050 - 1.1199999)
         MW[21] =  2.00264 - (0.9989 * XCarOcc) ; Shr of 1-Occ Vehs
         MW[22] = -1.00050 + (0.9952 * XCarOcc) ; Shr of 2-Occ Vehs
         MW[23] = -0.00158 + (0.0029 * XCarOcc) ; Shr of 3-Occ Vehs
         MW[24] = -0.00056 + (0.0008 * XCarOcc) ; Shr of 4-Occ Vehs
        ELSEIF (XCarOcc = 1.1200 - 2.5000)
         MW[21] =  1.59600 - (0.6357 * XCarOcc) ; Shr of 1-Occ Vehs
         MW[22] = -0.31143 + (0.3800 * XCarOcc) ; Shr of 2-Occ Vehs
         MW[23] = -0.17082 + (0.1540 * XCarOcc) ; Shr of 3-Occ Vehs
         MW[24] = -0.11375 + (0.1017 * XCarOcc) ; Shr of 4-Occ Vehs
        ENDIF

        ;
        ;   Apply Modeled Shares to the Extl Auto Drivers in mtx 51-54

         MW[51] =(MW[21] * MW[40]) ; Estimated Extl 1 occ vehicles
         MW[52] =(MW[22] * MW[40]) ; Estimated Extl 2 occ vehicles
         MW[53] =(MW[23] * MW[40]) ; Estimated Extl 3 occ vehicles
         MW[54] =(MW[24] * MW[40]) ; Estimated Extl 4+occ vehicles


; compute add intl and extl auto drivers by occ. groups together
; in mtx 61,62,63.  Total adrs will be in mtx 70

         MW[61] = MW[51] + MW[11]           ; Total 1-Occ Total Auto Drivers
         MW[62] = MW[52] + MW[12]           ;       2-occ
         MW[63] = MW[53] + MW[54] + MW[13]  ;       3+occ

         MW[70] = mw[61] + MW[62] + MW[63]
;
endjloop



JLOOP

; Lets sum up the above to get neat total summaries
     Int1_OccAPsn  =   Int1_OccAPsn + MW[1]                               ;
     Int2_OccAPsn  =   Int2_OccAPsn + MW[2]                               ;
     Int3POccAPsn  =   Int3POccAPsn + MW[3]                               ;
     IntAutoPsn    =   IntAutoPsn   + MW[1] + MW[2]+ MW[3]                              ;

     Int1_OccADrv  =   Int1_OccADrv + MW[11]                              ;
     Int2_OccADrv  =   Int2_OccADrv + MW[12]                              ;
     Int3POccADrv  =   Int3POccADrv + MW[13]                              ;
     IntAutoDrv    =   IntAutoDrv   + MW[11] + MW[12]+ MW[13]                              ;

     TotalMotorPsn =   TotalMotorPsn + MW[20]                              ;

     ExtAutoPsn    =   ExtAutoPsn   + MW[30]                              ;

     ExtAutoDrv    =   ExtAutoDrv   + MW[40]                              ;

     Ext1_OccADrv  =   Ext1_OccADrv + MW[51]                              ;
     Ext2_OccADrv  =   Ext2_OccADrv + MW[52]                              ;
     Ext3_OccADrv  =   Ext3_OccADrv + MW[53]                              ;
     Ext4POccADrv  =   Ext4POccADrv + MW[54]                              ;
     ExtchkAdrv    =   ExtchkADrv   + MW[51]+ MW[52]+ MW[53]+ MW[54]      ;

     Tot1_OccADrv  =   Tot1_OccADrv + MW[61]                              ;
     Tot2_OccADrv  =   Tot2_OccADrv + MW[62]                              ;
     Tot3POccADrv  =   Tot3POccADrv + MW[63]                              ;

     TotalAutoDrv  =   TotalAutoDrv + MW[70]                              ;
endjloop

IF (I == ZONES)
;


 Print LIST='/bt     '
 LIST='SUMMARY OF ','@PURPOSE@',' ITERATION: ','%_iter_%','  AUTO DRIVER TRIP RESULTS'
 LIST='   '
 Print form = 12.2  LIST='    Assumed Avg  3+Veh. Occ.:  ',@Avg3P_Occ@
 Print form = 12.2  LIST='    Assumed Extl Veh Occ.   :  ',@ExtCarOcc@
 LIST='   '
 List=' Input Internal Auto Persons   '
 Print form = 12.0csv List='       1-Occ.: ',   Int1_OccAPsn
 Print form = 12.0csv List='       2-Occ.: ',   Int2_OccAPsn
 Print form = 12.0csv List='       3+Occ.: ',   Int3POccAPsn
 List=' ------------------------------- '
 List='       Total   ',    IntAutoPsn
 List='                                 '
 List=' Input / Derived Internal Auto Drivers  '
 Print form = 12.0csv List='       1-Occ.: '    Int1_OccADrv
 Print form = 12.0csv List='       2-Occ.: '    Int2_OccADrv
 Print form = 12.0csv List='       3+Occ.: '    Int3POccADrv
 List=' ------------------------------- '
 Print form = 12.0csv List='       Total   ',   IntAutoDrv
 List='                '                   '
 Print form = 12.0csv List='  Input Total Motorized Person   ',  TotalMotorPsn
 List='                            '
 Print form = 12.0csv List='  Input Total External Auto Psn  ',  ExtAutoPsn
 List='                           '
 Print form = 12.0csv List=' Input/Derived External Auto Drv ',  ExtAutoDrv
 List='             '
 List=' Estimated External Auto Drivers  '
 Print form = 12.0csv List='       1-Occ.: ',   Ext1_OccADrv
 Print form = 12.0csv List='       2-Occ.: ',   Ext2_OccADrv
 Print form = 12.0csv List='       3-Occ.: ',   Ext3_OccADrv
 Print form = 12.0csv List='       4+Occ.: ',   Ext4POccADrv
 List=' ------------------------------- '
 Print form = 12.0csv List='       Total   ',   ExtchkADrv
 List='       '
 List=' Output / Combined Internal/External Auto Drivers  '
 Print form = 12.0csv List='       1-Occ.: '    Tot1_OccADrv
 Print form = 12.0csv List='       2-Occ.: '    Tot2_OccADrv
 Print form = 12.0csv List='       3+Occ.: '    Tot3POccADrv
 List=' ------------------------------- '
 Print form = 12.0csv LIST='       Total   ',   TotalAutoDrv
 LIST='        '
 LIST='===  END OF ','@PURPOSE@',' ITERATION: ','%_iter_%',' AUTO DRV RESULTS ==='
 LIST='/et     '
ENDIF

MATO=@MC123OCC@,MO=61,62,63 ; output file designation

ENDRUN
ENDLOOP
