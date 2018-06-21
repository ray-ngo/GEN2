
;=================================================================
;  Demo_Models.S
;
;   Version 2.3, 3722 TAZ System  - Demographic Model
;
;   The models have been updated using the 2007 ACS
;   Program to Allocation Total Zonal Households among 64 Classes:
;   4 HH Size groups by 4 Income Groups by 4 Veh. Avail. groups
;
;   Programmer: Milone
;   Date:      09/3/10
;
;   Test: BASE
;=================================================================
;
;

;
ZONESIZE    =  3722                  ;  No. of TAZs
LastIZn     =  3675                  ;  Last Internal TAZ no.

JrCl        =  24                    ;  No. of Juris. Classes (transformed JURIS. Code 0-23 becomes 1-24)
ArCl        =   6                    ;  No. of Area Classe (ATypes)
SzCl        =   4                    ;  No. of HH Size   Classes
InCl        =   4                    ;  No. of Income    Classes
VaCl        =   4                    ;  No. of Veh Avail Classes

ZNFILE_IN1  = 'inputs\ZONE.dbf'   ;  Input  Zonal Land Use File

ZNFILE_IN2  = 'AreaType_File.dbf'    ;  Input  Zonal Area Type File from network building

Rept        = '%_iter_%_Demo_Models.txt'      ;  Summary Reports

ZNFILE_INa1  = '%_iter_%_AM_WK_MR_JobAcc.dbf'  ;  Input  Jobs accessible within 45 min. by AM WalkAcc  Metrorail Only Service
ZNFILE_INa2  = '%_iter_%_AM_DR_MR_JobAcc.dbf'  ;  Input  Jobs accessible within 45 min. by AM DriveAcc Metrorail Only Service
ZNFILE_INa3  = '%_iter_%_AM_WK_BM_JobAcc.dbf'  ;  Input  Jobs accessible within 45 min. by AM WalkAcc  Bus&Metrorail  Service
ZNFILE_INa4  = '%_iter_%_AM_DR_BM_JobAcc.dbf'  ;  Input  Jobs accessible within 45 min. by AM DriveAcc Bus&Metrorail  Service

ZNFILE_OU1  = 'HHI1_SV.txt'              ;  Output Zonal Income 1 HH by Size& VehAv Classes: i1s1v1,i1s1v2,...,i1s4v4
ZNFILE_OU2  = 'HHI2_SV.txt'              ;  Output Zonal Income 2 HH by Size& VehAv Classes: i2s1v1,i2s1v2,...,i2s4v4
ZNFILE_OU3  = 'HHI3_SV.txt'              ;  Output Zonal Income 3 HH by Size& VehAv Classes: i3s1v1,i3s1v2,...,i3s4v4
ZNFILE_OU4  = 'HHI4_SV.txt'              ;  Output Zonal Income 4 HH by Size& VehAv Classes: i4s1v1,i4s1v2,...,i4s4v4

ZonalCCHHs  = '%_iter_%_Demo_Models_HHbyISV.dbf' ; output zonal HHs by 64 cross-classes

Ofmt        = '(12.2)'               ;  Format of Output file data  Note: Integer/real Spec. Here!


RUN PGM=MATRIX
ZONES=@ZONESIZE@

pageheight=32767  ; Preclude header breaks

; Set up zone arrays for accumulating I/O variables
;


ARRAY  ISZA       =@SzCl@,                  ;  Initial  Marginal HH Totals by size levels
       IINA       =@InCl@,                  ;  Initial  Marginal HH Totals by income levels
       AreaA      =@ArCl@,                  ;  Area Type class size

       CSZA       =@SzCl@,                  ;  Computed Marginal HH Totals by size levels
       CINA       =@InCl@,                  ;  Computed Marginal HH Totals by income levels
       CSZAdjA    =@SzCl@,                  ;  Marginal HH  adjustment ftr by Income class
       CINAdjA    =@InCl@,                  ;  Marginal Inc adjustment ftr by HH size class

       P_VA       =@VaCl@,                  ;  Veh Avail  probabilities
       CVAA       =@VaCl@,                  ;  Veh Avail  Totals
       JurA       =@JrCl@,                  ;  Juris. HH Totals  array
       RegSzA     =@SzCl@,                  ;  Regional HH by Size array
       RegInA     =@InCl@,                  ;  Regional HH by Inc  array
       RegVaA     =@VaCl@,                  ;  Regional HH by VeAv array
       HH_ArCoopT =@ArCl@

ARRAY  CSZINA     =@SzCL@,@InCl@            ;  HH Size by Income level Matrix, 11,12,13,...,44
ARRAY  JurSzA     =@JrCl@,@SzCl@            ;  Juris. HH by size array
ARRAY  JurInA     =@JrCl@,@InCl@            ;  Juris. HH by Inc  array
ARRAY  JurVaA     =@JrCl@,@VaCl@            ;  Juris. HH by VeAv array
ARRAY  RegSzInA   =@SzCL@,@InCl@            ;  Regional Size by Inc  array
ARRAY  RegVaSzA   =@VaCl@,@SzCl@            ;  Regional V    by Size  matrix
ARRAY  RegVaInA   =@VaCl@,@InCl@            ;  Regional V1   by Inc   matrix

ARRAY ArSzA       =@ArCl@,@SzCl@            ;  Area Type by size array
ARRAY ArInA       =@ArCl@,@InCl@            ;  Area Type by Inc  array
ARRAY ArVaA       =@ArCl@,@VaCl@            ;  Area Type by VeAv array

ARRAY CSZINVAA    =@SzCl@,@InCl@,@VaCl@     ;  Veh Avail by HH Size by Inc Matrix, 111,112,113,...,444
ARRAY RegSzInVaA  =@SzCl@,@InCl@,@VaCl@     ;  Regional Size by Inc  by vehav array

;=========================
; Define Loop-up Tables  =
;=========================
;
;==============================================================
; HH Size Distribution from 2000 CTPP                         =
;==============================================================
;
      LOOKUP Name=SZPCTA,
             LOOKUP[1]   = 1,Result = 2,
             LOOKUP[2]   = 1,Result = 3,
             LOOKUP[3]   = 1,Result = 4,
             LOOKUP[4]   = 1,Result = 5,
             Interpolate = N, FAIL=0,0,0,
 ;     Avg HHSize   PctHH1psn PctHH2psn PctHH3Psn PctHH4+Psn

   R="   1.0,           100.0,     0.0,     0.0,     0.0",
     "   1.1,            86.7,    10.5,     1.0,     1.8",
     "   1.2,            78.2,    15.8,     4.1,     1.9",
     "   1.3,            72.7,    20.4,     4.9,     2.0",
     "   1.4,            67.1,    24.7,     5.8,     2.4",
     "   1.5,            63.0,    27.1,     6.7,     3.2",
     "   1.6,            59.0,    28.9,     7.9,     4.2",
     "   1.7,            55.2,    30.2,     8.7,     5.9",
     "   1.8,            50.9,    31.1,    10.1,     7.9",
     "   1.9,            46.7,    31.7,    11.5,    10.1",
     "   2.0,            42.8,    32.1,    12.7,    12.4",
     "   2.1,            39.0,    32.3,    14.0,    14.7",
     "   2.2,            35.5,    32.4,    15.0,    17.1",
     "   2.3,            32.2,    32.4,    16.0,    19.4",
     "   2.4,            29.1,    32.3,    16.9,    21.7",
     "   2.5,            26.3,    32.1,    17.6,    24.0",
     "   2.6,            23.8,    31.9,    18.2,    26.1",
     "   2.7,            21.5,    31.5,    18.7,    28.3",
     "   2.8,            19.4,    31.1,    19.2,    30.3",
     "   2.9,            17.4,    30.5,    19.8,    32.3",
     "   3.0,            15.6,    29.8,    20.3,    34.3",
     "   3.1,            14.0,    28.9,    20.7,    36.4",
     "   3.2,            12.6,    27.9,    20.8,    38.7",
     "   3.3,            11.3,    26.6,    20.9,    41.2",
     "   3.4,            10.2,    25.0,    20.8,    44.0",
     "   3.5,            09.2,    23.2,    20.4,    47.2",
     "   3.6,            08.3,    21.2,    19.6,    50.9",
     "   3.7,            07.5,    18.9,    18.4,    55.2",
     "   3.8,            06.7,    15.6,    17.4,    60.3",
     "   3.9,            05.9,    11.2,    16.5,    66.4"


;==============================================================
;    income level distribution from 2000 CTPP                 =
;    adjusted by rjm 9/5/10 per 2007 ACS                      =
;==============================================================
;
      LOOKUP Name=INPCTA,
             LOOKUP[1]   = 1,Result = 2,
             LOOKUP[2]   = 1,Result = 3,
             LOOKUP[3]   = 1,Result = 4,                    ;
             LOOKUP[4]   = 1,Result = 5,                    ;  proportion of
             Interpolate = N, FAIL=0,0,0,                   ;  zonal median inc.
