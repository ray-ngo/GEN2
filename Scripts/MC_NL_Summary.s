;--------------------------------------------------------------------
; Program Name: MC_NL_Summary.s
; Version 2.3 Model w/ Nested Logit MC model
;
; Summarize final table by purpose & Mode & Submode
; 8/30/11 - Juris. level tables expanded to include auto person trips by occupant levels
;           (SOV, HOV 2-occ. and HOV 3+occ. auto person trips)
;
;
;  65 tables are written out: 6 purposes (HBW,HBS,HBO,NHW,NHO,Total) by 13 modes,submodes:
;  1.      Motorized Person
;  2.      Transit
;  3.      Transit Percentage
;  4.      Auto Person
;  5.      SOV Person
;  6.      HOV2Occ Person
;  7.      HOV3+Occ Person
;  8.      Auto Driver
;  9.      Auto Occupancy
; 10.     Commuter Rail
; 11.     All Bus
; 12.     Bus & Metrorail
; 13.     Metrorail Only
;
;
; Environment Variables Used:
;              %_iter_%
;              %_year_%
;              %_alt_%
;
;
;--------------------------------------------------------------------
;   Modes in AECOM MC model    Summary modes
;     1 DR ALONE                 1 All transit         4-14
;     2 SR2                      2 Metrorail only      7,13,14
;     3 SR3+                     3 Metrorail related   7,13,14,6,11,12
;     4 WK-CR                    4 Auto person         1-3
;     5 WK-BUS                   5 Total motorized psn 1-14
;     6 WK-BU/MR                 6 Commuter rail       4,8 (may incl bus/Mrail)
;     7 WK-MR                    7 Bus only            5,9,10
;     8 PNR-CR                   8 Bus only, WMATA Compact area
;     8 KNR-CR
;     9 PNR-BUS
;    10 KNR-BUS
;    11 PNR-BU/MR
;    12 KNR-BU/MR
;    13 PNR-MR
;    14 KNR-MR
;--------------------------------------------------------------------

; ---------------------------------------------------------------
; Now summarize total purpose trip tables, by mode
; ---------------------------------------------------------------
pageheight=32767  ; Preclude header breaks
  HOV3_OCC = 3.50  ; Assumed Occupancy of 3+ Vehicles

RUN PGM=MATRIX

  ZONES=3722

    MATI[1]= %_iter_%_HBW_NL_MC.MTT
    MATI[2]= %_iter_%_HBS_NL_MC.MTT
    MATI[3]= %_iter_%_HBO_NL_MC.MTT
    MATI[4]= %_iter_%_NHW_NL_MC.MTT
    MATI[5]= %_iter_%_NHO_NL_MC.MTT

    FILLMW MW[101] = mi.1.1,2,3,4,5,6,7,8,9,10,11,12,13,14   ; HBW modal trip tabs 101..114
    FILLMW MW[201] = mi.2.1,2,3,4,5,6,7,8,9,10,11,12,13,14   ; HBS modal trip tabs 201..214
    FILLMW MW[301] = mi.3.1,2,3,4,5,6,7,8,9,10,11,12,13,14   ; HBO modal trip tabs 301..314
    FILLMW MW[401] = mi.4.1,2,3,4,5,6,7,8,9,10,11,12,13,14   ; NHW modal trip tabs 401..414
    FILLMW MW[501] = mi.5.1,2,3,4,5,6,7,8,9,10,11,12,13,14   ; NHO modal trip tabs 501..514

   MW[601]= MW[101]+MW[201]+MW[301]+MW[401]+MW[501]   MW[602]= MW[102]+MW[202]+MW[302]+MW[402]+MW[502]  ; sum
   MW[603]= MW[103]+MW[203]+MW[303]+MW[403]+MW[503]   MW[604]= MW[104]+MW[204]+MW[304]+MW[404]+MW[504]  ; total purpose
   MW[605]= MW[105]+MW[205]+MW[305]+MW[405]+MW[505]   MW[606]= MW[106]+MW[206]+MW[306]+MW[406]+MW[506]  ; trips in tabs
   MW[607]= MW[107]+MW[207]+MW[307]+MW[407]+MW[507]   MW[608]= MW[108]+MW[208]+MW[308]+MW[408]+MW[508]  ; 501..514
   MW[609]= MW[109]+MW[209]+MW[309]+MW[409]+MW[509]   MW[610]= MW[110]+MW[210]+MW[310]+MW[410]+MW[510]  ;
   MW[611]= MW[111]+MW[211]+MW[311]+MW[411]+MW[511]   MW[612]= MW[112]+MW[212]+MW[312]+MW[412]+MW[512]  ;
   MW[613]= MW[113]+MW[213]+MW[313]+MW[413]+MW[513]   MW[614]= MW[114]+MW[214]+MW[314]+MW[414]+MW[514]  ;

   MATO[1] = %_iter_%_ALL_NL_MC.MTT, MO=601-614, dec = 14*3 ; Total Purpose Mode Choice Trips
