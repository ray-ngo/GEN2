*del voya*.prn
;; Walkacc.s - walk access link development - based on walkacc.for from AECOM
;; 5/10/11 - changed script so HBWV2A1.dbf is read in from the working SD, not the inputs SD
;; 06/11/14 - Changed line 116 so that TAZ number from the input file is used (_TAZ) as 
;; 	  		opposed to using the sequence number as TAZ (K), as notified by AECOM - RJM	
;; 04/17/17 - Corrected the distance notes: "tenths" to "hundredths" - DQN
;; Dimensions:
NodeSize    = 60000       ;; Highway node size
TAZSTASize  =  7999       ;; TAZ/Sta dimensions
ITAZSize    =  3675       ;; Internal TAZ dimensions
XLinkSize   =  1000       ;; Max. no. of user-defined Add/Del links

;;Input Files:
NodeF       = 'inputs\node.dbf'
AreaF       = 'HBWV2A1.dbf'           ;; used to be in \inputs SD, now created below and read as an input
XtraF       = 'inputs\Xtrawalk.dbf'
LinkF       = 'WalkAcc_Links.dbf'

;; Output Files:
sidewalkF   ='sidewalk.asc'
walkaccF    ='walkacc.asc'
supportF    ='support.asc'
;;---------------------------------------------------------------------
;;=============================================================================================================================;;
;;                                                                                                                             ;;
;; Create area walk percentage files first (This script section was formerly Create_HBWv2A1.s)                                 ;;
;;                     Read: 1) a short/long walk area file created by the GIS-based buffering procedures                      ;;
;;                           2) a standard zonal land use filecreate two file                                                  ;;
;;                    ...and create two files to be copied to the \inputs subdirectory for the appropriate year                ;;
;;                           1) HBWV2A1.dbf  - file used by the WALKACC.s    program the generate walk-access transit links    ;;
;;                           2) NLwalkPct.txt- file used by the PrefareV23.s program to generate zonal walks pcts to           ;;
;;                                             Metrorail for the MFARE2 process, and a zonal file for the NL Mode Choice model ;;
;;=============================================================================================================================;;
;;Input Files:
PctWalkF    = 'inputs\Areawalk.txt'   ; zonal walk percentage file from the GIS process
ZoneF       = 'inputs\zone.dbf'       ; standard zonal attribute input file
;; Outputs

NL_Pct_wk   = 'NLwalkPCT.txt'

; Convert zonal walk area file to dbf
RUN PGM=MATRIX
ZONES=1
FILEI reci  = @PctWalkF@ ,
              TAZ       =1,      ; TAZ
              TAZAREA   =2,      ; TAZ area (sq mi)
              MtrShort  =3,      ; Area within short walk range to a Metro Station
              MtrLong   =4,      ; Area within long  walk range to a Metro Station (incl short walk)
              AmShort   =5,      ; Area within short walk range to AM Prd Transit of any kind
              AmLong    =6,      ; Area within long  walk range to AM Prd Transit of any kind
              OPShort   =7,      ; Area within short walk range to Offpk Prd Transit of any kind
              OPLong    =8,      ; Area within long  walk range to Of pk Prd Transit of any kind
              sort=TAZ           ;



  IF (reci.RECNO>1)   ; Skip first record which has no data, only variable names
      n=n+1                     ;  n   record counter



   ; write out TAZ level dbf file
     FILEO RECO[1] ="AreaWlk.dbf", Fields = RECI.ALLFIELDS
     WRITE RECO=1
  ENDIF
endrun


;;---------------------------------------------------------------------
RUN PGM=MATRIX

ZONES=1
FileI DBI[1]    = "AreaWlk.dbf"
FILEO RECO[1]   ="HBWV2A1.dbf",  Fields = TAZ(8), Pctwksh(8), Pctwklg(8), Area(10.4)
FILEO PRINTO[1] ="@NL_PCT_Wk@"

