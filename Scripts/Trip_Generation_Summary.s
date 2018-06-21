*del Voya*.prn
;
ReportFile ='%_iter_%_Trip_Generation_Summary.txt'

;-----------------------------------------------------------------------------------------------------------------
; Trip_Generation_Summary.s - Summarize demographics and trip ends by purpose at the juris. level ("cores" broken out)
;                             and at area type level.
;
;-----------------------------------------------------------------------------------------------------------------
;;;----- Create Juris.TAZ Range Lookup --------------------
; file include jur index(1-23), 8 TAZ 'Low/High' ranges, and jur name (Some juris. categories have more than one TAZ range)
;
;
COPY File = JurCore.lkp
 1,    1,    4,    6,    47,    49,    50,   52,    63,  65,  65, 181, 209,  282,  287,  374,  381,   DC_Core     ,
 2,    5,    5,   48,    48,    51,    51,   64,    64,  66, 180, 210, 281,  288,  373,  382,  393,   DC_Noncore  ,
 3,  394,  769,    0,     0,     0,     0,    0,     0,   0,   0,   0,   0,    0,    0,    0,    0,   Mtg         ,
 4,  771,  776,  778,  1404,     0,     0,    0,     0,   0,   0,   0,   0,    0,    0,    0,    0,   PGeo        ,
 5, 1471, 1476, 1486,  1489,  1495,  1497,    0,     0,   0,   0,   0,   0,    0,    0,    0,    0,   ArlCore     ,
 6, 1405, 1470, 1477,  1485,  1490,  1494, 1498,  1545,   0,   0,   0,   0,    0,    0,    0,    0,   ArlNCore    ,
 7, 1546, 1610,    0,     0,     0,     0,    0,     0,   0,   0,   0,   0,    0,    0,    0,    0,   ALX         ,
 8, 1611, 2159,    0,     0,     0,     0,    0,     0,   0,   0,   0,   0,    0,    0,    0,    0,   FFX         ,
 9, 2160, 2441,    0,     0,     0,     0,    0,     0,   0,   0,   0,   0,    0,    0,    0,    0,   LDN         ,
10, 2442, 2554, 2556,  2628,  2630,  2819,    0,     0,   0,   0,   0,   0,    0,    0,    0,    0,   PW          ,
11, 2820, 2949,    0,     0,     0,     0,    0,     0,   0,   0,   0,   0,    0,    0,    0,    0,   Frd         ,
12, 3230, 3265, 3268,  3287,     0,     0,    0,     0,   0,   0,   0,   0,    0,    0,    0,    0,   Car         ,
13, 2950, 3017,    0,     0,     0,     0,    0,     0,   0,   0,   0,   0,    0,    0,    0,    0,   How         ,
14, 3018, 3102, 3104,  3116,     0,     0,    0,     0,   0,   0,   0,   0,    0,    0,    0,    0,   AnnAr       ,
15, 3288, 3334,    0,     0,     0,     0,    0,     0,   0,   0,   0,   0,    0,    0,    0,    0,   Calv        ,
16, 3335, 3409,    0,     0,     0,     0,    0,     0,   0,   0,   0,   0,    0,    0,    0,    0,   STM         ,
17, 3117, 3229,    0,     0,     0,     0,    0,     0,   0,   0,   0,   0,    0,    0,    0,    0,   Chs         ,
18, 3604, 3653,    0,     0,     0,     0,    0,     0,   0,   0,   0,   0,    0,    0,    0,    0,   Fau         ,
19, 3449, 3477, 3479,  3481,  3483,  3494, 3496,  3541,   0,   0,   0,   0,    0,    0,    0,    0,   Stf         ,
20, 3654, 3662, 3663,  3675,     0,     0,    0,     0,   0,   0,   0,   0,    0,    0,    0,    0,   Clk_Jeff    ,
21, 3435, 3448, 3542,  3543,  3545,  3603,    0,     0,   0,   0,   0,   0,    0,    0,    0,    0,   Fbg_Spots   ,
22, 3410, 3434,    0,     0,     0,     0,    0,     0,   0,   0,   0,   0,    0,    0,    0,    0,   KGeo        ,
23, 3676, 3722,    0,     0,     0,     0,    0,     0,   0,   0,   0,   0,    0,    0,    0,    0,   Externals   ,
ENDCOPY
;--------------------------------------------------------
; Put Juris-TAZ lookup into a DBF file
;
;
RUN PGM=MATRIX
ZONES=1
FILEI  RECI = JurCore.lkp,
 Jno             =  1,
 LoTAZ1          =  2,
 HiTAZ1          =  3,
 LoTAZ2          =  4,
 HiTAZ2          =  5,
 LoTAZ3          =  6,
 HiTAZ3          =  7,
 LoTAZ4          =  8,
 HiTAZ4          =  9,
 LoTAZ5          = 10,
 HiTAZ5          = 11,
 LoTAZ6          = 12,
 HiTAZ6          = 13,
 LoTAZ7          = 14,
 HiTAZ7          = 15,
 LoTAZ8          = 16,
 HiTAZ8          = 17,
 JName(c)        = 18,
 DELIMITER[1]=","
 n=n+1
 RECO[1] ="JurCore.dbf",
 Fields = RECI.ALLFIELDS ;
 WRITE RECO=1
endrun
;
;------------------------------------------------------------------------------------------------------------
; now summarize demographic data and trip end data files
;------------------------------------------------------------------------------------------------------------
RUN PGM=MATRIX
ZONES =1
;; zone file input
FILEI DBI[1] = "TripGen_LUFile.dbf"
;;variables in file:  TAZ     HH      HHPOP   GQPOP   TOTPOP  TOTEMP  INDEMP  RETEMP  OFFEMP  OTHEMP  JURCODE LANDAREA

;; Juris.-TAZ lookup (core broken out)
FILEI DBI[2] = "JurCore.dbf"

;; Zonal trip productions
FILEI DBI[3] = "%_iter_%_Trip_Gen_productions_Comp.dbf"
;; variables in file:
;;TAZ     HBW_MTR_PS      HBW_NMT_PS      HBW_ALL_PS      HBWMTRP_I1      HBWMTRP_I2      HBWMTRP_I3      HBWMTRP_I4
;;        HBS_MTR_PS      HBS_NMT_PS      HBS_ALL_PS      HBSMTRP_I1      HBSMTRP_I2      HBSMTRP_I3      HBSMTRP_I4
;;        HBO_MTR_PS      HBO_NMT_PS      HBO_ALL_PS      HBOMTRP_I1      HBOMTRP_I2      HBOMTRP_I3      HBOMTRP_I4
;;        NHW_MTR_PS      NHW_NMT_PS      NHW_ALL_PS      NHO_MTR_PS      NHO_NMT_PS      NHO_ALL_PS

;;Zonal final/scaled trip attractions
FILEI DBI[4]="%_iter_%_Trip_Gen_Attractions_Comp.dbf"
;; variables in file:
;;TAZ     HBW_MTR_AS      HBW_NMT_AS      HBW_ALL_AS      HBWMTRA_I1      HBWMTRA_I2      HBWMTRA_I3      HBWMTRA_I4
;;        HBS_MTR_AS      HBS_NMT_AS      HBS_ALL_AS      HBSMTRA_I1      HBSMTRA_I2      HBSMTRA_I3      HBSMTRA_I4
;;        HBO_MTR_AS      HBO_NMT_AS      HBO_ALL_AS      HBOMTRA_I1      HBOMTRA_I2      HBOMTRA_I3      HBOMTRA_I4
;;        NHW_MTR_AS      NHW_NMT_AS      NHW_ALL_AS      NHO_MTR_AS      NHO_NMT_AS      NHO_ALL_AS