; inc level:   QRT1      QRT2     QRT3     QRT4             ; to regional median income
 R= "   0,   100.00      0.00     0.00     0.00  ",     ;    0 inc ratio
    "   1,    88.83      8.19     2.34     0.64  ",     ;  0.1 inc ratio
    "   2,    80.54     14.73     3.13     1.60  ",     ;  0.2 inc ratio
    "   3,    73.42     20.29     4.23     2.05  ",     ;  0.3 inc ratio
    "   4,    65.32     25.44     6.44     2.80  ",     ;  0.4 inc ratio
    "   5,    56.93     29.97     9.32     3.78  ",     ;  0.5 inc ratio
    "   6,    48.78     33.41    12.51     5.30  ",     ;  0.6 inc ratio
    "   7,    41.27     35.85    15.69     7.19  ",     ;  0.7 inc ratio
    "   8,    34.56     36.96    18.64     9.84  ",     ;  0.8 inc ratio
    "   9,    28.84     36.84    21.22    13.10  ",     ;  0.9 inc ratio
    "  10,    24.27     35.69    23.28    16.77  ",     ;    1 inc ratio
    "  11,    20.63     33.70    24.75    20.92  ",     ;  1.1 inc ratio
    "  12,    17.89     30.95    25.59    25.56  ",     ;  1.2 inc ratio
    "  13,    16.00     27.91    25.83    30.27  ",     ;  1.3 inc ratio
    "  14,    14.63     24.78    25.45    35.15  ",     ;  1.4 inc ratio
    "  15,    13.72     21.74    24.71    39.83  ",     ;  1.5 inc ratio
    "  16,    12.99     19.13    23.53    44.35  ",     ;  1.6 inc ratio
    "  17,    12.23     17.04    22.16    48.57  ",     ;  1.7 inc ratio
    "  18,    11.39     15.65    20.67    52.29  ",     ;  1.8 inc ratio
    "  19,    10.50     14.70    19.19    55.61  ",     ;  1.9 inc ratio
    "  20,     9.71     14.35    17.77    58.17  ",     ;    2 inc ratio
    "  21,     8.74     14.16    16.60    60.50  ",     ;  2.1 inc ratio
    "  22,     8.05     14.11    15.46    62.38  ",     ;  2.2 inc ratio
    "  23,     7.79     14.02    14.54    63.65  ",     ;  2.3 inc ratio
    "  24,     7.37     13.77    14.08    64.77  ",     ;  2.4 inc ratio
    "  25,     7.25     13.49    13.60    65.66  ",     ;  2.5 inc ratio
    "  26,     7.17     12.55    13.54    66.75  ",     ;  2.6 inc ratio
    "  27,     6.89     12.26    13.34    67.51  ",     ;  2.7 inc ratio
    "  28,     6.93     11.97    12.74    68.36  ",     ;  2.8 inc ratio
    "  29,     6.52     11.03    12.90    69.55  ",     ;  2.9 inc ratio
    "  30,     5.96     10.06    13.19    70.78  ",     ;    3 inc ratio
    "  31,     5.21      9.27    13.49    72.04  ",     ;  3.1 inc ratio
    "  32,     5.26      8.78    13.01    72.96  ",     ;  3.2 inc ratio
    "  33,     4.97      8.30    12.75    73.98  ",     ;  3.3 inc ratio
    "  34,     4.69      7.64    12.62    75.05  ",     ;  3.4 inc ratio
    "  35,     4.41      6.96    12.49    76.14  ",     ;  3.5 inc ratio
    "  36,     3.95      6.27    12.50    77.28  ",     ;  3.6 inc ratio
    "  37,     3.66      5.56    12.40    78.38   "     ;  3.7 inc ratio

;==============================================================
; Initial Joint HH Size x Income Distribution from 2000 CTPP  =
;==============================================================

      LOOKUP Name=I_SPCTA, LOOKUP[1] = 1,Result = 2,
             Interpolate = N, FAIL=0,0,0,
;            Size_Inc Initial
;             Class   Pct                Pct of Size 'X' HHs in Inc group 'Y'
;             -----   ----                    'X'          'Y'
          R="  11,    45.51 ",  ;              1            1
            "  12,    29.18 ",  ;              1            2
            "  13,    18.47 ",  ;              1            3
            "  14,     6.84 ",  ;              1            4
            "  21,    18.77 ",  ;              2            1
            "  22,    22.26 ",  ;              2            2
            "  23,    29.81 ",  ;              2            3
            "  24,    29.16 ",  ;              2            4
            "  31,    16.61 ",  ;              3            1
            "  32,    20.66 ",  ;              3            2
            "  33,    31.27 ",  ;              3            3
            "  34,    31.46 ",  ;              3            4
            "  41,    13.32 ",  ;              4            1
            "  42,    19.65 ",  ;              4            2
            "  43,    32.53 ",  ;              4            3
            "  44,    34.50 "   ;              4            4


;==============================================================
; Final Size and Income adjustments by   area type            =
; Factors are Unused (set to 1.0) but available if needed     =
;==============================================================

      LOOKUP Name=AreaSizFtr,
       LOOKUP[1] = 1,Result = 2,
       LOOKUP[2] = 1,Result = 3,
       LOOKUP[3] = 1,Result = 4,
       LOOKUP[4] = 1,Result = 5,
             Interpolate = N, FAIL=0,0,0,
;             Area    Size1  Size2  Size3  Size4
;             Type    Factor Factor Factor Factor
;             -----   -----  -----  -----  -----
          R="  1,     1.00    1.00   1.00   1.00   ",
            "  2,     1.00    1.00   1.00   1.00   ",
            "  3,     1.00    1.00   1.00   1.00   ",
            "  4,     1.00    1.00   1.00   1.00   ",
            "  5,     1.00    1.00   1.00   1.00   ",
            "  6,     1.00    1.00   1.00   1.00   ",
            "  7,     1.00    1.00   1.00   1.00   "

      LOOKUP Name=AreaIncFtr,
       LOOKUP[1] = 1,Result = 2,
       LOOKUP[2] = 1,Result = 3,
       LOOKUP[3] = 1,Result = 4,
       LOOKUP[4] = 1,Result = 5,
             Interpolate = N, FAIL=0,0,0,
;             Area    Inc1   Inc2   Inc3   Inc4
;             Type    Factor Factor Factor Factor
;             -----  -----  -----  -----  -----
          R="  1,     1.00   1.00   1.00   1.00    ",
            "  2,     1.00   1.00   1.00   1.00    ",
            "  3,     1.00   1.00   1.00   1.00    ",
            "  4,     1.00   1.00   1.00   1.00    ",
            "  5,     1.00   1.00   1.00   1.00    ",
            "  6,     1.00   1.00   1.00   1.00    " ,
            "  7,     1.00   1.00   1.00   1.00    "


;=====================================================================================
;   Coefficients for the Veh Avail Model - provided as variables instead of lookups  =
;=====================================================================================

;; v1_constant= 0  v2_constant= 1.05719498    v3_constant =-2.70675604   v4_constant =-6.03433686 Estimated  Constants
;; v1_constant= 0  v2_constant= 0.4512        v3_constant =-3.1838       v4_constant =-6.9323     Calibrated Constants/Try 1
;; v1_constant= 0  v2_constant= 0.5173        v3_constant =-3.1112       v4_constant =-6.8805     Calibrated Constants/Try 2
;; v1_constant= 0  v2_constant= 0.5334        v3_constant =-3.0902       v4_constant =-6.8599     Calibrated Constants/Try 3
;; v1_constant= 0  v2_constant= 0.5382        v3_constant =-3.0820       v4_constant =-6.8508     Calibrated Constants/Try 4



;; Estimated Coefficients --updated by M. Martchouk 11/02/10
;; Calibrated constants updated     by Milone       11/02/10
v1_constant= 0  v2_constant= 0.5382        v3_constant =-3.0820       v4_constant =-6.8508
v1_idum1   = 0  v2_idum1   = 0.0           v3_idum1    = 0.0          v4_idum1    = 0.0
v1_idum2   = 0  v2_idum2   = 1.45353047    v3_idum2    = 1.84315742   v4_idum2    = 2.46187933
v1_idum3   = 0  v2_idum3   = 2.25891102    v3_idum3    = 3.42089498   v4_idum3    = 4.62339172
v1_idum4   = 0  v2_idum4   = 2.65576393    v3_idum4    = 3.91630481   v4_idum4    = 5.54022044
v1_hh      = 0  v2_hh      = 0.16933726    v3_hh       = 1.3438729    v4_hh       = 1.69095555
v1_TrnAcc  = 0  v2_TrnAcc  =-1.20E-06      v3_TrnAcc   =-2.04E-06     v4_TrnAcc   =-2.37E-06
v1_Atype   = 0  v2_Atype   = 0.20915613    v3_Atype    = 0.47716419   v4_Atype    = 0.77921942
v1_DcDum   = 0  v2_DcDum   =-0.94482292    v3_DcDum    =-1.39768896   v4_DcDum    =-1.52940323





;=====================================================================================================
; End of Lookups-  Now read the input files                                                           =
;=====================================================================================================

;
; read Zonal land use files  into Z-File
;

ZDATI[1] = @ZNFILE_IN1@ ;; variables in DBF file: TAZ,  HH, HHPOP, JURCODE, HHINCIDX

; Zonal Area Type File
ZDATI[2] = @ZNFILE_IN2@ ;; variables in DBF file: TAZ, ATYPE


; Zonal Transit Access. Files
  ZDATI[3] = @ZNFILE_INa1@ ;   TAZ, emp45
  ZDATI[4] = @ZNFILE_INa2@ ;   TAZ, emp45
  ZDATI[5] = @ZNFILE_INa3@ ;   TAZ, emp45
  ZDATI[6] = @ZNFILE_INa4@ ;   TAZ, emp45

  ; Jobs within 45 min by AM Transit (Metrorail), use the Maximum Accessibility
  ; of all the AM Metrorail related path options
  TrnAcc = MAX(zi.3.emp45, zi.4.emp45, zi.5.emp45, zi.6.emp45)

