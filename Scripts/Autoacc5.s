*del voya*.prn
; AutoAcc5.s - auto access link development - based on AutoAcc4.for from AECOM
; 2010-10-22  Previously, only bus PNR links were built to bus PNR & bus KNR paths.
;             Now, we have created bus KNR access links from TAZ to bus stop node,
;             instead of TAZ to PNR node (rjm/msm)
; 2012-12-03 File names have been made more consistent (msm)
;   -------------------------------------------------------
; 2016-03-29(rjm):
;    * Corrected problem causing erroneous PNR connections from the "CBD TAZ" 
;             Changed the line:
;                     TAZCBDDist =  dcbd/52.8
;             To this:
;                     IF (I=@NCBD@)
;                        TAZCBDDist = 0.001
;                      ELSE
;                       TAZCBDDist =  dcbd/52.8
;                     ENDIF
;   ----------------------------------------------------------
;    * Disabled "BackD" & "BackPC" params which are unused           
;   ----------------------------------------------------------
;   ----------------------------------------------------------
;    * Changed "CBD TAZ" (@NCBD@) from 35 to 8, per 3722 TAZ system           
;   ----------------------------------------------------------
;
; Dimensions:
;
TAZSTASize  = 7000
IZsize      = 3675
FrstStaCen  = 5001
Stasize     = 1000


;;Input Files:
  AMSkimFile  =  'am_sov_mod.skm'
  OPSkimFile  =  'md_sov_mod.skm'
;
  Sta_File    =  'inputs\Station.dbf'  ; Std. Station file
  StaAccFile  =  'inputs\StaAcc.dbf'   ; Station mode-station type-max access dist. lookup
  JurisFile   =  'inputs\Jur.dbf'      ; juris code- juris group lookup
  PentFile    =  'inputs\Pen.dbf'      ; TAZ in Pentagon's 'slug' shed
  TNodeFile   =  'TAZ_xys.dbf'         ; TAZ XY Crd. file
  Zonefile    =  'inputs\ZONE.dbf'     ; zonal land use file w/ jur code
;
; Output Files:
  M_Pnr_AM    =  'met_am_pnr.asc' ;unit 21
  M_Knr_AM    =  'met_am_knr.asc' ;     22
  C_Pnr_AM    =  'com_am.asc'     ;     23
  B_Pnr_AM    =  'bus_am_pnr.asc' ;     24 renamed file
  B_Knr_AM    =  'bus_am_knr.asc' ;     new file
  L_Pnr_AM    =  'lrt_am_pnr.asc' ;     25
  N_Pnr_AM    =  'new_am_pnr.asc' ;     26
  L_Knr_AM    =  'lrt_am_knr.asc' ;     43
  N_Knr_AM    =  'new_am_knr.asc' ;     44

  M_Pnr_OP    =  'met_op_pnr.asc' ;unit 21
  M_Knr_OP    =  'met_op_knr.asc' ;     22
  C_Pnr_OP    =  'com_op.asc'     ;     23
  B_Pnr_OP    =  'bus_op_pnr.asc' ;     24 renamed file
  B_Knr_OP    =  'bus_op_knr.asc' ;     new file
  L_Pnr_OP    =  'lrt_op_pnr.asc' ;     25
  N_Pnr_OP    =  'new_op_pnr.asc' ;     26
  L_Knr_OP    =  'lrt_op_knr.asc' ;     43
  N_Knr_OP    =  'new_op_knr.asc' ;     44
;
  AutoAll     =  'auto_all.asc' ;      40
;
; Params:
;;BackD   = 1000.00       ;  disabled param/ not used 
;;BackPC  =    0.30       ;  disabled param/ not used 
  Divpc     =    1.30     ;  Diversion tolerance of the ratio:  [TAZ/PNR Dist + PNR/CBDTAZ Dist] / TAZ/CBDTAZ Dist
  NCBD      =       8     ;  Representative TAZ of the region's CBD - TAZ 8 (Ellipse)

RUN PGM=MATRIX

ZONES=@TAZStaSize@
FILEI DBI[1]     ="@Sta_File@"
FILEI DBI[2]     ="@ZoneFile@"
FILEI DBI[3]     ="@TNODEFILE@"
FILEI DBI[4]     ="@StaAccFile@"