PRINTO[1]    = "@ReportFile@"
 ; juris and area type arrays:
 ARRAY   HH_Ja=25, HHPOP_Ja=25, GQPOP_Ja=25, TotPOP_Ja=25, TotEmp_Ja=25, IndEmp_Ja=25, RetEmp_Ja=25, OffEmp_Ja=25, OthEmp_Ja=25, LArea_Ja= 25
 ARRAY   HH_Aa=6 , HHPOP_Aa=6 , GQPOP_Aa=6 , TotPOP_Aa=6 , TotEmp_Aa=6 , IndEmp_Aa=6 , RetEmp_Aa=6 , OffEmp_Aa=6 , OthEmp_Aa=6 , LArea_Aa= 6

 ARRAY   AT_Za=3675        ; zonal area type array

 ARRAY   MTR_Pro_Ja=5,25   ; jurisdictional motor. productions
 ARRAY   NMT_Pro_Ja=5,25   ;                nonmot productions
 ARRAY   MTR_PTot_Ja=25    ;                       productions
 ARRAY   NMT_PTot_Ja=25    ;                       productions
 ARRAY   MTR_PTot_Aa=6     ;                       productions
 ARRAY   NMT_PTot_Aa=6     ;                       productions

 ARRAY   MTR_Att_Ja=5,25   ;                motor. attractions
 ARRAY   NMT_Att_Ja=5,25   ;                nonmot attractions
 ARRAY   MTR_ATot_Ja=25    ;                motor. attractions
 ARRAY   NMT_ATot_Ja=25    ;                nonmot attractions
 ARRAY   MTR_ATot_Aa=6     ;                motor. attractions
 ARRAY   NMT_ATot_Aa=6     ;                nonmot attractions

 ARRAY   MTR_ProInc_Ja=5,4,25 ; jurisdictional motor. productions by income group
 ARRAY   MTR_AttInc_Ja=5,4,25 ;             motor. attractions by income group

 ARRAY   MTR_Pro_Aa=5,6    ; area type      motor. productions
 ARRAY   NMT_Pro_Aa=5,6    ;                nonmot productions
 ARRAY   MTR_Att_Aa=5,6    ;                motor. attractions
 ARRAY   NMT_Att_Aa=5,6    ;                nonmot attractions

 ARRAY   MTR_ProInc_Aa=5,4,6 ; area type    motor. productions by income group
 ARRAY   MTR_AttInc_Aa=5,4,6 ;              motor. attractions by income group

 ARRAY   HHPrate_pj=5,25
 Array   HHTPrate_j=25,HHTPrate_p=5

 ARRAY   EMPArate_pj=5,25
 Array   EMPTArate_j=25,EMPTArate_p=5

 ;;#################################################################################
 ;;================================================================================
 ;; process land use file first                                                   =
 ;;================================================================================

 LOOP K = 1,dbi.1.NUMRECORDS
      x = DBIReadRecord(1,k)

        ; Define input variables in zone file
        _TAZ       = di.1.TAZ
        _HH        = di.1.HH
        _HHPOP     = di.1.HHPOP
        _GQPOP     = di.1.GQPOP
        _TotPOP    = di.1.TotPOP
        _TotEmp    = di.1.TotEmp
        _IndEmp    = di.1.IndEmp
        _RetEmp    = di.1.RetEmp
        _OffEmp    = di.1.OffEmp
        _OthEmp    = di.1.OthEmp
        _LArea     = di.1.Landarea
        _At        = di.1.Atype

        AT_Za[_TAZ] = _At    ; zonal area type array to be used later with trip prod/attr summaries

          ;; Slot TAZ into a jurisdiction --------------------
          ;; JDX = 25                       ; begin with assumed unknown juris
             Loop KK = 1,dbi.2.numrecords
                       xx = DBIReadRecord(2,kk)
                            IF ((_TAZ >= di.2.LoTAZ1 && _TAZ <= di.2.HiTAZ1) ||
                                (_TAZ >= di.2.LoTAZ2 && _TAZ <= di.2.HiTAZ2) ||
                                (_TAZ >= di.2.LoTAZ3 && _TAZ <= di.2.HiTAZ3) ||
                                (_TAZ >= di.2.LoTAZ4 && _TAZ <= di.2.HiTAZ4) ||
                                (_TAZ >= di.2.LoTAZ5 && _TAZ <= di.2.HiTAZ5) ||
                                (_TAZ >= di.2.LoTAZ6 && _TAZ <= di.2.HiTAZ6) ||
                                (_TAZ >= di.2.LoTAZ7 && _TAZ <= di.2.HiTAZ7) ||
                                (_TAZ >= di.2.LoTAZ8 && _TAZ <= di.2.HiTAZ8))
                                  JDX = di.2.Jno
                            ENDIF
             ENDLOOP

             ;; -------- Array accumulation for weighted HHs and trips by purpose-------

                 HH_Ja[jdx]     = HH_Ja[jdx]      +  di.1.HH
                 HHPOP_Ja[jdx]  = HHPOP_Ja[jdx]   +  di.1.HHPOP
                 GQPOP_Ja[jdx]  = GQPOP_Ja[jdx]   +  di.1.GQPOP
                 TotPOP_Ja[jdx] = TotPOP_Ja[jdx]  +  di.1.TotPOP
                 TotEmp_Ja[jdx] = TotEmp_Ja[jdx]  +  di.1.TotEmp
                 IndEmp_Ja[jdx] = IndEmp_Ja[jdx]  +  di.1.IndEmp
                 RetEmp_Ja[jdx] = RetEmp_Ja[jdx]  +  di.1.RetEmp
                 OffEmp_Ja[jdx] = OffEmp_Ja[jdx]  +  di.1.OffEmp
                 OthEmp_Ja[jdx] = OthEmp_Ja[jdx]  +  di.1.OthEmp
                 LArea_Ja[jdx]  = LArea_Ja[jdx]   +  di.1.Landarea

                 HH_Aa[_At]       = HH_Aa[_At]      +  di.1.HH
                 HHPOP_Aa[_At]    = HHPOP_Aa[_At]   +  di.1.HHPOP
                 GQPOP_Aa[_At]    = GQPOP_Aa[_At]   +  di.1.GQPOP
                 TotPOP_Aa[_At]   = TotPOP_Aa[_At]  +  di.1.TotPOP
                 TotEmp_Aa[_At]   = TotEmp_Aa[_At]  +  di.1.TotEmp
                 IndEmp_Aa[_At]   = IndEmp_Aa[_At]  +  di.1.IndEmp
                 RetEmp_Aa[_At]   = RetEmp_Aa[_At]  +  di.1.RetEmp
                 OffEmp_Aa[_At]   = OffEmp_Aa[_At]  +  di.1.OffEmp
                 OthEmp_Aa[_At]   = OthEmp_Aa[_At]  +  di.1.OthEmp
                 LArea_Aa[_At]    = LArea_Aa[_At]   +  di.1.Landarea

                 HH_Tot     = HH_Tot      +  di.1.HH
                 HHPOP_Tot  = HHPOP_Tot   +  di.1.HHPOP
                 GQPOP_Tot  = GQPOP_Tot   +  di.1.GQPOP
                 TotPOP_Tot = TotPOP_Tot  +  di.1.TotPOP
                 TotEmp_Tot = TotEmp_Tot  +  di.1.TotEmp
                 IndEmp_Tot = IndEmp_Tot  +  di.1.IndEmp
                 RetEmp_Tot = RetEmp_Tot  +  di.1.RetEmp
                 OffEmp_Tot = OffEmp_Tot  +  di.1.OffEmp
                 OthEmp_Tot = OthEmp_Tot  +  di.1.OthEmp
                 LArea_Tot  = LArea_Tot   +  di.1.Landarea


             ;; --------             End of Array accumulation                   -------
 ENDLOOP

;; =========   Printout  Reports ==========================================================================
;;
;; ----------------------------------------------------------------------------------------------------------------------------------------
 Print PRINTO=1 LIST= '\n','\n','  Land Activity by Jurisdiction    ', '\n','\n'
 Print PRINTO=1 LIST='      Jurisdiction       ',' Households','     HH_Pop','     GQ_Pop','    Tot_Pop','  Total_Emp','    IND_Emp',
                                                 '    RET_Emp','    Off_Emp','    Oth_Emp','   LandArea','    HH_Size','  JobHHRatio ','\n'

 Loop KK = 1,dbi.2.numrecords
      xx = DBIReadRecord(2,kk)
      jdx = di.2.Jno


      HH_Size  = 0
      JobHHRat = 0
      if (HH_Ja[jdx]      > 0)   HH_Size  = HHPop_Ja[jdx]  / HH_Ja[jdx]
      if (TotEmp_Ja[jdx]  > 0)   JobHHRat = TotEmp_Ja[jdx] / HH_Ja[jdx]
      Print form=10csv PRINTO=1 LIST=
        di.2.JNAME(c25),' ', HH_Ja[jdx],' ', HHPOP_Ja[jdx],' ',GQPOP_Ja[jdx],' ',TotPop_Ja[jdx],' ',TotEMP_Ja[jdx],' ',
                            INDEmp_Ja[jdx],' ',RetEmp_Ja[jdx],' ',OffEmp_Ja[jdx],' ',OthEmp_Ja[jdx],' ',Larea_Ja[jdx](10.3csv),
                            HH_Size(10.3csv)  ,' ',JobHHRat(10.3csv)
 ENDLOOP

      HH_Size  = 0
      JobHHRat = 0
      if (HH_Tot       > 0)   HH_Size  = HHPop_Tot  / HH_Tot
      if (TotEmp_Tot   > 0)   JobHHRat = TotEmp_Tot / HH_Tot

  Print PRINTO=1 LIST='                          '
  Print form=10csv PRINTO=1 LIST='      TOTAL               ', HH_Tot,    ' ', HHPOP_Tot,' ',GQPOP_Tot,' ',TotPop_Tot,' ',TotEMP_Tot,' ',
                                                               INDEmp_Tot,' ',RetEmp_Tot,' ',OffEmp_Tot,' ',OthEmp_Tot,' ',Larea_Tot(10.3csv),
                                                               HH_Size(10.3csv) ,' ',JobHHRat(10.3csv)


