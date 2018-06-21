*del voya*.prn
;
;=====================================================================================================
;  Prepare_Ext_Auto_Ends.s                                                                           =
;  This process prepares Auto-related external Ps, As for the External Trip Distribution Process     =
;  The zonal level internal Ps & As are scaled (or balanced) to match external As & Ps, respectively =
;=====================================================================================================

ZONESIZE       =  3722                       ;  No. of TAZs
Purps          =  5                          ;  No. of purposes
LastIZn        =  3675                       ;  Last Internal TAZ no.
Scaled_IntPsAs ='%_iter_%_Ext_Trip_Gen_PsAs.dbf'  ;; OUTPUT external zonal Ps,As file, HBW,HBS,HBO,NHW,NHO purposes

RUN PGM=MATRIX
ZONES=1

Fileo printo[1] ='%_iter_%_Ext_Trip_Gen_PsAs.txt' ;; report file

Array ZProdA   = 5,3722     ; input zonal productions array /Unscaled
Array ZAttrA   = 5,3722     ; input zonal attractions array /Unscaled

Array S_ZProdA = 5,3722     ; output zonal productions /  intls  scaled to extl attr. totals
Array S_ZAttrA = 5,3722     ; output zonal attractions /  intls  scaled to extl prod. totals

Array TotProda=5, IntProda=5, ExtProda=5, TotscaleP=5, TotscaleA=5
Array TotAttra=5, IntAttra=5, ExtAttra=5, Pscale=5,Ascale=5, IntScaleP=5, IntScaleA=5

;; INPUT Zonal trip productions
FILEI DBI[1] = "%_iter_%_Trip_Gen_productions_Comp.dbf"
;; variables in file:
;;TAZ     HBW_MTR_PS      HBW_NMT_PS      HBW_ALL_PS      HBWMTRP_I1      HBWMTRP_I2      HBWMTRP_I3      HBWMTRP_I4
;;        HBS_MTR_PS      HBS_NMT_PS      HBS_ALL_PS      HBSMTRP_I1      HBSMTRP_I2      HBSMTRP_I3      HBSMTRP_I4
;;        HBO_MTR_PS      HBO_NMT_PS      HBO_ALL_PS      HBOMTRP_I1      HBOMTRP_I2      HBOMTRP_I3      HBOMTRP_I4
;;        NHW_MTR_PS      NHW_NMT_PS      NHW_ALL_PS      NHO_MTR_PS      NHO_NMT_PS      NHO_ALL_PS

;;INPUT Zonal final/scaled trip attractions
FILEI DBI[2] = "%_iter_%_Trip_Gen_Attractions_Comp.dbf"
;; variables in file:
;;TAZ     HBW_MTR_AS      HBW_NMT_AS      HBW_ALL_AS      HBWMTRA_I1      HBWMTRA_I2      HBWMTRA_I3      HBWMTRA_I4
;;        HBS_MTR_AS      HBS_NMT_AS      HBS_ALL_AS      HBSMTRA_I1      HBSMTRA_I2      HBSMTRA_I3      HBSMTRA_I4
;;        HBO_MTR_AS      HBO_NMT_AS      HBO_ALL_AS      HBOMTRA_I1      HBOMTRA_I2      HBOMTRA_I3      HBOMTRA_I4
;;        NHW_MTR_AS      NHW_NMT_AS      NHW_ALL_AS      NHO_MTR_AS      NHO_NMT_AS      NHO_ALL_AS



;; Read productions into zonal array and accumulate, totals, internals, and externals by purpose
LOOP K = 1,dbi.1.NUMRECORDS
         x = DBIReadRecord(1,k)
              ZProda[1][di.1.TAZ]    =   di.1.HBW_Mtr_Ps
              ZProda[2][di.1.TAZ]    =   di.1.HBS_Mtr_Ps
              ZProda[3][di.1.TAZ]    =   di.1.HBO_Mtr_Ps
              ZProda[4][di.1.TAZ]    =   di.1.NHW_Mtr_Ps
              ZProda[5][di.1.TAZ]    =   di.1.NHO_Mtr_Ps

