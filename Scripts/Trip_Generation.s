*del voya*.prn
;=================================================================
;  Trip_Generation.s
;  Version 2.3, 3722 TAZ System  - Trip Generation Process
;
;   RM
;   Date:      2011-02-15
;
;=================================================================
; Note: Jurisdictional adjustment for P's A's added 2/8/11
; with nonmotorized fix  2/15/11
; Updated Area Type&juris marginal addjustments 9/14/2011
;=================================================================
; Corrected application of non-motorized area type adjustments 1/04/13
;============================================================================================
; Modified scaling procedure such that Attr. scaling is based on both Motr&Non-Motr Prod.s
; - Previously Attr scaling was done separately, for motorized P's and for non-motorized P's
;
; - Increase non-work, non-motorized trip rates by 30 percent in area types 1 and 2
;
; 3/4/13 Changes:
; - Removed I-X extraction process
; - Truncated Trip Gen process to stop after COMPUTED trip attractions are calculated
;   Scaling will be handled, after External Trip Distribution process.

; 3/13/13  applied 15% and 17% reduction on Loudoun County P,A Trip rates respectively
; 3/14/13  fixed conditions where the  final non-motor P/A share could exceed 1
;============================================================================================
;Parameters and file specifications:
;=================================================================

ZONESIZE    =  3722                       ;  No. of TAZs
LastIZn     =  3675                       ;  Last Internal TAZ no.

JrCl        =  24                         ;  No. of Juris. Classes (transformed JURIS. Code 0-23 becomes 1-24)
ArCl        =   6                         ;  No. of Area Classe (ATypes)
SzCl        =   4                         ;  No. of HH Size   Classes
InCl        =   4                         ;  No. of Income    Classes
VaCl        =   4                         ;  No. of Veh Avail Classes
PrCL        =   5                         ;  No. of Trip Purposes

ZNFILE_IN1  = 'inputs\ZONE.dbf'           ;  Input  Zonal Land Use File
Ext_PsAs    = 'inputs\Ext_PsAs.dbf'       ;  External Ps/As

ZNFILE_IN3  = 'AreaType_File.dbf'                    ;  Input  Zonal Area Type File from network building
ZNFILE_IN4  = '%_iter_%_Demo_Models_HHbyISV.dbf'     ;  HHs by Income Size Vehs Avail

ZNFILE_IN5  = 'TripGen_LUFile.dbf'                   ;  Consolidated zonal input file (intermediate I/O file)

ReportFile  = '%_iter_%_Trip_Generation.txt'             ; Trip Gen. Report file
TripPros    = '%_iter_%_Trip_Gen_Productions_Comp.dbf'   ; Zonal Trip productions - Initial /Computed by purpose
TripAttsCom = '%_iter_%_Trip_Gen_Attractions_Comp.dbf'   ; Zonal Trip Attractions - Initial /Computed by purpose


ZNFILE_IN2  ='inputs\GIS_variables.DBF'                  ;  Input  Zonal GIS variable File
Prate_IN    ='..\support\weighted_trip_rates.dbf'        ; Trip Prod. rates
NMPrate_in  ='..\support\NMPrates.dbf'                   ; NonMotorized Prod share model coeffs.
NMArate_in  ='..\support\NMArates.dbf'                   ; NonMotorized Attr share model coeffs.
Attrate_in  ='..\support\AttrRates.dbf'                  ; Trip attraction rates
IncRat_in   ='..\support\HBINCRAT.dbf'                   ; HB income shares


;; Area Type-Based Trip End Adjustments BY PURPOSE AND AREA TYPE
;;
;; MOTORIZED PRODUCTIONS
MHBWPAdj1=1.1358  MHBWPAdj2=1.1180  MHBWPAdj3=1.0554  MHBWPAdj4=0.9175  MHBWPAdj5=0.9577   MHBWPAdj6=0.9307  ;
MHBSPAdj1=0.8092  MHBSPAdj2=0.9504  MHBSPAdj3=1.0793  MHBSPAdj4=0.9059  MHBSPAdj5=1.0751   MHBSPAdj6=0.8620  ;
MHBOPAdj1=1.1067  MHBOPAdj2=1.1181  MHBOPAdj3=1.0303  MHBOPAdj4=0.9647  MHBOPAdj5=1.0109   MHBOPAdj6=0.8324  ;
MNHWPAdj1=1.0000  MNHWPAdj2=1.0000  MNHWPAdj3=1.0000  MNHWPAdj4=1.0000  MNHWPAdj5=1.0000   MNHWPAdj6=1.0000  ;
MNHOPAdj1=1.0000  MNHOPAdj2=1.0000  MNHOPAdj3=1.0000  MNHOPAdj4=1.0000  MNHOPAdj5=1.0000   MNHOPAdj6=1.0000  ;

;; MOTORIZED ATTRACTIONS
MHBWAAdj1=1.0765  MHBWAAdj2=0.8478  MHBWAAdj3=0.9612  MHBWAAdj4=1.1045  MHBWAAdj5=0.9871   MHBWAAdj6=1.0383  ;
MHBSAAdj1=0.7952  MHBSAAdj2=1.0967  MHBSAAdj3=1.1577  MHBSAAdj4=0.8770  MHBSAAdj5=0.9437   MHBSAAdj6=0.5187  ;
MHBOAAdj1=1.1542  MHBOAAdj2=1.1304  MHBOAAdj3=0.9307  MHBOAAdj4=1.0635  MHBOAAdj5=1.0480   MHBOAAdj6=0.8032  ;
MNHWAAdj1=1.1457  MNHWAAdj2=0.8686  MNHWAAdj3=0.9843  MNHWAAdj4=1.5731  MNHWAAdj5=1.1860   MNHWAAdj6=1.0919  ;
MNHOAAdj1=0.7953  MNHOAAdj2=1.0652  MNHOAAdj3=1.0724  MNHOAAdj4=0.9180  MNHOAAdj5=1.0899   MNHOAAdj6=0.7224  ;

;; NONMOTORIZED PRODUCTIONS
;; original
;NHBWPAdj1=1.2600  NHBWPAdj2=1.0000  NHBWPAdj3=1.0000  NHBWPAdj4=1.0000  NHBWPAdj5=1.0000   NHBWPAdj6=1.0000  ;
;NHBSPAdj1=1.6700  NHBSPAdj2=1.4000  NHBSPAdj3=1.0000  NHBSPAdj4=1.0000  NHBSPAdj5=1.0000   NHBSPAdj6=1.0000  ;
;NHBOPAdj1=0.7000  NHBOPAdj2=1.0700  NHBOPAdj3=1.0000  NHBOPAdj4=1.0000  NHBOPAdj5=1.0000   NHBOPAdj6=1.0000  ;
;NNHWPAdj1=1.0000  NNHWPAdj2=1.0000  NNHWPAdj3=1.0000  NNHWPAdj4=1.0000  NNHWPAdj5=1.0000   NNHWPAdj6=1.0000  ;
;NNHOPAdj1=1.0000  NNHOPAdj2=1.0000  NNHOPAdj3=1.0000  NNHOPAdj4=1.0000  NNHOPAdj5=1.0000   NNHOPAdj6=1.0000  ;

;; revised - non-work rates in AT 1,2 raised by 30%
 NHBWPAdj1=1.2600  NHBWPAdj2=1.0000  NHBWPAdj3=1.0000  NHBWPAdj4=1.0000  NHBWPAdj5=1.0000   NHBWPAdj6=1.0000  ;
 NHBSPAdj1=2.1700  NHBSPAdj2=1.8200  NHBSPAdj3=1.0000  NHBSPAdj4=1.0000  NHBSPAdj5=1.0000   NHBSPAdj6=1.0000  ;
 NHBOPAdj1=0.9100  NHBOPAdj2=1.3900  NHBOPAdj3=1.0000  NHBOPAdj4=1.0000  NHBOPAdj5=1.0000   NHBOPAdj6=1.0000  ;
 NNHWPAdj1=1.3000  NNHWPAdj2=1.3000  NNHWPAdj3=1.0000  NNHWPAdj4=1.0000  NNHWPAdj5=1.0000   NNHWPAdj6=1.0000  ;
 NNHOPAdj1=1.3000  NNHOPAdj2=1.3000  NNHOPAdj3=1.0000  NNHOPAdj4=1.0000  NNHOPAdj5=1.0000   NNHOPAdj6=1.0000  ;

;; NONMOTORIZED ATTRACTIONS
;; original
;NHBWAAdj1=1.0300  NHBWAAdj2=1.0000  NHBWAAdj3=1.1100  NHBWAAdj4=1.1100  NHBWAAdj5=1.1300   NHBWAAdj6=1.1000  ;
;NHBSAAdj1=1.8400  NHBSAAdj2=1.2900  NHBSAAdj3=1.0900  NHBSAAdj4=1.1000  NHBSAAdj5=1.0000   NHBSAAdj6=1.0000  ;
;NHBOAAdj1=0.6000  NHBOAAdj2=1.0600  NHBOAAdj3=1.1100  NHBOAAdj4=1.0900  NHBOAAdj5=1.1000   NHBOAAdj6=1.0800  ;
;NNHWAAdj1=1.0000  NNHWAAdj2=1.0000  NNHWAAdj3=1.0000  NNHWAAdj4=1.0000  NNHWAAdj5=1.0000   NNHWAAdj6=1.0000  ;
;NNHOAAdj1=1.6600  NNHOAAdj2=1.0000  NNHOAAdj3=0.7000  NNHOAAdj4=0.7000  NNHOAAdj5=0.7000   NNHOAAdj6=0.7000  ;

;; revised -non-work rates in AT 1,2 raised by 30%
 NHBWAAdj1=1.0300  NHBWAAdj2=1.0000  NHBWAAdj3=1.1100  NHBWAAdj4=1.1100  NHBWAAdj5=1.1300   NHBWAAdj6=1.1000  ;
 NHBSAAdj1=2.3900  NHBSAAdj2=1.6800  NHBSAAdj3=1.0900  NHBSAAdj4=1.1000  NHBSAAdj5=1.0000   NHBSAAdj6=1.0000  ;
 NHBOAAdj1=0.7800  NHBOAAdj2=1.3800  NHBOAAdj3=1.1100  NHBOAAdj4=1.0900  NHBOAAdj5=1.1000   NHBOAAdj6=1.0800  ;
 NNHWAAdj1=1.3000  NNHWAAdj2=1.3000  NNHWAAdj3=1.0000  NNHWAAdj4=1.0000  NNHWAAdj5=1.0000   NNHWAAdj6=1.0000  ;
 NNHOAAdj1=2.1600  NNHOAAdj2=1.3000  NNHOAAdj3=0.7000  NNHOAAdj4=0.7000  NNHOAAdj5=0.7000   NNHOAAdj6=0.7000  ;

XNHW_Share = 0.41      ; Pct. of external NHB Auto Driver Trips that are NHW (2007/08HTS)
XNHO_Share = 0.59      ; Pct. of external NHB Auto Driver Trips that are NHO (2007/08HTS)

XOccHBW    = 1.06      ;  HBW External Auto occupancy assumption (2007/08HTS)
XOccHBS    = 1.45      ;  HBS External Auto occupancy assumption
XOccHBO    = 1.63      ;  HBO External Auto occupancy assumption
XOccNHW    = 1.11      ;  NHW External Auto occupancy assumption
XOccNHO    = 1.50      ;  NHO External Auto occupancy assumption


Ofmt        = '(15.2)'               ;  Format of Output file data

;=================================================================
;Program Steps
;=================================================================
 RUN PGM=MATRIX
 ZONES=1
;=========================================================================
;  Accumulate floating 0.5 mile block density for each TAZ
;  Accumulation based on varying straightline distances between TAZ centroids
;
;;========================================================================


 FILEO RECO[1]    = "@ZNFile_IN5@",
                     fields = TAZ(5),
                     HH(8.0),        TOTPOP(8.0), TOTEMP(8.0), RETEMP(8.0),NRETEMP(8.0),
                     OFFEMP(8.0),    OTHEMP(8.0), INDEMP(8.0), HHPOP(8.0),   GQPOP(8.0),
                     LANDAREA(8.4), POP_10,      EMP_10,       AREA_10,
                     POPDEN10,       EMPDEN10,      ADISTTOX(5.2),
                     BLOCKS05(8.0), AREA05(15.4),   BlockDen05(8.0),
                     jurcode(5.0), Atype(5.0)

; read XY coords from the ZONE file, as a zonal lookup table
 FileI LOOKUPI[1] = "@ZNFILE_IN1@"
 LOOKUP LOOKUPI=1, NAME=tazdata,
        LOOKUP[1]  = TAZ, RESULT=TAZXCRD,  ;
        LOOKUP[2]  = TAZ, RESULT=TAZYCRD,  ;
        LOOKUP[3]  = TAZ, RESULT=HH,       ;
        LOOKUP[4]  = TAZ, RESULT=HHPOP,    ;
        LOOKUP[5]  = TAZ, RESULT=GQPOP,    ;
        LOOKUP[6]  = TAZ, RESULT=TOTPOP,   ;
        LOOKUP[7]  = TAZ, RESULT=TOTEMP,   ;
        LOOKUP[8]  = TAZ, RESULT=INDEMP,   ;
        LOOKUP[9]  = TAZ, RESULT=RETEMP,    ;
        LOOKUP[10] = TAZ, RESULT=OFFEMP,    ;
        LOOKUP[11] = TAZ, RESULT=OTHEMP,    ;
        LOOKUP[12] = TAZ, RESULT=JURCODE,   ;
        LOOKUP[13] = TAZ, RESULT=LANDAREA,  ;
        LOOKUP[14] = TAZ, RESULT=ADISTTOX,  ;
        INTERPOLATE=N, FAIL= 0,0,0, LIST=N


; Read GIS File as a zonal lookup table
 FileI LOOKUPI[2] = "@ZNFILE_IN2@"
 LOOKUP LOOKUPI=2,   NAME=gisdata,
        LOOKUP[1]  = TAZ, RESULT=BLOCKS,
        INTERPOLATE=N, FAIL= 0,0,0, LIST=N