FileI LOOKUPI[1] = "@PentFile@"
FileI LOOKUPI[2] = "@JurisFile@"

FILEI MATI[1]    =  @AMSKIMFile@
FILEI MATI[2]    =  @OPSKIMFile@

MW[101]  = mi.1.1  mw[102] = mi.1.2    ; am time, dist
MW[201]  = mi.2.1  mw[202] = mi.2.2    ; op time, dist


FILEO PRINTO[1] = @AutoAll@

FILEO PRINTO[2]  =@M_Knr_AM@
FILEO PRINTO[3]  =@M_Knr_OP@

FILEO PRINTO[4]  =@M_Pnr_AM@
FILEO PRINTO[5]  =@M_Pnr_OP@

FILEO PRINTO[6]  =@C_Pnr_AM@
FILEO PRINTO[7]  =@C_Pnr_OP@

FILEO PRINTO[8]  =@B_Pnr_AM@
FILEO PRINTO[9]  =@B_Pnr_OP@

FILEO PRINTO[10] =@L_Pnr_AM@
FILEO PRINTO[11] =@L_Pnr_OP@
FILEO PRINTO[12] =@L_Knr_AM@
FILEO PRINTO[13] =@L_Knr_OP@

FILEO PRINTO[14] =@N_Pnr_AM@
FILEO PRINTO[15] =@N_Pnr_OP@
FILEO PRINTO[16] =@N_Knr_AM@
FILEO PRINTO[17] =@N_Knr_OP@

FILEO PRINTO[18]  =@B_Knr_AM@
FILEO PRINTO[19]  =@B_Knr_OP@

ARRAY  Type=c1  MM          = @STASize@,
                STAPARK     = @STASize@,
                STAUSE      = @STASize@,
                MODE        = 14

ARRAY  NCT         = @STASize@,
       STAT        = @STASize@,
       STAP        = @STASize@,
       STAN1       = @STASize@,
       STAC        = @STASize@,
       STAZ        = @STASize@,
       STAX        = @STASize@,
       STAY        = @STASize@,
       STAD        = @STASize@,
       ST_J        = @STASize@

      ;SNAME       = @STASize@,   ;c27
      ;STAN2       = @STASize@,
      ;STAN3       = @STASize@,
      ;STAN4       = @STASize@,
      ;STAPCAP     = @STASize@,
      ;STAC        = @STASize@,
      ;STAZ        = @STASize@,
      ;STAPKCost   = @STASize@,
      ;STAOPCost   = @STASize@,
      ;STAPKShad   = @STASize@,
      ;STAOPShad   = @STASize@,
      ;FirstYr     = @STASize@

ARRAY  JurCode     = @IZSIZE@,
       JurGrp      = @IZSize@,
       JurAcc      = @IZSize@,
       PentTAZ     = @IZSize@,
       TazX        = @IZSize@,
       TazY        = @IZSize@,
       AccDIST     = 14,
       AccCode     = 14


;; Lookup list of origin TAZ's in the 'slug shed' of the Pentagon
   Lookup Lookupi=1, name = PentNodes,
          Lookup[1] = PentNode, result=Seqn, Interpolate=N, List=Y , fail=0,0,0


;; Lookup equivalence of Juris codes (0-23) and Access Groups
   Lookup Lookupi=2, name = JurAcceqv,
                    Lookup[1] = Jur_Code, result=AccGrp, Interpolate=N, List=Y, fail=0,0,0

; Fill Access Code/distance 'lookup' Array
LOOP K = 1,dbi.4.NUMRECORDS
       x = DBIReadRecord(4,k)
          idx              = dbi.4.recno

          Mode[idx]        = di.4.Mode
          AccCode[idx]     = di.4.AccCode
          AccDist[idx]     = di.4.AccDist
ENDLOOP