;; ----------------------------------------------------------------------------------------------------------------------------------------
 Print PRINTO=1 LIST= '\n','\n',' Land Activity by Area Type                      ', '\n','\n'
 Print PRINTO=1 LIST='      Area Type          ',' Households','     HH_Pop','     GQ_Pop','    Tot_Pop','  Total_Emp','    IND_Emp',
                                                 '    RET_Emp','    Off_Emp','    Oth_Emp','   LandArea','    HH_Size','  JobHHRatio ','\n'

 Loop KK = 1,6

      Adx = kk


      HH_Size  = 0
      JobHHRat = 0
      if (HH_Aa[Adx]      > 0)   HH_Size  = HHPop_Aa[Adx]  / HH_Aa[Adx]
      if (TotEmp_Aa[Adx]  > 0)   JobHHRat = TotEmp_Aa[Adx] / HH_Aa[Adx]
      Print form=10csv PRINTO=1 LIST=
                    Adx,'                ', HH_Aa[Adx],' ', HHPOP_Aa[Adx],' ',GQPOP_Aa[Adx],' ',TotPop_Aa[Adx],' ',TotEMP_Aa[Adx],' ',
                                            INDEmp_Aa[Adx],' ',RetEmp_Aa[Adx],' ',OffEmp_Aa[Adx],' ',OthEmp_Aa[Adx],' ',Larea_Aa[Adx](10.3csv),
                                            HH_Size(10.3csv)  ,' ',JobHHRat(10.3csv)
 ENDLOOP

      HH_Size  = 0
      JobHHRat = 0
      if (HH_Tot       > 0)   HH_Size  = HHPop_Tot  / HH_Tot
      if (TotEmp_Tot   > 0)   JobHHRat = TotEmp_Tot / HH_Tot

  Print PRINTO=1 LIST='                          '
  Print form=10csv PRINTO=1 LIST='      TOTAL               ', HH_Tot,    ' ', HHPOP_Tot,' ',GQPOP_Tot,' ',TotPop_Tot,' ',TotEMP_Tot,' ',
                                                               INDEmp_Tot,' ',RetEmp_Tot,' ',OffEmp_Tot,' ',OthEmp_Tot,' ',Larea_Tot(10.3csv),
                                                               HH_Size(10.3csv) ,' ',JobHHRat(10.3csv)
 ;;#############################################################################################################################################
 ;;================================================================================
 ;; process trip productions next                                                 =
 ;;================================================================================

 LOOP K = 1,dbi.3.NUMRECORDS
      x = DBIReadRecord(3,k)
      if (K <= 3675)
        ; Define input variables in production zone file

        _TAZ        = di.3.TAZ
        _HBW_MTR_PS = di.3.HBW_MTR_PS
        _HBW_NMT_PS = di.3.HBW_NMT_PS
        _HBW_ALL_PS = di.3.HBW_ALL_PS
        _HBWMTRP_I1 = di.3.HBWMTRP_I1
        _HBWMTRP_I2 = di.3.HBWMTRP_I2
        _HBWMTRP_I3 = di.3.HBWMTRP_I3
        _HBWMTRP_I4 = di.3.HBWMTRP_I4
        _HBS_MTR_PS = di.3.HBS_MTR_PS
        _HBS_NMT_PS = di.3.HBS_NMT_PS
        _HBS_ALL_PS = di.3.HBS_ALL_PS
        _HBSMTRP_I1 = di.3.HBSMTRP_I1
        _HBSMTRP_I2 = di.3.HBSMTRP_I2
        _HBSMTRP_I3 = di.3.HBSMTRP_I3
        _HBSMTRP_I4 = di.3.HBSMTRP_I4
        _HBO_MTR_PS = di.3.HBO_MTR_PS
        _HBO_NMT_PS = di.3.HBO_NMT_PS
        _HBO_ALL_PS = di.3.HBO_ALL_PS
        _HBOMTRP_I1 = di.3.HBOMTRP_I1
        _HBOMTRP_I2 = di.3.HBOMTRP_I2
        _HBOMTRP_I3 = di.3.HBOMTRP_I3
        _HBOMTRP_I4 = di.3.HBOMTRP_I4
        _NHW_MTR_PS = di.3.NHW_MTR_PS
        _NHW_NMT_PS = di.3.NHW_NMT_PS
        _NHW_ALL_PS = di.3.NHW_ALL_PS
        _NHO_MTR_PS = di.3.NHO_MTR_PS
        _NHO_NMT_PS = di.3.NHO_NMT_PS
        _NHO_ALL_PS = di.3.NHO_ALL_PS

         ADX = AT_Za[_TAZ]                        ; slot cuurent taz into an area type

          ;; Slot TAZ into a jurisdiction --------------------
             Loop KK = 1,dbi.2.numrecords
                       xx = DBIReadRecord(2,kk)
                            IF ((_TAZ >= di.2.LoTAZ1 && _TAZ <= di.2.HiTAZ1) ||
                                (_TAZ >= di.2.LoTAZ2 && _TAZ <= di.2.HiTAZ2) ||
                                (_TAZ >= di.2.LoTAZ3 && _TAZ <= di.2.HiTAZ3) ||
                                (_TAZ >= di.2.LoTAZ4 && _TAZ <= di.2.HiTAZ4) ||
                                (_TAZ >= di.2.LoTAZ5 && _TAZ <= di.2.HiTAZ5) ||
                                (_TAZ >= di.2.LoTAZ6 && _TAZ <= di.2.HiTAZ6) ||
                                (_TAZ >= di.2.LoTAZ7 && _TAZ <= di.2.HiTAZ7) ||
                                (_TAZ >= di.2.LoTAZ8 && _TAZ <= di.2.HiTAZ8))
                                  JDX = di.2.Jno
                            ENDIF
             ENDLOOP

             ;; -------- Array accumulation for productions-------

;; total Ps
    Mtr_Pro_ja[1][jdx] = Mtr_Pro_ja[1][jdx]  +  di.3.HBW_MTR_Ps      Mtr_Pro_Aa[1][adx] = Mtr_Pro_Aa[1][adx]  +  di.3.HBW_MTR_Ps
    Mtr_Pro_ja[2][jdx] = Mtr_Pro_ja[2][jdx]  +  di.3.HBS_MTR_Ps      Mtr_Pro_Aa[2][adx] = Mtr_Pro_Aa[2][adx]  +  di.3.HBS_MTR_Ps
    Mtr_Pro_ja[3][jdx] = Mtr_Pro_ja[3][jdx]  +  di.3.HBO_MTR_Ps      Mtr_Pro_Aa[3][adx] = Mtr_Pro_Aa[3][adx]  +  di.3.HBO_MTR_Ps
    Mtr_Pro_ja[4][jdx] = Mtr_Pro_ja[4][jdx]  +  di.3.NHW_MTR_Ps      Mtr_Pro_Aa[4][adx] = Mtr_Pro_Aa[4][adx]  +  di.3.NHW_MTR_Ps
    Mtr_Pro_ja[5][jdx] = Mtr_Pro_ja[5][jdx]  +  di.3.NHO_MTR_Ps      Mtr_Pro_Aa[5][adx] = Mtr_Pro_Aa[5][adx]  +  di.3.NHO_MTR_Ps

    MTR_PTot_Ja[jdx]   = MTR_PTot_Ja[jdx]    +  di.3.HBW_MTR_Ps + di.3.HBS_MTR_Ps + di.3.HBO_MTR_Ps + di.3.NHW_MTR_Ps + di.3.NHO_MTR_Ps
    MTR_PTot_Aa[adx]   = MTR_PTot_Aa[Adx]    +  di.3.HBW_MTR_Ps + di.3.HBS_MTR_Ps + di.3.HBO_MTR_Ps + di.3.NHW_MTR_Ps + di.3.NHO_MTR_Ps

    NMT_Pro_ja[1][jdx] = NMT_Pro_ja[1][jdx]  +  di.3.HBW_NMT_Ps      NMT_Pro_Aa[1][adx] = NMT_Pro_Aa[1][adx]  +  di.3.HBW_NMT_Ps
    NMT_Pro_ja[2][jdx] = NMT_Pro_ja[2][jdx]  +  di.3.HBS_NMT_Ps      NMT_Pro_Aa[2][adx] = NMT_Pro_Aa[2][adx]  +  di.3.HBS_NMT_Ps
    NMT_Pro_ja[3][jdx] = NMT_Pro_ja[3][jdx]  +  di.3.HBO_NMT_Ps      NMT_Pro_Aa[3][adx] = NMT_Pro_Aa[3][adx]  +  di.3.HBO_NMT_Ps
    NMT_Pro_ja[4][jdx] = NMT_Pro_ja[4][jdx]  +  di.3.NHW_NMT_Ps      NMT_Pro_Aa[4][adx] = NMT_Pro_Aa[4][adx]  +  di.3.NHW_NMT_Ps
    NMT_Pro_ja[5][jdx] = NMT_Pro_ja[5][jdx]  +  di.3.NHO_NMT_Ps      NMT_Pro_Aa[5][adx] = NMT_Pro_Aa[5][adx]  +  di.3.NHO_NMT_Ps

    NMT_PTot_Ja[jdx]   = NMT_PTot_Ja[jdx]    +  di.3.HBW_NMT_Ps + di.3.HBS_NMT_Ps + di.3.HBO_NMT_Ps + di.3.NHW_NMT_Ps + di.3.NHO_NMT_Ps
    NMT_PTot_Aa[adx]   = NMT_PTot_Aa[adx]    +  di.3.HBW_NMT_Ps + di.3.HBS_NMT_Ps + di.3.HBO_NMT_Ps + di.3.NHW_NMT_Ps + di.3.NHO_NMT_Ps