LOOP K = 1,dbi.1.NUMRECORDS
       x = DBIReadRecord(1,k)
           _TAZ      = di.1.TAZ            ;
           _Area     = di.1.TAZArea        ;
           _AMShort  = di.1.AMShort        ;
           _AMLong   = di.1.AMLong         ;
           _MtrShort = di.1.MtrShort       ; Area within short walk range to a Metro Station
           _MtrLong  = di.1.MtrLong        ; Area within long  walk range to a Metro Station (incl short walk)
           _OPShort  = di.1.OPShort        ; Area within short walk range to Offpk Prd Transit of any kind
           _OPLong   = di.1.OPLong         ; Area within long  walk range to Of pk Prd Transit of any kind


          ;;  evaluate pct walks for reasonablility (for future checking)

          ;;IF (_TAZ < 1 || _TAZ > 3675) abort  MSG=' TAZs < 1 or > 3675 ,I quit)
          ;;IF (_Area    < 0           ) abort  MSG='Zonal area < zero   ,I quit)
          ;;IF (_AMShort >  _Area      ) abort  MSG='AMShort area > Area ,I quit)
          ;;IF (_AMLong  >  _Area      ) abort  MSG='AMLong  area > Area ,I quit)
          ;;IF (_AMShort < 0           ) abort  MSG='AMShort area < zero ,I quit)
          ;;IF (_AMLong  < 0           ) abort  MSG='AMLong  area < zero ,I quit)

            _Pctwksh     =  MIN((_AMShort/_Area * 100.00),100.00)
            _Pctwksh_lg  =  MIN((_AMLong /_Area * 100.00),100.00)
            _Pctwklg     =  _Pctwksh_lg  -  _Pctwksh

            _Proamwksh      =  MIN((_AMShort/_Area  ),1.00)   ;  proportion of TAZ that is in AM short service area
            _Proamwksh_lg   =  MIN((_AMLong /_Area  ),1.00)   ;  proportion of TAZ that is in AM long  service area
            _Proopwksh      =  MIN((_OPShort/_Area  ),1.00)   ;  proportion of TAZ that is in OP short service area
            _Proopwksh_lg   =  MIN((_OPLong /_Area  ),1.00)   ;  proportion of TAZ that is in OP long  service area
            _Prometwksh     =  MIN((_MtrShort/_Area ),1.00)   ;  proportion of TAZ that is in Metrorail short service area
            _Prometwksh_lg  =  MIN((_MtrLong /_Area ),1.00)   ;  proportion of TAZ that is in Metrorail long  service area


           ro.TAZ      =  _TAZ
           ro.Pctwksh  =  _Pctwksh
           ro.Pctwklg  =  _Pctwklg
           ro.Area     =  _Area
           write reco=1
           if (K=1)
            print printo=1 list = '     TAZ  MetSht MetShLg   AMSht  AMShLg   OPSht  OPShLg '
           endif
           ;;print printo=1 list = K(8), _Prometwksh(8.2),_Prometwksh_lg(8.2),
		   print printo=1 list = _TAZ(8), _Prometwksh(8.2),_Prometwksh_lg(8.2),
                                       _Proamwksh(8.2), _Proamwksh_lg(8.2),
                                       _Proopwksh(8.2), _Proopwksh_lg(8.2)


ENDLOOP

ENDRUN

;;
;; Now begin walk access link process
;;---------------------------------------------------------------------
RUN PGM=MATRIX

ZONES=1
FileI DBI[1]   = "@nodef@"
FILEI DBI[2]   = "@Xtraf@"
FileI DBI[3]   = "@areaf@"
FILEI DBI[4]   = "@Linkf@"


FILEO PRINTO[1]  =@sidewalkf@
FILEO PRINTO[2]  =@walkaccf@
FILEO PRINTO[3]  =@supportf@


;ARRAY  Type=c1  AD = @Xlinksize@

ARRAY  nx            = @nodesize@,
       ny            = @nodesize@,
       use           = @nodesize@,
       Dela1         = @Xlinksize@,
       Delb1         = @Xlinksize@,
       Dela2         = @Xlinksize@,
       Delb2         = @Xlinksize@,
       DelTAZ        = @TAZSTASize@,
       Tazdist       = @TAZSTASize@,
       Tazarea       = @TAZSTASize@,
       Tazpctw       = @TAZSTASize@

; Fill node XY Array
Maxnode = 0.0

LOOP K = 1,dbi.1.NUMRECORDS
       x = DBIReadRecord(1,k)
           N             = di.1.N
           NX[N]         = di.1.X
           NY[N]         = di.1.Y
           IF (N > Maxnode) Maxnode = N
ENDLOOP