; Fill in  Station Array
LOOP K = 1,dbi.1.NUMRECORDS
      x = DBIReadRecord(1,k)
          idx         = dbi.1.recno
          STACx       = di.1.STAC
          STAZx       = di.1.STAZ
          MMx         = di.1.MM


          IF (MMx = 'M' || MMx = 'C')
                  Ino  = STACx
           ELSE
                  Ino  = STAZx
          ENDIF

          MM[idx]     = di.1.MM
          NCT[idx]    = di.1.NCT
          STAPARK[idx]= di.1.STAPARK
          STAUSE[idx] = di.1.STAUSE
          STAT[idx]   = di.1.STAT
          STAZ[idx]   = di.1.STAZ
          STAC[idx]   = di.1.STAC
          STAN1[idx]  = di.1.STAN1
          STAP[idx]   = di.1.STAP
          STAX[idx]   = di.1.STAX
          STAY[idx]   = di.1.STAY
          ST_J[idx]   = Ino

          STACnt      =  dbi.1.NUMRECORDS
ENDLOOP

IF (I=1)    ;---;
Loop fdx = 1,STACnt
          ;; put in default driv

          ;; Add Acc. dist to Station Array with lookup array
          STAD[fdx] = 0
          Loop L = 1,dbi.4.NUMRECORDS ; 13

               IF (MM[fDX] = Mode[L] && NCT[fdx] = AccCode[L])  STAD[fdx] = AccDist[L]

          ENDLOOP
               IF (STAPARK[fdx] != 'Y')                         STAD[fdx] = 300
               IF (STAUSE[fdx]  != 'Y')                         STAD[fdx] =   0

          IF (NCT[fdx] =  8)
                    Pentsta  = STAC[fdx]
                    Pentnode = STAT[fdx]

          ENDIF

          ;; write out transit XYs for used nodes

          IF (MM[fdx] = 'M' || MM[fdx] = 'C')
              IF (STAUSE[fdx] = 'Y')
                  print list = STAT[fDX](6), STAX[fDX](10), STAY[fDX](10),' ;  Final index: ',fdx(5), File= extra1.XY
              ENDIF
              IF (STAPARK[fdx] = 'Y')
                  print list = STAP[fDX](6), STAX[fDX](10), STAY[fDX](10),' ;  Final index: ',fdx(5), File= extra2.XY
              ENDIF
          ENDIF
          IF (MM[fdx] = 'B')
              IF (STAUSE[fdx] = 'Y')
                  print list = STAN1[fDX](6), STAX[fDX](10), STAY[fDX](10), ' ;  Final index: ',fdx(5),File= extra3.XY
              ENDIF
          ENDIF

        ;;debug1     - echo print out station data
          if (STAX[fdx] > 0)
          print form= 5.0 list =
                ' fdx: ', fdx(4),
                ' MM[fdx] ', MM[fdx],
                ' NCT[fdx] ', NCT[fdx],
                ' STAPARK[fdx] ', STAPARK[fdx],
                ' STAUSE[fdx]  ', STAUSE[fdx],
                ' STAT[fdx] ', STAT[fdx],
                ' STAZ[fdx] ', STAZ[fdx],
                ' STAC[fdx]  ', STAC[fdx],
                ' STAN1[fdx] ', STAN1[fdx],
                ' STAP[fdx]  ', STAP[fdx],
                ' STAX[fdx]  ', STAX[fdx](10),
                ' STAY[fdx]  ', STAY[fdx](10),
                ' ST_J[fdx]  ', ST_j[fdx],
                ' STAD[fdx]  ', STAD[fdx],file= debug1.asc
           endif
        ;; End debug1


 ENDLOOP

;
; Fill in  TAZ Array - jurCodes
 LOOP K = 1,dbi.2.NUMRECORDS
      x = DBIReadRecord(2,k)

          tdx           = di.2.TAZ
          IF (tdx <= @IZSize@)
            JurCode[tdx]  = di.2.JurCode               ; std juris code (0-23)
          ENDIF
 ENDLOOP

; Fill in  TAZ Array - X,Ys
 LOOP K = 1,dbi.3.NUMRECORDS
      x = DBIReadRecord(3,k)

          tdx           = di.3.N
          IF (tdx <= @IZSize@)
            TAZX[tdx]     = di.3.X
            TAZY[tdx]     = di.3.Y

            IF (tdx = @NCBD@)                         ;
                CBDX =  di.3.X                        ; X crd of CBD Taz
                CBDY =  di.3.Y                        ; Y crd of CBD TAZ
            ENDIF
            print list = tdx, tazx[tdx],tazy[tdx],pentnode, file= tazxys.dbg

          PentTAZ[tdx]= PentNodes(1,tdx)
          ENDIF
 ENDLOOP
          print list = 'CBD TAZ X,Y = ', @NCBD@,' ' cbdx,' ', cbdy ,' Pent Sta Node= ', pentsta,  file= cbd.dbg