;; total HB motorized Ps    by income
    Mtr_ProInc_ja[1][1][jdx] = Mtr_ProInc_ja[1][1][jdx]  +  di.3.HBWMTRP_I1     Mtr_ProInc_Aa[1][1][adx] = Mtr_ProInc_Aa[1][1][adx]  +  di.3.HBWMTRP_I1
    Mtr_ProInc_ja[2][1][jdx] = Mtr_ProInc_ja[2][1][jdx]  +  di.3.HBSMTRP_I1     Mtr_ProInc_Aa[2][1][adx] = Mtr_ProInc_Aa[2][1][adx]  +  di.3.HBSMTRP_I1
    Mtr_ProInc_ja[3][1][jdx] = Mtr_ProInc_ja[3][1][jdx]  +  di.3.HBOMTRP_I1     Mtr_ProInc_Aa[3][1][adx] = Mtr_ProInc_Aa[3][1][adx]  +  di.3.HBOMTRP_I1

    Mtr_ProInc_ja[1][2][jdx] = Mtr_ProInc_ja[1][2][jdx]  +  di.3.HBWMTRP_I2     Mtr_ProInc_Aa[1][2][adx] = Mtr_ProInc_Aa[1][2][adx]  +  di.3.HBWMTRP_I2
    Mtr_ProInc_ja[2][2][jdx] = Mtr_ProInc_ja[2][2][jdx]  +  di.3.HBSMTRP_I2     Mtr_ProInc_Aa[2][2][adx] = Mtr_ProInc_Aa[2][2][adx]  +  di.3.HBSMTRP_I2
    Mtr_ProInc_ja[3][2][jdx] = Mtr_ProInc_ja[3][2][jdx]  +  di.3.HBOMTRP_I2     Mtr_ProInc_Aa[3][2][adx] = Mtr_ProInc_Aa[3][2][adx]  +  di.3.HBOMTRP_I2

    Mtr_ProInc_ja[1][3][jdx] = Mtr_ProInc_ja[1][3][jdx]  +  di.3.HBWMTRP_I3     Mtr_ProInc_Aa[1][3][adx] = Mtr_ProInc_Aa[1][3][adx]  +  di.3.HBWMTRP_I3
    Mtr_ProInc_ja[2][3][jdx] = Mtr_ProInc_ja[2][3][jdx]  +  di.3.HBSMTRP_I3     Mtr_ProInc_Aa[2][3][adx] = Mtr_ProInc_Aa[2][3][adx]  +  di.3.HBSMTRP_I3
    Mtr_ProInc_ja[3][3][jdx] = Mtr_ProInc_ja[3][3][jdx]  +  di.3.HBOMTRP_I3     Mtr_ProInc_Aa[3][3][adx] = Mtr_ProInc_Aa[3][3][adx]  +  di.3.HBOMTRP_I3

    Mtr_ProInc_ja[1][4][jdx] = Mtr_ProInc_ja[1][4][jdx]  +  di.3.HBWMTRP_I4     Mtr_ProInc_Aa[1][4][adx] = Mtr_ProInc_Aa[1][4][adx]  +  di.3.HBWMTRP_I4
    Mtr_ProInc_ja[2][4][jdx] = Mtr_ProInc_ja[2][4][jdx]  +  di.3.HBSMTRP_I4     Mtr_ProInc_Aa[2][4][adx] = Mtr_ProInc_Aa[2][4][adx]  +  di.3.HBSMTRP_I4
    Mtr_ProInc_ja[3][4][jdx] = Mtr_ProInc_ja[3][4][jdx]  +  di.3.HBOMTRP_I4     Mtr_ProInc_Aa[3][4][adx] = Mtr_ProInc_Aa[3][4][adx]  +  di.3.HBOMTRP_I4

 ;; totals

    TotHBWMtrPs = TotHBWMtrPs + di.3.HBW_MTR_Ps   TotHBWNmtPs = TotHBWnmtPs + di.3.HBW_NMT_Ps
    TotHBSMtrPs = TotHBSMtrPs + di.3.HBS_MTR_Ps   TotHBSNmtPs = TotHBSnmtPs + di.3.HBS_NMT_Ps
    TotHBOMtrPs = TotHBOMtrPs + di.3.HBO_MTR_Ps   TotHBONmtPs = TotHBOnmtPs + di.3.HBO_NMT_Ps
    TotNHWMtrPs = TotNHWMtrPs + di.3.NHW_MTR_Ps   TotNHWNmtPs = TotNHWnmtPs + di.3.NHW_NMT_Ps
    TotNHOMtrPs = TotNHOMtrPs + di.3.NHO_MTR_Ps   TotNHONmtPs = TotNHOnmtPs + di.3.NHO_NMT_Ps

    TotMtrPs    = TotMtrPs    + di.3.HBW_MTR_Ps + di.3.HBS_MTR_Ps + di.3.HBO_MTR_Ps + di.3.NHW_MTR_Ps + di.3.NHO_MTR_Ps
    TotNmtPs    = TotNmtPs    + di.3.HBW_NMT_Ps + di.3.HBS_NMT_Ps + di.3.HBO_NMT_Ps + di.3.NHW_NMT_Ps + di.3.NHO_NMT_Ps

    TotHBWMtrPs_I1 = TotHBWMtrPs_I1 + di.3.HBWMTRP_I1
    TotHBSMtrPs_I1 = TotHBSMtrPs_I1 + di.3.HBSMTRP_I1
    TotHBOMtrPs_I1 = TotHBOMtrPs_I1 + di.3.HBOMTRP_I1

    TotHBWMtrPs_I2 = TotHBWMtrPs_I2 + di.3.HBWMTRP_I2
    TotHBSMtrPs_I2 = TotHBSMtrPs_I2 + di.3.HBSMTRP_I2
    TotHBOMtrPs_I2 = TotHBOMtrPs_I2 + di.3.HBOMTRP_I2

    TotHBWMtrPs_I3 = TotHBWMtrPs_I3 + di.3.HBWMTRP_I3
    TotHBSMtrPs_I3 = TotHBSMtrPs_I3 + di.3.HBSMTRP_I3
    TotHBOMtrPs_I3 = TotHBOMtrPs_I3 + di.3.HBOMTRP_I3

    TotHBWMtrPs_I4 = TotHBWMtrPs_I4 + di.3.HBWMTRP_I4
    TotHBSMtrPs_I4 = TotHBSMtrPs_I4 + di.3.HBSMTRP_I4
    TotHBOMtrPs_I4 = TotHBOMtrPs_I4 + di.3.HBOMTRP_I4




  ENDIF      ;; --------             End of Array accumulation                   -------
 ENDLOOP

  Loop Jdx = 1,25
      if (HH_ja[jdx]  > 0)  HHPrate_pj[1][Jdx] =  Mtr_Pro_ja[1][jdx] / HH_ja[jdx]
      if (HH_ja[jdx]  > 0)  HHPrate_pj[2][Jdx] =  Mtr_Pro_ja[2][jdx] / HH_ja[jdx]
      if (HH_ja[jdx]  > 0)  HHPrate_pj[3][Jdx] =  Mtr_Pro_ja[3][jdx] / HH_ja[jdx]
      if (HH_ja[jdx]  > 0)  HHPrate_pj[4][Jdx] =  Mtr_Pro_ja[4][jdx] / HH_ja[jdx]
      if (HH_ja[jdx]  > 0)  HHPrate_pj[5][Jdx] =  Mtr_Pro_ja[5][jdx] / HH_ja[jdx]

      if (HH_ja[jdx]  > 0)  HHTPrate_j[jdx]     =  MTR_PTot_Ja[jdx]   / HH_ja[jdx]
  ENDLOOP

      if (HH_Tot  > 0)   HHTPrate_p[1]    = TotHBWMtrPs    /    HH_Tot
      if (HH_Tot  > 0)   HHTPrate_p[2]    = TotHBSMtrPs    /    HH_Tot
      if (HH_Tot  > 0)   HHTPrate_p[3]    = TotHBOMtrPs    /    HH_Tot
      if (HH_Tot  > 0)   HHTPrate_p[4]    = TotNHWMtrPs    /    HH_Tot
      if (HH_Tot  > 0)   HHTPrate_p[5]    = TotNHOMtrPs    /    HH_Tot

      if (HH_Tot>0)      TotRATESALL      = (TotHBWMtrPs+TotHBSMtrPs+TotHBOMtrPs+TotNHWMtrPs+TotNHOMtrPs) / HH_Tot

; =========   Printout  Trip Production Reports ======================================================================