; Read Area Type File as a zonal lookup table
 FileI LOOKUPI[3] = "@ZNFILE_IN3@"
 LOOKUP LOOKUPI=3,   NAME=Atypedata,
        LOOKUP[1]  = TAZ, RESULT=pop_10,
        LOOKUP[2]  = TAZ, RESULT=emp_10,
        LOOKUP[3]  = TAZ, RESULT=Area_10,
        LOOKUP[4]  = TAZ, RESULT=popden,
        LOOKUP[5]  = TAZ, RESULT=empden,
        LOOKUP[6]  = TAZ, RESULT=atype,

        INTERPOLATE=N, FAIL= 0,0,0, LIST=N
;; define zonal arrays for accumulating the variables
ARRAY   BLOCKS05=3722, BLOCKDEN05=3722, AREA05=3722

 LOOP M = 1,@LastIZn@  ;  Loop through each zone, read coordinates

   Xi      = tazdata(1,M)
   Yi      = tazdata(2,M)
   IF (Xi  = 0.00)  Continue


      LOOP L= 1,@LastIZn@   ; Loop through all proximate zones, read coords.
           Xj      = tazdata(1,L)
           Yj      = tazdata(2,L)
           IF (Xj  = 0.00)  Continue

           Xdiff   = abs(Xi-Xj)                            ; calc. airline distance
           Ydiff   = abs(Yi-Yj)                            ;
                                                           ;
           d_ft    = sqrt(xdiff*xdiff + Ydiff*Ydiff)       ;
           d_mi    = d_ft/5280.0                           ;
                                                           ;
           ;debug1
           If (l=1)
                print form=10  list = l,m,xi,yi,xj,yj,d_ft,d_mi(6.2), file=debug1.txt
           endif
           ;end debug1

           IF      (D_mi <  0.500)
                    BLOCKS05[M]    =  BLOCKS05[M]    +  gisdata(1,L)
                    Area05[M]      =  Area05[M]      +  tazdata(13,L)
           ENDIF


       ENDLOOP

 ENDLOOP

;; All done reading, write out zonal results:

LOOP M= 1,@LastIZn@
            ro.TAZ            = M
            ro.Area05         = Area05[M]
            ro.BLOCKS05       = BLOCKS05[M]
            ro.BlockDen05     = 0
               IF (Area05[M] > 0)
                   ro.BlockDen05     = BLOCKS05[M]/Area05[M]
               ENDIF

            ro.HH             = TAZdata(3,M)
            ro.HHPOP          = TAZdata(4,M)
            ro.GQPOP          = TAZdata(5,M)
            ro.TOTPOP          =TAZdata(6,M)
            ro.TOTEMP          =TAZdata(7,M)
            ro.RETEMP          =TAZdata(9,M)
            ro.NRETEMP         =TAZdata(7,M) - TAZdata(9,M)
            ro.INDEMP          =TAZdata(8,M)
            ro.OTHEMP          =TAZdata(11,M)
            ro.OFFEMP          =TAZdata(10,M)
            ro.JURCODE         =TAZdata(12,M)
            ro.LANDAREA        =TAZdata(13,M)
            ro.ADISTTOX        =TAZdata(14,M)

            ro.POP_10          =Atypedata(1,M)
            ro.EMP_10          =Atypedata(2,M)
            ro.Area_10         =Atypedata(3,M)
            ro.POPDEN10        =Atypedata(4,M)
            ro.EMPDEN10        =Atypedata(5,M)
            ro.ATYPE           =Atypedata(6,M)

        WRITE RECO= 1
  ENDLOOP
 endrun




RUN PGM=MATRIX
ZONES=@ZONESIZE@

FILEO PRINTO[1]    = "@ReportFile@"
pageheight=32767  ; Preclude header breaks

; Set up zone arrays for accumulating I/O variables
;

Array Proda      =@PrCl@,@InCl@,@SzCl@,@VaCl@

Array Zproda     =@PrCl@,@ZoneSize@
Array ZprodaInc  =@PrCl@,@InCl@,@ZoneSize@
Array MZprodaInc =@PrCl@,@InCl@,@ZoneSize@
Array MZproda    =@PrCl@,@Zonesize@
Array MTotProdInca =@PrCl@,@Incl@
Array NMZProda   =@PrCl@,@Zonesize@
Array MZattra    =@PrCl@,@Zonesize@
Array MZattraInc =@PrCl@,@InCl@,@Zonesize@
Array NMZattra   =@PrCl@,@Zonesize@

Array AIncratio  =@InCl@,@ArCl@,@PrCl@
Array AIncShare  =@InCl@,@ArCl@,@PrCl@
Array IniAttra   =@InCl@,@PrCl@
Array FinAttra   =@InCl@,@PrCl@
Array IniAtot    =@PrCl@
Array FinAtot    =@PrCl@
Array Scaltot    =@PrCl@
Array Mscale     =@PrCl@
Array NMscale    =@PrCl@
Array MNMscale   =@PrCl@

Array HHa       =@InCl@,@SzCl@,@VaCl@
Array Prata     =@PrCl@,@InCl@,@SzCl@,@VaCl@
Array NMPrate   =10,@PrCl@,@ArCl@
Array NMArate   =10,@PrCl@,@ArCl@
Array Attrate   =10,@PrCl@,@ArCl@

Array I_proda   =@InCl@,@PrCl@
Array S_proda   =@SzCl@,@PrCl@
Array V_proda   =@VaCl@,@PrCl@
Array A_proda   =@ArCl@,@PrCl@
Array J_proda   =@JrCl@,@PrCl@

Array TotProda           =@PrCl@,
      MTotProda          =@PrCl@,
      MNMTotProda        =@PrCl@,
      XMTotProda         =@PrCl@,
      NMTotProda         =@PrCl@,
      MTotAttra          =@PrCl@,
      XMTotAttra         =@PrCl@,
     MNMTotAttra         =@PrCl@,
      NMTotAttra         =@PrCl@,

      Atypea             =@zonesize@,

      I_HHa              =@InCl@,
      S_HHa              =@SzCl@,
      V_HHa              =@VaCl@,
      A_HHa              =@ArCl@,
      J_HHa              =@JrCl@,

      TotProdInca        =@InCl@,
      TotProdSiza        =@SzCl@,
      TotProdVeha        =@VaCl@,
      TotProdAreaa       =@ArCl@,
      TotProdJura        =@JrCl@,

      HBWNMPro           =@zonesize@,
      HBSNMPro           =@zonesize@,
      HBONMPro           =@zonesize@,
      NHWNMPro           =@zonesize@,
      NHONMPro           =@zonesize@,

      HBWNMAtt           =@zonesize@,
      HBSNMAtt           =@zonesize@,
      HBONMAtt           =@zonesize@,
      NHWNMAtt           =@zonesize@,
      NHONMAtt           =@zonesize@,

      HBWCompATT         =@zonesize@,
      HBSCompATT         =@zonesize@,
      HBOCompATT         =@zonesize@,
      NHWCompATT         =@zonesize@,
      NHOCompATT         =@zonesize@,

      HBWScalATT         =@zonesize@,
      HBSScalATT         =@zonesize@,
      HBOScalATT         =@zonesize@,
      NHWScalATT         =@zonesize@,
      NHOScalATT         =@zonesize@

 Array HBWATTInca        =@zonesize@,@InCl@
 Array HBSATTInca        =@zonesize@,@InCl@
 Array HBOATTInca        =@zonesize@,@InCl@
 Array NHWATTInca        =@zonesize@
 Array NHOATTInca        =@zonesize@
;;-----------------------------------------------
;;-----------------------------------------------

Array MPro_Adj = @PrCl@,@ArCl@
Array MAtt_Adj = @PrCl@,@ArCl@
Array NPro_Adj = @PrCl@,@ArCl@
Array NAtt_Adj = @PrCl@,@ArCl@

; fill purpose and area type adjustments
;;motorized adjustments
MPro_Adj[1][1]=@MHBWPAdj1@  MPro_Adj[2][1]=@MHBSPAdj1@   MPro_Adj[3][1]= @MHBOPAdj1@  MPro_Adj[4][1]= @MNHWPAdj1@  MPro_Adj[5][1]=@MNHOPAdj1@
MPro_Adj[1][2]=@MHBWPAdj2@  MPro_Adj[2][2]=@MHBSPAdj2@   MPro_Adj[3][2]= @MHBOPAdj2@  MPro_Adj[4][2]= @MNHWPAdj2@  MPro_Adj[5][2]=@MNHOPAdj2@
MPro_Adj[1][3]=@MHBWPAdj3@  MPro_Adj[2][3]=@MHBSPAdj3@   MPro_Adj[3][3]= @MHBOPAdj3@  MPro_Adj[4][3]= @MNHWPAdj3@  MPro_Adj[5][3]=@MNHOPAdj3@
MPro_Adj[1][4]=@MHBWPAdj4@  MPro_Adj[2][4]=@MHBSPAdj4@   MPro_Adj[3][4]= @MHBOPAdj4@  MPro_Adj[4][4]= @MNHWPAdj4@  MPro_Adj[5][4]=@MNHOPAdj4@
MPro_Adj[1][5]=@MHBWPAdj5@  MPro_Adj[2][5]=@MHBSPAdj5@   MPro_Adj[3][5]= @MHBOPAdj5@  MPro_Adj[4][5]= @MNHWPAdj5@  MPro_Adj[5][5]=@MNHOPAdj5@
MPro_Adj[1][6]=@MHBWPAdj6@  MPro_Adj[2][6]=@MHBSPAdj6@   MPro_Adj[3][6]= @MHBOPAdj6@  MPro_Adj[4][6]= @MNHWPAdj6@  MPro_Adj[5][6]=@MNHOPAdj6@

MAtt_Adj[1][1]=@MHBWAAdj1@  MAtt_Adj[2][1]=@MHBSAAdj1@   MAtt_Adj[3][1]= @MHBOAAdj1@  MAtt_Adj[4][1]= @MNHWAAdj1@  MAtt_Adj[5][1]=@MNHOAAdj1@
MAtt_Adj[1][2]=@MHBWAAdj2@  MAtt_Adj[2][2]=@MHBSAAdj2@   MAtt_Adj[3][2]= @MHBOAAdj2@  MAtt_Adj[4][2]= @MNHWAAdj2@  MAtt_Adj[5][2]=@MNHOAAdj2@
MAtt_Adj[1][3]=@MHBWAAdj3@  MAtt_Adj[2][3]=@MHBSAAdj3@   MAtt_Adj[3][3]= @MHBOAAdj3@  MAtt_Adj[4][3]= @MNHWAAdj3@  MAtt_Adj[5][3]=@MNHOAAdj3@
MAtt_Adj[1][4]=@MHBWAAdj4@  MAtt_Adj[2][4]=@MHBSAAdj4@   MAtt_Adj[3][4]= @MHBOAAdj4@  MAtt_Adj[4][4]= @MNHWAAdj4@  MAtt_Adj[5][4]=@MNHOAAdj4@
MAtt_Adj[1][5]=@MHBWAAdj5@  MAtt_Adj[2][5]=@MHBSAAdj5@   MAtt_Adj[3][5]= @MHBOAAdj5@  MAtt_Adj[4][5]= @MNHWAAdj5@  MAtt_Adj[5][5]=@MNHOAAdj5@
MAtt_Adj[1][6]=@MHBWAAdj6@  MAtt_Adj[2][6]=@MHBSAAdj6@   MAtt_Adj[3][6]= @MHBOAAdj6@  MAtt_Adj[4][6]= @MNHWAAdj6@  MAtt_Adj[5][6]=@MNHOAAdj6@


;;nonmotorized adjustments
NPro_Adj[1][1]=@NHBWPAdj1@  NPro_Adj[2][1]=@NHBSPAdj1@   NPro_Adj[3][1]= @NHBOPAdj1@  NPro_Adj[4][1]= @NNHWPAdj1@  NPro_Adj[5][1]=@NNHOPAdj1@
NPro_Adj[1][2]=@NHBWPAdj2@  NPro_Adj[2][2]=@NHBSPAdj2@   NPro_Adj[3][2]= @NHBOPAdj2@  NPro_Adj[4][2]= @NNHWPAdj2@  NPro_Adj[5][2]=@NNHOPAdj2@
NPro_Adj[1][3]=@NHBWPAdj3@  NPro_Adj[2][3]=@NHBSPAdj3@   NPro_Adj[3][3]= @NHBOPAdj3@  NPro_Adj[4][3]= @NNHWPAdj3@  NPro_Adj[5][3]=@NNHOPAdj3@
NPro_Adj[1][4]=@NHBWPAdj4@  NPro_Adj[2][4]=@NHBSPAdj4@   NPro_Adj[3][4]= @NHBOPAdj4@  NPro_Adj[4][4]= @NNHWPAdj4@  NPro_Adj[5][4]=@NNHOPAdj4@
NPro_Adj[1][5]=@NHBWPAdj5@  NPro_Adj[2][5]=@NHBSPAdj5@   NPro_Adj[3][5]= @NHBOPAdj5@  NPro_Adj[4][5]= @NNHWPAdj5@  NPro_Adj[5][5]=@NNHOPAdj5@
NPro_Adj[1][6]=@NHBWPAdj6@  NPro_Adj[2][6]=@NHBSPAdj6@   NPro_Adj[3][6]= @NHBOPAdj6@  NPro_Adj[4][6]= @NNHWPAdj6@  NPro_Adj[5][6]=@NNHOPAdj6@