;;       Accumulate total, internal and external P's by purpose
              TotProda[1]  =  TotProda[1]  +  ZProda[1][di.1.TAZ]
              TotProda[2]  =  TotProda[2]  +  ZProda[2][di.1.TAZ]
              TotProda[3]  =  TotProda[3]  +  ZProda[3][di.1.TAZ]
              TotProda[4]  =  TotProda[4]  +  ZProda[4][di.1.TAZ]
              TotProda[5]  =  TotProda[5]  +  ZProda[5][di.1.TAZ]
              TotProdaSum  =  TotProdaSum  +  ZProda[1][di.1.TAZ] + ZProda[2][di.1.TAZ] + ZProda[3][di.1.TAZ] + ZProda[4][di.1.TAZ] + ZProda[5][di.1.TAZ]

          IF (K <= @LastIZn@)
              IntProda[1]  =  IntProda[1]  +  ZProda[1][di.1.TAZ]
              IntProda[2]  =  IntProda[2]  +  ZProda[2][di.1.TAZ]
              IntProda[3]  =  IntProda[3]  +  ZProda[3][di.1.TAZ]
              IntProda[4]  =  IntProda[4]  +  ZProda[4][di.1.TAZ]
              IntProda[5]  =  IntProda[5]  +  ZProda[5][di.1.TAZ]
              IntProdaSum  =  IntProdaSum  +  ZProda[1][di.1.TAZ] + ZProda[2][di.1.TAZ] + ZProda[3][di.1.TAZ] + ZProda[4][di.1.TAZ] + ZProda[5][di.1.TAZ]
           ELSE
              ExtProda[1]  =  ExtProda[1]  +  ZProda[1][di.1.TAZ]
              ExtProda[2]  =  ExtProda[2]  +  ZProda[2][di.1.TAZ]
              ExtProda[3]  =  ExtProda[3]  +  ZProda[3][di.1.TAZ]
              ExtProda[4]  =  ExtProda[4]  +  ZProda[4][di.1.TAZ]
              ExtProda[5]  =  ExtProda[5]  +  ZProda[5][di.1.TAZ]
              ExtProdaSum  =  ExtProdaSum  +  ZProda[1][di.1.TAZ] + ZProda[2][di.1.TAZ] + ZProda[3][di.1.TAZ] + ZProda[4][di.1.TAZ] + ZProda[5][di.1.TAZ]
          ENDIF
 ENDLOOP

;; Read attractions into zonal array and accumulate, totals, internals, and externals by purpose
LOOP K = 1,dbi.2.NUMRECORDS
         x = DBIReadRecord(2,k)
              ZAttra[1][di.2.TAZ]    =   di.2.HBW_Mtr_As
              ZAttra[2][di.2.TAZ]    =   di.2.HBS_Mtr_As
              ZAttra[3][di.2.TAZ]    =   di.2.HBO_Mtr_As
              ZAttra[4][di.2.TAZ]    =   di.2.NHW_Mtr_As
              ZAttra[5][di.2.TAZ]    =   di.2.NHO_Mtr_As

;;       Accumulate total, internal and external P's by purpose
              TotAttra[1]  =  TotAttra[1]  +  ZAttra[1][di.2.TAZ]
              TotAttra[2]  =  TotAttra[2]  +  ZAttra[2][di.2.TAZ]
              TotAttra[3]  =  TotAttra[3]  +  ZAttra[3][di.2.TAZ]
              TotAttra[4]  =  TotAttra[4]  +  ZAttra[4][di.2.TAZ]
              TotAttra[5]  =  TotAttra[5]  +  ZAttra[5][di.2.TAZ]
              TotAttraSum  =  TotAttraSum  +  ZAttra[1][di.2.TAZ] + ZAttra[2][di.2.TAZ] + ZAttra[3][di.2.TAZ] + ZAttra[4][di.2.TAZ] + ZAttra[5][di.2.TAZ]

          IF (K <= @LastIZn@)
              IntAttra[1]  =  IntAttra[1]  +  ZAttra[1][di.2.TAZ]
              IntAttra[2]  =  IntAttra[2]  +  ZAttra[2][di.2.TAZ]
              IntAttra[3]  =  IntAttra[3]  +  ZAttra[3][di.2.TAZ]
              IntAttra[4]  =  IntAttra[4]  +  ZAttra[4][di.2.TAZ]
              IntAttra[5]  =  IntAttra[5]  +  ZAttra[5][di.2.TAZ]
              IntAttraSum  =  IntAttraSum  +  ZAttra[1][di.2.TAZ] + ZAttra[2][di.2.TAZ] + ZAttra[3][di.2.TAZ] + ZAttra[4][di.2.TAZ] + ZAttra[5][di.2.TAZ]
           ELSE
              ExtAttra[1]  =  ExtAttra[1]  +  ZAttra[1][di.2.TAZ]
              ExtAttra[2]  =  ExtAttra[2]  +  ZAttra[2][di.2.TAZ]
              ExtAttra[3]  =  ExtAttra[3]  +  ZAttra[3][di.2.TAZ]
              ExtAttra[4]  =  ExtAttra[4]  +  ZAttra[4][di.2.TAZ]
              ExtAttra[5]  =  ExtAttra[5]  +  ZAttra[5][di.2.TAZ]
              ExtAttraSum  =  ExtAttraSum  +  ZAttra[1][di.2.TAZ] + ZAttra[2][di.2.TAZ] + ZAttra[3][di.2.TAZ] + ZAttra[4][di.2.TAZ] + ZAttra[5][di.2.TAZ]
          ENDIF
 ENDLOOP