; ----------------------------------------------------------------------------------------------------------------------------------------
 Print PRINTO=1 LIST= '\n','\n',' Motorized Trip Productions by Purpose and Jurisdiction    ', '\n','\n'
 Print PRINTO=1 LIST='      Jurisdiction       ','        HBW','        HBS','        HBO','        NHW','        NHO','      Total','\n'

 Loop KK = 1,dbi.2.numrecords
      xx = DBIReadRecord(2,kk)
      jdx = di.2.Jno

      Print form=10csv PRINTO=1 LIST=
        di.2.JNAME(c25),' ',Mtr_Pro_Ja[1][jdx],' ',Mtr_Pro_Ja[2][jdx],' ',Mtr_Pro_Ja[3][jdx],' ',Mtr_Pro_Ja[4][jdx],' ',
                            Mtr_Pro_Ja[5][jdx],' ',Mtr_Ptot_Ja[jdx]
 ENDLOOP

  Print PRINTO=1 LIST='                          '
  Print form=10csv PRINTO=1 LIST='      TOTAL               ',
                                 TOTHBWMTRPs, ' ',TOTHBSMTRPs,' ',TOTHBOMTRPs,' ',TOTNHWMTRPs,' ',TOTNHOMTRPs,' ',TOTMTRPs


; ----------------------------------------------------------------------------------------------------------------------------------------
 Print PRINTO=1 LIST= '\n','\n',' Motorized Trip Productions per Household by Purpose and Jurisdiction    ', '\n','\n'
 Print PRINTO=1 LIST='      Jurisdiction       ','        HBW','        HBS','        HBO','        NHW','        NHO','      Total','\n'

 Loop KK = 1,dbi.2.numrecords
      xx = DBIReadRecord(2,kk)
      jdx = di.2.Jno

      Print form=10.2csv PRINTO=1 LIST=
        di.2.JNAME(c25),' ',HHPrate_pj[1][jdx],' ',HHPrate_pj[2][jdx],' ',HHPrate_pj[3][jdx],' ',HHPrate_pj[4][jdx],' ',
                            HHPrate_pj[5][jdx],' ',HHTPrate_j[jdx]
 ENDLOOP

  Print PRINTO=1 LIST='                          '
  Print form=10.2csv PRINTO=1 LIST='      TOTAL               ',
                                 HHTPRate_P[1], ' ',HHTPRate_P[2],' ',HHTPRate_P[3],' ',HHTPRate_P[4],' ',HHTPRate_P[5],' ',TOTRatesall


;; ----------------------------------------------------------------------------------------------------------------------------------------
 Print PRINTO=1 LIST= '\n','\n',' Motorized Trip Productions by Purpose and Area Type     ', '\n','\n'
 Print PRINTO=1 LIST='      Jurisdiction       ','        HBW','        HBS','        HBO','        NHW','        NHO','      Total','\n'

 Loop KK = 1,6

      Adx = kk

      Print form=10csv PRINTO=1 LIST='     Area Type:     ',Adx(5),
                        ' ',Mtr_Pro_Aa[1][adx],' ',Mtr_Pro_Aa[2][adx],' ',Mtr_Pro_Aa[3][adx],' ',Mtr_Pro_Aa[4][adx],' ',
                            Mtr_Pro_Aa[5][adx],' ',Mtr_Ptot_Aa[adx]
 ENDLOOP


  Print PRINTO=1 LIST='                          '
  Print form=10csv PRINTO=1 LIST='      TOTAL               ',
                                 TOTHBWMTRPs, ' ',TOTHBSMTRPs,' ',TOTHBOMTRPs,' ',TOTNHWMTRPs,' ',TOTNHOMTRPs,' ',TOTMTRPs


; ----------------------------------------------------------------------------------------------------------------------------------------
 Print PRINTO=1 LIST= '\n','\n',' NonMotorized Trip Productions by Purpose and Jurisdiction    ', '\n','\n'
 Print PRINTO=1 LIST='      Jurisdiction       ','        HBW','        HBS','        HBO','        NHW','        NHO','      Total','\n'

 Loop KK = 1,dbi.2.numrecords
      xx = DBIReadRecord(2,kk)
      jdx = di.2.Jno

      Print form=10csv PRINTO=1 LIST=
        di.2.JNAME(c25),' ',Nmt_Pro_Ja[1][jdx],' ',Nmt_Pro_Ja[2][jdx],' ',Nmt_Pro_Ja[3][jdx],' ',Nmt_Pro_Ja[4][jdx],' ',
                            Nmt_Pro_Ja[5][jdx],' ',Nmt_Ptot_Ja[jdx]
 ENDLOOP

  Print PRINTO=1 LIST='                          '
  Print form=10csv PRINTO=1 LIST='      TOTAL               ',
                                 TOTHBWNMTPs, ' ',TOTHBSNMTPs,' ',TOTHBONMTPs,' ',TOTNHWNMTPs,' ',TOTNHONMTPs,' ',TOTNMTPs


;; ----------------------------------------------------------------------------------------------------------------------------------------
 Print PRINTO=1 LIST= '\n','\n',' NonMotorized Trip Productions by Purpose and Area Type     ', '\n','\n'
 Print PRINTO=1 LIST='      Jurisdiction       ','        HBW','        HBS','        HBO','        NHW','        NHO','      Total','\n'

 Loop KK = 1,6

      Adx = kk

      Print form=10csv PRINTO=1 LIST='     Area Type:     ',Adx(5),
                        ' ',Nmt_Pro_Aa[1][adx],' ',Nmt_Pro_Aa[2][adx],' ',Nmt_Pro_Aa[3][adx],' ',Nmt_Pro_Aa[4][adx],' ',
                            Nmt_Pro_Aa[5][adx],' ',Nmt_Ptot_Aa[adx]
 ENDLOOP


  Print PRINTO=1 LIST='                          '
  Print form=10csv PRINTO=1 LIST='      TOTAL               ',
                                 TOTHBWNMTPs, ' ',TOTHBSNMTPs,' ',TOTHBONMTPs,' ',TOTNHWNMTPs,' ',TOTNHONMTPs,' ',TOTNMTPs

; ----------------------------------------------------------------------------------------------------------------------------------------
 Print PRINTO=1 LIST= '\n','\n',' Home-Based Motorized Trip Productions by Purpose, Income, and Jurisdiction    ', '\n','\n'
 Print PRINTO=1 LIST='      Jurisdiction       ','   HBW_Inc1','   HBW_Inc2','   HBW_Inc3','   HBW_Inc4',
                                                 '   HBS_Inc1','   HBS_Inc2','   HBS_Inc3','   HBS_Inc4',
                                                 '   HBO_Inc1','   HBO_Inc2','   HBO_Inc3','   HBO_Inc4', '\n'


 Loop KK = 1,dbi.2.numrecords
      xx = DBIReadRecord(2,kk)
      jdx = di.2.Jno

      Print form=10csv PRINTO=1 LIST=
        di.2.JNAME(c25),' ',Mtr_ProInc_ja[1][1][jdx],' ',Mtr_ProInc_ja[1][2][jdx],' ',Mtr_ProInc_ja[1][3][jdx],' ',Mtr_ProInc_ja[1][4][jdx],' ',
                            Mtr_ProInc_ja[2][1][jdx],' ',Mtr_ProInc_ja[2][2][jdx],' ',Mtr_ProInc_ja[2][3][jdx],' ',Mtr_ProInc_ja[2][4][jdx],' ',
                            Mtr_ProInc_ja[3][1][jdx],' ',Mtr_ProInc_ja[3][2][jdx],' ',Mtr_ProInc_ja[3][3][jdx],' ',Mtr_ProInc_ja[3][4][jdx]

 ENDLOOP

  Print PRINTO=1 LIST='                          '
  Print form=10csv PRINTO=1 LIST='      TOTAL               ',
                                 TOTHBWMTRPs_i1, ' ',TOTHBWMTRPs_i2,' ',TOTHBWMTRPs_i3,' ',TOTHBWMTRPs_i4,' ',
                                 TOTHBSMTRPs_i1, ' ',TOTHBSMTRPs_i2,' ',TOTHBSMTRPs_i3,' ',TOTHBSMTRPs_i4,' ',
                                 TOTHBOMTRPs_i1, ' ',TOTHBOMTRPs_i2,' ',TOTHBOMTRPs_i3,' ',TOTHBOMTRPs_i4