NAtt_Adj[1][1]=@NHBWAAdj1@  NAtt_Adj[2][1]=@NHBSAAdj1@   NAtt_Adj[3][1]= @NHBOAAdj1@  NAtt_Adj[4][1]= @NNHWAAdj1@  NAtt_Adj[5][1]=@NNHOAAdj1@
NAtt_Adj[1][2]=@NHBWAAdj2@  NAtt_Adj[2][2]=@NHBSAAdj2@   NAtt_Adj[3][2]= @NHBOAAdj2@  NAtt_Adj[4][2]= @NNHWAAdj2@  NAtt_Adj[5][2]=@NNHOAAdj2@
NAtt_Adj[1][3]=@NHBWAAdj3@  NAtt_Adj[2][3]=@NHBSAAdj3@   NAtt_Adj[3][3]= @NHBOAAdj3@  NAtt_Adj[4][3]= @NNHWAAdj3@  NAtt_Adj[5][3]=@NNHOAAdj3@
NAtt_Adj[1][4]=@NHBWAAdj4@  NAtt_Adj[2][4]=@NHBSAAdj4@   NAtt_Adj[3][4]= @NHBOAAdj4@  NAtt_Adj[4][4]= @NNHWAAdj4@  NAtt_Adj[5][4]=@NNHOAAdj4@
NAtt_Adj[1][5]=@NHBWAAdj5@  NAtt_Adj[2][5]=@NHBSAAdj5@   NAtt_Adj[3][5]= @NHBOAAdj5@  NAtt_Adj[4][5]= @NNHWAAdj5@  NAtt_Adj[5][5]=@NNHOAAdj5@
NAtt_Adj[1][6]=@NHBWAAdj6@  NAtt_Adj[2][6]=@NHBSAAdj6@   NAtt_Adj[3][6]= @NHBOAAdj6@  NAtt_Adj[4][6]= @NNHWAAdj6@  NAtt_Adj[5][6]=@NNHOAAdj6@
;;-----------------------------------------------
;;-----------------------------------------------
;; Read in Consolidated zone file

 ZDATI[1] = @ZNFILE_IN5@ ;; variables in DBF file: TAZ,  HH, HHPOP, JURCODE, HHINCIDX
                         ;; TAZ,       HH,     TOTPOP, TOTEMP,  RETEMP,  NRETEMP, OFFEMP,  OTHEMP,
                         ;; INDEMP,    POP_10, EMP_10, AREA_10, POPDEN10,EMPDEN10,BLOCKS05,AREA05,
                         ;; BLOCKDEN05,JURCODE,ATYPE,ADISTTOX

Atypea[i] = zi.1.Atype   ; populate zonal area type array

;; Identify 'core' TAZs to be used for P-A-mod adjustments

coreflag = 0
 IF (I=1-4,6-47,49-50,52-63,65,181-209,282-287,374-381 ) coreflag = 1   ;DC core
 IF (I=1471-1476, 1486-1489, 1495-1497                 ) coreflag = 1   ;Arl Core


;;==================================================================================================
; Define Jurisdiction Motorized Production, Attraction Adjustment Lookup
; index = jurcode * 10 + core flag        jurcode ranges from 0-23 and core flag is binary 0(non-core) or 1(core)
;                                          so index is from    0 - 230
;;==================================================================================================
;
LOOKUP NAME=P_JurAdj,   ;
       LOOKUP[1] = 1, RESULT=2, ;  HBW Production Adjustment
       LOOKUP[2] = 1, RESULT=3, ;  HBS Production Adjustment
       LOOKUP[3] = 1, RESULT=4, ;  HBO Production Adjustment
       LOOKUP[4] = 1, RESULT=5, ;  NHW Production Adjustment
       LOOKUP[5] = 1, RESULT=6, ;  NHO Production Adjustment
       INTERPOLATE=N, FAIL= 1.0,1.0,1.0,
;;
;;         HBWPs  HBSPs  HBOPs  NNWPs  NHOPs
R="      0,  1.00,  0.85,  1.20,  1.00,  1.00,",  ;;dc  NONCORE
  "      1,  1.00,  0.85,  1.20,  1.00,  1.00,",  ;;dc  CORE
  "     10,  0.95,  1.00,  1.05,  1.00,  1.00,",  ;;mtg
  "     20,  1.00,  0.88,  0.97,  1.00,  1.00,",  ;;pg
  "     30,  1.00,  1.11,  1.08,  1.00,  1.00,",  ;;arl NONCORE
  "     31,  1.00,  1.11,  1.08,  1.00,  1.00,",  ;;arl CORE
  "     40,  1.00,  1.00,  1.00,  1.00,  1.00,",  ;;alx
  "     50,  1.02,  1.02,  1.02,  1.00,  1.00,",  ;;ffx
  "     60,  1.00,  0.95,  0.92,  1.00,  1.00,",  ;;ldn
  "     70,  1.04,  1.15,  0.94,  1.00,  1.00,",  ;;pw
  "     80,  1.00,  1.00,  1.00,  1.00,  1.00,",  ;;
  "     90,  1.13,  1.00,  1.04,  1.00,  1.00,",  ;;frd
  "    100,  1.00,  1.00,  0.94,  1.00,  1.00,",  ;;how
  "    110,  1.00,  1.12,  1.03,  1.00,  1.00,",  ;;aa
  "    120,  1.00,  1.00,  0.93,  1.00,  1.00,",  ;;chs
  "    130,  1.00,  1.00,  1.00,  1.00,  1.00,",  ;;
  "    140,  1.00,  1.00,  0.92,  1.00,  1.00,",  ;;car
  "    150,  1.00,  1.00,  1.12,  1.00,  1.00,",  ;;cal
  "    160,  1.36,  1.00,  1.00,  1.00,  1.00,",  ;;stm
  "    170,  1.00,  1.00,  1.00,  1.00,  1.00,",  ;;kg
  "    180,  1.00,  1.00,  1.00,  1.00,  1.00,",  ;;fbg
  "    190,  1.00,  1.14,  0.86,  1.00,  1.00,",  ;;sta
  "    200,  1.00,  1.00,  1.00,  1.00,  1.00,",  ;;spt
  "    210,  1.00,  1.00,  0.88,  1.00,  1.00,",  ;;fau
  "    220,  1.00,  1.00,  1.00,  1.00,  1.00,",  ;;clk
  "    230,  1.00,  1.00,  1.00,  1.00,  1.00,"   ;;jef
;;
;
LOOKUP NAME=A_JurAdj,   ;
       LOOKUP[1] = 1, RESULT=2, ;  HBW Attraction Adjustment
       LOOKUP[2] = 1, RESULT=3, ;  HBS Attraction Adjustment
       LOOKUP[3] = 1, RESULT=4, ;  HBO Attraction Adjustment
       LOOKUP[4] = 1, RESULT=5, ;  NHW Attraction Adjustment
       LOOKUP[5] = 1, RESULT=6, ;  NHO Attraction Adjustment
       INTERPOLATE=N, FAIL= 1.0,1.0,1.0,
;;
;;           HBWAs  HBSAs  HBOAs  NNWAs  NHOAs
R="       0,   1.10,  0.60,  0.90,  1.10,  0.80,",  ;;dc NONCORE
  "       1,   1.10,  0.60,  0.90,  1.10,  0.80,",  ;;dc CORE
  "      10,   1.02,  1.07,  1.10,  0.90,  1.13,",  ;;mtg
  "      20,   1.08,  0.78,  0.77,  1.00,  0.77,",  ;;pg
  "      30,   1.22,  0.87,  0.95,  1.00,  0.60,",  ;;arl NONCORE
  "      31,   1.22,  0.87,  0.95,  1.00,  0.60,",  ;;arl CORE
  "      40,   0.77,  0.85,  1.00,  1.00,  1.14,",  ;;alx
  "      50,   1.07,  1.05,  1.00,  0.95,  0.95,",  ;;ffx
  "      60,   0.89,  1.07,  0.87,  0.85,  1.00,",  ;;ldn
  "      70,   1.11,  1.05,  0.96,  1.00,  1.00,",  ;;pw
  "      80,   1.00,  1.00,  1.00,  1.00,  1.00,",  ;;
  "      90,   1.00,  1.00,  0.83,  0.88,  1.14,",  ;;frd
  "     100,   0.82,  1.18,  0.87,  0.78,  1.00,",  ;;how
  "     110,   0.86,  1.00,  0.85,  0.89,  0.94,",  ;;aa
  "     120,   1.00,  1.00,  1.00,  1.00,  1.00,",  ;;chs
  "     130,   1.00,  1.00,  1.00,  1.00,  1.00,",  ;;
  "     140,   1.00,  1.51,  0.94,  1.00,  1.24,",  ;;car
  "     150,   1.00,  0.78,  1.29,  1.00,  1.00,",  ;;cal
  "     160,   1.40,  1.00,  0.80,  1.49,  1.00,",  ;;stm
  "     170,   1.00,  1.00,  1.00,  1.00,  1.00,",  ;;kg
  "     180,   1.00,  1.00,  1.00,  1.00,  1.00,",  ;;fbg
  "     190,   1.00,  1.72,  1.00,  1.00,  1.00,",  ;;sta
  "     200,   1.00,  1.00,  1.00,  1.00,  1.00,",  ;;spt
  "     210,   1.00,  1.00,  1.00,  1.00,  1.00,",  ;;fau
  "     220,   1.00,  1.00,  1.00,  1.00,  1.00,",  ;;clk
  "     230,   1.00,  1.00,  1.00,  1.00,  1.00,"   ;;jef
;;
;;
;;             *  P_JurAdj(1,jurcode)
;;             *  A_JurAdj(1,jurcode)
;;
;;==================================================================================================
; End  Jurisdiction Motorized Production, Attraction Adjustment Lookups
;;==================================================================================================



; Read in Production rates, fill in production rate array
FILEI DBI[1]     ="@Prate_in@"
LOOP K = 1,dbi.1.NUMRECORDS
      x = DBIReadRecord(1,k)
           count       = dbi.1.recno
           Prata[1][di.1.Inc][di.1.Siz][di.1.Veh] = di.1.HBW
           Prata[2][di.1.Inc][di.1.Siz][di.1.Veh] = di.1.HBS
           Prata[3][di.1.Inc][di.1.Siz][di.1.Veh] = di.1.HBO
           Prata[4][di.1.Inc][di.1.Siz][di.1.Veh] = di.1.NHW
           Prata[5][di.1.Inc][di.1.Siz][di.1.Veh] = di.1.NHO
ENDLOOP



;; Read in NMproduction model
;;   rates arrayed as: variables (1-4) - 1/constant, 2/1-mi float.pop den.,3/1-mi float emp. den.,4/0.5mi. float. block density
;;                     purpose   (1-5)
;;                     area type (1-6)
FILEI DBI[2]     ="@NMPrate_in@"
LOOP K = 1,dbi.2.NUMRECORDS
      x = DBIReadRecord(2,k)
           NMPrate[dbi.2.recno][1][1] = di.2.HBW1
           NMPrate[dbi.2.recno][1][2] = di.2.HBW2
           NMPrate[dbi.2.recno][1][3] = di.2.HBW3
           NMPrate[dbi.2.recno][1][4] = di.2.HBW4
           NMPrate[dbi.2.recno][1][5] = di.2.HBW5
           NMPrate[dbi.2.recno][1][6] = di.2.HBW6

           NMPrate[dbi.2.recno][2][1] = di.2.HBS1
           NMPrate[dbi.2.recno][2][2] = di.2.HBS2
           NMPrate[dbi.2.recno][2][3] = di.2.HBS3
           NMPrate[dbi.2.recno][2][4] = di.2.HBS4
           NMPrate[dbi.2.recno][2][5] = di.2.HBS5
           NMPrate[dbi.2.recno][2][6] = di.2.HBS6

           NMPrate[dbi.2.recno][3][1] = di.2.HBO1
           NMPrate[dbi.2.recno][3][2] = di.2.HBO2
           NMPrate[dbi.2.recno][3][3] = di.2.HBO3
           NMPrate[dbi.2.recno][3][4] = di.2.HBO4
           NMPrate[dbi.2.recno][3][5] = di.2.HBO5
           NMPrate[dbi.2.recno][3][6] = di.2.HBO6

           NMPrate[dbi.2.recno][4][1] = di.2.NHW1
           NMPrate[dbi.2.recno][4][2] = di.2.NHW2
           NMPrate[dbi.2.recno][4][3] = di.2.NHW3
           NMPrate[dbi.2.recno][4][4] = di.2.NHW4
           NMPrate[dbi.2.recno][4][5] = di.2.NHW5
           NMPrate[dbi.2.recno][4][6] = di.2.NHW6

           NMPrate[dbi.2.recno][5][1] = di.2.NHO1
           NMPrate[dbi.2.recno][5][2] = di.2.NHO2
           NMPrate[dbi.2.recno][5][3] = di.2.NHO3
           NMPrate[dbi.2.recno][5][4] = di.2.NHO4
           NMPrate[dbi.2.recno][5][5] = di.2.NHO5
           NMPrate[dbi.2.recno][5][6] = di.2.NHO6
ENDLOOP