ENDRUN


;---------------------------------------------------------------
; Summarize the Mode Choice Model Output to Juris. Level
;---------------------------------------------------------------


DESCRIPT='Simulation - Year: %_year_% Alternative: %_alt_%   Iteration: %_iter_% '


LOOP PURP=1,6  ; Outer Loop for Each Purpose (HBW,HBS,HBO,NHW,NHO, Total)
IF (PURP=1)
    pur = 'HBW'
    purfile = 'A_HBW.tb1'
    MCOUTTAB='%_iter_%_HBW_NL_MC.MTT'
    PURPOSE ='Internal HBW Trips'
ELSEIF (PURP=2)
    pur = 'HBS'
    purfile = 'B_HBS.tb1'
    MCOUTTAB='%_iter_%_HBS_NL_MC.MTT'
    PURPOSE ='Internal HBS Trips'
ELSEIF (PURP=3)
    pur = 'HBO'
    purfile = 'C_HBO.tb1'
    MCOUTTAB='%_iter_%_HBO_NL_MC.MTT'
    PURPOSE ='Internal HBO Trips'
ELSEIF (PURP=4)
    pur = 'NHW'
    purfile = 'D_NHW.tb1'
    MCOUTTAB='%_iter_%_NHW_NL_MC.MTT'
    PURPOSE ='Internal NHW Trips'
ELSEIF (PURP=5)
    pur = 'NHO'
    purfile = 'E_NHO.tb1'
    MCOUTTAB='%_iter_%_NHO_NL_MC.MTT'
    PURPOSE ='Internal NHO Trips '
ELSEIF (PURP=6)
    pur = 'ALL'
    purfile = 'F_ALL.tb1'
    MCOUTTAB='%_iter_%_ALL_NL_MC.MTT'
    PURPOSE ='Total Internal Trips '
ENDIF