; ----------------------------------------------------------------------------------------------------------------------------------------
;; ----------------------------------------------------------------------------------------------------------------------------------------
 Print PRINTO=1 LIST= '\n','\n',' Home-Based Motorized Trip Productions by Purpose, Income, and Area Type       ', '\n','\n'
 Print PRINTO=1 LIST='      Area Type          ','   HBW_Inc1','   HBW_Inc2','   HBW_Inc3','   HBW_Inc4',
                                                 '   HBS_Inc1','   HBS_Inc2','   HBS_Inc3','   HBS_Inc4',
                                                 '   HBO_Inc1','   HBO_Inc2','   HBO_Inc3','   HBO_Inc4', '\n'

 Loop KK = 1,6

      Adx = kk

      Print form=10csv PRINTO=1 LIST='     Area Type:     ',Adx(5),
                        ' ',Mtr_ProInc_Aa[1][1][Adx],' ',Mtr_ProInc_Aa[1][2][Adx],' ',Mtr_ProInc_Aa[1][3][Adx],' ',Mtr_ProInc_Aa[1][4][Adx],' ',
                            Mtr_ProInc_Aa[2][1][Adx],' ',Mtr_ProInc_Aa[2][2][Adx],' ',Mtr_ProInc_Aa[2][3][Adx],' ',Mtr_ProInc_Aa[2][4][Adx],' ',
                            Mtr_ProInc_Aa[3][1][Adx],' ',Mtr_ProInc_Aa[3][2][Adx],' ',Mtr_ProInc_Aa[3][3][Adx],' ',Mtr_ProInc_Aa[3][4][Adx]
 ENDLOOP


 Print PRINTO=1 LIST='                          '
 Print form=10csv PRINTO=1 LIST='      TOTAL               ',
                                 TOTHBWMTRPs_i1, ' ',TOTHBWMTRPs_i2,' ',TOTHBWMTRPs_i3,' ',TOTHBWMTRPs_i4,' ',
                                 TOTHBSMTRPs_i1, ' ',TOTHBSMTRPs_i2,' ',TOTHBSMTRPs_i3,' ',TOTHBSMTRPs_i4,' ',
                                 TOTHBOMTRPs_i1, ' ',TOTHBOMTRPs_i2,' ',TOTHBOMTRPs_i3,' ',TOTHBOMTRPs_i4


 ;;#############################################################################################################################################
 ;;================================================================================
 ;; process Trip Attractions next                                                 =
 ;;================================================================================

 LOOP K = 1,dbi.4.NUMRECORDS
      x = DBIReadRecord(4,k)
      if (K <= 3675)
        ; Define input variables in ATTRACTION zone file

        _TAZ        = di.4.TAZ
        _HBW_MTR_AS = di.4.HBW_MTR_AS
        _HBW_NMT_AS = di.4.HBW_NMT_AS
        _HBW_ALL_AS = di.4.HBW_ALL_AS
        _HBWMTRA_I1 = di.4.HBWMTRA_I1
        _HBWMTRA_I2 = di.4.HBWMTRA_I2
        _HBWMTRA_I3 = di.4.HBWMTRA_I3
        _HBWMTRA_I4 = di.4.HBWMTRA_I4
        _HBS_MTR_AS = di.4.HBS_MTR_AS
        _HBS_NMT_AS = di.4.HBS_NMT_AS
        _HBS_ALL_AS = di.4.HBS_ALL_AS
        _HBSMTRA_I1 = di.4.HBSMTRA_I1
        _HBSMTRA_I2 = di.4.HBSMTRA_I2
        _HBSMTRA_I3 = di.4.HBSMTRA_I3
        _HBSMTRA_I4 = di.4.HBSMTRA_I4
        _HBO_MTR_AS = di.4.HBO_MTR_AS
        _HBO_NMT_AS = di.4.HBO_NMT_AS
        _HBO_ALL_AS = di.4.HBO_ALL_AS
        _HBOMTRA_I1 = di.4.HBOMTRA_I1
        _HBOMTRA_I2 = di.4.HBOMTRA_I2
        _HBOMTRA_I3 = di.4.HBOMTRA_I3
        _HBOMTRA_I4 = di.4.HBOMTRA_I4
        _NHW_MTR_AS = di.4.NHW_MTR_AS
        _NHW_NMT_AS = di.4.NHW_NMT_AS
        _NHW_ALL_AS = di.4.NHW_ALL_AS
        _NHO_MTR_AS = di.4.NHO_MTR_AS
        _NHO_NMT_AS = di.4.NHO_NMT_AS
        _NHO_ALL_AS = di.4.NHO_ALL_AS

         ADX = AT_Za[_TAZ]                        ; slot cuurent taz into an area type

          ;; Slot TAZ into a jurisdiction --------------------
             Loop KK = 1,dbi.2.numrecords
                       xx = DBIReadRecord(2,kk)
                            IF ((_TAZ >= di.2.LoTAZ1 && _TAZ <= di.2.HiTAZ1) ||
                                (_TAZ >= di.2.LoTAZ2 && _TAZ <= di.2.HiTAZ2) ||
                                (_TAZ >= di.2.LoTAZ3 && _TAZ <= di.2.HiTAZ3) ||
                                (_TAZ >= di.2.LoTAZ4 && _TAZ <= di.2.HiTAZ4) ||
                                (_TAZ >= di.2.LoTAZ5 && _TAZ <= di.2.HiTAZ5) ||
                                (_TAZ >= di.2.LoTAZ6 && _TAZ <= di.2.HiTAZ6) ||
                                (_TAZ >= di.2.LoTAZ7 && _TAZ <= di.2.HiTAZ7) ||
                                (_TAZ >= di.2.LoTAZ8 && _TAZ <= di.2.HiTAZ8))
                                  JDX = di.2.Jno
                            ENDIF
             ENDLOOP

             ;; -------- Array accumulation for productions-------

;; total As
    Mtr_Att_ja[1][jdx] = Mtr_Att_ja[1][jdx]  +  di.4.HBW_MTR_As      Mtr_Att_Aa[1][adx] = Mtr_Att_Aa[1][adx]  +  di.4.HBW_MTR_As
    Mtr_Att_ja[2][jdx] = Mtr_Att_ja[2][jdx]  +  di.4.HBS_MTR_As      Mtr_Att_Aa[2][adx] = Mtr_Att_Aa[2][adx]  +  di.4.HBS_MTR_As
    Mtr_Att_ja[3][jdx] = Mtr_Att_ja[3][jdx]  +  di.4.HBO_MTR_As      Mtr_Att_Aa[3][adx] = Mtr_Att_Aa[3][adx]  +  di.4.HBO_MTR_As
    Mtr_Att_ja[4][jdx] = Mtr_Att_ja[4][jdx]  +  di.4.NHW_MTR_As      Mtr_Att_Aa[4][adx] = Mtr_Att_Aa[4][adx]  +  di.4.NHW_MTR_As
    Mtr_Att_ja[5][jdx] = Mtr_Att_ja[5][jdx]  +  di.4.NHO_MTR_As      Mtr_Att_Aa[5][adx] = Mtr_Att_Aa[5][adx]  +  di.4.NHO_MTR_As

    MTR_ATot_Ja[jdx]   = MTR_ATot_Ja[jdx]    +  di.4.HBW_MTR_As + di.4.HBS_MTR_As + di.4.HBO_MTR_As + di.4.NHW_MTR_As + di.4.NHO_MTR_As
    MTR_ATot_Aa[adx]   = MTR_ATot_Aa[Adx]    +  di.4.HBW_MTR_As + di.4.HBS_MTR_As + di.4.HBO_MTR_As + di.4.NHW_MTR_As + di.4.NHO_MTR_As

    NMT_Att_ja[1][jdx] = NMT_Att_ja[1][jdx]  +  di.4.HBW_NMT_As      NMT_Att_Aa[1][adx] = NMT_Att_Aa[1][adx]  +  di.4.HBW_NMT_As
    NMT_Att_ja[2][jdx] = NMT_Att_ja[2][jdx]  +  di.4.HBS_NMT_As      NMT_Att_Aa[2][adx] = NMT_Att_Aa[2][adx]  +  di.4.HBS_NMT_As
    NMT_Att_ja[3][jdx] = NMT_Att_ja[3][jdx]  +  di.4.HBO_NMT_As      NMT_Att_Aa[3][adx] = NMT_Att_Aa[3][adx]  +  di.4.HBO_NMT_As
    NMT_Att_ja[4][jdx] = NMT_Att_ja[4][jdx]  +  di.4.NHW_NMT_As      NMT_Att_Aa[4][adx] = NMT_Att_Aa[4][adx]  +  di.4.NHW_NMT_As
    NMT_Att_ja[5][jdx] = NMT_Att_ja[5][jdx]  +  di.4.NHO_NMT_As      NMT_Att_Aa[5][adx] = NMT_Att_Aa[5][adx]  +  di.4.NHO_NMT_As

    NMT_ATot_Ja[jdx]   = NMT_ATot_Ja[jdx]    +  di.4.HBW_NMT_As + di.4.HBS_NMT_As + di.4.HBO_NMT_As + di.4.NHW_NMT_As + di.4.NHO_NMT_As
    NMT_ATot_Aa[adx]   = NMT_ATot_Aa[adx]    +  di.4.HBW_NMT_As + di.4.HBS_NMT_As + di.4.HBO_NMT_As + di.4.NHW_NMT_As + di.4.NHO_NMT_As



