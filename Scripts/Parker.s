*del voya*.prn
; Parker.s - PNR to Station Link development
; Dimensions:
;

;;Input Files:
  Sta_File       = 'inputs\Station.dbf ' ; Std. Station file
;
; Output Files:

  met_am_pnr       = 'met_am_pnr.tb'  ;unit:21x
  com_am_pnr       = 'com_am_pnr.tb'  ;     22
  bus_am_pnr       = 'bus_am_pnr.tb'  ;     23
  lrt_am_pnr       = 'lrt_am_pnr.tb'  ;     24
  new_am_pnr       = 'new_am_pnr.tb'  ;     25
  met_op_pnr       = 'met_op_pnr.tb'  ;     31x
  com_op_pnr       = 'com_op_pnr.tb'  ;     32
  bus_op_pnr       = 'bus_op_pnr.tb'  ;     33
  lrt_op_pnr       = 'lrt_op_pnr.tb'  ;     34
  new_op_pnr       = 'new_op_pnr.tb'  ;     35
;
; Params:

  VOTperHr       = 10.00          ; Assumed Value of time in $/hr
  VOTperMin      = VOTperHR/60.0  ; Derived Value of time in $/min
  MinPerDoll     = 1.0/VOTperMin  ; Derived Value of minutes per dollar (see comment below for units)

RUN PGM=MATRIX

ZONES=1
FILEI DBI[1]     = "@Sta_File@"

FILEO PRINTO[1]  = "@met_am_pnr@"
FILEO PRINTO[2]  = "@com_am_pnr@"
FILEO PRINTO[3]  = "@bus_am_pnr@"
FILEO PRINTO[4]  = "@lrt_am_pnr@"
FILEO PRINTO[5]  = "@new_am_pnr@"
FILEO PRINTO[6]  = "@met_op_pnr@"
FILEO PRINTO[7]  = "@com_op_pnr@"
FILEO PRINTO[8]  = "@bus_op_pnr@"
FILEO PRINTO[9]  = "@lrt_op_pnr@"
FILEO PRINTO[10] = "@new_op_pnr@"


; Read in Station File
LOOP K = 1,dbi.1.NUMRECORDS
      x = DBIReadRecord(1,k)

          MM          = di.1.MM          ;  Mode code ('M','C,','B','L','N')
          STAPARK     = di.1.STAPARK     ;  Station Parking lot flag ('Y' or blank)
          STAUSE      = di.1.STAUSE      ;  Station Active flag      ('Y' or blank)
          STAT        = di.1.STAT        ;  Station node         (9000 - 11999 series)
          STAZ        = di.1.STAZ        ;  Nearest TAZ centroid (   1 -  3722 series)
          STAC        = di.1.STAC        ;  Station centroid    ( 5000 -  8000 series)
          STAP        = di.1.STAP        ;  Station PNR node    (12000 - 14999 series)
          STAN1       = di.1.STAN1       ;  Bus Node connector
          STAPCAP     = di.1.STAPCAP     ;  Parking lot capacity
          STAPKCOST   = di.1.STAPKCOST   ;  AM Pk daily parking cost  (per-day cost for AM, cents)
          STAOPCOST   = di.1.STAOPCOST   ;  Offpk       parking cost  (per-hour cost for OP, cents; assumes 1 hour duration)
          STAPKSHAD   = di.1.STAPKSHAD   ;  AM    Shadow parking cost (per-day cost for AM, hundredths of minutes)
          STAOPSHAD   = di.1.STAOPSHAD   ;  Offpk Shadow parking cost (per-hour cost for OP, hundredths of minutes; assumes 1 hour duration)

          STACnt      =  dbi.1.NUMRECORDS

 _parkam = INT(max(1.0,(STAPKCOST/2.0)))   ; One-way AM     period parking cost
 _parkop = INT(max(1.0,(STAOPCOST/2.0)))   ; One-way Off Pk period parking cost
                                           ; Note: computed as truncated integer for consistency w/ Parker.for

 _Walkk   = 100.0                      ; Base KNR     walk connector time in hundredths of min ('100.0' = 1 min)
 _Walkpk  = 200.0                      ; Base AM PNR  walk connector time in hundredths of min ('100.0' = 1 min)
 _Walkop  = 200.0                      ; Base OP PNR  walk connector time in hundredths of min ('100.0' = 1 min)

 IF (STAPCAP >  500) _Walkpk = 250.0    ; Peak times are longer for stations with larger lots
 IF (STAPCAP > 1000) _Walkpk = 350.0    ;
 IF (STAPCAP > 1500) _Walkpk = 400.0    ;
 IF (STAPCAP > 2000) _Walkpk = 500.0    ;