;---------------------------------------------------------------
; Summarize the Est./Obs Output Files to Juris. Level
;---------------------------------------------------------------

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
  PAGEHEIGHT= 32767
  ZONES=3722
  MATI[1]= @MCOUTTAB@


  MW[01]  = MI.1.4  + MI.1.5  + MI.1.6  + MI.1.7  + MI.1.8  +   ; 1/Transit
            MI.1.9  + MI.1.10 + MI.1.11 + MI.1.12 + MI.1.13 +
            MI.1.14

  MW[02]  = MI.1.1  +  MI.1.2      + MI.1.3                     ; 2/Auto_Psn
  MW[03]  = MI.1.1  + (MI.1.2/2.0) + MI.1.3/@HOV3_OCC@          ; 3/Auto_Drv


  MW[04]  = MW[1] + MW[2]                                       ; 4/Person


  MW[05]  = MI.1.4  + MI.1.5  + MI.1.6  + MI.1.7                ; 5/TRN_Wlk
  MW[06]  = MI.1.8  + MI.1.9  + MI.1.11 + MI.1.13               ; 6/TRN_PNR
  MW[07]  = MI.1.10 + MI.1.12 + MI.1.14                         ; 7/TRN_KNR

  MW[08] = MI.1.1      ; DR ALONE                               ; 8/SOV_Psn
  MW[09] = MI.1.2      ; SR2                                    ; 9/HOV2_Psn
  MW[10] = MI.1.3      ; SR3+                                   ;10/HOV3_Psn

  MW[11] = MI.1.4      ; WK-CR                                  ;11/WLK_CR
  MW[12] = MI.1.5      ; WK-AB                                  ;12/WLK_AB
  MW[13] = MI.1.6      ; WK-BM                                  ;13/WLK_BM
  MW[14] = MI.1.7      ; WK-MR                                  ;14/WLK_MR

  MW[15] = MI.1.8      ; PNR-CR                                 ;15/PNR_CR
  MW[16] = MI.1.9      ; PNR-AB                                 ;16/PNR_AB
  MW[17] = MI.1.10     ; KNR-AB                                 ;17/KNR_AB
  MW[18] = MI.1.11     ; PNR-BM                                 ;18/PNR_BM
  MW[19] = MI.1.12     ; KNR-BM                                 ;19/KNR_BM
  MW[20] = MI.1.13     ; PNR-MR                                 ;20/PNR_MR
  MW[21] = MI.1.14     ; KNR-MR                                 ;21/KNR_MR

  MW[22] = MW[11] + MW[15]                                     ;22/cr
  MW[23] = MW[12] + MW[16] + MW[17]                            ;23/ab
  MW[24] = MW[13] + MW[18] + MW[19]                            ;24/bm
  MW[25] = MW[14] + MW[20] + MW[21]                            ;25/mr

  MW[26] = MI.1.1/1.0                                          ;26/SOV_vehs
  MW[27] = MI.1.2/2.0                                          ;27/HOV2_vehs
  MW[28] = MI.1.3/@HOV3_OCC@                                   ;28/HOV3_vehs

  MW[30]= 0            ; dummy/placemarker table