;; total HB motorized As    by income
    Mtr_AttInc_ja[1][1][jdx] = Mtr_AttInc_ja[1][1][jdx]  +  di.4.HBWMTRA_I1     Mtr_AttInc_Aa[1][1][adx] = Mtr_AttInc_Aa[1][1][adx]  +  di.4.HBWMTRA_I1
    Mtr_AttInc_ja[2][1][jdx] = Mtr_AttInc_ja[2][1][jdx]  +  di.4.HBSMTRA_I1     Mtr_AttInc_Aa[2][1][adx] = Mtr_AttInc_Aa[2][1][adx]  +  di.4.HBSMTRA_I1
    Mtr_AttInc_ja[3][1][jdx] = Mtr_AttInc_ja[3][1][jdx]  +  di.4.HBOMTRA_I1     Mtr_AttInc_Aa[3][1][adx] = Mtr_AttInc_Aa[3][1][adx]  +  di.4.HBOMTRA_I1

    Mtr_AttInc_ja[1][2][jdx] = Mtr_AttInc_ja[1][2][jdx]  +  di.4.HBWMTRA_I2     Mtr_AttInc_Aa[1][2][adx] = Mtr_AttInc_Aa[1][2][adx]  +  di.4.HBWMTRA_I2
    Mtr_AttInc_ja[2][2][jdx] = Mtr_AttInc_ja[2][2][jdx]  +  di.4.HBSMTRA_I2     Mtr_AttInc_Aa[2][2][adx] = Mtr_AttInc_Aa[2][2][adx]  +  di.4.HBSMTRA_I2
    Mtr_AttInc_ja[3][2][jdx] = Mtr_AttInc_ja[3][2][jdx]  +  di.4.HBOMTRA_I2     Mtr_AttInc_Aa[3][2][adx] = Mtr_AttInc_Aa[3][2][adx]  +  di.4.HBOMTRA_I2

    Mtr_AttInc_ja[1][3][jdx] = Mtr_AttInc_ja[1][3][jdx]  +  di.4.HBWMTRA_I3     Mtr_AttInc_Aa[1][3][adx] = Mtr_AttInc_Aa[1][3][adx]  +  di.4.HBWMTRA_I3
    Mtr_AttInc_ja[2][3][jdx] = Mtr_AttInc_ja[2][3][jdx]  +  di.4.HBSMTRA_I3     Mtr_AttInc_Aa[2][3][adx] = Mtr_AttInc_Aa[2][3][adx]  +  di.4.HBSMTRA_I3
    Mtr_AttInc_ja[3][3][jdx] = Mtr_AttInc_ja[3][3][jdx]  +  di.4.HBOMTRA_I3     Mtr_AttInc_Aa[3][3][adx] = Mtr_AttInc_Aa[3][3][adx]  +  di.4.HBOMTRA_I3

    Mtr_AttInc_ja[1][4][jdx] = Mtr_AttInc_ja[1][4][jdx]  +  di.4.HBWMTRA_I4     Mtr_AttInc_Aa[1][4][adx] = Mtr_AttInc_Aa[1][4][adx]  +  di.4.HBWMTRA_I4
    Mtr_AttInc_ja[2][4][jdx] = Mtr_AttInc_ja[2][4][jdx]  +  di.4.HBSMTRA_I4     Mtr_AttInc_Aa[2][4][adx] = Mtr_AttInc_Aa[2][4][adx]  +  di.4.HBSMTRA_I4
    Mtr_AttInc_ja[3][4][jdx] = Mtr_AttInc_ja[3][4][jdx]  +  di.4.HBOMTRA_I4     Mtr_AttInc_Aa[3][4][adx] = Mtr_AttInc_Aa[3][4][adx]  +  di.4.HBOMTRA_I4

 ;; totals

    TotHBWMtrAs = TotHBWMtrAs + di.4.HBW_MTR_As   TotHBWNmtAs = TotHBWnmtAs + di.4.HBW_NMT_As
    TotHBSMtrAs = TotHBSMtrAs + di.4.HBS_MTR_As   TotHBSNmtAs = TotHBSnmtAs + di.4.HBS_NMT_As
    TotHBOMtrAs = TotHBOMtrAs + di.4.HBO_MTR_As   TotHBONmtAs = TotHBOnmtAs + di.4.HBO_NMT_As
    TotNHWMtrAs = TotNHWMtrAs + di.4.NHW_MTR_As   TotNHWNmtAs = TotNHWnmtAs + di.4.NHW_NMT_As
    TotNHOMtrAs = TotNHOMtrAs + di.4.NHO_MTR_As   TotNHONmtAs = TotNHOnmtAs + di.4.NHO_NMT_As

    TotMtrAs    = TotMtrAs    + di.4.HBW_MTR_As + di.4.HBS_MTR_As + di.4.HBO_MTR_As + di.4.NHW_MTR_As + di.4.NHO_MTR_As
    TotNmtAs    = TotNmtAs    + di.4.HBW_NMT_As + di.4.HBS_NMT_As + di.4.HBO_NMT_As + di.4.NHW_NMT_As + di.4.NHO_NMT_As

    TotHBWMtrAs_I1 = TotHBWMtrAs_I1 + di.4.HBWMTRA_I1
    TotHBSMtrAs_I1 = TotHBSMtrAs_I1 + di.4.HBSMTRA_I1
    TotHBOMtrAs_I1 = TotHBOMtrAs_I1 + di.4.HBOMTRA_I1

    TotHBWMtrAs_I2 = TotHBWMtrAs_I2 + di.4.HBWMTRA_I2
    TotHBSMtrAs_I2 = TotHBSMtrAs_I2 + di.4.HBSMTRA_I2
    TotHBOMtrAs_I2 = TotHBOMtrAs_I2 + di.4.HBOMTRA_I2

    TotHBWMtrAs_I3 = TotHBWMtrAs_I3 + di.4.HBWMTRA_I3
    TotHBSMtrAs_I3 = TotHBSMtrAs_I3 + di.4.HBSMTRA_I3
    TotHBOMtrAs_I3 = TotHBOMtrAs_I3 + di.4.HBOMTRA_I3

    TotHBWMtrAs_I4 = TotHBWMtrAs_I4 + di.4.HBWMTRA_I4
    TotHBSMtrAs_I4 = TotHBSMtrAs_I4 + di.4.HBSMTRA_I4
    TotHBOMtrAs_I4 = TotHBOMtrAs_I4 + di.4.HBOMTRA_I4




  ENDIF      ;; --------             End of Array accumulation                   -------
 ENDLOOP


  Loop Jdx = 1,25
      if (TotEMP_ja[jdx]  > 0)  EMPARate_pj[1][Jdx] =  Mtr_Att_ja[1][jdx] / TotEMP_ja[jdx]
      if (TotEMP_ja[jdx]  > 0)  EMPARate_pj[2][Jdx] =  Mtr_Att_ja[2][jdx] / TotEMP_ja[jdx]
      if (TotEMP_ja[jdx]  > 0)  EMPARate_pj[3][Jdx] =  Mtr_Att_ja[3][jdx] / TotEMP_ja[jdx]
      if (TotEMP_ja[jdx]  > 0)  EMPARate_pj[4][Jdx] =  Mtr_Att_ja[4][jdx] / TotEMP_ja[jdx]
      if (TotEMP_ja[jdx]  > 0)  EMPARate_pj[5][Jdx] =  Mtr_Att_ja[5][jdx] / TotEMP_ja[jdx]

      if (TotEMP_ja[jdx]  > 0)  EMPTARate_j[jdx]     =  MTR_ATot_Ja[jdx]  / TotEMP_ja[jdx]
  ENDLOOP

      if (TotEMP_Tot  > 0)   EMPTARate_p[1]    = TotHBWMtrAs    /    TotEMP_Tot
      if (TotEMP_Tot  > 0)   EMPTARate_p[2]    = TotHBSMtrAs    /    TotEMP_Tot
      if (TotEMP_Tot  > 0)   EMPTARate_p[3]    = TotHBOMtrAs    /    TotEMP_Tot
      if (TotEMP_Tot  > 0)   EMPTARate_p[4]    = TotNHWMtrAs    /    TotEMP_Tot
      if (TotEMP_Tot  > 0)   EMPTARate_p[5]    = TotNHOMtrAs    /    TotEMP_Tot

      if (TotEMP_Tot>0)      TotRATESALL      = (TotHBWMtrAs+TotHBSMtrAs+TotHBOMtrAs+TotNHWMtrAs+TotNHOMtrAs) / TotEMP_Tot

; =========   Printout  Trip Production Reports ======================================================================

; ----------------------------------------------------------------------------------------------------------------------------------------
 Print PRINTO=1 LIST= '\n','\n',' Motorized Trip Attractions by Purpose and Jurisdiction    ', '\n','\n'
 Print PRINTO=1 LIST='      Jurisdiction       ','        HBW','        HBS','        HBO','        NHW','        NHO','      Total','\n'

 Loop KK = 1,dbi.2.numrecords
      xx = DBIReadRecord(2,kk)
      jdx = di.2.Jno

      Print form=10csv PRINTO=1 LIST=
        di.2.JNAME(c25),' ',Mtr_Att_Ja[1][jdx],' ',Mtr_Att_Ja[2][jdx],' ',Mtr_Att_Ja[3][jdx],' ',Mtr_Att_Ja[4][jdx],' ',
                            Mtr_Att_Ja[5][jdx],' ',Mtr_Atot_Ja[jdx]
 ENDLOOP

  Print PRINTO=1 LIST='                          '
  Print form=10csv PRINTO=1 LIST='      TOTAL               ',
                                 TOTHBWMTRAs, ' ',TOTHBSMTRAs,' ',TOTHBOMTRAs,' ',TOTNHWMTRAs,' ',TOTNHOMTRAs,' ',TOTMTRAs