;; write out Metrorail PNR-to-Station links (for AM & Offpeak periods)
 IF (MM = 'M' && STAPARK = 'Y' && STAUSE = 'Y')
; units for _time        are hundredths of minutes
; units for @MinPerDoll@ are hundredths of minutes per cent, which equals minutes per dollar
        _time  = _walkpk + STAPKSHAD + (@MinPerDoll@  * _parkam)
        _xtime = _time/100.0

        Print printo =1   list = 'SUPPLINK N=',STAP(5),'-',STAT(5),' ONEWAY=Y MODE=15',
                                 ' DIST= ',_parkam(5),' TIME= ', _Xtime(8.2)

        _time  = _walkop + STAOPSHAD + (@MinPerDoll@  * _parkop)
        _xtime = _time/100.0

        Print printo =6   list = 'SUPPLINK N=',STAP(5),'-',STAT(5),' ONEWAY=Y MODE=15',
                                 ' DIST= ',_parkop(5),' TIME= ', _Xtime(8.2)
 ENDIF


;; write out CommRail PNR-to-Station links (for AM & Offpeak periods)
 IF (MM = 'C' && STAPARK = 'Y' && STAUSE = 'Y')

        _time  = _walkpk + STAPKSHAD + (@MinPerDoll@  * _parkam)
        _xtime = _time/100.0

        Print printo =2   list = 'SUPPLINK N=',STAP(5),'-',STAT(5),' ONEWAY=Y MODE=15',
                                 ' DIST= ',_parkam(5),' TIME= ', _Xtime(8.2)

        _time  = _walkop + STAOPSHAD + (@MinPerDoll@  * _parkop)
        _xtime = _time/100.0

        Print printo =7   list = 'SUPPLINK N=',STAP(5),'-',STAT(5),' ONEWAY=Y MODE=15',
                                 ' DIST= ',_parkop(5),' TIME= ', _Xtime(8.2)
 ENDIF


;; write out BUS PNR-to-Bus Stop Node links (for AM & Offpeak periods)
 IF (MM = 'B' && STAPARK = 'Y' && STAUSE = 'Y')

        _time  = _walkpk + STAPKSHAD + (@MinPerDoll@  * _parkam)
        _xtime = _time/100.0

        Print printo =3   list = 'SUPPLINK N=',STAP(5),'-',STAN1(5),' ONEWAY=Y MODE=15',
                                 ' DIST= ',_parkam(5),' TIME= ', _Xtime(8.2)

        _time  = _walkop + STAOPSHAD + (@MinPerDoll@  * _parkop)
        _xtime = _time/100.0

        Print printo =8   list = 'SUPPLINK N=',STAP(5),'-',STAN1(5),' ONEWAY=Y MODE=15',
                                 ' DIST= ',_parkop(5),' TIME= ', _Xtime(8.2)
 ENDIF


;; write out Light Rail PNR-to-Station links (for AM & Offpeak periods)
 IF (MM = 'L' && STAPARK = 'Y' && STAUSE = 'Y')

        _time  = _walkpk + STAPKSHAD + (@MinPerDoll@  * _parkam)
        _xtime = _time/100.0

        Print printo =4   list = 'SUPPLINK N=',STAP(5),'-',STAT(5),' ONEWAY=Y MODE=15',
                                 ' DIST= ',_parkam(5),' TIME= ', _Xtime(8.2)

        _time  = _walkop + STAOPSHAD + (@MinPerDoll@  * _parkop)
        _xtime = _time/100.0

        Print printo =9   list = 'SUPPLINK N=',STAP(5),'-',STAT(5),' ONEWAY=Y MODE=15',
                                 ' DIST= ',_parkop(5),' TIME= ', _Xtime(8.2)
 ENDIF


;; write out BRT/New PNR-to-Station links (for AM & Offpeak periods)
 IF (MM = 'N' && STAPARK = 'Y' && STAUSE = 'Y')

        _time  = _walkpk + STAPKSHAD + (@MinPerDoll@  * _parkam)
        _xtime = _time/100.0

        Print printo =5   list = 'SUPPLINK N=',STAP(5),'-',STAT(5),' ONEWAY=Y MODE=15',
                                 ' DIST= ',_parkam(5),' TIME= ', _Xtime(8.2)

        _time  = _walkop + STAOPSHAD + (@MinPerDoll@  * _parkop)
        _xtime = _time/100.0

        Print printo =10   list = 'SUPPLINK N=',STAP(5),'-',STAT(5),' ONEWAY=Y MODE=15',
                                 ' DIST= ',_parkop(5),' TIME= ', _Xtime(8.2)
 ENDIF




ENDLOOP