; Fill xtra node Array
LOOP K = 1,dbi.2.NUMRECORDS
       x = DBIReadRecord(2,k)
          AD             = di.2.AD
          AD_A           = di.2.AD_A
          AD_B           = di.2.AD_B

          if (AD_A <=@TAZSTASIZE@ || AD_B <=@TAZSTASIZE@)
                       ip =16
              else
                       ip =13
          endif

          if (AD = '-' && ip = 13)
              Ndel1  = Ndel1 + 1.0
              Dela1[Ndel1] = AD_A
              Delb1[Ndel1] = AD_B
          endif

          if (AD = '-' && ip = 16)
              Ndel2  = Ndel2 + 1.0
              Dela2[Ndel2] = AD_A
              Delb2[Ndel2] = AD_B
              IF (AD_A <= @TAZSTASIZE@) DelTAZ[AD_A] = 1.0
              IF (AD_B <= @TAZSTASIZE@) DelTAZ[AD_B] = 1.0
          endif


          IF (AD = '+')
              Ndel2 = Ndel2 + 1.0
              Dela2[Ndel2] = AD_A
              Delb2[Ndel2] = AD_B
              Xdist   = abs(NX[AD_A] - NX[AD_B])
              Ydist   = abs(NY[AD_A] - NY[AD_B])
              Distft  =  ((Xdist*Xdist) + (Ydist*Ydist))**0.50
              Dist    =  Round(Distft/52.80)   ; distance in hundredths of miles

              IF (IP = 13)
                    Print PRINTO=1  list = 'SUPPORT N=',AD_A(6),'-',AD_B(6),
                                           ' MODE=13 SPEED=3 ONEWAY=Y DIST = ', DIST(6)

                    Print PRINTO=3  list = 'SUPPLINK N=',AD_A(6),'-',AD_B(6),
                                           ' MODE=13 SPEED=3 ONEWAY=Y DIST = ', DIST(6)
                 ELSE
                    Print PRINTO=2  list = 'SUPPORT N=',AD_A(6),'-',AD_B(6),
                    ' ONEWAY=N  MODE=16 SPEED= 3 DIST= ', DIST(6)

                    Print PRINTO=3  list = 'SUPPLINK N=',AD_A(6),'-',AD_B(6),
                    ' ONEWAY=N  MODE=16 SPEED= 3 DIST= ', DIST(6)

              ENDIF
          ENDIF
 ENDLOOP
;;

LOOP K = 1,dbi.3.NUMRECORDS
       x = DBIReadRecord(3,k)
           TAZ           = di.3.TAZ
           Pctwksh       = di.3.pctwksh
           Pctwklg       = di.3.pctwklg
           area          = di.3.area

           Tazarea[TAZ]  = area
           Tazdist[TAZ] = min(100.0,( 75*((area)**0.5)) )
           Tazpctw[TAZ]  = Pctwksh + Pctwklg
           print list = TAZ, Pctwksh,Pctwklg,TAZarea[TAZ],Tazdist[TAZ],Tazpctw[TAZ], file = zonal.asc
ENDLOOP


LOOP K = 1,dbi.4.NUMRECORDS
       x = DBIReadRecord(4,k)
           A             = di.4.A
           B             = di.4.B
           hdist         = di.4.distance
           htaz          = di.4.TAZ
           ftype         = di.4.ftype

           LOOP L=1, Ndel1
                IF (A = Dela1[L] && B = Delb1[L]) GOTO SKIP
                IF (B = Dela1[L] && A = Delb1[L]) GOTO SKIP
           ENDLOOP

           IF (ftype <= 1 || ftype=5 || ftype =6 )       GOTO SKIP
           IF (TAZPctw[hTAZ] = 0.0               )       GOTO SKIP


           USE[A] = 1.0
           USE[B] = 1.0

           tdist         = Round(hdist*100.00)
           Print PRINTO=1  list = 'SUPPORT N=',A(6),'-',B(6),
                                  ' MODE=13 SPEED=3 ONEWAY=Y DIST = ', TDIST(6)

           Print PRINTO=3  list = 'SUPPLINK N=',A(6),'-',B(6),
                                  ' MODE=13 SPEED=3 ONEWAY=Y DIST = ', TDIST(6)

:SKIP
ENDLOOP

;;   END of Sidewalk Links   ;;

;; debug
     LOOP NN = NNode,Maxnode
          print list = NN, USE[NN] ,file= uselist.asc
     ENDLOOP
;;


;;   BEGIN zonal access link development
; -----------------------------------------------------------------------
;    Find all access links within the 1.00 mile search radius:
; -----------------------------------------------------------------------
LOOP ZZ = 1,@ITAZSize@
     Find =0
     If (TAZPctw[ZZ]  = 0.0)  GOTO NextTAZ
     If (NX[ZZ]       = 0.0)  GOTO NextTAZ

     NNode = @ITAZSize@ + 1.0
     LOOP NN = NNode,Maxnode
               IF (DelTAZ[ZZ] = 0.0) GOTO SkipDLst
               LOOP M=1, Ndel2
                  IF (ZZ = Dela2[M] && NN = Delb2[M])  GOTO NextNode
                  IF (NN = Dela2[M] && ZZ = Delb2[M])  GOTO NextNode
               ENDLOOP
     :SkipDLst

     IF (Use[NN] = 0)  GOTO NextNode
     IF (NX[NN]  = 0)  GOTO NextNode

     Xdist   = abs(NX[zz] - NX[nn])
     Ydist   = abs(NY[zz] - NY[nn])
     search = 5280.0
     IF (Xdist > search )                              GOTO NextNode
     IF (Ydist > search )                              GOTO NextNode
     IF (Xdist =    0.0 && YDist =    0.0)             GOTO NextNode


     Distft  =  ((Xdist*Xdist) + (Ydist*Ydist))**0.50
     Dist    =  (Distft/52.80)   ; distance in hundrths of miles
    ;;;--
    ; IF (ZZ=190 )  ;; debug section
    ;      print list = '      zz','      NN',' TAZarea',' TAZPctw','   XDist',' YDist  ',' Search ',' Distft ','    Dist',' TAZdist',   file = dud.asc
    ;      print form=8.2 list = zz, NN,TAZarea[ZZ](8.4), TAZPctw[ZZ],XDist, YDist, search, Distft, Dist,TAZdist[ZZ],   file = dud.asc
    ;  endif
    ;;;--
     IF (Dist > TAZdist[ZZ])   GOTO NextNode


       Print PRINTO=2  list = 'SUPPORT N=',ZZ(6),'-',NN(6),
                    ' ONEWAY=N  MODE=16 SPEED= 3 DIST= ', DIST(6), ';; search = ',search

       Print PRINTO=3  list = 'SUPPLINK N=',ZZ(6),'-',NN(6),
                    ' ONEWAY=N  MODE=16 SPEED= 3 DIST= ', DIST(6)

       Find = Find + 1.0

      :NextNode
      ENDLOOP