;; ACCUMULATE MODAL TOTALS
    Transit          =  Transit   + ROWSUM(01)

    Auto_Psn         =  Auto_Psn  + ROWSUM(02)
    Auto_Drv         =  Auto_Drv  + ROWSUM(03)


    Person           =  Person    + ROWSUM(01) + ROWSUM(02)
    SOV_Psn          =  SOV_Psn   + ROWSUM(08)
    HOV2_Psn         =  HOV2_Psn  + ROWSUM(09)
    HOV3_Psn         =  HOV3_Psn  + ROWSUM(10)

    SOV_Veh          =  SOV_Veh   + ROWSUM(26)
    HOV2_Veh         =  HOV2_Veh  + ROWSUM(27)
    HOV3_Veh         =  HOV3_Veh  + ROWSUM(28)

    Trn_WLK          =  Trn_WLK   + ROWSUM(11) + ROWSUM(12) + ROWSUM(13) + ROWSUM(14)
    Trn_PNR          =  Trn_PNR   + ROWSUM(15) + ROWSUM(16) + ROWSUM(18) + ROWSUM(20)
    Trn_KNR          =  Trn_KNR   + ROWSUM(17) + ROWSUM(19) + ROWSUM(21)

    CR               =  CR        + ROWSUM(11) + ROWSUM(15)
    AB               =  AB        + ROWSUM(12) + ROWSUM(16) + ROWSUM(17)
    BM               =  BM        + ROWSUM(13) + ROWSUM(18) + ROWSUM(19)
    MR               =  MR        + ROWSUM(14) + ROWSUM(20) + ROWSUM(21)

    WLK_CR           =  WLK_CR    + ROWSUM(11)
    WLK_AB           =  WLK_AB    + ROWSUM(12)
    WLK_BM           =  WLK_BM    + ROWSUM(13)
    WLK_MR           =  WLK_MR    + ROWSUM(14)

    PNR_CR           =  PNR_CR    + ROWSUM(15)
    PNR_AB           =  PNR_AB    + ROWSUM(16)
    PNR_BM           =  PNR_BM    + ROWSUM(18)
    PNR_MR           =  PNR_MR    + ROWSUM(20)

    KNR_AB           =  KNR_AB    + ROWSUM(17)
    KNR_BM           =  KNR_BM    + ROWSUM(19)
    KNR_MR           =  KNR_MR    + ROWSUM(21)

    IF (I=ZONES)
       ;;
       ;; compute regional rates
       ;;
        Transit_Pct  =  Transit/Person    * 100.00
        Auto_Occ     =  Auto_Psn/Auto_Drv


       ;; print global totals:
         PRINT               LIST=' Purpose: ','@pur@', '  Regional Totals Summary',  file= @purfile@
         PRINT               LIST='      '
         PRINT FORM=12.0csv List= '      ','       Transit:             ', Transit      ,file= @purfile@;
         PRINT FORM=12.0csv List= '      ','       Auto_Person:         ', Auto_Psn     ,file= @purfile@;
         PRINT FORM=12.0csv List= '      ','      --------------------------------',file= @purfile@;
         PRINT FORM=12.0csv List= '      ','         Total_Person:      ', Person       ,file= @purfile@;
         PRINT FORM=12.0csv List= '      ','                                    '  ,file= @purfile@;
         PRINT FORM=12.2csv List= '      ','       Transit Pct.:        ', Transit_Pct  ,file= @purfile@;
         PRINT FORM=12.0csv List= '      ','                                    '  ,file= @purfile@;
         PRINT FORM=12.0csv List= '      ','                                    '  ,file= @purfile@;
         PRINT FORM=12.0csv List= '      ','       SOV_Auto_Person:     ', SOV_Psn      ,file= @purfile@;
         PRINT FORM=12.0csv List= '      ','       HOV2_Auto_Person:    ', HOV2_Psn     ,file= @purfile@;
         PRINT FORM=12.0csv List= '      ','       HOV3+Auto_Person     ', HOV3_Psn     ,file= @purfile@;
         PRINT FORM=12.0csv List= '      ','      --------------------------------'  ,file= @purfile@;
         PRINT FORM=12.0csv List= '      ','         Auto_Person:       ', Auto_Psn     ,file= @purfile@;
         PRINT FORM=12.0csv List= '      ','                                    '  ,file= @purfile@;
         PRINT FORM=12.0csv List= '      ','       SOV_Auto_Driver:     ', SOV_Veh      ,file= @purfile@;
         PRINT FORM=12.0csv List= '      ','       HOV2_Auto_Driver:    ', HOV2_Veh     ,file= @purfile@;
         PRINT FORM=12.0csv List= '      ','       HOV3+Auto_Driver:    ', HOV3_Veh     ,file= @purfile@;
         PRINT FORM=12.0csv List= '      ','      --------------------------------'  ,file= @purfile@;
         PRINT FORM=12.0csv List= '      ','         Auto_Driver:       ', Auto_Drv     ,file= @purfile@;
         PRINT FORM=12.0csv List= '      ','                                    '  ,file= @purfile@;
         PRINT FORM=12.2csv List= '      ','         Auto Occupancy:    ', Auto_Occ  ,file= @purfile@;
         PRINT FORM=12.0csv List= '      ','                                    '  ,file= @purfile@;
         PRINT FORM=12.0csv List= '      ','                                    '  ,file= @purfile@;
         PRINT FORM=12.0csv List= '      ','       Commuter_Rail:       ', CR           ,file= @purfile@;
         PRINT FORM=12.0csv List= '      ','       All_Bus:             ', AB           ,file= @purfile@;
         PRINT FORM=12.0csv List= '      ','       Bus&Metrorail:       ', BM           ,file= @purfile@;
         PRINT FORM=12.0csv List= '      ','       Metrorail_Only:      ', MR           ,file= @purfile@;
         PRINT FORM=12.0csv List= '      ','      -------------------------------- '  ,file= @purfile@;
         PRINT FORM=12.0csv List= '      ','          Transit:          ', Transit      ,file= @purfile@;
         PRINT FORM=12.0csv List= '      ','                                    '  ,file= @purfile@;
                                                                                   ;
         PRINT FORM=12.0csv List= '      ','       Walk_Commuter_Rail:  ', WLK_CR       ,file= @purfile@;
         PRINT FORM=12.0csv List= '      ','       Walk_All_Bus         ', WLK_AB       ,file= @purfile@;
         PRINT FORM=12.0csv List= '      ','       Walk_Bus_&_Metrorail:', WLK_BM       ,file= @purfile@;
         PRINT FORM=12.0csv List= '      ','       Walk_Metrorail_Only: ', WLK_MR       ,file= @purfile@;
         PRINT FORM=12.0csv List= '      ','      -------------------------------- '  ,file= @purfile@;
         PRINT FORM=12.0csv List= '      ','         Total WLK Acc:     ', Trn_WLK      ,file= @purfile@;
         PRINT FORM=12.0csv List= '      ','                                    '  ,file= @purfile@;
         PRINT FORM=12.0csv List= '      ','       PNR_Commuter_Rail:  ', PNR_CR       ,file= @purfile@;
         PRINT FORM=12.0csv List= '      ','       PNR_All_Bus         ', PNR_AB       ,file= @purfile@;
         PRINT FORM=12.0csv List= '      ','       PNR_Bus_&_Metrorail:', PNR_BM       ,file= @purfile@;
         PRINT FORM=12.0csv List= '      ','       PNR_Metrorail_Only: ', PNR_MR       ,file= @purfile@;
         PRINT FORM=12.0csv List= '      ','      -------------------------------- '  ,file= @purfile@;
         PRINT FORM=12.0csv List= '      ','         Total PNR Acc:     ', Trn_PNR      ,file= @purfile@;
         PRINT FORM=12.0csv List= '      ','                                    '  ,file= @purfile@;
         PRINT FORM=12.0csv List= '      ','       KNR_ALL_Bus:        ', KNR_AB       ,file= @purfile@;
         PRINT FORM=12.0csv List= '      ','       KNR_Bus_&_Metrorail:', KNR_BM       ,file= @purfile@;
         PRINT FORM=12.0csv List= '      ','       KNR_Metrorail_Only: ', KNR_MR       ,file= @purfile@;
         PRINT FORM=12.0csv List= '      ','      -------------------------------- '  ,file= @purfile@;
         PRINT FORM=12.0csv List= '      ','         Total KNR Acc:     ', Trn_KNR      ,file= @purfile@;
         PRINT FORM=12.0csv List= '      ','                                    '  ,file= @purfile@;
         PRINT               LIST=' ====== End ','@pur@',' Purpose =============== '  ,file= @purfile@;
         PRINT FORM=12.0csv List= '      ','     ','                              '  ,file= @purfile@;
         PRINT LIST='/et            '

    ENDIF

        ;;
  FILEO MATO[01]  = TEMP.trn MO= 1,30
        MATO[02]  = TEMP.apn MO= 2,30
        MATO[03]  = TEMP.sov MO= 8,30
        MATO[04]  = TEMP.hv2 MO= 9,30
        MATO[05]  = TEMP.hv3 MO= 10,30
        MATO[06]  = TEMP.adr MO= 3,30
        MATO[07]  = TEMP.psn MO= 4,30
        MATO[08]  = TEMP.cr  MO=22,30
        MATO[09]  = TEMP.ab  MO=23,30
        MATO[10]  = TEMP.bm  MO=24,30
        MATO[11]  = TEMP.mr  MO=25,30
        MATO[12]  = TEMP.trp MO=1,4
        MATO[13]  = TEMP.occ MO=2,3

  ; renumber OUT.MAT according to DJ.EQV
  RENUMBER FILE=DJ.EQV, MISSINGZI=M, MISSINGZO=W