;
; establish variables
;
                       HH      =  zi.1.HH[I]
                       HHPOP   =  zi.1.HHPOP[I]
                       IncRat  =  zi.1.HHINCIDX[I]
                       Atype   =  zi.2.ATYPE[I]
                         IF (I > @LastIzn@) Atype=6 ; temporarily assign externals to AT 6
                                                    ; so input value ('0') doesn't violate array dimensions
                       ;; TrnAcc  =  zi.3.TrnAcc[I]

                       IF( HH>HHPOP)
                           HH=HHPOP
                       ENDIF

                       HH_IP_Total = HH_IP_Total + HH  ; Input HH Total (to check O/P Total)

; Compute HH Size rounded to nearest 1/10th (K.Vaughn fix)
                       If (HH == 0)
                              AvHHSz = 1.0
                          Else
                              AvHHsz10ths = Round(HHPOP/HH * 10.0)                   ; compute Avg HH Size in tenths
                              AvHHsztrue  = AvHHsz10ths/10.0                         ; compute Avg HH Size actual
                              AvHHSz      = MIN(AvHHsztrue,3.9)                      ;
                       Endif


; Compute Juris. index 1-24 / compute DC dummy code for VA model

                       Jdx = zi.1.JURCODE + 1

                       IF (zi.1.JURCODE  = 0)
                            DCDUM = 1
                          ELSE
                            DCDUM = 0
                       ENDIF

; Accumulate jurisdiction level & total land use values
;

;-----------------------------------------------------------------------
;Begin Matrix Work Now ...
;-----------------------------------------------------------------------


; Clear all initial/computed arrays, establish initial marginal controls

Loop sz = 1, @SzCl@
     Loop in = 1, @InCl@

          CSZINA[sz][in] = 0      ; initial matrix cell value
     EndLoop
EndLoop

Loop IDX=1,@SzCl@
         ISZA[IDX] = 0
         CSZA[IDX] = 0
         ISZA[IDX] = HH * (SZPCTA(IDX,AvHHSz)/100.0)
EndLOOP

Loop IDX=1,@InCl@
         IInA[IDX] = 0
         CInA[IDX] = 0
         IInA[IDX] = HH * (INPCTA(IDX,IncRat)/100.0)
EndLOOP

;** Debug 1 On **
;* if (I==1)
;*     Print List = I(5),HHPOP(10),HH(10.0),Incrat(10.2), AvHHSz(10.2),file=debug.txt
;*  loop idx = 1,4
;*      spct =SZPCTA(IDX,AvHHSz)
;*      ipct =INPCTA(IDX,IncRat)
;*      Print List = HH(10), AvHHSz(10.2),Incrat(10.2),SPCT,IPCT,ISZA[IDX],IINA[IDX], file=debug1.txt
;*  endloop
;* endif
;** Debug 1 Off**


;
; Setup Initial HH Size by Income Matrix with PUMS seed Pcts
;   and accumulate Size, Income marginals

Loop sz = 1, @SzCl@
     Loop in = 1, @InCl@
          IDX = sz * 10.0 + in ; 2-digit index, 1st=HHsize& 2nd=Inc.level
          CSZINA[sz][in] = ISZA[sz] * (I_SPCTA(1,IDX)/100.00)  ; initial matrix cell value
          CSZA[sz]    = CSZA[sz] + CSZINA[sz][in]    ; initial/'control' marginal size total
          CINA[in]    = CINA[in] + CSZINA[sz][in]    ; initial/'control' marginal Inc  total

;** Debug 2 On **
;* if (I==1)
;*      IF (sz <= 4 &&  in<=4)
;*         print list =' init matrix: inc: ', in(3),' hhs: ', sz(3), cszina[idx](7.3) , file=debug2.txt
;*      Endif
;* endif
;*
;*
;** Debug 2 Off**
     EndLoop
EndLoop


; Initial matrix now established, now
; begin fratar process
;
;

LOOP FRAT= 1,3
  OddEve   = FRAT%2  ; Modulo function to check Odd/Even iteration:0=even/nonzero=odd
  IF (OddEve != 0) ; if an odd iteration then adjust cols ...
;
       Loop in=1,@InCl@
            IF  (CINA[in] == 0 )
                     CINADJA[in] = 0
               ELSE
                     CINADJA[in] = IINA[in] / CINA[in]
            ENDIF
       EndLoop


       Loop IDX=1,@SzCl@
                CSZA[IDX] = 0
       EndLOOP

       Loop IDX=1,@InCl@
                CINA[IDX] = 0
       EndLOOP

       Loop sz= 1,@SzCl@
         Loop in= 1,@InCl@

                 CSZINA[sz][in] = CSZINA[sz][in] * CINADJA[in]
                 CSZA[sz]      = CSZA[sz]    + CSZINA[sz][in]    ; computed/current marginal size total
                 CINA[in]      = CINA[in]    + CSZINA[sz][in]    ; computed/current marginal Inc  total
         EndLoop
       EndLoop
       ;
    ELSE
       ; begin computing of row (size) adjustments
       ; and apply adjustments to the matrix...
       ;

       Loop sz=1,@SzCl@
            IF  (CSZA[sz] == 0 )
                     CSZADJA[sz] = 0
               ELSE
                     CSZADJA[sz] = ISZA[sz] / CSZA[sz]
            ENDIF
       EndLoop

       Loop IDX=1,@SzCl@
                CSZA[IDX] = 0
       EndLOOP

       Loop IDX=1,@InCl@
                CINA[IDX] = 0
       EndLOOP

       Loop sz= 1,@SzCl@
         Loop in= 1,@InCl@

                 CSZINA[sz][in] = CSZINA[sz][in] * CSZADJA[sz]
                 CSZA[sz]    = CSZA[sz]    + CSZINA[sz][in]    ; computed/current marginal size total
                 CINA[in]    = CINA[in]    + CSZINA[sz][in]    ; computed/current marginal Inc  total
         EndLoop
       EndLoop
  ENDIF
ENDLOOP

; ============================================================================================
; Apply final Size/Income adjustments (if desired) and then
; accumulate final Jurisdictional/ Regional marginals and totals
; ============================================================================================

       Loop sz= 1,@SzCl@
         Loop in= 1,@InCl@

                 temp         =  CSZINA[sz][in] * AreaSizFtr(Sz,Atype) * AreaIncFtr(In,Atype) ; Apply Final Size/Income Adjustment
                 CSZINA[sz][in]      =  temp                         ; and store back in CSZINA array
                 RegSzInA[sz][in]    =  RegSzInA[sz][in]     +  CSZINA[sz][in]
                 JurSzA[jdx][sz]     =  JurSzA[jdx][sz]      +  CSZINA[sz][in]
                 JurInA[jdx][in]     =  JurInA[jdx][in]      +  CSZINA[sz][in]
                 RegSzA[sz]          =  RegSzA[sz]           +  CSZINA[sz][in]
                 RegInA[in]          =  RegInA[in]           +  CSZINA[sz][in]
                 ArSzA[Atype][sz]    =  ArSzA[Atype][sz]     +  CSZINA[sz][in]
                 ArInA[Atype][in]    =  ArInA[Atype][in]     +  CSZINA[sz][in]
                 AreaA[Atype]        =  AreaA[Atype]         +  CSZINA[sz][in]
                 JurA[Jdx]         =  JurA[Jdx]              +  CSZINA[sz][in]
                 SITotal           =  SITotal                +  CSZINA[sz][in]
         EndLoop
       EndLoop

; ============================================================================================
; Summarize/Print HHs by size groups and HHs by Income groups for zonal checking
;
; ============================================================================================
        HH_Sz1   =  CSZINA[1][1] + CSZINA[1][2] + CSZINA[1][3] + CSZINA[1][4]
        HH_Sz2   =  CSZINA[2][1] + CSZINA[2][2] + CSZINA[2][3] + CSZINA[2][4]
        HH_Sz3   =  CSZINA[3][1] + CSZINA[3][2] + CSZINA[3][3] + CSZINA[3][4]
        HH_Sz4   =  CSZINA[4][1] + CSZINA[4][2] + CSZINA[4][3] + CSZINA[4][4]
;
        HH_In1   =  CSZINA[1][1] + CSZINA[2][1] + CSZINA[3][1] + CSZINA[4][1]
        HH_In2   =  CSZINA[1][2] + CSZINA[2][2] + CSZINA[3][2] + CSZINA[4][2]
        HH_In3   =  CSZINA[1][3] + CSZINA[2][3] + CSZINA[3][3] + CSZINA[4][3]
        HH_In4   =  CSZINA[1][4] + CSZINA[2][4] + CSZINA[3][4] + CSZINA[4][4]
;
;
    Print List=  I(4),HH_Sz1@ofmt@,HH_Sz2@ofmt@,HH_Sz3@ofmt@,HH_Sz4@ofmt@,file=Est_Zonal_HH_Size.TXT
    Print List=  I(4),HH_In1@ofmt@,HH_In2@ofmt@,HH_In3@ofmt@,HH_In4@ofmt@,file=Est_Zonal_HH_Inc.TXT