;; compute scaling  factors by purpose

    Loop pp= 1, @Purps@

         If (IntProda[pp]!= 0)  Pscale[pp] = ExtAttra[pp]/IntProda[pp]
         If (IntAttra[pp]!= 0)  Ascale[pp] = ExtProda[pp]/IntAttra[pp]

    ENDLOOP

;;print input P/A results by intl, external groups
   print printo=1            List =  ' Listing of INPUT P/A Totals by Purpose and computed scaling factors '
   print printo= 1 form=12.2 list = '            '

   print printo =1              list = ' Purpose>>>                     ','            HBW              HBS            HBO             NHW             NHO             ALL'
   print printo= 1              list = '            '
   print printo= 1 form=16.2csv list = ' Total Internal  Ps by purpose: ', IntProda[1],  IntProda[2], IntProda[3], IntProda[4], IntProda[5],  IntProdaSum
   print printo= 1 form=16.2csv list = ' Total External  Ps by purpose: ', ExtProda[1],  ExtProda[2], ExtProda[3], ExtProda[4], ExtProda[5],  ExtProdaSum
   print printo= 1 form=16.2csv list = ' Total Intl&Extl Ps by purpose: ', TotProda[1],  TotProda[2], TotProda[3], TotProda[4], TotProda[5],  TotProdaSum
   print printo= 1              list = '            '
   print printo= 1 form=16.2csv list = ' Total Internal  As by purpose: ', IntAttra[1],  IntAttra[2], IntAttra[3], IntAttra[4], IntAttra[5],  IntAttraSum
   print printo= 1 form=16.2csv list = ' Total External  As by purpose: ', ExtAttra[1],  ExtAttra[2], ExtAttra[3], ExtAttra[4], ExtAttra[5],  ExtAttraSum
   print printo= 1 form=16.2csv list = ' Total Intl&Extl As by purpose: ', TotAttra[1],  TotAttra[2], TotAttra[3], TotAttra[4], TotAttra[5],  TotAttraSum
   print printo= 1              list = '            '
   print printo= 1 form=16.6csv list = 'Prod_scale fts ExtAs/IntlPs:    ',   Pscale[1], Pscale[2], Pscale[3], Pscale[4], Pscale[5]
   print printo= 1 form=16.6csv list = 'Attr_scale fts ExtPs/ExtlPs:    ',   Ascale[1], Ascale[2], Ascale[3], Ascale[4], Ascale[5]
   print printo= 1              list = '            '
   print printo= 1              list = '            '
   print printo= 1              list = '            '


;;set up out file


 ;; DEFINE OUTPUT FILE & VARIABLES
 FILEO RECO[1]    = "@Scaled_IntPsAs@",
                     fields = TAZ(5),
                              SHBW_MtrPs(15.2), SHBS_MtrPs(15.2), SHBO_MtrPs(15.2), SNHW_MtrPs(15.2), SNHO_MtrPs(15.2),
                              SHBW_MtrAs(15.2), SHBS_MtrAs(15.2), SHBO_MtrAs(15.2), SNHW_MtrAs(15.2), SNHO_MtrAs(15.2),
                              NHWIIAs(15.2), NHOIIAs(15.2)

 ;;
 ;; Now loop through each internal TAZ and
 ;;   1)  scale INT Attractions to EXT productions
 ;;   2)  scale INT Productions to EXT attractions
 ;;   3)  write out scaled/INT Ps As and unscaled EXT P's, As

 Loop zz= 1, @ZONESIZE@

    Loop pp= 1, @Purps@

          IF (zz <= @LastIZn@)      ;;if TAZ is internal, then scale and accumulate
            S_ZProda[pp][zz] =  ZProda[pp][zz] *   Pscale[pp]
            S_ZAttra[pp][zz] =  ZAttra[pp][zz] *   Ascale[pp]