; ----------------------------------------------------------------------------------------------------------------------------------------
 Print PRINTO=1 LIST= '\n','\n',' Motorized Trip Attractions per Job by Purpose and Jurisdiction    ', '\n','\n'
 Print PRINTO=1 LIST='      Jurisdiction       ','        HBW','        HBS','        HBO','        NHW','        NHO','      Total','\n'

 Loop KK = 1,dbi.2.numrecords
      xx = DBIReadRecord(2,kk)
      jdx = di.2.Jno

      Print form=10.2csv PRINTO=1 LIST=
        di.2.JNAME(c25),' ',EMPARate_pj[1][jdx],' ',EMPARate_pj[2][jdx],' ',EMPARate_pj[3][jdx],' ',EMPARate_pj[4][jdx],' ',
                            EMPARate_pj[5][jdx],' ',EMPTARate_j[jdx]
 ENDLOOP

  Print PRINTO=1 LIST='                          '
  Print form=10.2csv PRINTO=1 LIST='      TOTAL               ',
                                 EMPTARate_P[1], ' ',EMPTARate_P[2],' ',EMPTARate_P[3],' ',EMPTARate_P[4],' ',EMPTARate_P[5],' ',TOTRatesall


;; ----------------------------------------------------------------------------------------------------------------------------------------
 Print PRINTO=1 LIST= '\n','\n',' Motorized Trip Attractions by Purpose and Area Type     ', '\n','\n'
 Print PRINTO=1 LIST='      Jurisdiction       ','        HBW','        HBS','        HBO','        NHW','        NHO','      Total','\n'

 Loop KK = 1,6

      Adx = kk

      Print form=10csv PRINTO=1 LIST='     Area Type:     ',Adx(5),
                        ' ',Mtr_Att_Aa[1][adx],' ',Mtr_Att_Aa[2][adx],' ',Mtr_Att_Aa[3][adx],' ',Mtr_Att_Aa[4][adx],' ',
                            Mtr_Att_Aa[5][adx],' ',Mtr_Atot_Aa[adx]
 ENDLOOP


  Print PRINTO=1 LIST='                          '
  Print form=10csv PRINTO=1 LIST='      TOTAL               ',
                                 TOTHBWMTRAs, ' ',TOTHBSMTRAs,' ',TOTHBOMTRAs,' ',TOTNHWMTRAs,' ',TOTNHOMTRAs,' ',TOTMTRAs


; ----------------------------------------------------------------------------------------------------------------------------------------
 Print PRINTO=1 LIST= '\n','\n',' NonMotorized Trip Attractions by Purpose and Jurisdiction    ', '\n','\n'
 Print PRINTO=1 LIST='      Jurisdiction       ','        HBW','        HBS','        HBO','        NHW','        NHO','      Total','\n'

 Loop KK = 1,dbi.2.numrecords
      xx = DBIReadRecord(2,kk)
      jdx = di.2.Jno

      Print form=10csv PRINTO=1 LIST=
        di.2.JNAME(c25),' ',Nmt_Att_Ja[1][jdx],' ',Nmt_Att_Ja[2][jdx],' ',Nmt_Att_Ja[3][jdx],' ',Nmt_Att_Ja[4][jdx],' ',
                            Nmt_Att_Ja[5][jdx],' ',Nmt_Atot_Ja[jdx]
 ENDLOOP

  Print PRINTO=1 LIST='                          '
  Print form=10csv PRINTO=1 LIST='      TOTAL               ',
                                 TOTHBWNMTAs, ' ',TOTHBSNMTAs,' ',TOTHBONMTAs,' ',TOTNHWNMTAs,' ',TOTNHONMTAs,' ',TOTNMTAs


;; ----------------------------------------------------------------------------------------------------------------------------------------
 Print PRINTO=1 LIST= '\n','\n',' NonMotorized Trip Attractions by Purpose and Area Type     ', '\n','\n'
 Print PRINTO=1 LIST='      Jurisdiction       ','        HBW','        HBS','        HBO','        NHW','        NHO','      Total','\n'

 Loop KK = 1,6

      Adx = kk

      Print form=10csv PRINTO=1 LIST='     Area Type:     ',Adx(5),
                        ' ',Nmt_Att_Aa[1][adx],' ',Nmt_Att_Aa[2][adx],' ',Nmt_Att_Aa[3][adx],' ',Nmt_Att_Aa[4][adx],' ',
                            Nmt_Att_Aa[5][adx],' ',Nmt_Atot_Aa[adx]
 ENDLOOP


  Print PRINTO=1 LIST='                          '
  Print form=10csv PRINTO=1 LIST='      TOTAL               ',
                                 TOTHBWNMTAs, ' ',TOTHBSNMTAs,' ',TOTHBONMTAs,' ',TOTNHWNMTAs,' ',TOTNHONMTAs,' ',TOTNMTAs

; ----------------------------------------------------------------------------------------------------------------------------------------
 Print PRINTO=1 LIST= '\n','\n',' Home-Based Motorized Trip Attractions by Purpose, Income, and Jurisdiction    ', '\n','\n'
 Print PRINTO=1 LIST='      Jurisdiction       ','   HBW_Inc1','   HBW_Inc2','   HBW_Inc3','   HBW_Inc4',
                                                 '   HBS_Inc1','   HBS_Inc2','   HBS_Inc3','   HBS_Inc4',
                                                 '   HBO_Inc1','   HBO_Inc2','   HBO_Inc3','   HBO_Inc4', '\n'


 Loop KK = 1,dbi.2.numrecords
      xx = DBIReadRecord(2,kk)
      jdx = di.2.Jno

      Print form=10csv PRINTO=1 LIST=
        di.2.JNAME(c25),' ',Mtr_AttInc_ja[1][1][jdx],' ',Mtr_AttInc_ja[1][2][jdx],' ',Mtr_AttInc_ja[1][3][jdx],' ',Mtr_AttInc_ja[1][4][jdx],' ',
                            Mtr_AttInc_ja[2][1][jdx],' ',Mtr_AttInc_ja[2][2][jdx],' ',Mtr_AttInc_ja[2][3][jdx],' ',Mtr_AttInc_ja[2][4][jdx],' ',
                            Mtr_AttInc_ja[3][1][jdx],' ',Mtr_AttInc_ja[3][2][jdx],' ',Mtr_AttInc_ja[3][3][jdx],' ',Mtr_AttInc_ja[3][4][jdx]

 ENDLOOP

  Print PRINTO=1 LIST='                          '
  Print form=10csv PRINTO=1 LIST='      TOTAL               ',
                                 TOTHBWMTRAs_i1, ' ',TOTHBWMTRAs_i2,' ',TOTHBWMTRAs_i3,' ',TOTHBWMTRAs_i4,' ',
                                 TOTHBSMTRAs_i1, ' ',TOTHBSMTRAs_i2,' ',TOTHBSMTRAs_i3,' ',TOTHBSMTRAs_i4,' ',
                                 TOTHBOMTRAs_i1, ' ',TOTHBOMTRAs_i2,' ',TOTHBOMTRAs_i3,' ',TOTHBOMTRAs_i4

; ----------------------------------------------------------------------------------------------------------------------------------------
;; ----------------------------------------------------------------------------------------------------------------------------------------
 Print PRINTO=1 LIST= '\n','\n',' Home-Based Motorized Trip Attractions by Purpose, Income, and Area Type       ', '\n','\n'
 Print PRINTO=1 LIST='      Area Type          ','   HBW_Inc1','   HBW_Inc2','   HBW_Inc3','   HBW_Inc4',
                                                 '   HBS_Inc1','   HBS_Inc2','   HBS_Inc3','   HBS_Inc4',
                                                 '   HBO_Inc1','   HBO_Inc2','   HBO_Inc3','   HBO_Inc4', '\n'

 Loop KK = 1,6

      Adx = kk

      Print form=10csv PRINTO=1 LIST='     Area Type:     ',Adx(5),
                        ' ',Mtr_AttInc_Aa[1][1][Adx],' ',Mtr_AttInc_Aa[1][2][Adx],' ',Mtr_AttInc_Aa[1][3][Adx],' ',Mtr_AttInc_Aa[1][4][Adx],' ',
                            Mtr_AttInc_Aa[2][1][Adx],' ',Mtr_AttInc_Aa[2][2][Adx],' ',Mtr_AttInc_Aa[2][3][Adx],' ',Mtr_AttInc_Aa[2][4][Adx],' ',
                            Mtr_AttInc_Aa[3][1][Adx],' ',Mtr_AttInc_Aa[3][2][Adx],' ',Mtr_AttInc_Aa[3][3][Adx],' ',Mtr_AttInc_Aa[3][4][Adx]
 ENDLOOP


 Print PRINTO=1 LIST='                          '
 Print form=10csv PRINTO=1 LIST='      TOTAL               ',
                                 TOTHBWMTRAs_i1, ' ',TOTHBWMTRAs_i2,' ',TOTHBWMTRAs_i3,' ',TOTHBWMTRAs_i4,' ',
                                 TOTHBSMTRAs_i1, ' ',TOTHBSMTRAs_i2,' ',TOTHBSMTRAs_i3,' ',TOTHBSMTRAs_i4,' ',
                                 TOTHBOMTRAs_i1, ' ',TOTHBOMTRAs_i2,' ',TOTHBOMTRAs_i3,' ',TOTHBOMTRAs_i4

ENDRUN
*copy voya*.prn Juris_Trip_Rate_summary.rpt