;=============================================================================================
; All Done with Size and Income computations - Now apply Veh. Availability Model
; Loop through size and income cell and further disggregate among veh.av. groups
;===========================================================================================

  Loop sz=1,@SzCl@
    Loop in=1,@InCl@



                  P_VA[1] = 0
                  P_VA[2] = 0
                  P_VA[3] = 0
                  P_VA[4] = 0
                  IncDum1 = 0
                  IncDum2 = 0
                  IncDum3 = 0
                  IncDum4 = 0
                  If (in == 1)  IncDum1 = 1
                  If (in == 2)  IncDum2 = 1
                  If (in == 3)  IncDum3 = 1
                  If (in == 4)  IncDum4 = 1

                  ;;compute VA utilities
                   u_1  = v1_constant                       +
                          v1_idum1     * IncDum1            +
                          v1_idum2     * IncDum2            +
                          v1_idum3     * IncDum3            +
                          v1_idum4     * IncDum4            +
                          v1_hh        * SZ                 +
                          v1_TrnAcc    * TrnAcc             +
                          v1_Atype     * AType              +
                          v1_DcDum     * DCDUM

                   u_2  = v2_constant                       +
                          v2_idum1     * IncDum1            +
                          v2_idum2     * IncDum2            +
                          v2_idum3     * IncDum3            +
                          v2_idum4     * IncDum4            +
                          v2_hh        * SZ                 +
                          v2_TrnAcc    * TrnAcc             +
                          v2_Atype     * AType              +
                          v2_DcDum     * DCDUM

                   u_3  = v3_constant                       +
                          v3_idum1     * IncDum1            +
                          v3_idum2     * IncDum2            +
                          v3_idum3     * IncDum3            +
                          v3_idum4     * IncDum4            +
                          v3_hh        * SZ                 +
                          v3_TrnAcc    * TrnAcc             +
                          v3_Atype     * AType              +
                          v3_DcDum     * DCDUM

                   u_4  = v4_constant                       +
                          v4_idum1     * IncDum1            +
                          v4_idum2     * IncDum2            +
                          v4_idum3     * IncDum3            +
                          v4_idum4     * IncDum4            +
                          v4_hh        * SZ                 +
                          v4_TrnAcc    * TrnAcc             +
                          v4_Atype     * AType              +
                          v4_DcDum     * DCDUM

             ;;compute VA probabilities
                    P_VA[1] =  exp(u_1) / (exp(u_1) + exp(u_2) + exp(u_3) + exp(u_4))
                    P_VA[2] =  exp(u_2) / (exp(u_1) + exp(u_2) + exp(u_3) + exp(u_4))
                    P_VA[3] =  exp(u_3) / (exp(u_1) + exp(u_2) + exp(u_3) + exp(u_4))
                    P_VA[4] =  exp(u_4) / (exp(u_1) + exp(u_2) + exp(u_3) + exp(u_4))


             ;; apply Veh Avail. probabilities
                    CSZINVAA[Sz][In][1]  =   CSZINA[Sz][In]  *  P_VA[1] ;


                    CSZINVAA[Sz][In][2]  =   CSZINA[Sz][In]  *  P_VA[2] ;


                    CSZINVAA[Sz][In][3]  =   CSZINA[Sz][In]  *  P_VA[3] ;


                    CSZINVAA[Sz][In][4]  =   CSZINA[Sz][In]  *  P_VA[4] ;

         EndLoop
       EndLoop


      ; accumulate HHs in Vehicle Available groups (0,1,2+) for current TAZ
      ; also accumulate regional totals for checking

                    HHw0Vehs =  CSZINVAA[1][1][1] +  CSZINVAA[1][2][1] +  CSZINVAA[1][3][1] +  CSZINVAA[1][4][1] +
                                CSZINVAA[2][1][1] +  CSZINVAA[2][2][1] +  CSZINVAA[2][3][1] +  CSZINVAA[2][4][1] +
                                CSZINVAA[3][1][1] +  CSZINVAA[3][2][1] +  CSZINVAA[3][3][1] +  CSZINVAA[3][4][1] +
                                CSZINVAA[4][1][1] +  CSZINVAA[4][2][1] +  CSZINVAA[4][3][1] +  CSZINVAA[4][4][1]


                    HHw1Vehs =  CSZINVAA[1][1][2] +  CSZINVAA[1][2][2] +  CSZINVAA[1][3][2] +  CSZINVAA[1][4][2] +
                                CSZINVAA[2][1][2] +  CSZINVAA[2][2][2] +  CSZINVAA[2][3][2] +  CSZINVAA[2][4][2] +
                                CSZINVAA[3][1][2] +  CSZINVAA[3][2][2] +  CSZINVAA[3][3][2] +  CSZINVAA[3][4][2] +
                                CSZINVAA[4][1][2] +  CSZINVAA[4][2][2] +  CSZINVAA[4][3][2] +  CSZINVAA[4][4][2]


                    HHw2Vehs =  CSZINVAA[1][1][3] +  CSZINVAA[1][2][3] +  CSZINVAA[1][3][3] +  CSZINVAA[1][4][3] +
                                CSZINVAA[2][1][3] +  CSZINVAA[2][2][3] +  CSZINVAA[2][3][3] +  CSZINVAA[2][4][3] +
                                CSZINVAA[3][1][3] +  CSZINVAA[3][2][3] +  CSZINVAA[3][3][3] +  CSZINVAA[3][4][3] +
                                CSZINVAA[4][1][3] +  CSZINVAA[4][2][3] +  CSZINVAA[4][3][3] +  CSZINVAA[4][4][3]


                    HHw3Vehs =  CSZINVAA[1][1][4] +  CSZINVAA[1][2][4] +  CSZINVAA[1][3][4] +  CSZINVAA[1][4][4] +
                                CSZINVAA[2][1][4] +  CSZINVAA[2][2][4] +  CSZINVAA[2][3][4] +  CSZINVAA[2][4][4] +
                                CSZINVAA[3][1][4] +  CSZINVAA[3][2][4] +  CSZINVAA[3][3][4] +  CSZINVAA[3][4][4] +
                                CSZINVAA[4][1][4] +  CSZINVAA[4][2][4] +  CSZINVAA[4][3][4] +  CSZINVAA[4][4][4]

                    HHw2PVehs = HHw2Vehs + HHw3Vehs


                   Tot_HHw0Vehs =  Tot_HHw0Vehs +  HHw0Vehs
                   Tot_HHw1Vehs =  Tot_HHw1Vehs +  HHw1Vehs
                   Tot_HHw2Vehs =  Tot_HHw2Vehs +  HHw2Vehs
                   Tot_HHw3Vehs =  Tot_HHw3Vehs +  HHw3Vehs

                   Tot_HHw2PVehs =  Tot_HHw2PVehs +  HHw2PVehs

;===========================================================================================
;  --Print out
;     zonal Household file for Mode Choice Model HHs by 0 , 1, 2+     Groups
;     and   Household file for Mode Choice Model HHs by 0 , 1, 2, 3+  Groups
;===========================================================================================

;;  Print List=  I(5),
;;               HHw0Vehs(6),HHw1Vehs(6),HHw2PVehs(6),file=@ZNFILE_OU5@

    Print List=  I(4), HHw0Vehs@ofmt@, HHw1Vehs@ofmt@, HHw2Vehs@ofmt@, HHw3Vehs@ofmt@,file=Est_Zonal_HH_VehAv.TXT

;===========================================================================================
; The Calculations are complete for the current zone
; and let's accumulate Veh Av. related Jurisdictional/ Regional marginals and totals
;===========================================================================================


  Loop sz=1,@SzCl@
    Loop in=1,@InCl@
      Loop Va=1,@VaCl@
                    RegSzInVaA[Sz][In][Va] = RegSzInVaA[Sz][In][Va] +  CSZINVAA[Sz][In][Va]
                    JurVaA[Jdx][Va]        = JurVaA[Jdx][Va]        +  CSZINVAA[Sz][In][Va]
                    ArVaA[Atype][va]       = ArVaA[Atype][va]       +  CSZINVAA[Sz][In][Va]
                    RegVaA[VA]             = RegVaA[VA]             +  CSZINVAA[Sz][In][Va]
                    RegVaSzA[va][sz]       = RegVaSzA[va][sz]       +  CSZINVAA[Sz][In][Va]
                    RegVaInA[va][in]       = RegVaInA[va][in]       +  CSZINVAA[Sz][In][Va]
                    SIVTotal               = SIVTotal               +  CSZINVAA[Sz][In][Va]
     EndLoop
   EndLoop
 EndLoop




;===========================================================================================
; Now We're at the end of the Iloop
;  --Print out input files to Trip Generation
;     4 income based files written in text form TAZ, HH by size&VeAv s1v1,s1v2,...,s4v4
;===========================================================================================

;Income 1 file with HHs by Size and VehAv:
    Print List=  I(4),
                 CSZINVAA[1][1][1]@ofmt@, CSZINVAA[1][1][2]@ofmt@, CSZINVAA[1][1][3]@ofmt@, CSZINVAA[1][1][4]@ofmt@,
                 CSZINVAA[2][1][1]@ofmt@, CSZINVAA[2][1][2]@ofmt@, CSZINVAA[2][1][3]@ofmt@, CSZINVAA[2][1][4]@ofmt@,
                 CSZINVAA[3][1][1]@ofmt@, CSZINVAA[3][1][2]@ofmt@, CSZINVAA[3][1][3]@ofmt@, CSZINVAA[3][1][4]@ofmt@,
                 CSZINVAA[4][1][1]@ofmt@, CSZINVAA[4][1][2]@ofmt@, CSZINVAA[4][1][3]@ofmt@, CSZINVAA[4][1][4]@ofmt@,file=@ZNFILE_OU1@

;Income 2 file with HHs by Size and VehAv:
    Print List=  I(4),
                 CSZINVAA[1][2][1]@ofmt@, CSZINVAA[1][2][2]@ofmt@, CSZINVAA[1][2][3]@ofmt@, CSZINVAA[1][2][4]@ofmt@,
                 CSZINVAA[2][2][1]@ofmt@, CSZINVAA[2][2][2]@ofmt@, CSZINVAA[2][2][3]@ofmt@, CSZINVAA[2][2][4]@ofmt@,
                 CSZINVAA[3][2][1]@ofmt@, CSZINVAA[3][2][2]@ofmt@, CSZINVAA[3][2][3]@ofmt@, CSZINVAA[3][2][4]@ofmt@,
                 CSZINVAA[4][2][1]@ofmt@, CSZINVAA[4][2][2]@ofmt@, CSZINVAA[4][2][3]@ofmt@, CSZINVAA[4][2][4]@ofmt@,file=@ZNFILE_OU2@