;; Read in NMattraction model
;;   rates arrayed as: Ind.Variable (1-4) - 1/constant, 2/1-mi float.pop den.,3/1-mi float emp. den.,4/0.5mi. float. block density
;;                     purpose      (1-5)
;;                     area type    (1-6)
FILEI DBI[3]     ="@NMArate_in@"
LOOP K = 1,dbi.3.NUMRECORDS
      x = DBIReadRecord(3,k)
           NMArate[dbi.3.recno][1][1] = di.3.HBW1
           NMArate[dbi.3.recno][1][2] = di.3.HBW2
           NMArate[dbi.3.recno][1][3] = di.3.HBW3
           NMArate[dbi.3.recno][1][4] = di.3.HBW4
           NMArate[dbi.3.recno][1][5] = di.3.HBW5
           NMArate[dbi.3.recno][1][6] = di.3.HBW6

           NMArate[dbi.3.recno][2][1] = di.3.HBS1
           NMArate[dbi.3.recno][2][2] = di.3.HBS2
           NMArate[dbi.3.recno][2][3] = di.3.HBS3
           NMArate[dbi.3.recno][2][4] = di.3.HBS4
           NMArate[dbi.3.recno][2][5] = di.3.HBS5
           NMArate[dbi.3.recno][2][6] = di.3.HBS6

           NMArate[dbi.3.recno][3][1] = di.3.HBO1
           NMArate[dbi.3.recno][3][2] = di.3.HBO2
           NMArate[dbi.3.recno][3][3] = di.3.HBO3
           NMArate[dbi.3.recno][3][4] = di.3.HBO4
           NMArate[dbi.3.recno][3][5] = di.3.HBO5
           NMArate[dbi.3.recno][3][6] = di.3.HBO6

           NMArate[dbi.3.recno][4][1] = di.3.NHW1
           NMArate[dbi.3.recno][4][2] = di.3.NHW2
           NMArate[dbi.3.recno][4][3] = di.3.NHW3
           NMArate[dbi.3.recno][4][4] = di.3.NHW4
           NMArate[dbi.3.recno][4][5] = di.3.NHW5
           NMArate[dbi.3.recno][4][6] = di.3.NHW6

           NMArate[dbi.3.recno][5][1] = di.3.NHO1
           NMArate[dbi.3.recno][5][2] = di.3.NHO2
           NMArate[dbi.3.recno][5][3] = di.3.NHO3
           NMArate[dbi.3.recno][5][4] = di.3.NHO4
           NMArate[dbi.3.recno][5][5] = di.3.NHO5
           NMArate[dbi.3.recno][5][6] = di.3.NHO6
ENDLOOP


;; Read in Attraction rates
;;   rates arrayed as: Ind.Variables - 1/TotalEmp.,2/Total Pop.,3/Ret.Emp.,4/Off.Emp.,5/OtherEmp.,6/Non-retail Emp.
;;                     purpose   (1-5)
;;                     area type (1-6)
FILEI DBI[4]     ="@Attrate_in@"
LOOP K = 1,dbi.4.NUMRECORDS
      x = DBIReadRecord(4,k)
           ATTrate[dbi.4.recno][1][1] = di.4.HBW1
           ATTrate[dbi.4.recno][1][2] = di.4.HBW2
           ATTrate[dbi.4.recno][1][3] = di.4.HBW3
           ATTrate[dbi.4.recno][1][4] = di.4.HBW4
           ATTrate[dbi.4.recno][1][5] = di.4.HBW5
           ATTrate[dbi.4.recno][1][6] = di.4.HBW6

           ATTrate[dbi.4.recno][2][1] = di.4.HBS1
           ATTrate[dbi.4.recno][2][2] = di.4.HBS2
           ATTrate[dbi.4.recno][2][3] = di.4.HBS3
           ATTrate[dbi.4.recno][2][4] = di.4.HBS4
           ATTrate[dbi.4.recno][2][5] = di.4.HBS5
           ATTrate[dbi.4.recno][2][6] = di.4.HBS6

           ATTrate[dbi.4.recno][3][1] = di.4.HBO1
           ATTrate[dbi.4.recno][3][2] = di.4.HBO2
           ATTrate[dbi.4.recno][3][3] = di.4.HBO3
           ATTrate[dbi.4.recno][3][4] = di.4.HBO4
           ATTrate[dbi.4.recno][3][5] = di.4.HBO5
           ATTrate[dbi.4.recno][3][6] = di.4.HBO6

           ATTrate[dbi.4.recno][4][1] = di.4.NHW1
           ATTrate[dbi.4.recno][4][2] = di.4.NHW2
           ATTrate[dbi.4.recno][4][3] = di.4.NHW3
           ATTrate[dbi.4.recno][4][4] = di.4.NHW4
           ATTrate[dbi.4.recno][4][5] = di.4.NHW5
           ATTrate[dbi.4.recno][4][6] = di.4.NHW6

           ATTrate[dbi.4.recno][5][1] = di.4.NHO1
           ATTrate[dbi.4.recno][5][2] = di.4.NHO2
           ATTrate[dbi.4.recno][5][3] = di.4.NHO3
           ATTrate[dbi.4.recno][5][4] = di.4.NHO4
           ATTrate[dbi.4.recno][5][5] = di.4.NHO5
           ATTrate[dbi.4.recno][5][6] = di.4.NHO6
ENDLOOP


;; Read in Income/Area Type - Attraction Shares
;;   rates arrayed as: Income, AreaType
;;
;;
FILEI DBI[5]     ="@Incrat_in@"
LOOP K = 1,dbi.5.NUMRECORDS
      x = DBIReadRecord(5,k)
           AIncRatio[di.5.income][di.5.Atype][1]  = di.5.HBWRat
           AIncShare[di.5.income][di.5.Atype][1]  = di.5.HBWShare

           AIncRatio[di.5.income][di.5.Atype][2]  = di.5.HBSRat
           AIncShare[di.5.income][di.5.Atype][2]  = di.5.HBSShare

           AIncRatio[di.5.income][di.5.Atype][3]  = di.5.HBORat
           AIncShare[di.5.income][di.5.Atype][3]  = di.5.HBOShare
ENDLOOP

If (I <= @LastIZN@)

; Read in HHs by Income , Size, Vehs. Avail
 ZDATI[2] = @ZNFILE_IN4@ ;; variables in DBF file:
                         ;; HHSISV111       HHSISV112       HHSISV113       HHSISV114
                         ;; HHSISV211       HHSISV212       HHSISV213       HHSISV214
                         ;; HHSISV311       HHSISV312       HHSISV313       HHSISV314
                         ;; HHSISV411       HHSISV412       HHSISV413       HHSISV414
                         ;; HHSISV121       HHSISV122       HHSISV123       HHSISV124
                         ;; HHSISV221       HHSISV222       HHSISV223       HHSISV224
                         ;; HHSISV321       HHSISV322       HHSISV323       HHSISV324
                         ;; HHSISV421       HHSISV422       HHSISV423       HHSISV424
                         ;; HHSISV131       HHSISV132       HHSISV133       HHSISV134
                         ;; HHSISV231       HHSISV232       HHSISV233       HHSISV234
                         ;; HHSISV331       HHSISV332       HHSISV333       HHSISV334
                         ;; HHSISV431       HHSISV432       HHSISV433       HHSISV434
                         ;; HHSISV141       HHSISV142       HHSISV143       HHSISV144
                         ;; HHSISV241       HHSISV242       HHSISV243       HHSISV244
                         ;; HHSISV341       HHSISV342       HHSISV343       HHSISV344
                         ;; HHSISV441       HHSISV442       HHSISV443       HHSISV444

;; store current TAZ HHs in Array
   Hha[1][1][1] = zi.2.HHSISV111  Hha[1][1][2] = zi.2.HHSISV112  Hha[1][1][3] = zi.2.HHSISV113  Hha[1][1][4] = zi.2.HHSISV114
   Hha[2][1][1] = zi.2.HHSISV211  Hha[2][1][2] = zi.2.HHSISV212  Hha[2][1][3] = zi.2.HHSISV213  Hha[2][1][4] = zi.2.HHSISV214
   Hha[3][1][1] = zi.2.HHSISV311  Hha[3][1][2] = zi.2.HHSISV312  Hha[3][1][3] = zi.2.HHSISV313  Hha[3][1][4] = zi.2.HHSISV314
   Hha[4][1][1] = zi.2.HHSISV411  Hha[4][1][2] = zi.2.HHSISV412  Hha[4][1][3] = zi.2.HHSISV413  Hha[4][1][4] = zi.2.HHSISV414
   Hha[1][2][1] = zi.2.HHSISV121  Hha[1][2][2] = zi.2.HHSISV122  Hha[1][2][3] = zi.2.HHSISV123  Hha[1][2][4] = zi.2.HHSISV124
   Hha[2][2][1] = zi.2.HHSISV221  Hha[2][2][2] = zi.2.HHSISV222  Hha[2][2][3] = zi.2.HHSISV223  Hha[2][2][4] = zi.2.HHSISV224
   Hha[3][2][1] = zi.2.HHSISV321  Hha[3][2][2] = zi.2.HHSISV322  Hha[3][2][3] = zi.2.HHSISV323  Hha[3][2][4] = zi.2.HHSISV324
   Hha[4][2][1] = zi.2.HHSISV421  Hha[4][2][2] = zi.2.HHSISV422  Hha[4][2][3] = zi.2.HHSISV423  Hha[4][2][4] = zi.2.HHSISV424
   Hha[1][3][1] = zi.2.HHSISV131  Hha[1][3][2] = zi.2.HHSISV132  Hha[1][3][3] = zi.2.HHSISV133  Hha[1][3][4] = zi.2.HHSISV134
   Hha[2][3][1] = zi.2.HHSISV231  Hha[2][3][2] = zi.2.HHSISV232  Hha[2][3][3] = zi.2.HHSISV233  Hha[2][3][4] = zi.2.HHSISV234
   Hha[3][3][1] = zi.2.HHSISV331  Hha[3][3][2] = zi.2.HHSISV332  Hha[3][3][3] = zi.2.HHSISV333  Hha[3][3][4] = zi.2.HHSISV334
   Hha[4][3][1] = zi.2.HHSISV431  Hha[4][3][2] = zi.2.HHSISV432  Hha[4][3][3] = zi.2.HHSISV433  Hha[4][3][4] = zi.2.HHSISV434
   Hha[1][4][1] = zi.2.HHSISV141  Hha[1][4][2] = zi.2.HHSISV142  Hha[1][4][3] = zi.2.HHSISV143  Hha[1][4][4] = zi.2.HHSISV144
   Hha[2][4][1] = zi.2.HHSISV241  Hha[2][4][2] = zi.2.HHSISV242  Hha[2][4][3] = zi.2.HHSISV243  Hha[2][4][4] = zi.2.HHSISV244
   Hha[3][4][1] = zi.2.HHSISV341  Hha[3][4][2] = zi.2.HHSISV342  Hha[3][4][3] = zi.2.HHSISV343  Hha[3][4][4] = zi.2.HHSISV344
   Hha[4][4][1] = zi.2.HHSISV441  Hha[4][4][2] = zi.2.HHSISV442  Hha[4][4][3] = zi.2.HHSISV443  Hha[4][4][4] = zi.2.HHSISV444

Jr             = zi.1.Jurcode + 1.0  ; Initialize Jur code index
At             = zi.1.Atype          ; Initialize Area Type index


   loop in=1,4
      loop Si=1,4
         loop Ve=1,4

             TotHHa          =  TotHHa         + HHa[in][si][ve]
             I_HHa[in]       =  I_HHa[in]      + HHa[in][Si][Ve]                                ; HHs by Inc
             S_HHa[Si]       =  S_HHa[Si]      + HHa[in][Si][Ve]                                ;     by Size
             V_HHa[Ve]       =  V_HHa[Ve]      + HHa[in][Si][Ve]                                ;     by Vehs.
             A_HHa[At]       =  A_HHa[At]      + HHa[in][Si][Ve]                                ;     by Area Type
             J_HHa[Jr]       =  J_HHa[Jr]      + HHa[in][Si][Ve]                                ;     by Juris.
             TotHH           =  TotHH          + HHa[in][Si][Ve]                                ; Sum of all HHs

             loop pu=1,5

                Proda[pu][in][Si][Ve]  =  HHa[in][Si][Ve]  *   Prata[Pu][In][Si][Ve]           ; Compute Motorized/NonMotorized productions
                Zproda[pu][i]          =  Zproda[pu][i]        + Proda[pu][in][Si][Ve]         ; Zonal Motor/NonMotor productions by purp
                ZprodaInc[pu][in][i]   =  ZprodaInc[pu][in][i] + Proda[pu][in][Si][Ve]         ; Zonal Motor/NonMotor productions by purp&Inc

                TotProda[pu]          =  TotProda[pu]     + Proda[pu][in][Si][Ve]               ; Accumulate total M/NM productions by purpose
                                                                                                ; Accumualte M/NM summary arrays
                I_proda[in][pu]       =  I_proda[in][pu]  +  Proda[pu][in][Si][Ve]              ;  Productions by Inc and Purpose
                S_proda[Si][pu]       =  S_proda[si][pu]  +  Proda[pu][in][Si][Ve]              ;  Productions by Size and Purpose
                V_proda[Ve][pu]       =  V_proda[Ve][pu]  +  Proda[pu][in][Si][Ve]              ;  Productions by Vehs. and Purpose
                A_proda[at][pu]       =  A_proda[at][pu]  +  Proda[pu][in][Si][Ve]              ;  Productions by Area Tp. and Purpose
                J_proda[Jr][pu]       =  J_proda[Jr][pu]  +  Proda[pu][in][Si][Ve]              ;  Productions by Juris. and Purpose

                TotProdInca[in]       =  TotProdInca[In]  +  Proda[pu][in][Si][Ve]              ;  Total Productions by Inc.
                TotProdSiza[Si]       =  TotProdSiza[Si]  +  Proda[pu][in][Si][Ve]              ;  Total Productions by Size
                TotProdVeha[Ve]       =  TotProdVeha[Ve]  +  Proda[pu][in][Si][Ve]              ;  Total Productions by Vehs.
                TotProdAreaa[At]      =  TotProdAreaa[At] +  Proda[pu][in][Si][Ve]              ;  Total Productions by Area Tp.
                TotProdJura[Jr]       =  TotProdJura[At]  +  Proda[pu][in][Si][Ve]              ;  Total Productions by Juris.

             endloop
         endloop
      endloop
   endloop