;;          accumulate scaled internal Ps, As by purpose and for total
            IntScaleP[pp] = IntScaleP[pp] +   S_ZProda[pp][zz]
            IntScaleA[pp] = IntScaleA[pp] +   S_ZAttra[pp][zz]

            IntScalePSum  = IntScalePSum  +   S_ZProda[pp][zz]
            IntScaleASum  = IntScaleASum  +   S_ZAttra[pp][zz]

           ELSE                    ;; Else TAZ is external, final scaled P/S equals input P,A
             S_ZProda[pp][zz] =  ZProdA[pp][zz]
             S_ZAttra[pp][zz] =  ZAttrA[pp][zz]

          ENDIF                    ;;
            ;; Accum. total of scaled intls and untouched extls for reporting, by purpose and for total
            TotScaleP[pp] = TotScaleP[pp] +   S_ZProda[pp][zz]
            TotScaleA[pp] = TotScaleA[pp] +   S_ZAttra[pp][zz]

            TotScalePSum  = TotScalePSum  +   S_ZProda[pp][zz]
            TotScaleASum  = TotScaleASum  +   S_ZAttra[pp][zz]
    ENDLOOP




;;       Write out the unscaled and scaled Ps,As by purpose
;;       The scaled internal productions will equal the sum of external attractions
;;       The scaled internal attractions will equal the sum of external productions
;;       The external Ps, As will remain unchanged
          ro.TAZ        =  zz
          ro.SHBW_MtrPs = S_ZProda[1][zz]
          ro.SHBS_MtrPs = S_ZProda[2][zz]
          ro.SHBO_MtrPs = S_ZProda[3][zz]
          ro.SNHW_MtrPs = S_ZAttra[4][zz]
          ro.SNHO_MtrPs = S_ZAttra[5][zz]

          ro.SHBW_MtrAs = S_ZAttra[1][zz]
          ro.SHBS_MtrAs = S_ZAttra[2][zz]
          ro.SHBO_MtrAs = S_ZAttra[3][zz]
          ro.SNHW_MtrAs = S_ZAttra[4][zz]
          ro.SNHO_MtrAs = S_ZAttra[5][zz]

          IF (ZZ <= @LastIZn@)
                ro.NHWIIAs = ZAttra[4][zz]
                ro.NHOIIAs = ZAttra[5][zz]
            ELSE
                ro.NHWIIAs = 0.0
                ro.NHOIIAs = 0.0
          ENDIF


          WRITE RECO=1

ENDLOOP



print printo=1            List =  ' Listing of OUTPUT P/A Totals by purpose to be used in the External Trip Distribution Process '
;;print input P/A results by intl, external groups

   print printo= 1              list = '            '
   print printo =1              list = ' Purpose>>>                     ','            HBW              HBS            HBO             NHW             NHO             ALL'
   print printo= 1              list = '            '
   print printo= 1 form=16.2csv list = ' Internal Ps, scaled to Extl As:', IntScaleP[1], IntScaleP[2],IntScaleP[3], IntScaleP[4], IntScaleP[5],  IntScalePSum
   print printo= 1 form=16.2csv list = ' External Ps by purpose:        ',  ExtProda[1],  ExtProda[2], ExtProda[3], ExtProda[4],  ExtProda[5],   ExtProdaSum
   print printo= 1 form=16.2csv list = ' Total    Ps by purpose:        ', TotScaleP[1], TotScaleP[2],TotScaleP[3], TotScaleP[4], TotScaleP[5],  TotScalePSum
   print printo= 1              list = '            '
   print printo= 1 form=16.2csv list = ' Internal As, scaled to Extl Ps:', IntScaleA[1], IntScaleA[2],IntScaleA[3], IntScaleA[4], IntScaleA[5],  IntScaleASum
   print printo= 1 form=16.2csv list = ' Total External  As by purpose: ',  ExtAttra[1],  ExtAttra[2], ExtAttra[3], ExtAttra[4],  ExtAttra[5],   ExtAttraSum
   print printo= 1 form=16.2csv list = ' Total Intl&Extl As by purpose: ', TotScaleA[1], TotScaleA[2],TotScaleA[3], TotScaleA[4], TotScaleA[5],  TotScaleASum
   print printo= 1              list = '            '

ENDRUN
*copy voya*.prn mod2.rpt