;Income 3 file with HHs by Size and VehAv:
    Print List=  I(4),
                 CSZINVAA[1][3][1]@ofmt@, CSZINVAA[1][3][2]@ofmt@, CSZINVAA[1][3][3]@ofmt@, CSZINVAA[1][3][4]@ofmt@,
                 CSZINVAA[2][3][1]@ofmt@, CSZINVAA[2][3][2]@ofmt@, CSZINVAA[2][3][3]@ofmt@, CSZINVAA[2][3][4]@ofmt@,
                 CSZINVAA[3][3][1]@ofmt@, CSZINVAA[3][3][2]@ofmt@, CSZINVAA[3][3][3]@ofmt@, CSZINVAA[3][3][4]@ofmt@,
                 CSZINVAA[4][3][1]@ofmt@, CSZINVAA[4][3][2]@ofmt@, CSZINVAA[4][3][3]@ofmt@, CSZINVAA[4][3][4]@ofmt@,file=@ZNFILE_OU3@

;Income 4 file with HHs by Size and VehAv:
    Print List=  I(4),
                 CSZINVAA[1][4][1]@ofmt@, CSZINVAA[1][4][2]@ofmt@, CSZINVAA[1][4][3]@ofmt@, CSZINVAA[1][4][4]@ofmt@,
                 CSZINVAA[2][4][1]@ofmt@, CSZINVAA[2][4][2]@ofmt@, CSZINVAA[2][4][3]@ofmt@, CSZINVAA[2][4][4]@ofmt@,
                 CSZINVAA[3][4][1]@ofmt@, CSZINVAA[3][4][2]@ofmt@, CSZINVAA[3][4][3]@ofmt@, CSZINVAA[3][4][4]@ofmt@,
                 CSZINVAA[4][4][1]@ofmt@, CSZINVAA[4][4][2]@ofmt@, CSZINVAA[4][4][3]@ofmt@, CSZINVAA[4][4][4]@ofmt@,file=@ZNFILE_OU4@

;;
;; write out dbf files for HHs by cross-class
;; Define output variables

FILEO RECO[1]    = "@ZonalCCHHs@",fields =
                 I(5),
                 HHsISV111@ofmt@, HHsISV112@ofmt@, HHsISV113@ofmt@, HHsISV114@ofmt@,
                 HHsISV211@ofmt@, HHsISV212@ofmt@, HHsISV213@ofmt@, HHsISV214@ofmt@,
                 HHsISV311@ofmt@, HHsISV312@ofmt@, HHsISV313@ofmt@, HHsISV314@ofmt@,
                 HHsISV411@ofmt@, HHsISV412@ofmt@, HHsISV413@ofmt@, HHsISV414@ofmt@,
                 HHsISV121@ofmt@, HHsISV122@ofmt@, HHsISV123@ofmt@, HHsISV124@ofmt@,
                 HHsISV221@ofmt@, HHsISV222@ofmt@, HHsISV223@ofmt@, HHsISV224@ofmt@,
                 HHsISV321@ofmt@, HHsISV322@ofmt@, HHsISV323@ofmt@, HHsISV324@ofmt@,
                 HHsISV421@ofmt@, HHsISV422@ofmt@, HHsISV423@ofmt@, HHsISV424@ofmt@,
                 HHsISV131@ofmt@, HHsISV132@ofmt@, HHsISV133@ofmt@, HHsISV134@ofmt@,
                 HHsISV231@ofmt@, HHsISV232@ofmt@, HHsISV233@ofmt@, HHsISV234@ofmt@,
                 HHsISV331@ofmt@, HHsISV332@ofmt@, HHsISV333@ofmt@, HHsISV334@ofmt@,
                 HHsISV431@ofmt@, HHsISV432@ofmt@, HHsISV433@ofmt@, HHsISV434@ofmt@,
                 HHsISV141@ofmt@, HHsISV142@ofmt@, HHsISV143@ofmt@, HHsISV144@ofmt@,
                 HHsISV241@ofmt@, HHsISV242@ofmt@, HHsISV243@ofmt@, HHsISV244@ofmt@,
                 HHsISV341@ofmt@, HHsISV342@ofmt@, HHsISV343@ofmt@, HHsISV344@ofmt@,
                 HHsISV441@ofmt@, HHsISV442@ofmt@, HHsISV443@ofmt@, HHsISV444@ofmt@


;;
;; write out dbf files for HHs by cross class (Corrected 10/30/10)
;;
 ro.HHsISV111 = CSZINVAA[1][1][1]   ro.HHsISV112 = CSZINVAA[1][1][2]  ro.HHsISV113 = CSZINVAA[1][1][3]  ro.HHsISV114 = CSZINVAA[1][1][4]
 ro.HHsISV211 = CSZINVAA[1][2][1]   ro.HHsISV212 = CSZINVAA[1][2][2]  ro.HHsISV213 = CSZINVAA[1][2][3]  ro.HHsISV214 = CSZINVAA[1][2][4]
 ro.HHsISV311 = CSZINVAA[1][3][1]   ro.HHsISV312 = CSZINVAA[1][3][2]  ro.HHsISV313 = CSZINVAA[1][3][3]  ro.HHsISV314 = CSZINVAA[1][3][4]
 ro.HHsISV411 = CSZINVAA[1][4][1]   ro.HHsISV412 = CSZINVAA[1][4][2]  ro.HHsISV413 = CSZINVAA[1][4][3]  ro.HHsISV414 = CSZINVAA[1][4][4]

 ro.HHsISV121 = CSZINVAA[2][1][1]   ro.HHsISV122 = CSZINVAA[2][1][2]  ro.HHsISV123 = CSZINVAA[2][1][3]  ro.HHsISV124 = CSZINVAA[2][1][4]
 ro.HHsISV221 = CSZINVAA[2][2][1]   ro.HHsISV222 = CSZINVAA[2][2][2]  ro.HHsISV223 = CSZINVAA[2][2][3]  ro.HHsISV224 = CSZINVAA[2][2][4]
 ro.HHsISV321 = CSZINVAA[2][3][1]   ro.HHsISV322 = CSZINVAA[2][3][2]  ro.HHsISV323 = CSZINVAA[2][3][3]  ro.HHsISV324 = CSZINVAA[2][3][4]
 ro.HHsISV421 = CSZINVAA[2][4][1]   ro.HHsISV422 = CSZINVAA[2][4][2]  ro.HHsISV423 = CSZINVAA[2][4][3]  ro.HHsISV424 = CSZINVAA[2][4][4]

 ro.HHsISV131 = CSZINVAA[3][1][1]   ro.HHsISV132 = CSZINVAA[3][1][2]  ro.HHsISV133 = CSZINVAA[3][1][3]  ro.HHsISV134 = CSZINVAA[3][1][4]
 ro.HHsISV231 = CSZINVAA[3][2][1]   ro.HHsISV232 = CSZINVAA[3][2][2]  ro.HHsISV233 = CSZINVAA[3][2][3]  ro.HHsISV234 = CSZINVAA[3][2][4]
 ro.HHsISV331 = CSZINVAA[3][3][1]   ro.HHsISV332 = CSZINVAA[3][3][2]  ro.HHsISV333 = CSZINVAA[3][3][3]  ro.HHsISV334 = CSZINVAA[3][3][4]
 ro.HHsISV431 = CSZINVAA[3][4][1]   ro.HHsISV432 = CSZINVAA[3][4][2]  ro.HHsISV433 = CSZINVAA[3][4][3]  ro.HHsISV434 = CSZINVAA[3][4][4]

 ro.HHsISV141 = CSZINVAA[4][1][1]   ro.HHsISV142 = CSZINVAA[4][1][2]  ro.HHsISV143 = CSZINVAA[4][1][3]  ro.HHsISV144 = CSZINVAA[4][1][4]
 ro.HHsISV241 = CSZINVAA[4][2][1]   ro.HHsISV242 = CSZINVAA[4][2][2]  ro.HHsISV243 = CSZINVAA[4][2][3]  ro.HHsISV244 = CSZINVAA[4][2][4]
 ro.HHsISV341 = CSZINVAA[4][3][1]   ro.HHsISV342 = CSZINVAA[4][3][2]  ro.HHsISV343 = CSZINVAA[4][3][3]  ro.HHsISV344 = CSZINVAA[4][3][4]
 ro.HHsISV441 = CSZINVAA[4][4][1]   ro.HHsISV442 = CSZINVAA[4][4][2]  ro.HHsISV443 = CSZINVAA[4][4][3]  ro.HHsISV444 = CSZINVAA[4][4][4]
 WRITE RECO=1

;===========================================================================================
; Finally accumulate Size, Inc, Veh.Av variables by area type for reporting
;===========================================================================================