ENDIF       ;---;

;;--------------------------------------------------------------------------
;; Now begin zonal I-Loop with binary matrices
;;--------------------------------------------------------------------------


IF  (I <= @IZSize@ )        ; if 'I's are internal TAZs'
IF  (TAZX[I] >  0)          ; if 'I's are 'Used'



LOOP STADX  =1,StaCnt     ; STADX LOOP

CurrJ=  ST_j[stadx]

IJur      = jurcode[I]
IJurAcc   = JurAcceqv(1,IJur)  ; Origin TAZ-  juris group code 1-4 (determines river crossings)

JTAZ      = STAZ[stadx]
JJur      = Jurcode[JTAZ]
JStaAcc   = JurAcceqv(1,JJur)  ; Stat.TAZ- juris group code 1-4 (determines river crossings)


;1 1 0 1 0 - original crossing array
;2 0 1 0 1
;3 1 0 1 0
;4 0 1 1 1
                                                                              ;
       IF ((IJurAcc = 1 && JStaAcc = 1) || (IJurAcc = 1 && JStaAcc = 3) ||    ;1 1 0 1 0
           (IJurAcc = 2 && JStaAcc = 2) || (IJurAcc = 2 && JStaAcc = 4) ||    ;2 0 1 0 1
           (IJurAcc = 3 && JStaAcc = 1) || (IJurAcc = 3 && JStaAcc = 3) ||    ;3 1 0 1 0
           (IJurAcc = 4 && JStaAcc = 2) || (IJurAcc = 4 && JStaAcc = 3) ||    ;4 0 1 1 1
           (IJurAcc = 4 && JStaAcc = 4) )  ; If station doesn't cross river   ;


 ;;  debug 4
      IF (I= 35  )
        print list = 'i: ', i,' St_j: ',ST_j[stadx],' Sta Cen: ',STAC[stadx],' StaPark: ',STAP[stadx],' Ijuracc: ',Ijuracc ,' JSTAAcc: ',JStaAcc, file =debug4.asc
      ENDIF
 ;;  debug4


;; Clear all variables in the Jloop
amdist     = 0
amtime     = 0
amspd      = 0

opdist     = 0
optime     = 0
opspd      = 0


Xdiff      = 0
Ydiff      = 0
xback      = 0
xi         = 0
xj         = 0
dcbd       = 0
TAZCBDDist = 0
STACBDDist = 0
TSdist     = 0
TAZSTADist = 0
xdiv       = 0
xback      = 0

;;------------------------------------------------------------------------------
JLOOP ; process J stations for each I-TAZ
;;------------------------------------------------------------------------------


;; Skip all j's not equal to current station/taz
IF (j != CurrJ) CONTINUE

       amdist = max(10.0,(mw[102][j] * 10.00))
       amtime = mw[101][j]
       amspd  = 0.0
       IF (AMtime > 0) amspd =0.60 * amdist/AMtime
       IF (AMtime = 0)
                amspd  = 25
                amdist = 50
       endif

      opdist = max(10.0,(mw[202][j] * 10.00))
      optime = mw[201][j]
      opspd  = 0.0
      IF (optime > 0) opspd =0.60 * opdist/optime
      IF (optime = 0)
                opspd  = 25
                opdist = 50
      endif

;;------------------------------------------------------------------------------
;; Print out special AM/OP Pentagon KNR Access links ---------------------------
;;------------------------------------------------------------------------------
     IF (PentTAZ[I] > 0 && j = pentsta)

         Print Printo=1 list = ' SUPPLINK N=',I(5),'-',Pentnode(5),' DIST=',AMDIST(6),
                      ' ONEWAY=Y MODE=11 SPEED=',AMSPD(4)

         Print Printo=2 list = ' SUPPORT N=',I(5),'-',Pentnode(5),' DIST=',AMDIST(6),
                      ' ONEWAY=Y MODE=11 SPEED=',AMSPD(4)


         Print Printo=3 list = ' SUPPORT N=',I(5),'-',Pentnode(5),' DIST=',OPDIST(6),
                      ' ONEWAY=Y MODE=11 SPEED=',OPSPD(4)
     ENDIF