; -----------------------------------------------------------------------
;   Expand search radius to 1.25 * TAZDist if no access links found thus far
; -----------------------------------------------------------------------
IF (Find > 0)  GOTO NEXTTAZ


    LOOP NN = NNode,Maxnode

              LOOP M=1, Ndel2
                 IF (ZZ = Dela2[M] && NN = Delb2[M])  GOTO NextNode1
                 IF (NN = Dela2[M] && ZZ = Delb2[M])  GOTO NextNode1
              ENDLOOP

    IF (Use[NN] = 0)  GOTO NextNode1
    IF (NX[NN]  = 0)  GOTO NextNode1

    Xdist   = abs(NX[zz] - NX[nn])
    Ydist   = abs(NY[zz] - NY[nn])
    search = 1.25 * 52.80* TAZdist[ZZ]
    IF (Xdist > search )                              GOTO NextNode1
    IF (Ydist > search )                              GOTO NextNode1
    IF (Xdist =    0.0 && YDist =    0.0)             GOTO NextNode1


    Distft  =  ((Xdist*Xdist) + (Ydist*Ydist))**0.50
    Dist    =  (Distft/52.80)   ; distance in hundredths of miles

    IF (Dist > 100.0)   GOTO NextNode1


       Print PRINTO=2  list = 'SUPPORT N=',ZZ(6),'-',NN(6),
                    ' ONEWAY=N  MODE=16 SPEED= 3 DIST= ', DIST(6), ';; search = ',search

       Print PRINTO=3  list = 'SUPPLINK N=',ZZ(6),'-',NN(6),
                    ' ONEWAY=N  MODE=16 SPEED= 3 DIST= ', DIST(6)

      Find = Find + 1.0


     :NextNode1
     ENDLOOP

; -----------------------------------------------------------------------
;   Expand search radius to 1.50 * TAZDist if no access links found thus far
; -----------------------------------------------------------------------
IF (Find > 0)  GOTO NEXTTAZ


    LOOP NN = NNode,Maxnode

              LOOP M=1, Ndel2
                 IF (ZZ = Dela2[M] && NN = Delb2[M])  GOTO NextNode2
                 IF (NN = Dela2[M] && ZZ = Delb2[M])  GOTO NextNode2
              ENDLOOP

    IF (Use[NN] = 0)  GOTO NextNode2
    IF (NX[NN]  = 0)  GOTO NextNode2

    Xdist   = abs(NX[zz] - NX[nn])
    Ydist   = abs(NY[zz] - NY[nn])
    search = 1.50 * 52.80* TAZdist[ZZ]
    IF (Xdist > search )                              GOTO NextNode2
    IF (Ydist > search )                              GOTO NextNode2
    IF (Xdist =    0.0 && YDist =    0.0)             GOTO NextNode2


    Distft  =  ((Xdist*Xdist) + (Ydist*Ydist))**0.50
    Dist    =  (Distft/52.80)   ; distance in hundredths of miles
    IF (Dist > 100.0)   GOTO NextNode2

       Print PRINTO=2  list = 'SUPPORT N=',ZZ(6),'-',NN(6),
                    ' ONEWAY=N  MODE=16 SPEED= 3 DIST= ', DIST(6), ';; search = ',search

       Print PRINTO=3  list = 'SUPPLINK N=',ZZ(6),'-',NN(6),
                    ' ONEWAY=N  MODE=16 SPEED= 3 DIST= ', DIST(6)

      Find = Find + 1.0
     :NextNode2
     ENDLOOP

:NextTAZ
ENDLOOP
ENDRUN
*copy voya*.prn WalkAcc.rpt