If (I <= @LastIZN@)



   HH_S1  = HH_S1     + CSZINA[1][1] + CSZINA[1][2] + CSZINA[1][3] + CSZINA[1][4]
   HH_S2  = HH_S2     + CSZINA[2][1] + CSZINA[2][2] + CSZINA[2][3] + CSZINA[2][4]
   HH_S3  = HH_S3     + CSZINA[3][1] + CSZINA[3][2] + CSZINA[3][3] + CSZINA[3][4]
   HH_S4  = HH_S4     + CSZINA[4][1] + CSZINA[4][2] + CSZINA[4][3] + CSZINA[4][4]

   HH_I1  = HH_I1     + CSZINA[1][1] + CSZINA[2][1] + CSZINA[3][1] + CSZINA[4][1]
   HH_I2  = HH_I2     + CSZINA[1][2] + CSZINA[2][2] + CSZINA[3][2] + CSZINA[4][2]
   HH_I3  = HH_I3     + CSZINA[1][3] + CSZINA[2][3] + CSZINA[3][3] + CSZINA[4][3]
   HH_I4  = HH_I4     + CSZINA[1][4] + CSZINA[2][4] + CSZINA[3][4] + CSZINA[4][4]

   HH_V1  = HH_V1     + HHw0Vehs
   HH_V2  = HH_V2     + HHw1Vehs
   HH_V3  = HH_V3     + HHw2Vehs
   HH_V4  = HH_V4     + HHw3Vehs

   HH_S   = HH_S      + CSZINA[1][1] + CSZINA[1][2] + CSZINA[1][3] + CSZINA[1][4] +
                        CSZINA[2][1] + CSZINA[2][2] + CSZINA[2][3] + CSZINA[2][4] +
                        CSZINA[3][1] + CSZINA[3][2] + CSZINA[3][3] + CSZINA[3][4] +
                        CSZINA[4][1] + CSZINA[4][2] + CSZINA[4][3] + CSZINA[4][4]

   HH_I   = HH_I      + CSZINA[1][1] + CSZINA[2][1] + CSZINA[3][1] + CSZINA[4][1] +
                        CSZINA[1][2] + CSZINA[2][2] + CSZINA[3][2] + CSZINA[4][2] +
                        CSZINA[1][3] + CSZINA[2][3] + CSZINA[3][3] + CSZINA[4][3] +
                        CSZINA[1][4] + CSZINA[2][4] + CSZINA[3][4] + CSZINA[4][4]



   HH_V   = HH_V      + HHw0Vehs +
                        HHw1Vehs +
                        HHw2Vehs +
                        HHw3Vehs



Endif

;===========================================================================================
;  If we're at the last Zone, it's time to printout the listings and we're done.
;===========================================================================================

IF (I=@ZONESIZE@)

   Print LIST= '  Demographic Model Report ', file=@Rept@ ;
   Print LIST= '   ',file=@Rept@
   Print LIST= '   ',file=@Rept@

   Print LIST= '   ',file=@Rept@
   Print LIST= '      Untransformed - Household Total from the Input File:', HH_IP_Total(12.0),file=@Rept@ ;
   Print LIST= '   ',file=@Rept@
   Print LIST= '   ',file=@Rept@
   PRINT LIST =' Regional Households by Size and Income Summary ',file=@Rept@
   PRINT LIST ='   Size      Inc_1         Inc_2      Inc_3       Inc_4      Total       ',file=@Rept@
   PRINT LIST ='          ------------ ----------- ----------- ----------- -----------   ',file=@Rept@

   Print form=12.csv LIST= '      1   ',RegSzInA[1][1],RegSzInA[1][2],RegSzInA[1][3],RegSzInA[1][4],RegSzA[1],file=@Rept@ ;
   Print form=12.csv LIST= '      2   ',RegSzInA[2][1],RegSzInA[2][2],RegSzInA[2][3],RegSzInA[2][4],RegSzA[2],file=@Rept@ ;
   Print form=12.csv LIST= '      3   ',RegSzInA[3][1],RegSzInA[3][2],RegSzInA[3][3],RegSzInA[3][4],RegSzA[3],file=@Rept@ ;
   Print form=12.csv LIST= '      4+  ',RegSzInA[4][1],RegSzInA[4][2],RegSzInA[4][3],RegSzInA[4][4],RegSzA[4],file=@Rept@ ;
   Print LIST= '   ',file=@Rept@
   Print form=12.csv LIST= ' Total    ',RegInA[1],   RegInA[2],   RegInA[3],   RegInA[4],   SITotal,file=@Rept@ ;
   Print LIST= '   ',file=@Rept@
   Print LIST= '   ',file=@Rept@

;===========================================================================================================

   PRINT LIST =' Jurisdictional Households by Size ',file=@Rept@
   PRINT LIST ='  Juris.    Size_1        Size_2     Size_3      Size_4      Total       ',file=@Rept@
   PRINT LIST ='          ------------ ----------- ----------- ----------- -----------   ',file=@Rept@

   Print form=12.csv LIST= '    0_DC  ',JurSzA[01][1],JurSzA[01][2],JurSzA[01][3],JurSzA[01][4],JurA[01],file=@Rept@ ;
   Print form=12.csv LIST= '    1_Mtg ',JurSzA[02][1],JurSzA[02][2],JurSzA[02][3],JurSzA[02][4],JurA[02],file=@Rept@ ;
   Print form=12.csv LIST= '    2_PG  ',JurSzA[03][1],JurSzA[03][2],JurSzA[03][3],JurSzA[03][4],JurA[03],file=@Rept@ ;
   Print form=12.csv LIST= '    3_Arl ',JurSzA[04][1],JurSzA[04][2],JurSzA[04][3],JurSzA[04][4],JurA[04],file=@Rept@ ;
   Print form=12.csv LIST= '    4_Alx ',JurSzA[05][1],JurSzA[05][2],JurSzA[05][3],JurSzA[05][4],JurA[05],file=@Rept@ ;
   Print form=12.csv LIST= '    5_Ffx ',JurSzA[06][1],JurSzA[06][2],JurSzA[06][3],JurSzA[06][4],JurA[06],file=@Rept@ ;
   Print form=12.csv LIST= '    6_Ldn ',JurSzA[07][1],JurSzA[07][2],JurSzA[07][3],JurSzA[07][4],JurA[07],file=@Rept@ ;
   Print form=12.csv LIST= '    7_PW  ',JurSzA[08][1],JurSzA[08][2],JurSzA[08][3],JurSzA[08][4],JurA[08],file=@Rept@ ;
   Print form=12.csv LIST= '    8_ -  ',JurSzA[09][1],JurSzA[09][2],JurSzA[09][3],JurSzA[09][4],JurA[09],file=@Rept@ ;
   Print form=12.csv LIST= '    9_Frd ',JurSzA[10][1],JurSzA[10][2],JurSzA[10][3],JurSzA[10][4],JurA[10],file=@Rept@ ;
   Print form=12.csv LIST= '   10_How ',JurSzA[11][1],JurSzA[11][2],JurSzA[11][3],JurSzA[11][4],JurA[11],file=@Rept@ ;
   Print form=12.csv LIST= '   11_AA  ',JurSzA[12][1],JurSzA[12][2],JurSzA[12][3],JurSzA[12][4],JurA[12],file=@Rept@ ;
   Print form=12.csv LIST= '   12_Chs ',JurSzA[13][1],JurSzA[13][2],JurSzA[13][3],JurSzA[13][4],JurA[13],file=@Rept@ ;
   Print form=12.csv LIST= '   13_ -  ',JurSzA[14][1],JurSzA[14][2],JurSzA[14][3],JurSzA[14][4],JurA[14],file=@Rept@ ;
   Print form=12.csv LIST= '   14_Car ',JurSzA[15][1],JurSzA[15][2],JurSzA[15][3],JurSzA[15][4],JurA[15],file=@Rept@ ;
   Print form=12.csv LIST= '   15_Cal ',JurSzA[16][1],JurSzA[16][2],JurSzA[16][3],JurSzA[16][4],JurA[16],file=@Rept@ ;
   Print form=12.csv LIST= '   16_SM  ',JurSzA[17][1],JurSzA[17][2],JurSzA[17][3],JurSzA[17][4],JurA[17],file=@Rept@ ;
   Print form=12.csv LIST= '   17_KGeo',JurSzA[18][1],JurSzA[18][2],JurSzA[18][3],JurSzA[18][4],JurA[18],file=@Rept@ ;
   Print form=12.csv LIST= '   18_Fbg ',JurSzA[19][1],JurSzA[19][2],JurSzA[19][3],JurSzA[19][4],JurA[19],file=@Rept@ ;
   Print form=12.csv LIST= '   19_Sta ',JurSzA[20][1],JurSzA[20][2],JurSzA[20][3],JurSzA[20][4],JurA[20],file=@Rept@ ;
   Print form=12.csv LIST= '   20_Spt ',JurSzA[21][1],JurSzA[21][2],JurSzA[21][3],JurSzA[21][4],JurA[21],file=@Rept@ ;
   Print form=12.csv LIST= '   21_Fau ',JurSzA[22][1],JurSzA[22][2],JurSzA[22][3],JurSzA[22][4],JurA[22],file=@Rept@ ;
   Print form=12.csv LIST= '   22_Clk ',JurSzA[23][1],JurSzA[23][2],JurSzA[23][3],JurSzA[23][4],JurA[23],file=@Rept@ ;
   Print form=12.csv LIST= '   23_Jef ',JurSzA[24][1],JurSzA[24][2],JurSzA[24][3],JurSzA[24][4],JurA[24],file=@Rept@ ;

   Print LIST= '   ',file=@Rept@
   Print form=12.csv LIST= ' Total    ',RegSzA[1],  RegSzA[2],  RegSzA[3],  RegSzA[4],  SITotal,file=@Rept@ ;
   Print LIST= '   ',file=@Rept@
   Print LIST= '   ',file=@Rept@