ENDRUN

;
LOOP INDEX2=1,13  ; Inner Loop for Each Summary Type:
;
;
;
IF (INDEX2=1)                    ; Parameters for each table:
       SQFNAME='temp.psn'        ;
       MODE ='Motorized Person'
       DCML=0
       TABTYPE=1
       SCALE=1                   ;
       OPER='+'                  ;
     ELSEIF (INDEX2=2)
       SQFNAME='temp.trn'        ; - name of squeezed modal trip table(s)
       MODE ='Transit        '   ; - mode label od trip table
       DCML=0                    ; - decimal specification
       TABTYPE=1                 ; - table type(1/2)-involves 1 or 2 trip tables
       SCALE=1                   ; - scale factor to be applied (if desired)
       OPER='+'                  ; - operation(if tabtype=2) Tab1(?)Tab2=Result
     ELSEIF (INDEX2=3 )
       SQFNAME='temp.trp'        ;
       MODE ='Transit Percentage'
       DCML=1
       TABTYPE=2
       SCALE=100                 ;
       OPER='/'
     ELSEIF (INDEX2=4)
       SQFNAME='temp.apn'        ;
       MODE ='Auto Person    '
       DCML=0
       TABTYPE=1
       SCALE=1                   ;
       OPER='+'                  ;
     ELSEIF (INDEX2=5)
       SQFNAME='temp.sov'        ;
       MODE ='SOV Person        '
       DCML=0
       TABTYPE=1
       SCALE=1                   ;
       OPER='+'
     ELSEIF (INDEX2=6 )
       SQFNAME='temp.hv2'        ;
       MODE ='HOV2Occ Person    '
       DCML=0
       TABTYPE=1
       SCALE=1                   ;
       OPER='+'
     ELSEIF (INDEX2=7 )
       SQFNAME='temp.hv3'        ;
       MODE ='HOV3+Occ Person   '
       DCML=0
       TABTYPE=1
       SCALE=1                   ;
       OPER='+'
     ELSEIF (INDEX2=8 )
       SQFNAME='temp.adr'        ;
       MODE ='Auto Driver       '
       DCML=0
       TABTYPE=1
       SCALE=1                   ;
       OPER='+'
     ELSEIF (INDEX2=9 )
       SQFNAME='temp.occ'        ;
       MODE ='Auto Occupancy    '
       DCML=2
       TABTYPE=2
       SCALE=1                  ;
       OPER='/'
     ELSEIF (INDEX2=10)
       SQFNAME='temp.cr '        ;
       MODE ='Commuter Rail  '
       DCML=0
       TABTYPE=1
       SCALE=1                   ;
       OPER='+'                  ;
     ELSEIF (INDEX2=11)
       SQFNAME='temp.ab '        ;
       MODE ='All Bus    '
       DCML=0
       TABTYPE=1
       SCALE=1                   ;
       OPER='+'                  ;
     ELSEIF (INDEX2=12)
       SQFNAME='temp.bm'        ;
       MODE ='Bus & Metrorail  '
       DCML=0
       TABTYPE=1
       SCALE=1                   ;
       OPER='+'                  ;
     ELSEIF (INDEX2=13)
       SQFNAME='temp.mr'        ;
       MODE ='Metrorail Only '
       DCML=0
       TABTYPE=1
       SCALE=1                   ;
       OPER='+'                  ;
     ENDIF
;
RUN PGM=MATRIX
  PAGEHEIGHT= 32767
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
  denom  =     ROWSUM(3)
  IF (@TABTYPE@=2)
       if (denom>0)  RSUM = @SCALE@*ROWSUM(2)@OPER@ROWSUM(3)  ; non-'normal' table
  ENDIF                                     ; compute the row marginal(%)

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
  ELSE ;  (I=24)
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

ENDLOOP ; End 'Inner' Loop
ENDLOOP ; End 'Outer' Loop