;;  end  AM/OP Pentagon Links-------------------------------------------
;; ENDJLOOP
;;

;;------------------------------------------------------------------------------
;; Calculate  TAZ-CBD, Sta-CBD, TAZ-Sta  distances & diversion ratio
;;------------------------------------------------------------------------------


                       xback      = 0
                       xi         = abs(TAZx[I] - CBDX )
                       xj         = abs(TAZy[I] - CBDY )
                       dcbd       = sqrt(xi*xi+xj*xj)
                       ;;; TAZCBDDist =  dcbd/52.8                       < Original Code (disabled)
                       IF (I=@NCBD@)                                   ; < Updated Code
                           TAZCBDDist = 0.001                          ; <
                        ELSE                                           ; <
                          TAZCBDDist =  dcbd/52.8                      ; <
                       ENDIF                                           ; <

                       Xi         = abs(STAX[STADX] - CBDX)
                       xj         = abs(STAY[STADX] - CBDY)
                       dscbd      = sqrt(xi*xi+xj*xj)
                       STACBDDist = dscbd/52.8

                       xi         = abs(TAZx[I] - STAX[STADX])
                       xj         = abs(TAZY[I] - STAY[STADX])
                       dtsta      = sqrt(xi*xi+xj*xj)
                       TAZSTADist = round(dtsta/52.8)
                       xdiv       = 0.0
                       if(TAZCBDDIST > 0.0)   xdiv=  (STACBDDist + TAZSTADist)/TAZCBDDIST
                       if(xdiv  > @divpc@) xback=1

           ;; debug 7
            ; if ((i=  241 && stap[stadx] =7310) || (i=  397 && stap[stadx] =7523) ||
            ;     (i=  483 && stap[stadx] =7302) || (i=  491 && stap[stadx] =7803) ||
            ;     (i=  499 && stap[stadx] =8004) || (i=  680 && stap[stadx] =8008) ||
            ;     (i=  746 && stap[stadx] =7543) || (i=  753 && stap[stadx] =7340) ||
            ;     (i=  878 && stap[stadx] =8007) || (i=  964 && stap[stadx] =8034) ||
            ;     (i= 1217 && stap[stadx] =7545) || (i= 1425 && stap[stadx] =7363) ||
            ;     (i= 1935 && stap[stadx] =8210))

               IF (i = 20-38)
                           print form = 8.2 list =  'ITAZ: ', i,' JTAZ: ',j,
                              ,' ',MM[stadx],' ',' STATION: ', stat[STADX], ' STAPARK: ',staP[STADX],
                             ' IJURACC ', IJURACC,' JSTAACC ', JSTAACC,' TAZCBDDist: ', tazcbddist,
                              '  ',' STACBDDist: ',STACBDDist, ' TAZSTADist: ',TAZSTADist,' Z-S dist.max: ', STAd[stadx], ' div.ratio:  ',xdiv(6.4), file =debug7.asc
                          endif
           ;;  debug7

               IF (xback = 0 && TAZStaDist <= STAD[stadx])   ; If diversion factor and TAZ-station distance is acceptable