;===========================================================================================================

   PRINT LIST =' Jurisdictional Households by Income ',file=@Rept@
   PRINT LIST ='  Juris.    Inc_1         Inc_2       Inc_3       Inc_4      Total       ',file=@Rept@
   PRINT LIST ='          ------------ ----------- ----------- ----------- -----------   ',file=@Rept@

   Print form=12.csv LIST= '    0_DC  ',JurInA[01][1],JurInA[01][2],JurInA[01][3],JurInA[01][4],JurA[01],file=@Rept@ ;
   Print form=12.csv LIST= '    1_Mtg ',JurInA[02][1],JurInA[02][2],JurInA[02][3],JurInA[02][4],JurA[02],file=@Rept@ ;
   Print form=12.csv LIST= '    2_PG  ',JurInA[03][1],JurInA[03][2],JurInA[03][3],JurInA[03][4],JurA[03],file=@Rept@ ;
   Print form=12.csv LIST= '    3_Arl ',JurInA[04][1],JurInA[04][2],JurInA[04][3],JurInA[04][4],JurA[04],file=@Rept@ ;
   Print form=12.csv LIST= '    4_Alx ',JurInA[05][1],JurInA[05][2],JurInA[05][3],JurInA[05][4],JurA[05],file=@Rept@ ;
   Print form=12.csv LIST= '    5_Ffx ',JurInA[06][1],JurInA[06][2],JurInA[06][3],JurInA[06][4],JurA[06],file=@Rept@ ;
   Print form=12.csv LIST= '    6_Ldn ',JurInA[07][1],JurInA[07][2],JurInA[07][3],JurInA[07][4],JurA[07],file=@Rept@ ;
   Print form=12.csv LIST= '    7_PW  ',JurInA[08][1],JurInA[08][2],JurInA[08][3],JurInA[08][4],JurA[08],file=@Rept@ ;
   Print form=12.csv LIST= '    8_ -  ',JurInA[09][1],JurInA[09][2],JurInA[09][3],JurInA[09][4],JurA[09],file=@Rept@ ;
   Print form=12.csv LIST= '    9_Frd ',JurInA[10][1],JurInA[10][2],JurInA[10][3],JurInA[10][4],JurA[10],file=@Rept@ ;
   Print form=12.csv LIST= '   10_How ',JurInA[11][1],JurInA[11][2],JurInA[11][3],JurInA[11][4],JurA[11],file=@Rept@ ;
   Print form=12.csv LIST= '   11_AA  ',JurInA[12][1],JurInA[12][2],JurInA[12][3],JurInA[12][4],JurA[12],file=@Rept@ ;
   Print form=12.csv LIST= '   12_Chs ',JurInA[13][1],JurInA[13][2],JurInA[13][3],JurInA[13][4],JurA[13],file=@Rept@ ;
   Print form=12.csv LIST= '   13_ -  ',JurInA[14][1],JurInA[14][2],JurInA[14][3],JurInA[14][4],JurA[14],file=@Rept@ ;
   Print form=12.csv LIST= '   14_Car ',JurInA[15][1],JurInA[15][2],JurInA[15][3],JurInA[15][4],JurA[15],file=@Rept@ ;
   Print form=12.csv LIST= '   15_Cal ',JurInA[16][1],JurInA[16][2],JurInA[16][3],JurInA[16][4],JurA[16],file=@Rept@ ;
   Print form=12.csv LIST= '   16_SM  ',JurInA[17][1],JurInA[17][2],JurInA[17][3],JurInA[17][4],JurA[17],file=@Rept@ ;
   Print form=12.csv LIST= '   17_KGeo',JurInA[18][1],JurInA[18][2],JurInA[18][3],JurInA[18][4],JurA[18],file=@Rept@ ;
   Print form=12.csv LIST= '   18_Fbg ',JurInA[19][1],JurInA[19][2],JurInA[19][3],JurInA[19][4],JurA[19],file=@Rept@ ;
   Print form=12.csv LIST= '   19_Sta ',JurInA[20][1],JurInA[20][2],JurInA[20][3],JurInA[20][4],JurA[20],file=@Rept@ ;
   Print form=12.csv LIST= '   20_Spt ',JurInA[21][1],JurInA[21][2],JurInA[21][3],JurInA[21][4],JurA[21],file=@Rept@ ;
   Print form=12.csv LIST= '   21_Fau ',JurInA[22][1],JurInA[22][2],JurInA[22][3],JurInA[22][4],JurA[22],file=@Rept@ ;
   Print form=12.csv LIST= '   22_Clk ',JurInA[23][1],JurInA[23][2],JurInA[23][3],JurInA[23][4],JurA[23],file=@Rept@ ;
   Print form=12.csv LIST= '   23_Jef ',JurInA[24][1],JurInA[24][2],JurInA[24][3],JurInA[24][4],JurA[24],file=@Rept@ ;

   Print LIST= '   ',file=@Rept@
   Print form=12.csv LIST= ' Total    ',RegInA[1],  RegInA[2],  RegInA[3],  RegInA[4],  SITotal,file=@Rept@ ;

   Print LIST= '   ',file=@Rept@
   Print LIST= '   ',file=@Rept@

;===========================================================================================================

   Print LIST= '   ',file=@Rept@
   Print LIST= '   ',file=@Rept@
   PRINT LIST =' Regional Households by Vehicles Available and Size Summary ',file=@Rept@
   PRINT LIST ='   VeAv     Size_1        Size_2     Size_3      Size_4      Total       ',file=@Rept@
   PRINT LIST ='          ------------ ----------- ----------- ----------- -----------   ',file=@Rept@

   Print form=12.csv LIST= '      1   ',RegVaSzA[1][1],RegVaSzA[1][2],RegVaSzA[1][3],RegVaSzA[1][4],RegVaA[1],file=@Rept@ ;
   Print form=12.csv LIST= '      2   ',RegVaSzA[2][1],RegVaSzA[2][2],RegVaSzA[2][3],RegVaSzA[2][4],RegVaA[2],file=@Rept@ ;
   Print form=12.csv LIST= '      3   ',RegVaSzA[3][1],RegVaSzA[3][2],RegVaSzA[3][3],RegVaSzA[3][4],RegVaA[3],file=@Rept@ ;
   Print form=12.csv LIST= '      4+  ',RegVaSzA[4][1],RegVaSzA[4][2],RegVaSzA[4][3],RegVaSzA[4][4],RegVaA[4],file=@Rept@ ;
   Print LIST= '   ',file=@Rept@
   Print form=12.csv LIST= ' Total    ',RegSzA[1],   RegSzA[2],   RegSzA[3],   RegSzA[4],   SITotal,file=@Rept@ ;

   Print LIST= '   ',file=@Rept@
   Print LIST= '   ',file=@Rept@

   Print LIST= '   ',file=@Rept@
   Print LIST= '   ',file=@Rept@
   PRINT LIST =' Regional Households by Vehicles Available Groups 1, 2, 3&4  ','\n',
               ' HHs w/ 0 Vehs:  ', Tot_HHw0Vehs(12.0),'\n',
               ' HHs w/ 1 Vehs:  ', Tot_HHw1Vehs(12.0),'\n',
               ' HHs w/ 2+Vehs:  ', Tot_HHw2PVehs(12.0),'\n', file=@Rept@
;===========================================================================================================

   Print LIST= '   ',file=@Rept@
   Print LIST= '   ',file=@Rept@
   PRINT LIST =' Regional Households by Vehicles Available and Income Summary ',file=@Rept@
   PRINT LIST ='   VeAv      Inc_1         Inc_2      Inc_3       Inc_4      Total       ',file=@Rept@
   PRINT LIST ='          ------------ ----------- ----------- ----------- -----------   ',file=@Rept@

   Print form=12.csv LIST= '      1   ',RegVaInA[1][1],RegVaInA[1][2],RegVaInA[1][3],RegVaInA[1][4],RegVaA[1],file=@Rept@ ;
   Print form=12.csv LIST= '      2   ',RegVaInA[2][1],RegVaInA[2][2],RegVaInA[2][3],RegVaInA[2][4],RegVaA[2],file=@Rept@ ;
   Print form=12.csv LIST= '      3   ',RegVaInA[3][1],RegVaInA[3][2],RegVaInA[3][3],RegVaInA[3][4],RegVaA[3],file=@Rept@ ;
   Print form=12.csv LIST= '      4+  ',RegVaInA[4][1],RegVaInA[4][2],RegVaInA[4][3],RegVaInA[4][4],RegVaA[4],file=@Rept@ ;
   Print form=12.csv LIST= '   ',file=@Rept@
   Print form=12.csv LIST= ' Total    ',RegInA[1],   RegInA[2],   RegInA[3],   RegInA[4],   SITotal,file=@Rept@ ;

   Print LIST= '   ',file=@Rept@
   Print LIST= '   ',file=@Rept@