;;  I-X Model is voided out
;;  Compute Internal Motorized / NonMotorized productions here:
;;
;; H.Humeida's NM Model - 10/14/10
;; original model (single curve:  IX_ShareHBW = 0.1786 * (exp(-0.1435 * zi.1.ADISTTOX))
;; updated model

;;  Default Curves
;;  IX_ShareHBW = 0.2133 * (exp(-0.1950 * zi.1.ADISTTOX))
;;  IX_ShareHBS = 0.2133 * (exp(-0.1950 * zi.1.ADISTTOX))
;;  IX_ShareHBO = 0.2133 * (exp(-0.1950 * zi.1.ADISTTOX))
;;  IX_ShareNHW = 0.2133 * (exp(-0.1950 * zi.1.ADISTTOX))
;;  IX_ShareNHO = 0.2133 * (exp(-0.1950 * zi.1.ADISTTOX))

;; Baltimore area curves:
;;  If (zi.1.jurcode = 10 || zi.1.jurcode = 11 || zi.1.jurcode = 14 )
;;    IX_ShareHBW = 0.3348 * (exp(-0.0938 * zi.1.ADISTTOX))
;;    IX_ShareHBS = 0.1766 * (exp(-0.1957 * zi.1.ADISTTOX))
;;    IX_ShareHBO = 0.1766 * (exp(-0.1957 * zi.1.ADISTTOX))
;;    IX_ShareNHW = 0.1766 * (exp(-0.1957 * zi.1.ADISTTOX))
;;    IX_ShareNHO = 0.1766 * (exp(-0.1957 * zi.1.ADISTTOX))
;;  endif
;;--------------------------------------------------------------------------------------

;; Compute "raw" Non-Motorized shares here:
NMP_ShareHBW = NMPrate[1][1][zi.1.atype]                   +
               NMPrate[2][1][zi.1.atype] * zi.1.POPDEN10   +
               NMPrate[3][1][zi.1.atype] * zi.1.EMPDEN10   +
               NMPrate[4][1][zi.1.atype] * zi.1.Blockden05

NMP_ShareHBS = NMPrate[1][2][zi.1.atype]                   +
               NMPrate[2][2][zi.1.atype] * zi.1.POPDEN10   +
               NMPrate[3][2][zi.1.atype] * zi.1.EMPDEN10   +
               NMPrate[4][2][zi.1.atype] * zi.1.Blockden05

NMP_ShareHBO = NMPrate[1][3][zi.1.atype]                   +
               NMPrate[2][3][zi.1.atype] * zi.1.POPDEN10   +
               NMPrate[3][3][zi.1.atype] * zi.1.EMPDEN10   +
               NMPrate[4][3][zi.1.atype] * zi.1.Blockden05

NMP_ShareNHW = NMPrate[1][4][zi.1.atype]                   +
               NMPrate[2][4][zi.1.atype] * zi.1.POPDEN10   +
               NMPrate[3][4][zi.1.atype] * zi.1.EMPDEN10   +
               NMPrate[4][4][zi.1.atype] * zi.1.Blockden05

NMP_ShareNHO = NMPrate[1][5][zi.1.atype]                   +
               NMPrate[2][5][zi.1.atype] * zi.1.POPDEN10   +
               NMPrate[3][5][zi.1.atype] * zi.1.EMPDEN10   +
               NMPrate[4][5][zi.1.atype] * zi.1.Blockden05

;; Compute Non-Motorized shares with area type adjustments here (make sure shares do not exceed 1.00):

NMP_ShareHBW_adj =  MIN(1.00,(NMP_ShareHBW * NPro_Adj[1][At]))
NMP_ShareHBS_adj =  MIN(1.00,(NMP_ShareHBS * NPro_Adj[2][At]))
NMP_ShareHBO_adj =  MIN(1.00,(NMP_ShareHBO * NPro_Adj[3][At]))
NMP_ShareNHW_adj =  MIN(1.00,(NMP_ShareNHW * NPro_Adj[4][At]))
NMP_ShareNHO_adj =  MIN(1.00,(NMP_ShareNHO * NPro_Adj[5][At]))


;; compute Internal Motor/NonMotor productions by purpose
  jurcode2 = jurcode* 10 + coreflag  ;; establish juris/core-noncore index for P-/A-mods

;;---------------HBW-----------
   MZProda[1][i]  =     Zproda[1][i] * (1.0 - NMP_ShareHBW_adj) * MPro_Adj[1][At] *  P_JurAdj(1,jurcode2) ;; compute internal HBW Motorized productions
   NMZProda[1][i] =     Zproda[1][i] *        NMP_ShareHBW_adj  * MPro_Adj[1][At] *  P_JurAdj(1,jurcode2) ;;       ;; compute internal HBW Non-Motorized productions

   IF (Zproda[1][i]>0)
        ;;   Pr In zone;          Pr Zn         Pr Zn               in pr  zn          ;; compute internal HBW Motorized productions by Income level
     MZProdaInc[1][1][i]  = (MZProda[1][i]/Zproda[1][i]) * ZprodaInc[1][1][i]
     MZProdaInc[1][2][i]  = (MZProda[1][i]/Zproda[1][i]) * ZprodaInc[1][2][i]
     MZProdaInc[1][3][i]  = (MZProda[1][i]/Zproda[1][i]) * ZprodaInc[1][3][i]
     MZProdaInc[1][4][i]  = (MZProda[1][i]/Zproda[1][i]) * ZprodaInc[1][4][i]
   ENDIF

;;---------------HBS-----------
   MZProda[2][i]  =     Zproda[2][i] * (1.0 - NMP_ShareHBS_adj) * MPro_Adj[2][At] *  P_JurAdj(2,jurcode2)  ;; compute internal HBS Motorized productions
   NMZProda[2][i] =     Zproda[2][i] *        NMP_ShareHBS_adj  * MPro_Adj[2][At] *  P_JurAdj(2,jurcode2)  ;;       ;; compute internal HBS Non-Motorized productions

   IF (Zproda[2][i]>0)
        ;;   Pr In zone;          Pr Zn         Pr Zn               in pr  zn          ;; compute internal HBS Motorized productions by Income level
     MZProdaInc[2][1][i]  = (MZProda[2][i]/Zproda[2][i]) * ZprodaInc[2][1][i]
     MZProdaInc[2][2][i]  = (MZProda[2][i]/Zproda[2][i]) * ZprodaInc[2][2][i]
     MZProdaInc[2][3][i]  = (MZProda[2][i]/Zproda[2][i]) * ZprodaInc[2][3][i]
     MZProdaInc[2][4][i]  = (MZProda[2][i]/Zproda[2][i]) * ZprodaInc[2][4][i]
   ENDIF


;;---------------HBO-----------
   MZProda[3][i]  =     Zproda[3][i] * (1.0 - NMP_ShareHBO_adj) * MPro_Adj[3][At] *  P_JurAdj(3,jurcode2) ;; compute internal HBO Motorized productions
   NMZProda[3][i] =     Zproda[3][i] *        NMP_ShareHBO_adj  * MPro_Adj[3][At] *  P_JurAdj(3,jurcode2) ;;        ;; compute internal HBO Non-Motorized productions

   IF (Zproda[3][i]>0)
        ;;   Pr In zone;          Pr Zn         Pr Zn               in pr zn           ;; compute internal HBO Motorized productions by Income level
     MZProdaInc[3][1][i]  = (MZProda[3][i]/Zproda[3][i]) * ZprodaInc[3][1][i]
     MZProdaInc[3][2][i]  = (MZProda[3][i]/Zproda[3][i]) * ZprodaInc[3][2][i]
     MZProdaInc[3][3][i]  = (MZProda[3][i]/Zproda[3][i]) * ZprodaInc[3][3][i]
     MZProdaInc[3][4][i]  = (MZProda[3][i]/Zproda[3][i]) * ZprodaInc[3][4][i]
   ENDIF


;;---------------NHW-----------
   MZProda[4][i]  =     Zproda[4][i] * (1.0 - NMP_ShareNHW_adj) * MPro_Adj[4][At] *  P_JurAdj(4,jurcode2)  ;; compute internal NHW Motorized productions
   NMZProda[4][i] =     Zproda[4][i] *        NMP_ShareNHW_adj  * MPro_Adj[4][At] *  P_JurAdj(4,jurcode2)  ;;        ;; compute internal NHW Non-Motorized productions

;;---------------NHO-----------
   MZProda[5][i]  =     Zproda[5][i] * (1.0 - NMP_ShareNHO_adj) * MPro_Adj[5][At] *  P_JurAdj(5,jurcode2)  ;; compute internal NHO Motorized productions
   NMZProda[5][i] =     Zproda[5][i] *        NMP_ShareNHO_adj  * MPro_Adj[5][At] *  P_JurAdj(5,jurcode2)  ;;         ;; compute internal NHO Non-Motorized productions


;;--;; Debug productions calculations
if (I <300)
 print  form=6.4 list ='taz: ',i,'  NMP shares by purp:  ', NMP_ShareHBW,' ', NMP_ShareHBS,' ', NMP_ShareHBO,' ', NMP_ShareNHW,' ', NMP_ShareNHO, file= debug_P_Shares.txt
 print  form=6.4 list ='taz: ',i,'  NMP shares w/NMMODS: ', NMP_ShareHBW_adj,' ', NMP_ShareHBS_adj,' ', NMP_ShareHBO_adj,' ', NMP_ShareNHW_adj,' ', NMP_ShareNHO_adj, file= debug_P_Shares.txt
 print  form=6.2 list ='taz: ',i,' Total Prods by purp: ', ZProda[1][i],' ',ZProda[2][i],' ', ZProda[3][i],' ', ZProda[4][i],' ',ZProda[5][i],                           file= debug_P_Shares.txt
 print  form=6.2 list ='taz: ',i,' Motr  Prods by purp: ',MZProda[1][i],' ',MZProda[2][i],' ',MZProda[3][i],' ',MZProda[4][i],' ',MZProda[5][i],                         file= debug_P_Shares.txt
 print  form=6.2 list ='taz: ',i,' NMtr  Prods by purp: ',NMZProda[1][i],' ',NMZProda[2][i],' ',NMZProda[3][i],' ',NMZProda[4][i],' ',nMZProda[5][i],                    file= debug_P_Shares.txt


endif
;;
;; write out dbf files for Trip Productions by purpose and mode                            ;;   Pr In zone;
;;                                                                                      MZProdaInc[1][1][i]
FILEO RECO[1]    = "@TripPros@",fields =
                 TAZ(5),
                 HBW_Mtr_Ps@ofmt@, HBW_NMt_Ps@ofmt@, HBW_All_Ps@ofmt@,HBWMtrP_I1@ofmt@,HBWMtrP_I2@ofmt@,HBWMtrP_I3@ofmt@,HBWMtrP_I4@ofmt@,
                 HBS_Mtr_Ps@ofmt@, HBS_NMt_Ps@ofmt@, HBS_All_Ps@ofmt@,HBSMtrP_I1@ofmt@,HBSMtrP_I2@ofmt@,HBSMtrP_I3@ofmt@,HBSMtrP_I4@ofmt@,
                 HBO_Mtr_Ps@ofmt@, HBO_NMt_Ps@ofmt@, HBO_All_Ps@ofmt@,HBOMtrP_I1@ofmt@,HBOMtrP_I2@ofmt@,HBOMtrP_I3@ofmt@,HBOMtrP_I4@ofmt@,
                 NHW_Mtr_Ps@ofmt@, NHW_NMt_Ps@ofmt@, NHW_All_Ps@ofmt@,
                 NHO_Mtr_Ps@ofmt@, NHO_NMt_Ps@ofmt@, NHO_All_Ps@ofmt@


 ro.TAZ = i
 ro.HBW_Mtr_Ps =    MZProda[1][i]
 ro.HBW_NMt_Ps =   NMZProda[1][i]
 ro.HBW_All_Ps =    MZProda[1][i] + NMZProda[1][i]      ;ZProda[1][i]

 ro.HBWMtrP_I1 = MZProdaInc[1][1][i]
 ro.HBWMtrP_I2 = MZProdaInc[1][2][i]
 ro.HBWMtrP_I3 = MZProdaInc[1][3][i]
 ro.HBWMtrP_I4 = MZProdaInc[1][4][i]

 ro.HBS_Mtr_Ps =    MZProda[2][i]
 ro.HBS_NMt_Ps =   NMZProda[2][i]
 ro.HBS_All_Ps =    MZProda[2][i] + NMZProda[2][i]      ;ZProda[2][i]

 ro.HBSMtrP_I1 = MZProdaInc[2][1][i]
 ro.HBSMtrP_I2 = MZProdaInc[2][2][i]
 ro.HBSMtrP_I3 = MZProdaInc[2][3][i]
 ro.HBSMtrP_I4 = MZProdaInc[2][4][i]

 ro.HBO_Mtr_Ps =    MZProda[3][i]
 ro.HBO_NMt_Ps =   NMZProda[3][i]
 ro.HBO_All_Ps =    MZProda[3][i] + NMZProda[3][i]      ;ZProda[3][i]

 ro.HBOMtrP_I1 = MZProdaInc[3][1][i]
 ro.HBOMtrP_I2 = MZProdaInc[3][2][i]
 ro.HBOMtrP_I3 = MZProdaInc[3][3][i]
 ro.HBOMtrP_I4 = MZProdaInc[3][4][i]

 ro.NHW_Mtr_Ps =    MZProda[4][i]
 ro.NHW_NMt_Ps =   NMZProda[4][i]
 ro.NHW_All_Ps =    MZProda[4][i] + NMZProda[4][i]      ;ZProda[4][i]

 ro.NHO_Mtr_Ps =    MZProda[5][i]
 ro.NHO_NMt_Ps =   NMZProda[5][i]
 ro.NHO_All_Ps =    MZProda[5][i] + NMZProda[5][i]      ;ZProda[5][i]


 WRITE RECO=1


;; Accumulate Regional Motor/NonMotor Totals by purpose

   MTotProda[1]           =        MTotProda[1]    +     MZProda[1][i]                  ;; accum. internal HBW Motorized productions
     MTotProdInca[1][1]   =     MTotProdInca[1][1] +  MZProdaInc[1][1][i]               ;; accum. internal HBW Motorized productions by inc.
     MTotProdInca[1][2]   =     MTotProdInca[1][2] +  MZProdaInc[1][2][i]               ;; accum. internal HBW Motorized productions by inc.
     MTotProdInca[1][3]   =     MTotProdInca[1][3] +  MZProdaInc[1][3][i]               ;; accum. internal HBW Motorized productions by inc.
     MTotProdInca[1][4]   =     MTotProdInca[1][4] +  MZProdaInc[1][4][i]               ;; accum. internal HBW Motorized productions by inc.
   NMTotProda[1]          =       NMTotProda[1]    +    NMZProda[1][i]                  ;; accum. internal HBW Non-Motorized productions
  MNMTotProda[1]          =      MNMTotProda[1]    +     MZProda[1][i] + NMZProda[1][i] ;; accum. internal HBW Motorized&Non-Motorized productions

   MTotProda[2]           =        MTotProda[2]    +     MZProda[2][i]                  ;; accum.internal HBS Motorized productions
     MTotProdInca[2][1]   =     MTotProdInca[2][1] +  MZProdaInc[2][1][i]               ;; accum. internal HBS Motorized productions by inc.
     MTotProdInca[2][2]   =     MTotProdInca[2][2] +  MZProdaInc[2][2][i]               ;; accum. internal HBS Motorized productions by inc.
     MTotProdInca[2][3]   =     MTotProdInca[2][3] +  MZProdaInc[2][3][i]               ;; accum. internal HBS Motorized productions by inc.
     MTotProdInca[2][4]   =     MTotProdInca[2][4] +  MZProdaInc[2][4][i]               ;; accum. internal HBS Motorized productions by inc.
   NMTotProda[2]          =       NMTotProda[2]    +    NMZProda[2][i]                  ;; accum.internal HBS Non-Motorized productions
  MNMTotProda[2]          =      MNMTotProda[2]    +     MZProda[2][i] + NMZProda[2][i] ;; accum.internal HBS Motorized&Non-Motorized productions

   MTotProda[3]           =        MTotProda[3]    +     MZProda[3][i]                  ;; accum.internal HBO Motorized productions
     MTotProdInca[3][1]   =     MTotProdInca[3][1] +  MZProdaInc[3][1][i]               ;; accum. internal HBO Motorized productions by inc.
     MTotProdInca[3][2]   =     MTotProdInca[3][2] +  MZProdaInc[3][2][i]               ;; accum. internal HBO Motorized productions by inc.
     MTotProdInca[3][3]   =     MTotProdInca[3][3] +  MZProdaInc[3][3][i]               ;; accum. internal HBO Motorized productions by inc.
     MTotProdInca[3][4]   =     MTotProdInca[3][4] +  MZProdaInc[3][4][i]               ;; accum. internal HBO Motorized productions by inc.
   NMTotProda[3]          =       NMTotProda[3]    +    NMZProda[3][i]                  ;; accum.internal HBO Non-Motorized productions
  MNMTotProda[3]          =      MNMTotProda[3]    +     MZProda[3][i] + NMZProda[3][i] ;; accum.internal HBO Motorized&Non-Motorized productions

   MTotProda[4]           =        MTotProda[4]    +     MZProda[4][i]                  ;; accum.internal NHW Motorized productions
   NMTotProda[4]          =       NMTotProda[4]    +    NMZProda[4][i]                  ;; accum.internal NHW Non-Motorized productions
  MNMTotProda[4]          =      MNMTotProda[4]    +     MZProda[4][i] + NMZProda[4][i] ;; accum.internal NHW Motorized&Non-Motorized productions

   MTotProda[5]           =        MTotProda[5]    +     MZProda[5][i]                  ;; accum.internal NHO Motorized productions
   NMTotProda[5]          =       NMTotProda[5]    +    NMZProda[5][i]                  ;; accum.internal NHO Non-Motorized productions
  MNMTotProda[5]          =      MNMTotProda[5]    +     MZProda[5][i] + NMZProda[5][i] ;; accum.internal NHO Motorized&Non-Motorized productions


;; Accumulate Regional Motor/NonMotor/ summed Totals
   MTotProd       =   MTotProd     +   MZProda[1][i] +   MZProda[2][i] +   MZProda[3][i] +   MZProda[4][i] +   MZProda[5][i]
   NMTotProd      =  NMTotProd     +  NMZProda[1][i] +  NMZProda[2][i] +  NMZProda[3][i] +  NMZProda[4][i] +  NMZProda[5][i]

  MNMTotProd      = MNMTotProd     +   MZProda[1][i] +   MZProda[2][i] +   MZProda[3][i] +   MZProda[4][i] +   MZProda[5][i] +
                                      NMZProda[1][i] +  NMZProda[2][i] +  NMZProda[3][i] +  NMZProda[4][i] +  NMZProda[5][i]
;;==========================================================================================================================








;;==========================================================================================================================


   HBWCompATT[i] =(Attrate[1][1][zi.1.atype] * zi.1.TOTEMP   +
                   Attrate[2][1][zi.1.atype] * zi.1.TOTPOP   +
                   Attrate[3][1][zi.1.atype] * zi.1.RETEMP   +
                   Attrate[4][1][zi.1.atype] * zi.1.OFFEMP   +
                   Attrate[5][1][zi.1.atype] * zi.1.OTHEMP   +
                   Attrate[6][1][zi.1.atype] * zi.1.NRETEMP)

   HBSCompATT[i] =(Attrate[1][2][zi.1.atype] * zi.1.TOTEMP   +
                   Attrate[2][2][zi.1.atype] * zi.1.TOTPOP   +
                   Attrate[3][2][zi.1.atype] * zi.1.RETEMP   +
                   Attrate[4][2][zi.1.atype] * zi.1.OFFEMP   +
                   Attrate[5][2][zi.1.atype] * zi.1.OTHEMP   +
                   Attrate[6][2][zi.1.atype] * zi.1.NRETEMP)

   HBOCompATT[i] =(Attrate[1][3][zi.1.atype] * zi.1.TOTEMP   +
                   Attrate[2][3][zi.1.atype] * zi.1.TOTPOP   +
                   Attrate[3][3][zi.1.atype] * zi.1.RETEMP   +
                   Attrate[4][3][zi.1.atype] * zi.1.OFFEMP   +
                   Attrate[5][3][zi.1.atype] * zi.1.OTHEMP   +
                   Attrate[6][3][zi.1.atype] * zi.1.NRETEMP)

   NHWCompATT[i] =(Attrate[1][4][zi.1.atype] * zi.1.TOTEMP   +
                   Attrate[2][4][zi.1.atype] * zi.1.TOTPOP   +
                   Attrate[3][4][zi.1.atype] * zi.1.RETEMP   +
                   Attrate[4][4][zi.1.atype] * zi.1.OFFEMP   +
                   Attrate[5][4][zi.1.atype] * zi.1.OTHEMP   +
                   Attrate[6][4][zi.1.atype] * zi.1.NRETEMP)

   NHOCompATT[i] =(Attrate[1][5][zi.1.atype] * zi.1.TOTEMP   +
                   Attrate[2][5][zi.1.atype] * zi.1.TOTPOP   +
                   Attrate[3][5][zi.1.atype] * zi.1.RETEMP   +
                   Attrate[4][5][zi.1.atype] * zi.1.OFFEMP   +
                   Attrate[5][5][zi.1.atype] * zi.1.OTHEMP   +
                   Attrate[6][5][zi.1.atype] * zi.1.NRETEMP)



 TOTHBWCompATT = TOTHBWCompATT + HBWCompATT[I]
 TOTHBSCompATT = TOTHBSCompATT + HBSCompATT[I]
 TOTHBOCompATT = TOTHBOCompATT + HBOCompATT[I]
 TOTNHWCompATT = TOTNHWCompATT + NHWCompATT[I]
 TOTNHOCompATT = TOTNHOCompATT + NHOCompATT[I]


;;
;;  Compute Internal Motorized / NonMotorized ATTRACTIONS here:
;;


NMA_ShareHBW = NMArate[1][1][zi.1.atype]                   +
               NMArate[2][1][zi.1.atype] * zi.1.POPDEN10   +
               NMArate[3][1][zi.1.atype] * zi.1.EMPDEN10   +
               NMArate[4][1][zi.1.atype] * zi.1.Blockden05

NMA_ShareHBS = NMArate[1][2][zi.1.atype]                   +
               NMArate[2][2][zi.1.atype] * zi.1.POPDEN10   +
               NMArate[3][2][zi.1.atype] * zi.1.EMPDEN10   +
               NMArate[4][2][zi.1.atype] * zi.1.Blockden05

NMA_ShareHBO = NMArate[1][3][zi.1.atype]                   +
               NMArate[2][3][zi.1.atype] * zi.1.POPDEN10   +
               NMArate[3][3][zi.1.atype] * zi.1.EMPDEN10   +
               NMArate[4][3][zi.1.atype] * zi.1.Blockden05

NMA_ShareNHW = NMArate[1][4][zi.1.atype]                   +
               NMArate[2][4][zi.1.atype] * zi.1.POPDEN10   +
               NMArate[3][4][zi.1.atype] * zi.1.EMPDEN10   +
               NMArate[4][4][zi.1.atype] * zi.1.Blockden05

NMA_ShareNHO = NMArate[1][5][zi.1.atype]                   +
               NMArate[2][5][zi.1.atype] * zi.1.POPDEN10   +
               NMArate[3][5][zi.1.atype] * zi.1.EMPDEN10   +
               NMArate[4][5][zi.1.atype] * zi.1.Blockden05

;; Compute Non-Motorized shares with area type adjustments here (make sure shares do not exceed 1.00):

NMA_ShareHBW_adj =  MIN(1.00,(NMA_ShareHBW * NAtt_Adj[1][At]))
NMA_ShareHBS_adj =  MIN(1.00,(NMA_ShareHBS * NAtt_Adj[2][At]))
NMA_ShareHBO_adj =  MIN(1.00,(NMA_ShareHBO * NAtt_Adj[3][At]))
NMA_ShareNHW_adj =  MIN(1.00,(NMA_ShareNHW * NAtt_Adj[4][At]))
NMA_ShareNHO_adj =  MIN(1.00,(NMA_ShareNHO * NAtt_Adj[5][At]))

;; compute Internal Motor/NonMotor ATTRACTIONS by purpose


   MZAttra[1][i]  =     HBWCompATT[i] * (1.0 -  NMA_ShareHBW_adj) * MAtt_Adj[1][at]  *  A_JurAdj(1,jurcode2)     ;; compute internal HBW Motorized attractions
   NMZAttra[1][i] =     HBWCompATT[i] *         NMA_ShareHBW_adj  * MAtt_Adj[1][at]  *  A_JurAdj(1,jurcode2)     ;; compute internal HBW Non-Motorized attractions

   MZAttra[2][i]  =     HBSCompATT[i] * (1.0 -  NMA_ShareHBS_adj) * MAtt_Adj[2][at]  *  A_JurAdj(2,jurcode2)     ;; compute internal HBS Motorized attractions
   NMZAttra[2][i] =     HBSCompATT[i] *         NMA_ShareHBS_adj  * MAtt_Adj[2][at]  *  A_JurAdj(2,jurcode2)     ;; compute internal HBS Non-Motorized attractions

   MZAttra[3][i]  =     HBOCompATT[i] * (1.0 -  NMA_ShareHBO_adj) * MAtt_Adj[3][at]  *  A_JurAdj(3,jurcode2)     ;; compute internal HBO Motorized attractions
   NMZAttra[3][i] =     HBOCompATT[i] *         NMA_ShareHBO_adj  * MAtt_Adj[3][at]  *  A_JurAdj(3,jurcode2)     ;; compute internal HBO Non-Motorized attractions

   MZAttra[4][i]  =     NHWCompATT[i] * (1.0 -  NMA_ShareNHW_adj) * MAtt_Adj[4][at]  *  A_JurAdj(4,jurcode2)     ;; compute internal NHW Motorized attractions
   NMZAttra[4][i] =     NHWCompATT[i] *         NMA_ShareNHW_adj  * MAtt_Adj[4][at]  *  A_JurAdj(4,jurcode2)     ;; compute internal NHW Non-Motorized attractions

   MZAttra[5][i]  =     NHOCompATT[i] * (1.0 -  NMA_ShareNHO_adj) * MAtt_Adj[5][at]  *  A_JurAdj(5,jurcode2)     ;; compute internal NHO Motorized attractions
   NMZAttra[5][i] =     NHOCompATT[i] *         NMA_ShareNHO_adj  * MAtt_Adj[5][at]  *  A_JurAdj(5,jurcode2)     ;; compute internal NHO Non-Motorized attractions


;; Accumulate Regional Motor/NonMotor Totals by purpose

   MTotAttra[1]   =     MTotAttra[1] +  MZAttra[1][i]                               ;; compute internal HBW Motorized attractions
  NMTotAttra[1]   =    NMTotAttra[1] + NMZAttra[1][i]                               ;; compute internal HBW Non-Motorized attractions
 MNMTotAttra[1]   =   MNMTotAttra[1] +  MZAttra[1][i] + NMZAttra[1][i]              ;; compute internal HBW Motorized&Non-Motorized attractions

   MTotAttra[2]   =     MTotAttra[2] +  MZAttra[2][i]                               ;; compute internal HBS Motorized attractions
  NMTotAttra[2]   =    NMTotAttra[2] + NMZAttra[2][i]                               ;; compute internal HBS Non-Motorized attractions
 MNMTotAttra[2]   =   MNMTotAttra[2] +  MZAttra[2][i] + NMZAttra[2][i]              ;; compute internal HBS Motorized&Non-Motorized attractions

   MTotAttra[3]   =     MTotAttra[3]  + MZAttra[3][i]                               ;; compute internal HBO Motorized attractions
  NMTotAttra[3]   =    NMTotAttra[3] + NMZAttra[3][i]                               ;; compute internal HBO Non-Motorized attractions
 MNMTotAttra[3]   =   MNMTotAttra[3] +  MZAttra[3][i] + NMZAttra[3][i]              ;; compute internal HBO Motorized&Non-Motorized attractions

   MTotAttra[4]   =     MTotAttra[4]  + MZAttra[4][i]                               ;; compute internal NHW Motorized attractions
  NMTotAttra[4]   =    NMTotAttra[4] + NMZAttra[4][i]                               ;; compute internal NHW Non-Motorized attractions
 MNMTotAttra[4]   =   MNMTotAttra[4] +  MZAttra[4][i] + NMZAttra[4][i]              ;; compute internal NHW Motorized&Non-Motorized attractions

   MTotAttra[5]   =     MTotAttra[5]  + MZAttra[5][i]                               ;; compute internal NHO Motorized attractions
  NMTotAttra[5]   =    NMTotAttra[5] + NMZAttra[5][i]                               ;; compute internal NHO Non-Motorized attractions
 MNMTotAttra[5]   =   MNMTotAttra[5] +  MZAttra[5][i] + NMZAttra[5][i]              ;; compute internal NHO Motorized&Non-Motorized attractions


;; Accumulate Regional Motor/NonMotor/Summed Totals
   MTotAttr       =  MTotAttr      +   MZAttra[1][i] +   MZAttra[2][i] +   MZAttra[3][i] +   MZAttra[4][i]  +   MZAttra[5][i]
   NMTotAttr      =  NMTotAttr     +  NMZAttra[1][i] +  NMZAttra[2][i] +  NMZAttra[3][i] +  NMZAttra[4][i]  +  NMZAttra[5][i]

  MNMTotAttr      = MNMTotAttr     +   MZAttra[1][i] +   MZAttra[2][i] +   MZAttra[3][i] +   MZAttra[4][i]  +   MZAttra[5][i] +
                                      NMZAttra[1][i] +  NMZAttra[2][i] +  NMZAttra[3][i] +  NMZAttra[4][i]  +  NMZAttra[5][i]





;;==========================================================================================================================
;; debug1
   if (i=1 )

          print list= ' TAZ ',' NMP_ShHW ',' NMP_ShHS ',' NMP_ShHO ',' NMP_ShNW ',' NMP_ShNO ',
                              ' NMA_ShHW ',' NMA_ShHS ',' NMA_ShHO ',' NMA_ShNW ',' NMA_ShNO ',
                              ' AttrsHBW ',' AttrsHBS ',' AttrsHBO ',' AttrsNHW ',' AttrsNHO ',
                                file= debug.txt
    endif
          print form=10.4,list= I(5),NMP_ShareHBW,     NMP_ShareHBS,     NMP_ShareHBO,     NMP_ShareNHW,     NMP_ShareNHO,
                                     NMA_ShareHBW,     NMA_ShareHBS,     NMA_ShareHBO,     NMA_ShareNHW,     NMA_ShareNHO,
                                     HBWCOMPATT[i](10),HBSCOMPATT[i](10),HBOCOMPATT[i](10),NHWCOMPATT[i](10),NHOCOMPATT[i](10),
                                     file= debug.txt

          print form=10.4,list= I(5),MZAttra[1][i](10), HBWATTInca[i][1](10), HBWATTInca[i][2](10),HBWATTInca[i][3](10),HBWATTInca[i][4](10),
                                     file= debugHBWaS.txt
          print form=10.4,list= I(5),MZAttra[2][i](10), HBSATTInca[i][1](10), HBSATTInca[i][2](10),HBSATTInca[i][3](10),HBSATTInca[i][4](10),
                                     file= debugHBSas.txt
          print form=10.4,list= I(5),MZAttra[3][i](10), HBOATTInca[i][1](10), HBOATTInca[i][2](10),HBOATTInca[i][3](10),HBOATTInca[i][4](10),
                                     file= debugaHBOas.txt


;;=================================================================================================================================
;; Disaggregate Motorized Attractions by Income
;;=================================================================================================================================

Loop Pr = 1,3
     IniAtot[Pr] = 0
     FinAtot[Pr] = 0
     Scaltot[Pr] = 0
     Loop In = 1,4
             IniAttra[In][Pr]= MZAttra[Pr][i]* AincRatio[In][zi.1.Atype][Pr] * AincShare[In][zi.1.Atype][Pr]  ;; compute initial attractions by income
             IniAtot[Pr]     =                 IniAtot[Pr] + IniAttra[In][Pr]                                 ;; accum.  initial attractions by purpose
     EndLoop
EndLoop



Loop Pr = 1,3

     if (IniAtot[Pr] = 0)
              Scaltot[Pr] = 0
         else
              Scaltot[Pr] =  MZAttra[Pr][i] / IniAtot[Pr]        ;; compute scaling factor by purpose
     endif

     Loop In = 1,4
             FinAttra[In][Pr]= 0
             FinAttra[In][Pr]= IniAttra[In][Pr] * Scaltot[Pr]   ;; compute final attractions by purp/income level (apply scaling factor)
             FinAtot[Pr]     = FinAtot[Pr] + FinAttra[In][Pr]   ;; accumu. final attractions by income level
     EndLoop
EndLoop
;;; ---
  print list = 'comp HBW attractions    ',MZAttra[1][i], ' Area Type: ', zi.1.Atype                                               ,file= debug_incdisagg.txt
  print list = 'Initial  HBW attractions ',IniAttra[1][1] , IniAttra[2][1] ,IniAttra[3][1] ,IniAttra[4][1] , ' Sum: ', IniAtot[1] ,file= debug_incdisagg.txt
  print list = 'HBW scale               ',scaltot[1](8.6)                                                                         ,file= debug_incdisagg.txt
  print list = 'FINAL    HBW attractions ',FinAttra[1][1] , FinAttra[2][1] ,FinAttra[3][1] ,FinAttra[4][1] , ' Sum: ', FinAtot[1] ,file= debug_incdisagg.txt

  ;;                        in  pr
  HBWATTInca[i][1] =FinAttra[1][1]
  HBWATTInca[i][2] =FinAttra[2][1]
  HBWATTInca[i][3] =FinAttra[3][1]
  HBWATTInca[i][4] =FinAttra[4][1]

  ;;                        in  pr
  HBSATTInca[i][1] =FinAttra[1][2]
  HBSATTInca[i][2] =FinAttra[2][2]
  HBSATTInca[i][3] =FinAttra[3][2]
  HBSATTInca[i][4] =FinAttra[4][2]

  ;;                        in  pr
  HBOATTInca[i][1] =FinAttra[1][3]
  HBOATTInca[i][2] =FinAttra[2][3]
  HBOATTInca[i][3] =FinAttra[3][3]
  HBOATTInca[i][4] =FinAttra[4][3]



;;-------------------------------------------------------------------------------------------------------------------------------
ENDIF ; if I <= last internal zone
;;-------------------------------------------------------------------------------------------------------------------------------

;;
;;=====================================================================
;;
IF (I=@Zonesize@)  ;; If at last TAZ

;;=================================================================================================================================
;; Now at the end of the internal TAZs--
;; Write out the attractions here
;; then read external Ps& As, and write to the P,A files
;;=================================================================================================================================


;; Write out zonal dbf files for Computed Trip Attractions by purpose and mode
;;   The NHB and NHO attractions will be scaled to match the production totals here!

LOOP zz= 1,@LastIZn@

   FILEO RECO[2]    = "@TripAttsCom@",fields =
                 TAZ(5),
                 HBW_Mtr_As@ofmt@, HBW_NMt_As@ofmt@, HBW_All_As@ofmt@,
                 HBWMtrA_I1@ofmt@, HBWMtrA_I2@ofmt@, HBWMtrA_I3@ofmt@, HBWMtrA_I4@ofmt@,

                 HBS_Mtr_As@ofmt@, HBS_NMt_As@ofmt@, HBS_All_As@ofmt@,
                 HBSMtrA_I1@ofmt@, HBSMtrA_I2@ofmt@, HBSMtrA_I3@ofmt@, HBSMtrA_I4@ofmt@,

                 HBO_Mtr_As@ofmt@, HBO_NMt_As@ofmt@, HBO_All_As@ofmt@,
                 HBOMtrA_I1@ofmt@, HBOMtrA_I2@ofmt@, HBOMtrA_I3@ofmt@, HBOMtrA_I4@ofmt@,

                 NHW_Mtr_As@ofmt@, NHW_NMt_As@ofmt@, NHW_All_As@ofmt@,

                 NHO_Mtr_As@ofmt@, NHO_NMt_As@ofmt@, NHO_All_As@ofmt@


 ro.TAZ = zz
 ro.HBW_Mtr_As =  MZAttra[1][zz]
 ro.HBW_NMt_As = NMZAttra[1][zz]
 ro.HBW_All_As =  MZAttra[1][zz] + NMZAttra[1][zz]

 ro.HBWMtrA_I1 = HBWAttInca[zz][1]
 ro.HBWMtrA_I2 = HBWAttInca[zz][2]
 ro.HBWMtrA_I3 = HBWAttInca[zz][3]
 ro.HBWMtrA_I4 = HBWAttInca[zz][4]

 ro.HBS_Mtr_As =  MZAttra[2][zz]
 ro.HBS_NMt_As = NMZAttra[2][zz]
 ro.HBS_All_As =  MZAttra[2][zz] + NMZAttra[2][zz]

 ro.HBSMtrA_I1 = HBSAttInca[zz][1]
 ro.HBSMtrA_I2 = HBSAttInca[zz][2]
 ro.HBSMtrA_I3 = HBSAttInca[zz][3]
 ro.HBSMtrA_I4 = HBSAttInca[zz][4]

 ro.HBO_Mtr_As =  MZAttra[3][zz]
 ro.HBO_NMt_As = NMZAttra[3][zz]
 ro.HBO_All_As =  MZAttra[3][zz] + NMZAttra[3][zz]

 ro.HBOMtrA_I1 = HBOAttInca[zz][1]
 ro.HBOMtrA_I2 = HBOAttInca[zz][2]
 ro.HBOMtrA_I3 = HBOAttInca[zz][3]
 ro.HBOMtrA_I4 = HBOAttInca[zz][4]

 ro.NHW_Mtr_As =  MZAttra[4][zz]
 ro.NHW_NMt_As = NMZAttra[4][zz]
 ro.NHW_All_As =  MZAttra[4][zz] + NMZAttra[4][zz]

 ro.NHO_Mtr_As =  MZAttra[5][zz]
 ro.NHO_NMt_As = NMZAttra[5][zz]
 ro.NHO_All_As =  MZAttra[5][zz] + NMZAttra[5][zz]

 WRITE RECO=2
ENDLOOP

FILEI DBI[6]     ="@Ext_PsAs@"   ;;  variables in file:  TAZ     HBW_XI  HBS_XI  HBO_XI  NHB_XI   HBW_IX  HBS_IX  HBO_IX  NHB_IX

LOOP K = 1,dbi.6.NUMRECORDS
         x = DBIReadRecord(6,k)
              MZProda[1][di.6.TAZ]    =   di.6.HBW_XI * @XOccHBW@
              MZProda[2][di.6.TAZ]    =   di.6.HBS_XI * @XOccHBS@
              MZProda[3][di.6.TAZ]    =   di.6.HBO_XI * @XOccHBO@
              NHBProds                =   di.6.NHB_XI

              MZProda[4][di.6.TAZ]    =   NHBProds * @XNHW_Share@ * @XOccNHW@
              MZProda[5][di.6.TAZ]    =   NHBProds * @XNHO_Share@ * @XOccNHO@

              MZAttra[1][di.6.TAZ]    =   di.6.HBW_IX * @XOccHBW@
              MZAttra[2][di.6.TAZ]    =   di.6.HBS_IX * @XOccHBS@
              MZAttra[3][di.6.TAZ]    =   di.6.HBO_IX * @XOccHBO@
              NHBAttrs                =   di.6.NHB_IX

              MZAttra[4][di.6.TAZ]    =   NHBAttrs * @XNHW_Share@ * @XOccNHW@
              MZAttra[5][di.6.TAZ]    =   NHBAttrs * @XNHO_Share@ * @XOccNHO@

;;       Accumulate external P's As by purpose
              XMTotProda[1]           =   XMTotProda[1] +  MZProda[1][di.6.TAZ]
              XMTotProda[2]           =   XMTotProda[2] +  MZProda[2][di.6.TAZ]
              XMTotProda[3]           =   XMTotProda[3] +  MZProda[3][di.6.TAZ]
              XMTotProda[4]           =   XMTotProda[4] +  MZProda[4][di.6.TAZ]
              XMTotProda[5]           =   XMTotProda[5] +  MZProda[5][di.6.TAZ]

              XMTotAttra[1]           =   XMTotAttra[1] +  MZAttra[1][di.6.TAZ]
              XMTotAttra[2]           =   XMTotAttra[2] +  MZAttra[2][di.6.TAZ]
              XMTotAttra[3]           =   XMTotAttra[3] +  MZAttra[3][di.6.TAZ]
              XMTotAttra[4]           =   XMTotAttra[4] +  MZAttra[4][di.6.TAZ]
              XMTotAttra[5]           =   XMTotAttra[5] +  MZAttra[5][di.6.TAZ]


;;       Write extl Motorized Ps out to the zonal production file (Internals were written out previously)
;;         the extl Motorized As will be written out below, along with the scaled attractions
           ro.TAZ        =  di.6.TAZ
           ro.HBW_Mtr_Ps =  MZProda[1][di.6.taz]
           ro.HBS_Mtr_Ps =  MZProda[2][di.6.taz]
           ro.HBO_Mtr_Ps =  MZProda[3][di.6.taz]
           ro.NHW_Mtr_Ps =  MZProda[4][di.6.taz]
           ro.NHO_Mtr_Ps =  MZProda[5][di.6.taz]

           ;; all external Ps are motorized, zero out all other external P-data (Non-motorized Ps, Ps by Income, etc.)
           ro.HBW_NMT_PS =  0
           ro.HBS_NMT_PS =  0
           ro.HBO_NMT_PS =  0
           ro.NHW_NMT_PS =  0
           ro.NHO_NMT_PS =  0

           ro.HBW_ALL_PS =  MZProda[1][di.6.taz]
           ro.HBS_ALL_PS =  MZProda[2][di.6.taz]
           ro.HBO_ALL_PS =  MZProda[3][di.6.taz]
           ro.NHW_ALL_PS =  MZProda[4][di.6.taz]
           ro.NHO_ALL_PS =  MZProda[5][di.6.taz]

           ro.HBWMTRP_I1 =  0
           ro.HBSMTRP_I1 =  0
           ro.HBOMTRP_I1 =  0

           ro.HBWMTRP_I2 =  0
           ro.HBSMTRP_I2 =  0
           ro.HBOMTRP_I2 =  0

           ro.HBWMTRP_I3 =  0
           ro.HBSMTRP_I3 =  0
           ro.HBOMTRP_I3 =  0

           ro.HBWMTRP_I4 =  0
           ro.HBSMTRP_I4 =  0
           ro.HBOMTRP_I4 =  0


         WRITE RECO=1


 ro.TAZ = di.6.taz
 ro.HBW_Mtr_As =  MZAttra[1][di.6.taz]
 ro.HBW_NMt_As =  0.0
 ro.HBW_All_As =  MZAttra[1][di.6.taz]

 ro.HBWMtrA_I1 = 0.0
 ro.HBWMtrA_I2 = 0.0
 ro.HBWMtrA_I3 = 0.0
 ro.HBWMtrA_I4 = 0.0

 ro.HBS_Mtr_As =  MZAttra[2][di.6.taz]
 ro.HBS_NMt_As =  0.0
 ro.HBS_All_As =  MZAttra[2][di.6.taz]

 ro.HBSMtrA_I1 = 0.0
 ro.HBSMtrA_I2 = 0.0
 ro.HBSMtrA_I3 = 0.0
 ro.HBSMtrA_I4 = 0.0

 ro.HBO_Mtr_As =  MZAttra[3][di.6.taz]
 ro.HBO_NMt_As =  0.0
 ro.HBO_All_As =  MZAttra[3][di.6.taz]

 ro.HBOMtrA_I1 =  0.0
 ro.HBOMtrA_I2 =  0.0
 ro.HBOMtrA_I3 =  0.0
 ro.HBOMtrA_I4 =  0.0

 ro.NHW_Mtr_As =  MZAttra[4][di.6.taz]
 ro.NHW_NMt_As =  0.0
 ro.NHW_All_As =  MZAttra[4][di.6.taz]

 ro.NHO_Mtr_As =  MZAttra[5][di.6.taz]
 ro.NHO_NMt_As =  0.0
 ro.NHO_All_As =  MZAttra[5][di.6.taz]

 WRITE RECO=2

 ENDLOOP




  TotExtPs = XMTotProda[1] + XMTotProda[2] + XMTotProda[3] + XMTotProda[4] + XMTotProda[5]
  TotExtAs = XMTotAttra[1] + XMTotAttra[2] + XMTotAttra[3] + XMTotAttra[4] + XMTotAttra[5]


;;==========================================================================================================================
;; Print out computed trip productions:

;; -------------------------------------------------------------------------------

   PRINT PRINTO=1 form=10.0csv list = ' Regional TOTAL (II,IX) COMPUTED PERSON TRIP PRODUCTIONS SUMMARY - INTERNAL TAZs    '
   PRINT PRINTO=1 form=10.0csv list = '                HBW        HBS       HBO         NHW       NHO       TOTAL   '
   PRINT PRINTO=1 form=10.0csv list = '            ---------- ---------- ---------- ---------- ---------- ----------'
   PRINT PRINTO=1 form=10.0csv list = ' Motorized  ',  MtotProda[1],' ',  MtotProda[2],' ',  MtotProda[3],' ',  MtotProda[4],' ',  MtotProda[5],' ',  MtotProd
   PRINT PRINTO=1 form=10.0csv list = ' Non-Motor. ', NMtotProda[1],' ', NMtotProda[2],' ', NMtotProda[3],' ', NMtotProda[4],' ', NMtotProda[5],' ', NMtotProd
   PRINT PRINTO=1 form=10.0csv list = ' Total      ',MNMtotProda[1],' ',MNMtotProda[2],' ',MNMtotProda[3],' ',MNMtotProda[4],' ',MNMtotProda[5],' ',MNMtotProd
   PRINT PRINTO=1 form=10.0csv list = '     '
   PRINT PRINTO=1 form=10.0csv list = '     '
 ;; end


;; ---------------------------------------------------------------------------------------------------------------------------------
;; print out Total (I-I and I-X,Motorized, NonMotorized) Attractions Tables- by Income

   PRINT PRINTO=1 form=10.0csv list = ' Regional TOTAL (II,XI) COMPUTED PERSON TRIP ATTRACTIONS SUMMARY - INTERNAL TAZs    '
   PRINT PRINTO=1 form=10.0csv list = '                HBW        HBS       HBO         NHW       NHO       TOTAL   '
   PRINT PRINTO=1 form=10.0csv list = '            ---------- ---------- ---------- ---------- ---------- ----------'
   PRINT PRINTO=1 form=10.0csv list = ' Motorized  ',  MtotAttra[1],' ',  MtotAttra[2],' ',  MtotAttra[3],' ',  MtotAttra[4],' ',  MtotAttra[5],' ',  MtotAttr
   PRINT PRINTO=1 form=10.0csv list = ' Non-Motor. ', NMtotAttra[1],' ', NMtotAttra[2],' ', NMtotAttra[3],' ', NMtotAttra[4],' ', NMtotAttra[5],' ', NMtotAttr
   PRINT PRINTO=1 form=10.0csv list = ' Total      ',MNMtotAttra[1],' ',MNMtotAttra[2],' ',MNMtotAttra[3],' ',MNMtotAttra[4],' ',MNMtotAttra[5],' ',MNMtotAttr
   PRINT PRINTO=1 form=10.0csv list = '     '
   PRINT PRINTO=1 form=10.0csv list = '     '
 ;; end
;; Print out computed Exteranl Trips from the External File :

;; -------------------------------------------------------------------------------

   PRINT PRINTO=1 form=10.0csv list = ' EXTERNAL PERSON TRIPS FROM THE EXTERNAL TRIP FILE INPUT                     '
   PRINT PRINTO=1 form=10.0csv list = '                HBW        HBS       HBO         NHW       NHO       TOTAL   '
   PRINT PRINTO=1 form=10.0csv list = '            ---------- ---------- ---------- ---------- ---------- ----------'
   PRINT PRINTO=1 form=10.0csv list = ' X-I Trips  ',XMTotProda[1],' ',XMTotProda[2],' ',XMTotProda[3],' ',XMTotProda[4],' ',XMTotProda[5],' ',TotExtPs
   PRINT PRINTO=1 form=10.0csv list = ' I-X Trips  ',XMTotAttra[1],' ',XMTotAttra[2],' ',XMTotAttra[3],' ',XMTotAttra[4],' ',XMTotAttra[5],' ',TotExtAs





print list = '  HBW attrs ',  TotHBWCompAtt,
             '  HBS attrs ',  TotHBSCompAtt,
             '  HBO attrs ',  TotHBOCompAtt,
             '  NHW attrs ',  TotNHWCompAtt,
             '  NHO attrs ',  TotNHOCompAtt




;;
;; -------------------------------------------------------------------------------
;; print out Total (I-I and I-X,Motorized, NonMotorized) Productions Tables- by Income

   PRINT PRINTO=1 form=10.0csv list = ' Regional Total (I-I,I-X & Motorized, NonMotorized) Trip Productions Summary by Income '
   PRINT PRINTO=1 form=10.0csv list = '              Income_1   Income_2   Income_3   Income_4     Sum   '
   PRINT PRINTO=1 form=10.0csv list = '            ---------- ---------- ---------- ---------- ----------'
   PRINT PRINTO=1 form=10.0csv list = ' HHs:       ',  I_HHa[1]   ,' ',I_HHa[2]     ,' ',I_HHa[3]     ,' ',I_HHa[4]     ,' ',TOTHHa
   PRINT PRINTO=1 form=10.0csv list = ' HBW Trips: ',I_Proda[1][1],' ',I_Proda[2][1],' ',I_Proda[3][1],' ',I_Proda[4][1],' ',TOTProda[1]
   PRINT PRINTO=1 form=10.0csv list = ' HBS Trips: ',I_Proda[1][2],' ',I_Proda[2][2],' ',I_Proda[3][2],' ',I_Proda[4][2],' ',TOTProda[2]
   PRINT PRINTO=1 form=10.0csv list = ' HBO Trips: ',I_Proda[1][3],' ',I_Proda[2][3],' ',I_Proda[3][3],' ',I_Proda[4][3],' ',TOTProda[3]
   PRINT PRINTO=1 form=10.0csv list = ' NHW Trips: ',I_Proda[1][4],' ',I_Proda[2][4],' ',I_Proda[3][4],' ',I_Proda[4][4],' ',TOTProda[4]
   PRINT PRINTO=1 form=10.0csv list = ' NHO Trips: ',I_Proda[1][5],' ',I_Proda[2][5],' ',I_Proda[3][5],' ',I_Proda[4][5],' ',TOTProda[5]
   PRINT PRINTO=1 form=10.0csv list = '            ---------- ---------- ---------- ---------- ----------'
   PRINT PRINTO=1 form=10.0csv list = '     '
 ;; end

;; print out Total Productions Tables- by Size

   PRINT PRINTO=1 form=10.0csv list = ' Regional Total (I-I,I-X & Motorized, NonMotorized) Trip Productions Summary by Size   '
   PRINT PRINTO=1 form=10.0csv list = '                Size_1     Size_2     Size_3     Size_4      Sum   '
   PRINT PRINTO=1 form=10.0csv list = '            ---------- ---------- ---------- ----------  ----------'
   PRINT PRINTO=1 form=10.0csv list = ' HHs:       ',  S_HHa[1]   ,' ',S_HHa[2]     ,' ',S_HHa[3]     ,' ',S_HHa[4]     ,' ',TOTHHa
   PRINT PRINTO=1 form=10.0csv list = ' HBW Trips: ',S_Proda[1][1],' ',S_Proda[2][1],' ',S_Proda[3][1],' ',S_Proda[4][1],' ',TOTProda[1]
   PRINT PRINTO=1 form=10.0csv list = ' HBS Trips: ',S_Proda[1][2],' ',S_Proda[2][2],' ',S_Proda[3][2],' ',S_Proda[4][2],' ',TOTProda[2]
   PRINT PRINTO=1 form=10.0csv list = ' HBO Trips: ',S_Proda[1][3],' ',S_Proda[2][3],' ',S_Proda[3][3],' ',S_Proda[4][3],' ',TOTProda[3]
   PRINT PRINTO=1 form=10.0csv list = ' NHW Trips: ',S_Proda[1][4],' ',S_Proda[2][4],' ',S_Proda[3][4],' ',S_Proda[4][4],' ',TOTProda[4]
   PRINT PRINTO=1 form=10.0csv list = ' NHO Trips: ',S_Proda[1][5],' ',S_Proda[2][5],' ',S_Proda[3][5],' ',S_Proda[4][5],' ',TOTProda[5]
   PRINT PRINTO=1 form=10.0csv list = '            ---------- ---------- ---------- ---------- ----------'
   PRINT PRINTO=1 form=10.0csv list = '     '
 ;; end

;; print out Total Productions Tables- by Size

   PRINT PRINTO=1 form=10.0csv list = ' Regional Total (I-I,I-X & Motorized, NonMotorized) Trip Productions Summary by Vehicles '
   PRINT PRINTO=1 form=10.0csv list = '                0_Vehs     1_Veh      2_Vehs     3+Vehs      Sum   '
   PRINT PRINTO=1 form=10.0csv list = '            ---------- ---------- ---------- ----------  ----------'
   PRINT PRINTO=1 form=10.0csv list = ' HHs:       ',  V_HHa[1]   ,' ',V_HHa[2]     ,' ',V_HHa[3]     ,' ',V_HHa[4]     ,' ',TOTHHa
   PRINT PRINTO=1 form=10.0csv list = ' HBW Trips: ',V_Proda[1][1],' ',V_Proda[2][1],' ',V_Proda[3][1],' ',V_Proda[4][1],' ',TOTProda[1]
   PRINT PRINTO=1 form=10.0csv list = ' HBS Trips: ',V_Proda[1][2],' ',V_Proda[2][2],' ',V_Proda[3][2],' ',V_Proda[4][2],' ',TOTProda[2]
   PRINT PRINTO=1 form=10.0csv list = ' HBO Trips: ',V_Proda[1][3],' ',V_Proda[2][3],' ',V_Proda[3][3],' ',V_Proda[4][3],' ',TOTProda[3]
   PRINT PRINTO=1 form=10.0csv list = ' NHW Trips: ',V_Proda[1][4],' ',V_Proda[2][4],' ',V_Proda[3][4],' ',V_Proda[4][4],' ',TOTProda[4]
   PRINT PRINTO=1 form=10.0csv list = ' NHO Trips: ',V_Proda[1][5],' ',V_Proda[2][5],' ',V_Proda[3][5],' ',V_Proda[4][5],' ',TOTProda[5]
   PRINT PRINTO=1 form=10.0csv list = '            ---------- ---------- ---------- ---------- ----------'
   PRINT PRINTO=1 form=10.0csv list = '     '
 ;; end

      print list =' idx      ','     HHInc','     IncPs','     Irate','     HHsiz','     sizPs','     Srate','     HHVeh','     VehPs','     Vrate', file=dud.dat
loop m= 1,4
      irate= TotProdInca[m]/I_HHa[m] srate= TotProdSiza[m]/S_HHa[m] vrate= TotProdVeha[m]/V_HHa[m]

      print form = 10.0 list =  m, I_HHa[m], TotProdInca[m], irate(10.2), S_HHa[m],TotProdSiza[m], srate(10.2), V_HHa[m], TotProdVeha[m],vrate, file=dud.dat
endloop



;;
;; -------------------------------------------------------------------------------
;;
ENDIF ;; If at last TAZ


ENDRUN
*copy voya*.prn mod2.rpt