;;------------------------------------------------------------------------------
;; Print out Standard Auto Access Links ----------------------------------
;;------------------------------------------------------------------------------


                         ;;---------------------------------------------------------------------
                           IF (MM[STADX] = 'M' && STAPARK[STADX] = 'Y') ;;; print am/op metro PNR links

                               Print Printo=1 list = ' SUPPLINK N=',I(5),'-',stap[STADX](5),' DIST=',AMDIST(6),
                                            ' ONEWAY=Y MODE=11 SPEED=',AMSPD(4)

                               Print PRINTO=4 list = ' SUPPORT N=',I(5),'-',stap[STADX](5),' DIST=',AMDIST(6),
                                            ' ONEWAY=Y MODE=11 SPEED=',AMSPD(4)

                               Print PRINTO=5 list = ' SUPPORT N=',I(5),'-',stap[STADX](5),' DIST=',opDIST(6),
                                            ' ONEWAY=Y MODE=11 SPEED=',opSPD(4)
                           ENDIF                                 ;;; end print am/op metro PNR links

                         ;;---------------------------------------------------------------------

                         ;;---------------------------------------------------------------------

                           IF ((MM[STADX] = 'M' && STAPARK[STADX] !='Y'  && NCT[STADX] !=9 && TAZSTADist <= 300.0) ||
                               (MM[STADX] = 'M' && STAPARK[STADX] = 'Y'  && TAZSTADist <= 300.0))       ;;; print am/op metro KNR links

                               Print Printo=1 list = ' SUPPLINK N=',I(5),'-',stat[STADX](5),' DIST=',AMDIST(6),
                                            ' ONEWAY=Y MODE=11 SPEED=',AMSPD(4)

                               Print PRINTO=2 list = ' SUPPORT N=',I(5),'-',stat[STADX](5),' DIST=',AMDIST(6),
                                            ' ONEWAY=Y MODE=11 SPEED=',AMSPD(4)

                               Print PRINTO=3 list = ' SUPPORT N=',I(5),'-',stat[STADX](5),' DIST=',opDIST(6),
                                            ' ONEWAY=Y MODE=11 SPEED=',opSPD(4)
                           ENDIF                                 ;;; end print am/op metro KNR links

                         ;;---------------------------------------------------------------------
                         ;;---------------------------------------------------------------------
                           IF (MM[STADX] = 'C' && STAPARK[STADX] = 'Y') ;;; print am/op Comm Rail PNR links

                               Print Printo=1 list = ' SUPPLINK N=',I(5),'-',stap[STADX](5),' DIST=',AMDIST(6),
                                            ' ONEWAY=Y MODE=11 SPEED=',AMSPD(4)

                               Print PRINTO=6 list = ' SUPPORT N=',I(5),'-',stap[STADX](5),' DIST=',AMDIST(6),
                                            ' ONEWAY=Y MODE=11 SPEED=',AMSPD(4)

                               Print PRINTO=7 list = ' SUPPORT N=',I(5),'-',stap[STADX](5),' DIST=',opDIST(6),
                                            ' ONEWAY=Y MODE=11 SPEED=',opSPD(4)
                           ENDIF                                 ;;; end print am/op comm Rail PNR links

                         ;;---------------------------------------------------------------------
                         ;;---------------------------------------------------------------------
                           IF (MM[STADX] = 'B' && STAPARK[STADX] = 'Y') ;;; print am/op Bus PNR links

                               Print Printo=1 list = ' SUPPLINK N=',I(5),'-',stap[STADX](5),' DIST=',AMDIST(6),
                                            ' ONEWAY=Y MODE=11 SPEED=',AMSPD(4)

                               Print PRINTO= 8 list = ' SUPPORT N=',I(5),'-',stap[STADX](5),' DIST=',AMDIST(6),
                                            ' ONEWAY=Y MODE=11 SPEED=',AMSPD(4)

                               Print PRINTO= 9 list = ' SUPPORT N=',I(5),'-',stap[STADX](5),' DIST=',opDIST(6),
                                            ' ONEWAY=Y MODE=11 SPEED=',opSPD(4)
                           ENDIF                                 ;;; end print am/op BUS PNR links

                         ;;---------------------------------------------------------------------
                         ;;---------------------------------------------------------------------
                           IF (MM[STADX] = 'B' && STAPARK[STADX] = 'Y') ;;; print am/op Bus KNR links

                               Print Printo=1 list = ' SUPPLINK N=',I(5),'-',stan1[STADX](5),' DIST=',AMDIST(6),
                                            ' ONEWAY=Y MODE=11 SPEED=',AMSPD(4)

                               Print PRINTO= 18 list = ' SUPPORT N=',I(5),'-',stan1[STADX](5),' DIST=',AMDIST(6),
                                            ' ONEWAY=Y MODE=11 SPEED=',AMSPD(4)

                               Print PRINTO= 19 list = ' SUPPORT N=',I(5),'-',stan1[STADX](5),' DIST=',opDIST(6),
                                            ' ONEWAY=Y MODE=11 SPEED=',opSPD(4)
                           ENDIF                                 ;;; end print am/op BUS KNR links


                         ;;---------------------------------------------------------------------
                         ;;---------------------------------------------------------------------
                           IF (MM[STADX] = 'L' && STAPARK[STADX] = 'Y') ;;; print am/op Light Rail PNR links

                               Print Printo=1 list = ' SUPPLINK N=',I(5),'-',stap[STADX](5),' DIST=',AMDIST(6),
                                            ' ONEWAY=Y MODE=11 SPEED=',AMSPD(4)

                               Print PRINTO=10 list = ' SUPPORT N=',I(5),'-',stap[STADX](5),' DIST=',AMDIST(6),
                                            ' ONEWAY=Y MODE=11 SPEED=',AMSPD(4)

                               Print PRINTO=11 list = ' SUPPORT N=',I(5),'-',stap[STADX](5),' DIST=',opDIST(6),
                                            ' ONEWAY=Y MODE=11 SPEED=',opSPD(4)
                           ENDIF                                 ;;; end print am/op Light Rail PNR links

                         ;;---------------------------------------------------------------------
                         ;;---------------------------------------------------------------------
                           IF (MM[STADX] = 'L' && STAPARK[STADX] !='Y'  && NCT[STADX] !=9 && TAZSTADist < 300.0 ) ;;; print am/op Light Rail KNR links

                               Print Printo=1 list = ' SUPPLINK N=',I(5),'-',stat[STADX](5),' DIST=',AMDIST(6),
                                            ' ONEWAY=Y MODE=11 SPEED=',AMSPD(4)

                               Print PRINTO=12 list = ' SUPPORT N=',I(5),'-',stat[STADX](5),' DIST=',AMDIST(6),
                                            ' ONEWAY=Y MODE=11 SPEED=',AMSPD(4)

                               Print PRINTO=13 list = ' SUPPORT N=',I(5),'-',stat[STADX](5),' DIST=',opDIST(6),
                                            ' ONEWAY=Y MODE=11 SPEED=',opSPD(4)
                           ENDIF                                 ;;; end print am/op Comm KNR links

                         ;;---------------------------------------------------------------------

                         ;;---------------------------------------------------------------------
                           IF (MM[STADX] = 'N' && STAPARK[STADX] = 'Y') ;;; print am/op New PNR links

                               Print Printo=1 list = ' SUPPLINK N=',I(5),'-',stap[STADX](5),' DIST=',AMDIST(6),
                                            ' ONEWAY=Y MODE=11 SPEED=',AMSPD(4)

                               Print PRINTO=14 list = ' SUPPORT N=',I(5),'-',stap[STADX](5),' DIST=',AMDIST(6),
                                            ' ONEWAY=Y MODE=11 SPEED=',AMSPD(4)

                               Print PRINTO=15 list = ' SUPPORT N=',I(5),'-',stap[STADX](5),' DIST=',opDIST(6),
                                            ' ONEWAY=Y MODE=11 SPEED=',opSPD(4)
                           ENDIF                                 ;;; end print am/op New PNR links

                         ;;---------------------------------------------------------------------
                         ;;---------------------------------------------------------------------
                           IF (MM[STADX] = 'N' && STAPARK[STADX] !='Y'  && NCT[STADX] !=9 && TAZSTADist < 300.0 ) ;;; print am/op New KNR links


                               Print Printo=1 list = ' SUPPLINK N=',I(5),'-',stat[STADX](5),' DIST=',AMDIST(6),
                                            ' ONEWAY=Y MODE=11 SPEED=',AMSPD(4)

                               Print PRINTO=16 list = ' SUPPORT N=',I(5),'-',stat[STADX](5),' DIST=',AMDIST(6),
                                            ' ONEWAY=Y MODE=11 SPEED=',AMSPD(4)


                               Print PRINTO=17 list = ' SUPPORT N=',I(5),'-',stat[STADX](5),' DIST=',opDIST(6),
                                            ' ONEWAY=Y MODE=11 SPEED=',opSPD(4)
                           ENDIF                                 ;;; end print am/op New KNR links

                         ;;---------------------------------------------------------------------

                ENDIF                       ;   endif diversion factor and TAZ-Sta distance is acceptable

ENDJLOOP

ENDIF                            ; endif station doesn't cross river


ENDLOOP               ; STATION (STADX) Loop
ENDIF                 ; endif 'I's are Used
ENDIF                 ; endif 'I's are internal


ENDRUN

*copy extra1.xy+extra2.XY+extra3.xy extra.xy
*del  extra1.xy
*del  extra2.xy
*del  extra3.xy