;===========================================================================================================

   PRINT LIST =' Jurisdictional Households by Vehicles Available ',file=@Rept@
   PRINT LIST ='  Juris.    Veh_0         Veh_1       Veh_2       Veh_3+     Total       ',file=@Rept@
   PRINT LIST ='          ------------ ----------- ----------- ----------- -----------   ',file=@Rept@

   Print form=12.csv LIST= '    0_DC  ',JurVaA[01][1],JurVaA[01][2],JurVaA[01][3],JurVaA[01][4],JurA[01],file=@Rept@ ;
   Print form=12.csv LIST= '    1_Mtg ',JurVaA[02][1],JurVaA[02][2],JurVaA[02][3],JurVaA[02][4],JurA[02],file=@Rept@ ;
   Print form=12.csv LIST= '    2_PG  ',JurVaA[03][1],JurVaA[03][2],JurVaA[03][3],JurVaA[03][4],JurA[03],file=@Rept@ ;
   Print form=12.csv LIST= '    3_Arl ',JurVaA[04][1],JurVaA[04][2],JurVaA[04][3],JurVaA[04][4],JurA[04],file=@Rept@ ;
   Print form=12.csv LIST= '    4_Alx ',JurVaA[05][1],JurVaA[05][2],JurVaA[05][3],JurVaA[05][4],JurA[05],file=@Rept@ ;
   Print form=12.csv LIST= '    5_Ffx ',JurVaA[06][1],JurVaA[06][2],JurVaA[06][3],JurVaA[06][4],JurA[06],file=@Rept@ ;
   Print form=12.csv LIST= '    6_Ldn ',JurVaA[07][1],JurVaA[07][2],JurVaA[07][3],JurVaA[07][4],JurA[07],file=@Rept@ ;
   Print form=12.csv LIST= '    7_PW  ',JurVaA[08][1],JurVaA[08][2],JurVaA[08][3],JurVaA[08][4],JurA[08],file=@Rept@ ;
   Print form=12.csv LIST= '    8_ -  ',JurVaA[09][1],JurVaA[09][2],JurVaA[09][3],JurVaA[09][4],JurA[09],file=@Rept@ ;
   Print form=12.csv LIST= '    9_Frd ',JurVaA[10][1],JurVaA[10][2],JurVaA[10][3],JurVaA[10][4],JurA[10],file=@Rept@ ;
   Print form=12.csv LIST= '   10_How ',JurVaA[11][1],JurVaA[11][2],JurVaA[11][3],JurVaA[11][4],JurA[11],file=@Rept@ ;
   Print form=12.csv LIST= '   11_AA  ',JurVaA[12][1],JurVaA[12][2],JurVaA[12][3],JurVaA[12][4],JurA[12],file=@Rept@ ;
   Print form=12.csv LIST= '   12_Chs ',JurVaA[13][1],JurVaA[13][2],JurVaA[13][3],JurVaA[13][4],JurA[13],file=@Rept@ ;
   Print form=12.csv LIST= '   13_ -  ',JurVaA[14][1],JurVaA[14][2],JurVaA[14][3],JurVaA[14][4],JurA[14],file=@Rept@ ;
   Print form=12.csv LIST= '   14_Car ',JurVaA[15][1],JurVaA[15][2],JurVaA[15][3],JurVaA[15][4],JurA[15],file=@Rept@ ;
   Print form=12.csv LIST= '   15_Cal ',JurVaA[16][1],JurVaA[16][2],JurVaA[16][3],JurVaA[16][4],JurA[16],file=@Rept@ ;
   Print form=12.csv LIST= '   16_SM  ',JurVaA[17][1],JurVaA[17][2],JurVaA[17][3],JurVaA[17][4],JurA[17],file=@Rept@ ;
   Print form=12.csv LIST= '   17_KGeo',JurVaA[18][1],JurVaA[18][2],JurVaA[18][3],JurVaA[18][4],JurA[18],file=@Rept@ ;
   Print form=12.csv LIST= '   18_Fbg ',JurVaA[19][1],JurVaA[19][2],JurVaA[19][3],JurVaA[19][4],JurA[19],file=@Rept@ ;
   Print form=12.csv LIST= '   19_Sta ',JurVaA[20][1],JurVaA[20][2],JurVaA[20][3],JurVaA[20][4],JurA[20],file=@Rept@ ;
   Print form=12.csv LIST= '   20_Spt ',JurVaA[21][1],JurVaA[21][2],JurVaA[21][3],JurVaA[21][4],JurA[21],file=@Rept@ ;
   Print form=12.csv LIST= '   21_Fau ',JurVaA[22][1],JurVaA[22][2],JurVaA[22][3],JurVaA[22][4],JurA[22],file=@Rept@ ;
   Print form=12.csv LIST= '   22_Clk ',JurVaA[23][1],JurVaA[23][2],JurVaA[23][3],JurVaA[23][4],JurA[23],file=@Rept@ ;
   Print form=12.csv LIST= '   23_Jef ',JurVaA[24][1],JurVaA[24][2],JurVaA[24][3],JurVaA[24][4],JurA[24],file=@Rept@ ;

   Print LIST= '   ',file=@Rept@
   Print form=12.csv LIST= ' Total    ',RegVaA[1],  RegVaA[2],  RegVaA[3],  RegVaA[4],  SITotal,file=@Rept@ ;

   Print LIST= '   ',file=@Rept@
   Print LIST= '   ',file=@Rept@


   PRINT LIST =' Estimated Households By Size Level by Area Type  ','\n', file=@Rept@

   PRINT LIST =            '   Area_Tp  HHs_Size1    HHs_Size2   HHs_Size3   HHs_Size4    Total     ' ,file=@Rept@
   PRINT LIST =            '    ----   ----------- ------------ ----------- ----------- ----------  ' ,file=@Rept@
   Print form=12.csv LIST= '      1   ',ArSzA[1][1], ArSzA[1][2] , ArSzA[1][3], ArSzA[1][4] , AreaA[1],file =@Rept@ ;
   Print form=12.csv LIST= '      2   ',ArSzA[2][1], ArSzA[2][2] , ArSzA[2][3], ArSzA[2][4] , AreaA[2],file =@Rept@ ;
   Print form=12.csv LIST= '      3   ',ArSzA[3][1], ArSzA[3][2] , ArSzA[3][3], ArSzA[3][4] , AreaA[3],file =@Rept@ ;
   Print form=12.csv LIST= '      4   ',ArSzA[4][1], ArSzA[4][2] , ArSzA[4][3], ArSzA[4][4] , AreaA[4],file =@Rept@ ;
   Print form=12.csv LIST= '      5   ',ArSzA[5][1], ArSzA[5][2] , ArSzA[5][3], ArSzA[5][4] , AreaA[5],file =@Rept@ ;
   Print form=12.csv LIST= '      6   ',ArSzA[6][1], ArSzA[6][2] , ArSzA[6][3], ArSzA[6][4] , AreaA[6],file =@Rept@ ;
   Print LIST= '    ',file=@Rept@
   Print form=12.csv LIST= '     Sum  ',  RegSzA[1],   RegSzA[2] , RegSzA[3],     RegSzA[4] ,  SITotal, file =@Rept@ ;
   Print LIST= '   ','\n',file=@Rept@




   PRINT LIST =' Estimated Households By Income Level by Area Type  ','\n', file=@Rept@

   PRINT LIST =            '   Area_Tp  Income_1     Income_2    Income_3    Income_4     Total      ',file=@Rept@
   PRINT LIST =            '    ----   ----------- ------------ ----------- ----------- -----------  ',file=@Rept@
   Print form=12.csv LIST= '      1   ',ArInA[1][1], ArInA[1][2] , ArInA[1][3], ArInA[1][4] , AreaA[1],file =@Rept@ ;
   Print form=12.csv LIST= '      2   ',ArInA[2][1], ArInA[2][2] , ArInA[2][3], ArInA[2][4] , AreaA[2],file =@Rept@ ;
   Print form=12.csv LIST= '      3   ',ArInA[3][1], ArInA[3][2] , ArInA[3][3], ArInA[3][4] , AreaA[3],file =@Rept@ ;
   Print form=12.csv LIST= '      4   ',ArInA[4][1], ArInA[4][2] , ArInA[4][3], ArInA[4][4] , AreaA[4],file =@Rept@ ;
   Print form=12.csv LIST= '      5   ',ArInA[5][1], ArInA[5][2] , ArInA[5][3], ArInA[5][4] , AreaA[5],file =@Rept@ ;
   Print form=12.csv LIST= '      6   ',ArInA[6][1], ArInA[6][2] , ArInA[6][3], ArInA[6][4] , AreaA[6],file =@Rept@ ;
   Print LIST= '    ',file=@Rept@
   Print form=12.csv LIST= '     Sum  ',  RegInA[1],   RegInA[2] , RegInA[3],     RegInA[4] ,  SITotal, file =@Rept@ ;
   Print LIST= '   ','\n',file=@Rept@




   PRINT LIST =' Estimated Households By Vehicle Availability Level by Area Type  ','\n', file=@Rept@

   PRINT LIST =            '   Area_Tp  0 Vehs.Av.   1 Veh.Av.   2 Vehs.Av.  3+ Vehs.Av.  Total      ',file=@Rept@
   PRINT LIST =            '    ----   ----------- ------------ ----------- ----------- -----------  ',file=@Rept@
   Print form=12.csv LIST= '      1   ',ArVaA[1][1], ArVaA[1][2] , ArVaA[1][3], ArVaA[1][4] , AreaA[1],file =@Rept@ ;
   Print form=12.csv LIST= '      2   ',ArVaA[2][1], ArVaA[2][2] , ArVaA[2][3], ArVaA[2][4] , AreaA[2],file =@Rept@ ;
   Print form=12.csv LIST= '      3   ',ArVaA[3][1], ArVaA[3][2] , ArVaA[3][3], ArVaA[3][4] , AreaA[3],file =@Rept@ ;
   Print form=12.csv LIST= '      4   ',ArVaA[4][1], ArVaA[4][2] , ArVaA[4][3], ArVaA[4][4] , AreaA[4],file =@Rept@ ;
   Print form=12.csv LIST= '      5   ',ArVaA[5][1], ArVaA[5][2] , ArVaA[5][3], ArVaA[5][4] , AreaA[5],file =@Rept@ ;
   Print form=12.csv LIST= '      6   ',ArVaA[6][1], ArVaA[6][2] , ArVaA[6][3], ArVaA[6][4] , AreaA[6],file =@Rept@ ;
   Print LIST= '    ',file=@Rept@
   Print form=12.csv LIST= '     Sum  ',  RegVaA[1],   RegVaA[2] , RegVaA[3],     RegVaA[4] ,  SIVTotal, file =@Rept@ ;
   Print LIST= '   ','\n',file=@Rept@

ENDIF   ; -end of printing section


;
;
;
ENDRUN
