;  MC_Constraint.s
;   4/3/12 - Three (3) decimals added to all MATO files intermediate and final
;///////////////////////////////////////////////////////////////////
; Mode choice constraint process per the Version 2.3 model
;      Metrorail trips to/through the core are constrained to a predetermined level
;      current year for which constrained levels are set:          2020
;      current years for which the constrained levels are imposed: 2030, 2040
;///////////////////////////////////////////////////////////////////
;
; 4/3/12:  Three(3) decimals are maintained in output files
; ===========================================================================
;
;
; Transit Constraint Process -Applied to modeled mode choice output
;         file for forecast years beyond the constraint year.
;         The process constrains peak period Metrorail trips heading
;         TO or THROUGH the regional core to be constrained
;         levels and converts "excess" back to auto person trips.
;
; The process consists of 3 Steps:
; Step 1. constraint year & post-constraint year peak/off-peak transit trips are calculated
;         for each purpose using 2007/08 HTS time period factors.
;         (2 Loops for constr./unconstr. mode choice output files)
;
; Step 2.  constraint year & post-constraint year peak & total transit trips are squeezed to
;          a 3x3 (core/va/dc,md).  Factors for scaling unconstrained
;          transit trips to constrained transit trips are computed, on
;          an i/j basis.  A 'lookup' of constraint factors is produced.
;
; Step 3.  Future year constrained zonal trips are computed by applying
;          the constraint factors to the zonal trip tables.
;          The factors yeild constrained transit trips at the zone level.
;          The excess transit trips are converted to auto person trips.
;
;         (5 Loops for each purpose as per the V2.3 model)
;
;---------------------------------------------------------------------------
; Step 1.
;         Constrained year & future year peak/off-peak transit trips are calculated
;         for each purpose using 2007/08 HTS time period factors.
;---------------------------------------------------------------------------
                     
TODFile = '..\support\todcomp_2008HTS.dbf' ; Time of Day Factor File

;; define TOD ARRAY parameters in the time of day file
Pur = 5  ;  1/HBW,   2/HBS,    3/HBO, 4/NHW, 5/NHO
Mod = 4  ;  1/Adr,   2/DrAlone 3/CarPoolPsn  4/Transit
Dir = 2  ;  1/H>NH,  2/NH>H
Per = 4  ;  1/AM,    2/MD,     3/PM,  4/NT

LOOP Time  = 1, 2            ; Time '1' = constraint year loop/ Time '2' = Future year loop

 IF (Time = 1)
  PATHSPECHBW = '%_tcHBW_%'    ; path specification of constraint-year HBW transit trips
  PATHSPECHBS = '%_tcHBS_%'    ; path specification of constraint-year HBS transit trips
  PATHSPECHBO = '%_tcHBO_%'    ; path specification of constraint-year HBO transit trips
  PATHSPECNHW = '%_tcNHW_%'    ; path specification of constraint-year NHW transit trips
  PATHSPECNHO = '%_tcNHO_%'    ; path specification of constraint-year NHO transit trips
  YR       = 'con'             ; constraint indicator    (for file naming)
  title    = ' Constraint-Year Metrorail Trip Summary by Time Period '

 ELSE
  PATHSPECHBW = '%_iter_%_HBW_NL_MC.MTT'   ; forecast year should be in current subdir
  PATHSPECHBS = '%_iter_%_HBS_NL_MC.MTT'   ; forecast year should be in current subdir
  PATHSPECHBO = '%_iter_%_HBO_NL_MC.MTT'   ; forecast year should be in current subdir
  PATHSPECNHW = '%_iter_%_NHW_NL_MC.MTT'   ; forecast year should be in current subdir
  PATHSPECNHO = '%_iter_%_NHO_NL_MC.MTT'   ; forecast year should be in current subdir
  YR       = 'ucn'           ; unconstrained indicator (for file naming)
  title    = ' Future/Post-Constraint Year - UnConstrained Metrorail Trip Summary by Time Period '

 ENDIF

;
;  Factors for distributing Daily Transit Trips
;  (HBW,HBS,HBO,NHW,NHO) Among 4 Time Periods:
;
;              -  AM peak  (6:00 AM - 9:00 AM)
;              -  Midday   (9:00 AM - 3:00 PM)
;              -  PM peak  (3:00 PM - 7:00 PM)
;              -  Night    (All Other hrs )
;


;///////////////////////////////////////////////////////////////////
;
; Begin Voyager Step 1
;
;\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

RUN PGM=MATRIX
pageheight=32767  ; Preclude header breaks
ZONES=3722
Array TODFtrs  =@Pur@,@Mod@,@Dir@,@Per@
FILEI DBI[1]    ="@TODFile@"
;==============================================================================================
;==============================================================================================
IF (I=1)
 ; Read in Time of Day factor file and populate TOD factor array
  LOOP K = 1,dbi.1.NUMRECORDS       ;;PURP    MODE    DIR     AM      MD      PM      OP

     x = DBIReadRecord(1,k)
           count       = dbi.1.recno
           TODFtrs[di.1.Purp][di.1.Mode][di.1.DIR][1] = di.1.AM
           TODFtrs[di.1.Purp][di.1.Mode][di.1.DIR][2] = di.1.MD
           TODFtrs[di.1.Purp][di.1.Mode][di.1.DIR][3] = di.1.PM
           TODFtrs[di.1.Purp][di.1.Mode][di.1.DIR][4] = di.1.OP
           print list = count, di.1.am, di.1.md, di.1.pm, di.1.op, file = tod.chk
  ENDLOOP
 ENDIF
;==============================================================================================
;==============================================================================================


; Read input NL Mode Choice Model Output files to pull out Metrorail trips
   MATI[1] = @PATHSPECHBW@ ; HBW Metrorail Only, Bus/Metrorail (T6-7,11-14) Trips
   MATI[2] = @PATHSPECHBS@ ; HBS Metrorail Only, Bus/Metrorail (T6-7,11-14) Trips
   MATI[3] = @PATHSPECHBO@ ; HBO Metrorail Only, Bus/Metrorail (T6-7,11-14) Trips
   MATI[4] = @PATHSPECNHW@ ; NBW Metrorail Only, Bus/Metrorail (T6-7,11-14) Trips
   MATI[5] = @PATHSPECNHO@ ; NBO Metrorail Only, Bus/Metrorail (T6-7,11-14) Trips

;  Specify output Pk, Offpk Total Metrorail trips (t1-3) by purpose
   MATO[1] = HBWPKOPALL.@yr@, MO=121,122,120, dec=3*3 ;HBW Pk(AM,PM), Off-Pk(MD,NT), total(AM,PM,MD,NT) Transit Trips
   MATO[2] = HBSPKOPALL.@yr@, MO=221,222,220, dec=3*3 ;HBS Pk(AM,PM), Off-Pk(MD,NT), total(AM,PM,MD,NT) Transit Trips
   MATO[3] = HBOPKOPALL.@yr@, MO=321,322,320, dec=3*3 ;HBO Pk(AM,PM), Off-Pk(MD,NT), total(AM,PM,MD,NT) Transit Trips
   MATO[4] = NHWPKOPALL.@yr@, MO=421,422,420, dec=3*3 ;NHW Pk(AM,PM), Off-Pk(MD,NT), total(AM,PM,MD,NT) Transit Trips
   MATO[5] = NHOPKOPALL.@yr@, MO=521,522,520, dec=3*3 ;NHO Pk(AM,PM), Off-Pk(MD,NT), total(AM,PM,MD,NT) Transit Trips

;
;  Put Total HBW - NHO Metrorail Transit Trips in MWs  101-105
;  These are in P/A format and represent the Home-to-NonHome direction

   MW[101]  = MI.1.6 + MI.1.7 + MI.1.11 + MI.1.12 + MI.1.13 + MI.1.14 ; Work  Metrorail P/A fmt
   MW[102]  = MI.2.6 + MI.2.7 + MI.2.11 + MI.2.12 + MI.2.13 + MI.2.14 ; Shop  Metrorail P/A fmt
   MW[103]  = MI.3.6 + MI.3.7 + MI.3.11 + MI.3.12 + MI.3.13 + MI.3.14 ; Other Metrorail P/A fmt
   MW[104]  = MI.4.6 + MI.4.7 + MI.4.11 + MI.4.12 + MI.4.13 + MI.4.14 ; NHWrk Metrorail P/A fmt
   MW[105]  = MI.5.6 + MI.5.7 + MI.5.11 + MI.5.12 + MI.5.13 + MI.5.14 ; NHOth Metrorail P/A fmt

; develop xpose of the above input tables
; then add xposed tabs to developed total Metrorail tabs in  A/P format (MWs 201-205)
; The transpose represents the NonHome-to-Home direction

   MW[11]= MI.1.6.T   MW[12]= MI.1.7.T   MW[13]= MI.1.11.T   MW[14]= MI.1.12.T   MW[15]= MI.1.13.T   MW[16]= MI.1.14.T ;Work  Metrorail A/P fmt
   MW[21]= MI.2.6.T   MW[22]= MI.2.7.T   MW[23]= MI.2.11.T   MW[24]= MI.2.12.T   MW[25]= MI.2.13.T   MW[26]= MI.2.14.T ;Shop  Metrorail A/P fmt
   MW[31]= MI.3.6.T   MW[32]= MI.3.7.T   MW[33]= MI.3.11.T   MW[34]= MI.3.12.T   MW[35]= MI.3.13.T   MW[36]= MI.3.14.T ;Other Metrorail A/P fmt
   MW[41]= MI.4.6.T   MW[42]= MI.4.7.T   MW[43]= MI.4.11.T   MW[44]= MI.4.12.T   MW[45]= MI.4.13.T   MW[46]= MI.4.14.T ;NHWrk Metrorail A/P fmt
   MW[51]= MI.5.6.T   MW[52]= MI.5.7.T   MW[53]= MI.5.11.T   MW[54]= MI.5.12.T   MW[55]= MI.5.13.T   MW[56]= MI.5.14.T ;NHOth Metrorail A/P fmt

   MW[201] =MW[11] + MW[12]  + MW[13]  + MW[14]  + MW[15]  + MW[16]              ; Work  total Metrorail A/P fmt
   MW[202] =MW[21] + MW[22]  + MW[23]  + MW[24]  + MW[25]  + MW[26]              ; Shop  total Metrorail A/P fmt
   MW[203] =MW[31] + MW[32]  + MW[33]  + MW[34]  + MW[35]  + MW[36]              ; Other total Metrorail A/P fmt
   MW[204] =MW[41] + MW[42]  + MW[43]  + MW[44]  + MW[45]  + MW[46]              ; NHWrk total Metrorail A/P fmt
   MW[205] =MW[51] + MW[52]  + MW[53]  + MW[54]  + MW[55]  + MW[56]              ; NHOth total Metrorail A/P fmt
;
; Now we're ready to apply apply TOD factors
;
;
 JLOOP

;\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
;//////////////// AM Trip Calculations - MWs 111-115 ///////////////
;\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
;;           24Hr Trips          p  m  d  p           24 Hr Trips         p  m  d  p
;;              in               u  o  i  e            in                 u  o  i  e
;;              H-NH Dir         r  d  r  r            NH-H Dir           r  d  r  r
;;              |                |  |  |  |             |                 |  |  |  |
   MW[111] = (MW[101] * (TODFtrs[1][4][1][1]/100.00) + MW[201] * (TODFtrs[1][4][2][1]/100.00)) / 2.0  ;   AM Period HBW Metrorail Trips *****
   MW[112] = (MW[102] * (TODFtrs[2][4][1][1]/100.00) + MW[202] * (TODFtrs[2][4][2][1]/100.00)) / 2.0  ;   AM Period HBS Metrorail Trips *****
   MW[113] = (MW[103] * (TODFtrs[3][4][1][1]/100.00) + MW[203] * (TODFtrs[3][4][2][1]/100.00)) / 2.0  ;   AM Period HBO Metrorail Trips *****
   MW[114] = (MW[104] * (TODFtrs[4][4][1][1]/100.00) + MW[204] * (TODFtrs[4][4][2][1]/100.00)) / 2.0  ;   AM Period NHW Metrorail Trips *****
   MW[115] = (MW[105] * (TODFtrs[5][4][1][1]/100.00) + MW[205] * (TODFtrs[5][4][2][1]/100.00)) / 2.0  ;   AM Period NHO Metrorail Trips *****
;
;\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
;//////////////// MD Trip Calculations - MWs 211-215 ///////////////
;\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
;;              Trips            p  m  d  p            Trips              p  m  d  p
;;              in               u  o  i  e            in                 u  o  i  e
;;              H-NH Dir         r  d  r  r            NH-H Dir           r  d  r  r
;;              |                |  |  |  |             |                 |  |  |  |
   MW[211] = (MW[101] * (TODFtrs[1][4][1][2]/100.00) + MW[201] * (TODFtrs[1][4][2][2]/100.00)) / 2.0  ;   MD Period HBW Metrorail Trips *****
   MW[212] = (MW[102] * (TODFtrs[2][4][1][2]/100.00) + MW[202] * (TODFtrs[2][4][2][2]/100.00)) / 2.0  ;   MD Period HBS Metrorail Trips *****
   MW[213] = (MW[103] * (TODFtrs[3][4][1][2]/100.00) + MW[203] * (TODFtrs[3][4][2][2]/100.00)) / 2.0  ;   MD Period HBO Metrorail Trips *****
   MW[214] = (MW[104] * (TODFtrs[4][4][1][2]/100.00) + MW[204] * (TODFtrs[4][4][2][2]/100.00)) / 2.0  ;   MD Period NHW Metrorail Trips *****
   MW[215] = (MW[105] * (TODFtrs[5][4][1][2]/100.00) + MW[205] * (TODFtrs[5][4][2][2]/100.00)) / 2.0  ;   MD Period NHO Metrorail Trips *****
;
;\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
;//////////////// PM Trip Calculations - MWs 311-315 ///////////////
;\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
;;              Trips            p  m  d  p            Trips              p  m  d  p
;;              in               u  o  i  e            in                 u  o  i  e
;;              H-NH Dir         r  d  r  r            NH-H Dir           r  d  r  r
;;              |                |  |  |  |             |                 |  |  |  |
   MW[311] = (MW[101] * (TODFtrs[1][4][1][3]/100.00) + MW[201] * (TODFtrs[1][4][2][3]/100.00)) / 2.0  ;   PM Period HBW Metrorail Trips *****
   MW[312] = (MW[102] * (TODFtrs[2][4][1][3]/100.00) + MW[202] * (TODFtrs[2][4][2][3]/100.00)) / 2.0  ;   PM Period HBS Metrorail Trips *****
   MW[313] = (MW[103] * (TODFtrs[3][4][1][3]/100.00) + MW[203] * (TODFtrs[3][4][2][3]/100.00)) / 2.0  ;   PM Period HBO Metrorail Trips *****
   MW[314] = (MW[104] * (TODFtrs[4][4][1][3]/100.00) + MW[204] * (TODFtrs[4][4][2][3]/100.00)) / 2.0  ;   PM Period NHW Metrorail Trips *****
   MW[315] = (MW[105] * (TODFtrs[5][4][1][3]/100.00) + MW[205] * (TODFtrs[5][4][2][3]/100.00)) / 2.0  ;   PM Period NHO Metrorail Trips *****
;
;\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
;//////////////// NT Trip Calculations - MWs 411-415 ///////////////
;\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
;;              Trips            p  m  d  p            Trips              p  m  d  p
;;              in               u  o  i  e            in                 u  o  i  e
;;              H-NH Dir         r  d  r  r            NH-H Dir           r  d  r  r
;;              |                |  |  |  |             |                 |  |  |  |
   MW[411] = (MW[101] * (TODFtrs[1][4][1][4]/100.00) + MW[201] * (TODFtrs[1][4][2][4]/100.00)) / 2.0  ;   NT Period HBW Metrorail Trips *****
   MW[412] = (MW[102] * (TODFtrs[2][4][1][4]/100.00) + MW[202] * (TODFtrs[2][4][2][4]/100.00)) / 2.0  ;   NT Period HBS Metrorail Trips *****
   MW[413] = (MW[103] * (TODFtrs[3][4][1][4]/100.00) + MW[203] * (TODFtrs[3][4][2][4]/100.00)) / 2.0  ;   NT Period HBO Metrorail Trips *****
   MW[414] = (MW[104] * (TODFtrs[4][4][1][4]/100.00) + MW[204] * (TODFtrs[4][4][2][4]/100.00)) / 2.0  ;   NT Period NHW Metrorail Trips *****
   MW[415] = (MW[105] * (TODFtrs[5][4][1][4]/100.00) + MW[205] * (TODFtrs[5][4][2][4]/100.00)) / 2.0  ;   NT Period NHO Metrorail Trips *****
;
;
; DONE WITH TIME OF DAY CALCULATIONS AT I/J LEVEL
;
ENDJLOOP


;-----------------------------------------------------------------------
; Summarize TOTAL Output / calculated Metrorail Trips across time periods for each purpose for checking (MWs 120,220,...,520)
 MW[120] = MW[111] + MW[211] + MW[311] + MW[411]  ; Total HBW summed across time periods
 MW[220] = MW[112] + MW[212] + MW[312] + MW[412]  ; Total HBS summed across time periods
 MW[320] = MW[113] + MW[213] + MW[313] + MW[413]  ; Total HBO summed across time periods
 MW[420] = MW[114] + MW[214] + MW[314] + MW[414]  ; Total NBW summed across time periods
 MW[520] = MW[115] + MW[215] + MW[315] + MW[415]  ; Total NBO summed across time periods
;
;-----------------------------------------------------------------------
; Summarize PEAK Period (AM&PM) Output / calculated Metrorail Trips for each purpose  (MWs 121,221,...,521)
 MW[121] = MW[111]           + MW[311]            ; Peak  HBW Metrorail Trips
 MW[221] = MW[112]           + MW[312]            ; Peak  HBS Metrorail Trips
 MW[321] = MW[113]           + MW[313]            ; Peak  HBO Metrorail Trips
 MW[421] = MW[114]           + MW[314]            ; Peak  NBW Metrorail Trips
 MW[521] = MW[115]           + MW[315]            ; Peak  NBO Metrorail Trips
;
; Summarize Off PK Period (MD&NT) Output / calculated Metrorail Trips for each purpose  (MWs 122,222,...,522)
 MW[122] = MW[211]           + MW[411]            ; Off Peak  HBW Metrorail Trips
 MW[222] = MW[212]           + MW[412]            ; Off Peak  HBS Metrorail Trips
 MW[322] = MW[213]           + MW[413]            ; Off Peak  HBO Metrorail Trips
 MW[422] = MW[214]           + MW[414]            ; Off Peak  NBW Metrorail Trips
 MW[522] = MW[215]           + MW[415]            ; Off Peak  NBO Metrorail Trips
;
;
; Now get regional totals to summarize neatly
Jloop
; accumulate calculated Metrorail trips by period(am,md,pm,nt), purpose(hbw,hbs,hbo,nhw,nho)
; e.g. 'amhbw' refers to period 'am',  and purp 'hbw'


amhbw=amhbw + mw[111]   amhbs=amhbs + mw[112]   amhbo=amhbo + mw[113]  amnhw=amnhw + mw[114]  amnho = amnho + mw[115]
mdhbw=mdhbw + mw[211]   mdhbs=mdhbs + mw[212]   mdhbo=mdhbo + mw[213]  mdnhw=mdnhw + mw[214]  mdnho = mdnho + mw[215]
pmhbw=pmhbw + mw[311]   pmhbs=pmhbs + mw[312]   pmhbo=pmhbo + mw[313]  pmnhw=pmnhw + mw[314]  pmnho = pmnho + mw[315]
nthbw=nthbw + mw[411]   nthbs=nthbs + mw[412]   nthbo=nthbo + mw[413]  ntnhw=ntnhw + mw[414]  ntnho = ntnho + mw[415]



; accumulate total Metrorail output trips by time period
 outam =outam   + MW[111] + MW[112] + MW[113] + MW[114] + MW[115]
 outmd =outmd   + MW[211] + MW[212] + MW[213] + MW[214] + MW[215]
 outpm =outpm   + MW[311] + MW[312] + MW[313] + MW[314] + MW[315]
 outnt =outnt   + MW[411] + MW[412] + MW[413] + MW[414] + MW[415]

 outall =outall + MW[111] + MW[112] + MW[113] + MW[114] + MW[115] +
                  MW[211] + MW[212] + MW[213] + MW[214] + MW[215] +
                  MW[311] + MW[312] + MW[313] + MW[314] + MW[315] +
                  MW[411] + MW[412] + MW[413] + MW[414] + MW[415]





; accumulate total input Metrorail trips by purpose, total
 inhbw=inhbw + MW[101]                                           ;  Input HBW Metrorail Trips
 inhbs=inhbs + MW[102]                                           ;  Input HBS Metrorail Trips
 inhbo=inhbo + MW[103]                                           ;  Input HBO Metrorail Trips
 innhw=innhw + MW[104]                                           ;  Input NHB Metrorail Trips
 innho=innho + MW[105]                                           ;  Input NHB Metrorail Trips
 intot=intot + MW[101] + MW[102] + MW[103] + MW[104] + MW[105]   ;  Input ALL Metrorail Trips


; accumulate total output Metrorail trips by purpose, total
 outhbw=outhbw + MW[120]                                         ; Output HBW Metrorail Trips
 outhbs=outhbs + MW[220]                                         ; Output HBS Metrorail Trips
 outhbo=outhbo + MW[320]                                         ; Output HBO Metrorail Trips
 outnhw=outnhw + MW[420]                                         ; Output NHB Metrorail Trips
 outnho=outnho + MW[520]                                         ; Output NHB Metrorail Trips
 outtot=outtot + MW[120] + MW[220] + MW[320] + MW[420] + MW[520] ; Output ALL Metrorail Trips

endjloop

; now write out the totals neatly if at the last zone:
if (i=zones)
; get differences by purpose (output - Input)
dfhbw = outhbw - inhbw;
dfhbs = outhbs - inhbs;
dfhbo = outhbo - inhbo;
dfnhw = outnhw - innhw;
dfnho = outnho - innho;
dftot = outtot - intot;

LIST = '/bt     '
LIST = '@title@','\n'
LIST = '     '
list = 'TIME PERIOD      HBW         HBS         HBO         NHW         NHO         Sum '
list = '-----------      ---         ---         ---         ---         ---         --- '
list = 'AM       ',amhbw(12csv),  amhbs(12csv),  amhbo(12csv),  amnhw(12csv),  amnho(12csv), outam(12csv)
list = 'MD       ',mdhbw(12csv),  mdhbs(12csv),  mdhbo(12csv),  mdnhw(12csv),  mdnho(12csv), outmd(12csv)
list = 'PM       ',pmhbw(12csv),  pmhbs(12csv),  pmhbo(12csv),  pmnhw(12csv),  pmnho(12csv), outpm(12csv)
list = 'NT       ',nthbw(12csv),  nthbs(12csv),  nthbo(12csv),  ntnhw(12csv),  ntnho(12csv), outnt(12csv)
list = '  '
list = 'Total    ',outhbw(12csv), outhbs(12csv), outhbo(12csv), outnhw(12csv), outnho(12csv),outall(12csv)
list = '  '
list = '  '
list = 'I/P Totls',inhbw(12csv),inhbs(12csv),inhbo(12csv),innhw(12csv),innho(12csv),intot(12csv)
list = '  '
list = 'Diff.    ',dfhbw(12csv),dfhbs(12csv),dfhbo(12csv),dfnhw(12csv),dfnho(12csv),dftot(12csv)

list = '/et       '
endif

;
;--------------------------------------------------------------
;---  END of TRANSIT Time-of-Day Process             ----------
;---                                                 ----------
;--------------------------------------------------------------
ENDRUN
ENDLOOP ; End  of time-of -day loop





;///////////////////////////////////////////////////////////////////
;
;   Step 2
;         2010 & Future year peak & total transit trips are squeezed to
;          a 3x3 (core/va/dc,md).  Factors for scaling unconstrained
;          transit trips to constrained transit trips are computed, on
;          an i/j basis FOR ijS TO AND THROUGH the regional core.
;
;\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
; create equiv table
COPY FILE = three.eqv
; Beginning of 3x3 Equivalency Table
D 1=1405-1470,1477-1485,1490-1494,1498-1545            ;   ArlNCore       [1]
D 1=1546-1610                                          ;   Alex           [1]
D 1=1611-2159                                          ;   FFx            [1]
D 1=2160-2441                                          ;   LDn            [1]
D 1=2442-2554,2556-2628,2630-2819                      ;   PW             [1]
D 1=3604-3653                                          ;   Fau            [1]
D 1=3449-3477,3479-3481,3483-3494,3496-3541            ;   Stf.           [1]
D 1=3654-3662,3663-3675                                ;   Clk,Jeff.      [1]
D 1=3435-3448,3542-3543,3545-3603                      ;   Fbg,Spots      [1]
D 1=3410-3434                                          ;   KG.            [1]
D 1=3676-3722                                          ;   Ext(unused)    [1]
D 1=770,777,2555,2629,3103,3266-3267                   ;   Unused         [1]
D 1=3478,3482,3495,3544                                ;   Unused         [1]
D 2=1-4,6-47,49-50,52-63,65,181-209,282-287,374-381    ;   DC CORE        [2]
D 2=1471-1476, 1486-1489, 1495-1497                    ;   ArlCore        [2]
D 3=5,48,51,64,66-180,210-281,288-373,382-393          ;   DC Noncore     [3]
D 3=394-769                                            ;   Montgomery     [3]
D 3=771-776,778-1404                                   ;   Prince George  [3]
D 3=2820-2949                                          ;   Frd            [3]
D 3=3230-3265,3268-3287                                ;   Car.           [3]
D 3=2950-3017                                          ;   How.           [3]
D 3=3018-3102,3104-3116                                ;   AnnAr          [3]
D 3=3288-3334                                          ;   Calv           [3]
D 3=3335-3409                                          ;   StM            [3]
D 3=3117-3229                                          ;   Chs.           [3]
;       End of 3x3 Equivalency Table
ENDCOPY

RUN PGM=MATRIX
; Read input Files

 ; Input Constrained Metrorail Trips:
  MATI[01] = HBWPKOPALL.con             ; t1-3 >HBW Pk,OffPk, Total Metrorail Trips
  MATI[02] = HBSPKOPALL.con             ; t1-3 >HBS Pk,OffPk, Total Metrorail Trips
  MATI[03] = HBOPKOPALL.con             ; t1-3 >HBO Pk,OffPk, Total Metrorail Trips
  MATI[04] = NHWPKOPALL.con             ; t1-3 >NHW Pk,OffPk, Total Metrorail Trips
  MATI[05] = NHOPKOPALL.con             ; t1-3 >NHO Pk,OffPk, Total Metrorail Trips

 ; Input Forecast Year /Unconstrained Metrorail Trips:
  MATI[06] = HBWPKOPALL.ucn             ; t1-3 >HBW Pk,OffPk, Total Metrorail Trips
  MATI[07] = HBSPKOPALL.ucn             ; t1-3 >HBS Pk,OffPk, Total Metrorail Trips
  MATI[08] = HBOPKOPALL.ucn             ; t1-3 >HBO Pk,OffPk, Total Metrorail Trips
  MATI[09] = NHWPKOPALL.ucn             ; t1-3 >NHW Pk,OffPk, Total Metrorail Trips
  MATI[10] = NHOPKOPALL.ucn             ; t1-3 >NHO Pk,OffPk, Total Metrorail Trips

 ; Output 3x3 tables
   FILEO MATO[1] = tempsqz.dat, MO=1-20
         ;  sequence of squeezed (3x3) output trip tables
         ;  1- 5 ->> Constrained Peak  HBW,HBS,HBO,NHW,NHO Metrorail trips
         ;  6-10 ->> Constrained Daily HBW,HBS,HBO,NHW,NHO Metrorail trips
         ; 11-15 ->> Forecast    Peak  HBW,HBS,HBO,NHW,NHO Metrorail trips
         ; 16-20 ->> Forecast    Daily HBW,HBS,HBO,NHW,NHO Metrorail trips


  ; Read in Constrained Trips for each purpose (mw 1-10)
  MW[01] = MI.1.1       MW[06]=MI.1.3   ; HBW Pk,Total Trips (MWs 1,6)
  MW[02] = MI.2.1       MW[07]=MI.2.3   ; HBS Pk,Total Trips (MWs 2,7)
  MW[03] = MI.3.1       MW[08]=MI.3.3   ; HBO Pk,Total Trips (MWs 3,8)
  MW[04] = MI.4.1       MW[09]=MI.4.3   ; NHW Pk,Total Trips (MWs 4,9)
  MW[05] = MI.5.1       MW[10]=MI.5.3   ; NHO Pk,Total Trips (MWs 5,10)

  ; Read in Forecasted Transit Trips for each purpose  (mw 11-20)
  MW[11] = MI.6.1       MW[16]=MI.6.3   ; HBW Pk,Total Trn Trips (MWs 11,16)
  MW[12] = MI.7.1       MW[17]=MI.7.3   ; HBS Pk,Total Trn Trips (MWs 12,17)
  MW[13] = MI.8.1       MW[18]=MI.8.3   ; HBO Pk,Total Trn Trips (MWs 13,18)
  MW[14] = MI.9.1       MW[19]=MI.9.3   ; NHW Pk,Total Trn Trips (MWs 14,19)
  MW[15] = MI.10.1      MW[20]=MI.10.3  ; NHO Pk,Total Trn Trips (MWs 15,20)

 RENUMBER FILE=three.eqv, MISSINGZI=M, MISSINGZO=W
ENDRUN
;;-------------------------------------------------------------------------------------------
;;-------------------------------------------------------------------------------------------
;; create a zonal matrix that indicates 3 superdistrict interchange type
;; for example '11' means from SD 1 to SD 1,...,'33' means from SD 3 to SD 3
RUN PGM=MATRIX
ZONES= 3722
FILEO MATO[1] = superdist.dat, MO=100

IF (I=1405-1470,1477-1485,1490-1494,1498-1545        ) SDi=1  ;   ArlNCore       [1]------
IF (I=1546-1610                                      ) SDi=1  ;   Alex           [1]
IF (I=1611-2159                                      ) SDi=1  ;   FFx            [1]
IF (I=2160-2441                                      ) SDi=1  ;   LDn            [1]
IF (I=2442-2554,2556-2628,2630-2819                  ) SDi=1  ;   PW             [1] VA NonCore
IF (I=3604-3653                                      ) SDi=1  ;   Fau            [1]
IF (I=3449-3477,3479-3481,3483-3494,3496-3541        ) SDi=1  ;   Stf.           [1]
IF (I=3654-3662,3663-3675                            ) SDi=1  ;   Clk,Jeff.      [1]
IF (I=3435-3448,3542-3543,3545-3603                  ) SDi=1  ;   Fbg,Spots      [1]
IF (I=3410-3434                                      ) SDi=1  ;   KG.            [1]
IF (I=3676-3722                                      ) SDi=1  ;   Ext(unused)    [1]
IF (I=770,777,2555,2629,3103,3266-3267               ) SDi=1  ;   Unused         [1]
IF (I=3478,3482,3495,3544                            ) SDi=1  ;   Unused         [1]------
IF (I=1-4,6-47,49-50,52-63,65,181-209,282-287,374-381) SDi=2  ;   DC CORE        [2] Regional
IF (I=1471-1476, 1486-1489, 1495-1497                ) SDi=2  ;   ArlCore        [2]    Core
IF (I=5,48,51,64,66-180,210-281,288-373,382-393      ) SDi=3  ;   DC Noncore     [3]------
IF (I=394-769                                        ) SDi=3  ;   Montgomery     [3]
IF (I=771-776,778-1404                               ) SDi=3  ;   Prince George  [3]
IF (I=2820-2949                                      ) SDi=3  ;   Frd            [3] DC/
IF (I=3230-3265,3268-3287                            ) SDi=3  ;   Car.           [3]  MD Non-Core
IF (I=2950-3017                                      ) SDi=3  ;   How.           [3]
IF (I=3018-3102,3104-3116                            ) SDi=3  ;   AnnAr          [3]
IF (I=3288-3334                                      ) SDi=3  ;   Calv           [3]
IF (I=3335-3409                                      ) SDi=3  ;   StM            [3]
IF (I=3117-3229                                      ) SDi=3  ;   Chs.           [3]------

jloop
 IF (J=1405-1470,1477-1485,1490-1494,1498-1545        ) SDj=1  ;   ArlNCore       [1]------
 IF (J=1546-1610                                      ) SDj=1  ;   Alex           [1]
 IF (J=1611-2159                                      ) SDj=1  ;   FFx            [1]
 IF (J=2160-2441                                      ) SDj=1  ;   LDn            [1]
 IF (J=2442-2554,2556-2628,2630-2819                  ) SDj=1  ;   PW             [1] VA NonCore
 IF (J=3604-3653                                      ) SDj=1  ;   Fau            [1]
 IF (J=3449-3477,3479-3481,3483-3494,3496-3541        ) SDj=1  ;   Stf.           [1]
 IF (J=3654-3662,3663-3675                            ) SDj=1  ;   Clk,Jeff.      [1]
 IF (J=3435-3448,3542-3543,3545-3603                  ) SDj=1  ;   Fbg,Spots      [1]
 IF (J=3410-3434                                      ) SDj=1  ;   KG.            [1]
 IF (J=3676-3722                                      ) SDj=1  ;   Ext(unused)    [1]
 IF (J=770,777,2555,2629,3103,3266-3267               ) SDj=1  ;   Unused         [1]
 IF (J=3478,3482,3495,3544                            ) SDj=1  ;   Unused         [1]------
 IF (J=1-4,6-47,49-50,52-63,65,181-209,282-287,374-381) SDj=2  ;   DC CORE        [2] Regional
 IF (J=1471-1476, 1486-1489, 1495-1497                ) SDj=2  ;   ArlCore        [2]    Core
 IF (J=5,48,51,64,66-180,210-281,288-373,382-393      ) SDj=3  ;   DC Noncore     [3]------
 IF (J=394-769                                        ) SDj=3  ;   Montgomery     [3]
 IF (J=771-776,778-1404                               ) SDj=3  ;   Prince George  [3]
 IF (J=2820-2949                                      ) SDj=3  ;   Frd            [3] DC/
 IF (J=3230-3265,3268-3287                            ) SDj=3  ;   Car.           [3]  MD Non-Core
 IF (J=2950-3017                                      ) SDj=3  ;   How.           [3]
 IF (J=3018-3102,3104-3116                            ) SDj=3  ;   AnnAr          [3]
 IF (J=3288-3334                                      ) SDj=3  ;   Calv           [3]
 IF (J=3335-3409                                      ) SDj=3  ;   StM            [3]
 IF (J=3117-3229                                      ) SDj=3  ;   Chs.           [3]------

  mw[100][j] = SDi*10 + SDj
  IF (MW[100][j] = 0) Abort ;; if ANY ij is not assigned a non-zero interchange assignment stop
endjloop

;;-------------------------------------------------------------------------------------------
;;-------------------------------------------------------------------------------------------
ENDRUN

RUN PGM=MATRIX
; Read input Squeezed
ZONES=3
    MATI[1] = tempsqz.dat
  ; Read in Constraining Metrorail Trips for each purpose (mw 1-10)
  MW[1] = MI.1.1       MW[6] =MI.1.6  ; HBW Pk,Total Trips (MW1,6)
  MW[2] = MI.1.2       MW[7] =MI.1.7  ; HBS Pk,Total Trips (MW2,7)
  MW[3] = MI.1.3       MW[8] =MI.1.8  ; HBO Pk,Total Trips (MW3,8)
  MW[4] = MI.1.4       MW[9] =MI.1.9  ; NHW Pk,Total Trips (MW4,9)
  MW[5] = MI.1.5       MW[10]=MI.1.10 ; NHO Pk,Total Trips (MW5,10)

  ; Read in Forecasted Metrorail Trips for each purpose  (mw 11-20)
  MW[11] = MI.1.11      MW[16] =MI.1.16  ; HBW Pk,Total Trips (MW11,16)
  MW[12] = MI.1.12      MW[17] =MI.1.17  ; HBS Pk,Total Trips (MW12,17)
  MW[13] = MI.1.13      MW[18] =MI.1.18  ; HBO Pk,Total Trips (MW13,18)
  MW[14] = MI.1.14      MW[19] =MI.1.19  ; NHW Pk,Total Trips (MW14,19)
  MW[15] = MI.1.15      MW[20] =MI.1.20  ; NHO Pk,Total Trips (MW15,20)

;      Now calculate constrained factors on an ij basis
 JLOOP               ; Initialize transit constraint factors
   HBWConFtr = 1.000  ; HBW ftr
   HBSConFtr = 1.000  ; HBS Ftr
   HBOConFtr = 1.000  ; HBO Ftr
   NHWConFtr = 1.000  ; NHW Ftr
   NHOConFtr = 1.000  ; NHO Ftr

     IF ((I = 1 && J = 2) || ; IF from VA nonCore   to Regional Core
         (I = 1 && J = 3) || ; or from VA nonCore   to DC/MD Non Reg Core
         (I = 3 && J = 1) || ; or from MD/DCnonCore to VA    Non Reg Core
         (I = 3 && J = 2))   ; or from MD/DCnonCore to Regional Core
         ; THEN calculate peak constraint factor, by purpose
         ; Constrained Metrorail trips =
         ; UnCon. Daily trips - UnCon. Pk Trips + Constrained Pk Trips
          MW[21] = (MW[16]-MW[11])+MW[1] ; "Target" Constrained HBW Daily  Trips
          MW[22] = (MW[17]-MW[12])+MW[2] ; "Target" Constrained HBS Daily  Trips
          MW[23] = (MW[18]-MW[13])+MW[3] ; "Target" Constrained HBO Daily  Trips
          MW[24] = (MW[19]-MW[14])+MW[4] ; "Target" Constrained NHBW Daily  Trips
          MW[25] = (MW[20]-MW[15])+MW[5] ; "Target" Constrained NHO Daily  Trips

          ;  compute factors for moderating forecasted trips to constrained trips
          ;  also, do not allow factors be greater than 1.00 (some strange cases may exist)
          IF (MW[16]!=0)  HBWConFtr = MIN(1.00,(MW[21] / MW[16]))  ;  HBW
          IF (MW[17]!=0)  HBSConFtr = MIN(1.00,(MW[22] / MW[17]))  ;  HBS
          IF (MW[18]!=0)  HBOConFtr = MIN(1.00,(MW[23] / MW[18]))  ;  HBO
          IF (MW[19]!=0)  NHWConFtr = MIN(1.00,(MW[24] / MW[19]))  ;  NHW
          IF (MW[20]!=0)  NHOConFtr = MIN(1.00,(MW[25] / MW[20]))  ;  NHO


; Accumulate Final Constrained Metrorail trips
        HBW_FCT  = HBW_FCT + ((MW[16]-MW[11])+MW[1]) ; Constrained HBW Daily Trips
        HBS_FCT  = HBS_FCT + ((MW[17]-MW[12])+MW[2]) ; Constrained HBS Daily Trips
        HBO_FCT  = HBO_FCT + ((MW[18]-MW[13])+MW[3]) ; Constrained HBO Daily Trips
        NHW_FCT  = NHW_FCT + ((MW[19]-MW[14])+MW[4]) ; Constrained NHW Daily Trips
        NHO_FCT  = NHO_FCT + ((MW[20]-MW[15])+MW[5]) ; Constrained NHO Daily Trips

     ELSE

        HBW_FCT  = HBW_FCT + MW[16] ;                  Constrained HBW Daily Trips
        HBS_FCT  = HBS_FCT + MW[17] ;                  Constrained HBS Daily Trips
        HBO_FCT  = HBO_FCT + MW[18] ;                  Constrained HBO Daily Trips
        NHW_FCT  = NHW_FCT + MW[19] ;                  Constrained NHW Daily Trips
        NHO_FCT  = NHO_FCT + MW[20] ;                  Constrained NHO Daily Trips

     ENDIF



     IJ = I*10+j         ; create two digit no where 1st digit=i,2nd=j

; print ij, const pk&total,unconstr pk/total, final total trn trips,ftr
;  --one file for each purpose

  Print LIST = ij(4),MW[1](8),MW[6](8), MW[11](8),MW[16](8),MW[21](8),HBWConFtr(10.4),File=tconftr.HBW
  Print LIST = ij(4),MW[2](8),MW[7](8), MW[12](8),MW[17](8),MW[22](8),HBSConFtr(10.4),File=tconftr.HBS
  Print LIST = ij(4),MW[3](8),MW[8](8), MW[13](8),MW[18](8),MW[23](8),HBOConFtr(10.4),File=tconftr.HBO
  Print LIST = ij(4),MW[4](8),MW[9](8), MW[14](8),MW[19](8),MW[24](8),NHWConFtr(10.4),File=tconftr.NHW
  Print LIST = ij(4),MW[5](8),MW[10](8),MW[15](8),MW[20](8),MW[25](8),NHOConFtr(10.4),File=tconftr.NHO
 ENDJLOOP


IF (I=ZONES)
  Print LIST = ' Control Total HBW Constrained Transit Trips: ',HBW_FCT(10)
  Print LIST = ' Control Total HBS Constrained Transit Trips: ',HBS_FCT(10)
  Print LIST = ' Control Total HBO Constrained Transit Trips: ',HBO_FCT(10)
  Print LIST = ' Control Total NHW Constrained Transit Trips: ',NHW_FCT(10)
  Print LIST = ' Control Total NHO Constrained Transit Trips: ',NHO_FCT(10)
endif
; Now, Let's carry the control totals with us so we can compare with the
; zonal totals, that will be computed in the next step
LOG PREFIX = MATRIX, VAR = HBW_FCT, HBS_FCT, HBO_FCT, NHW_FCT, NHO_FCT
;
;
ENDRUN

;///////////////////////////////////////////////////////////////////
;
; Begin Step 3
;          future year constrained trips are computed by applying
;          the constraint factors to the zonal trip tables.
;          constrained transit trips are produced (i.e., residual auto
;          persons are generated. and LOV,HOV auto person/driver trips
;          are computed using existing distributions on a cell by cell
;          basis.
;
;\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
LOOP TIME = 1,5    ; Loop through for each purpose
   IF     (TIME=1)
      PRP     = 'HBW'                             ; Purpose code
      Control = MATRIX.HBW_FCT                    ; Transit Control Total
   ELSEIF (TIME=2)
      PRP   = 'HBS'                               ; Purpose Code
      Control = MATRIX.HBS_FCT                    ; Transit Control Total
   ELSEIF (TIME=3)
      PRP   = 'HBO'      ; Purpose code
      Control = MATRIX.HBO_FCT                    ; Transit Control Total
   ELSEIF (TIME=4)
      PRP   = 'NHW'                               ; Purpose code
      Control = MATRIX.NHW_FCT                    ; Transit Control Total
   ELSEIF (TIME=5)
      PRP   = 'NHO'      ; Purpose code
      Control = MATRIX.NHO_FCT                    ; Transit Control Total
   ENDIF

RUN PGM=MATRIX
ZONES = 3722
pageheight=32767  ; Preclude header breaks
;--------------------------------------------------------------------
;   Tables NL MC model outfile
;     1 DR ALONE                   All transit         4-14
;     2 SR2                        Metrorail only      7,13,14
;     3 SR3+                       Metrorail related   7,13,14,6,11,12
;     4 WK-CR                      Auto person         1-3
;     5 WK-BUS                     Total motorized psn 1-14
;     6 WK-BU/MR                   Commuter rail       4,8 (may incl bus/Mrail)
;     7 WK-MR                      Bus only            5,9,10
;     8 PNR-CR                     Bus only, WMATA Compact area
;     8 KNR-CR
;     9 PNR-BUS
;    10 KNR-BUS
;    11 PNR-BU/MR
;    12 KNR-BU/MR
;    13 PNR-MR
;    14 KNR-MR
;--------------------------------------------------------------------


; DEFINE INPUT/OUTPUT  FILES HERE:
  MATI[1] = %_iter_%_@prp@_NL_MC.MTT                        ; UNCONST. MODE CH TRIPS
  MATI[2] = superdist.dat                                   ; 3x3 super district ij indicator
  MATO[1] = %_iter_%_@prp@_NL_MC.CON,MO=201-214,dec = 14*3  ; CONSTR.  MODE CH TRIPS
  FILLMW MW[101]=MI.1.1,2,3,4,5,6,7,8,9,10,11,12,13,14      ; Read in Unconstrained NL MC tabs 1-14

  LOOKUP NAME=TCONFTR,
  LOOKUP[1]=1,RESULT=7,INTERPOLATE=N,LIST=T,FAIL=0,0,0,FILE=TCONFTR.@prp@

  MW[30] = MI.2.1   ; superdistrict ij indicator '11' to '33'
;
; Now Factor transit tables
;
  MW[31] = MW[101]  + MW[102]  + MW[103]                                                ;; Initial Auto Person
  MW[32] = MW[106]  + MW[107]  + MW[111]  + MW[112]  + MW[113]  + MW[114]               ;; Initial/Unconstr. Metrorail
  MW[33] = MW[104]  + MW[105]  + MW[106]  + MW[107]  +
           MW[108]  + MW[109]  + MW[110]  + MW[111]  + MW[112]  + MW[113]  + MW[114]    ;; Initial/Unconstrained Transit
  MW[34] = MW[101]  + MW[102]  + MW[103]  + MW[104]  + MW[105]  + MW[106]  + MW[107]  +
           MW[108]  + MW[109]  + MW[110]  + MW[111]  + MW[112]  + MW[113]  + MW[114]    ;; Initial Total Person

 JLOOP
     MW[204] = MW[104]                        ; unaffected  Transit
     MW[205] = MW[105]                        ; unaffected  Transit
     MW[206] = MW[106] * tconftr(1,MW[30])    ; Constrained Metrorail WK-BU/MR
     MW[207] = MW[107] * tconftr(1,MW[30])    ; Constrained Metrorail WK-MR
     MW[208] = MW[108]                        ; unaffected  Transit
     MW[209] = MW[109]                        ; unaffected  Transit
     MW[210] = MW[110]                        ; unaffected  Transit
     MW[211] = MW[111] * tconftr(1,MW[30])    ; Constrained Metrorail PNR-BU/MR
     MW[212] = MW[112] * tconftr(1,MW[30])    ; Constrained Metrorail KNR-BU/MR
     MW[213] = MW[113] * tconftr(1,MW[30])    ; Constrained Metrorail PNR-MR
     MW[214] = MW[114] * tconftr(1,MW[30])    ; Constrained Metrorail KNR-MR

     MW[42] = MW[206]  + MW[207]  + MW[211]  + MW[212]  + MW[213]  + MW[214]               ;; Constrained Metrorail
     MW[43] = MW[204]  + MW[205]  + MW[206]  + MW[207]  +
              MW[208]  + MW[209]  + MW[210]  + MW[211]  + MW[212]  + MW[213]  + MW[214]    ;; Constrained Transit


     MW[99] = MW[32] - MW[42]                ; Metrorail 'Residual' /Unconstrained - Constrained Metrorail
        IF (MW[99] < 0.0)                     ; - Make sure the residual is
            MW[99] = 0.0                      ;   NOT negative
        ENDIF                                 ;
     ;;
     ;; Now work on converting 'residual'  Metrorail trips among auto modes based on proration
     ;;

     MW[35] = MW[101] + MW[102] + MW[103]  ;; initial total auto person trips

     IF (mw[35] = 0.0)   ;; if no auto person trips exist, put residual transit trips into SOVs

        MW[201] = MW[99]                               ; Updated SOV   Psn
        MW[202] = 0.0                                  ; Updated HOV2  Psn
        MW[203] = 0.0                                  ; Updated HOV3+ Psn

         ELSE               ;; else, add residual trips to occupant groups based on existing proration

       MW[201] = MW[101] + (MW[99] * (MW[101]/MW[35])) ; Updated SOV   Psn
       MW[202] = MW[102] + (MW[99] * (MW[102]/MW[35])) ; Updated HOV2  Psn
       MW[203] = MW[103] + (MW[99] * (MW[103]/MW[35])) ; Updated HOV3+ Psn
     ENDIF

ENDJLOOP
;
;
;
JLOOP
     ;
     ; Now Accumulate Initial and Updated Totals /RATES Here:
     ;
     INI_SOV     = INI_SOV      + MW[101]
     INI_HOV_2   = INI_HOV_2    + MW[102]
     INI_HOV_3   = INI_HOV_3    + MW[103]
     INI_WLK_COM = INI_WLK_COM  + MW[104]
     INI_WLK_BUS = INI_WLK_BUS  + MW[105]
     INI_WLK_BMR = INI_WLK_BMR  + MW[106]
     INI_WLK_MR  = INI_WLK_MR   + MW[107]
     INI_PNR_COM = INI_PNR_COM  + MW[108]
     INI_PNR_BUS = INI_PNR_BUS  + MW[109]
     INI_KNR_BUS = INI_KNR_BUS  + MW[110]
     INI_PNR_BMR = INI_PNR_BMR  + MW[111]
     INI_KNR_BMR = INI_KNR_BMR  + MW[112]
     INI_PNR_MR  = INI_PNR_MR   + MW[113]
     INI_KNR_MR  = INI_KNR_MR   + MW[114]

     INI_Metro   = INI_Metro    + MW[106]  + MW[107]  + MW[111]  + MW[112]  + MW[113]  + MW[114]

     INI_Transit = INI_Transit  + MW[104]  + MW[105]  + MW[106]  + MW[107]  +
                                  MW[108]  + MW[109]  + MW[110]  + MW[111]  + MW[112]  + MW[113]  + MW[114]

     INI_AutoPsn = INI_AutoPsn  + MW[101]  + MW[102]  + MW[103]

     INI_Person  = INI_Person   + MW[101]  + MW[102]  + MW[103]  + MW[104]  + MW[105]  + MW[106]  + MW[107]  +
                                  MW[108]  + MW[109]  + MW[110]  + MW[111]  + MW[112]  + MW[113]  + MW[114]


     UPD_SOV     = UPD_SOV      + MW[201]
     UPD_HOV_2   = UPD_HOV_2    + MW[202]
     UPD_HOV_3   = UPD_HOV_3    + MW[203]
     UPD_WLK_COM = UPD_WLK_COM  + MW[204]
     UPD_WLK_BUS = UPD_WLK_BUS  + MW[205]
     UPD_WLK_BMR = UPD_WLK_BMR  + MW[206]
     UPD_WLK_MR  = UPD_WLK_MR   + MW[207]
     UPD_PNR_COM = UPD_PNR_COM  + MW[208]
     UPD_PNR_BUS = UPD_PNR_BUS  + MW[209]
     UPD_KNR_BUS = UPD_KNR_BUS  + MW[210]
     UPD_PNR_BMR = UPD_PNR_BMR  + MW[211]
     UPD_KNR_BMR = UPD_KNR_BMR  + MW[212]
     UPD_PNR_MR  = UPD_PNR_MR   + MW[213]
     UPD_KNR_MR  = UPD_KNR_MR   + MW[214]

     UPD_Metro   = UPD_Metro    + MW[206]  + MW[207]  + MW[211]  + MW[212]  + MW[213]  + MW[214]

     UPD_Transit = UPD_Transit  + MW[204]  + MW[205]  + MW[206]  + MW[207]  +
                                  MW[208]  + MW[209]  + MW[210]  + MW[211]  + MW[212]  + MW[213]  + MW[214]

     UPD_AutoPsn = UPD_AutoPsn  + MW[201]  + MW[202]  + MW[203]

     UPD_Person  = UPD_Person   + MW[201]  + MW[202]  + MW[203]  + MW[204]  + MW[205]  + MW[206]  + MW[207]  +
                                  MW[208]  + MW[209]  + MW[210]  + MW[211]  + MW[212]  + MW[213]  + MW[214]

ENDJLOOP


; If at end,  Get Global Mode differences and regional rates

if (i=zones)

; get differences by purpose (output - Input)

 DIF_SOV      = UPD_SOV      -  INI_SOV
 DIF_HOV_2    = UPD_HOV_2    -  INI_HOV_2
 DIF_HOV_3    = UPD_HOV_3    -  INI_HOV_3
 DIF_WLK_COM  = UPD_WLK_COM  -  INI_WLK_COM
 DIF_WLK_BUS  = UPD_WLK_BUS  -  INI_WLK_BUS
 DIF_WLK_BMR  = UPD_WLK_BMR  -  INI_WLK_BMR
 DIF_WLK_MR   = UPD_WLK_MR   -  INI_WLK_MR
 DIF_PNR_COM  = UPD_PNR_COM  -  INI_PNR_COM
 DIF_PNR_BUS  = UPD_PNR_BUS  -  INI_PNR_BUS
 DIF_KNR_BUS  = UPD_KNR_BUS  -  INI_KNR_BUS
 DIF_PNR_BMR  = UPD_PNR_BMR  -  INI_PNR_BMR
 DIF_KNR_BMR  = UPD_KNR_BMR  -  INI_KNR_BMR
 DIF_PNR_MR   = UPD_PNR_MR   -  INI_PNR_MR
 DIF_KNR_MR   = UPD_KNR_MR   -  INI_KNR_MR

 DIF_Metro    = UPD_Metro    -  INI_Metro
 DIF_Transit  = UPD_Transit  -  INI_Transit
 DIF_AutoPsn  = UPD_AutoPsn  -  INI_AutoPsn
 DIF_Person   = UPD_Person   -  INI_Person

; Calculate transit percentages, initial and updated

IF (INI_Person != 0)  INI_TrnPct = INI_Transit/ INI_Person * 100.00         ; input  %TRN
IF (UPD_Person != 0)  UPD_TrnPct = UPD_Transit/ UPD_Person * 100.00         ; output %TRN

DIF_TrnPct    =    UPD_TrnPct - INI_TrnPct


 CONTOTAL  = @control@ ; control total from previous step
LIST = '/bt     '
LIST = ' @prp@ METRORAIL CONSTRAINT RESULTS- Global Totals by Submode'
LIST = '       Initial and Final Totals by Mode','\n'
LIST = '    '
list = 'MODE                   ','  INITIAL ','  UPDATED ','DIFFERENCE'
list = '---------------------- ','  ------- ','  ------- ',' -------- '
LIST='  '
LIST = 'SOV                    ', INI_SOV(12.2csv),     UPD_SOV(12.2csv),      DIF_SOV(12.2csv)
LIST = 'HOV_2                  ', INI_HOV_2(12.2csv),   UPD_HOV_2(12.2csv),    DIF_HOV_2(12.2csv)
LIST = 'HOV_3                  ', INI_HOV_3(12.2csv),   UPD_HOV_3(12.2csv),    DIF_HOV_3(12.2csv)
LIST = 'WLK_COM                ', INI_WLK_COM(12.2csv), UPD_WLK_COM(12.2csv),  DIF_WLK_COM(12.2csv)
LIST = 'WLK_BUS                ', INI_WLK_BUS(12.2csv), UPD_WLK_BUS(12.2csv),  DIF_WLK_BUS(12.2csv)
LIST = 'WLK_BMR                ', INI_WLK_BMR(12.2csv), UPD_WLK_BMR(12.2csv),  DIF_WLK_BMR(12.2csv)
LIST = 'WLK_MR                 ', INI_WLK_MR(12.2csv),  UPD_WLK_MR(12.2csv),   DIF_WLK_MR(12.2csv)
LIST = 'PNR_COM                ', INI_PNR_COM(12.2csv), UPD_PNR_COM(12.2csv),  DIF_PNR_COM(12.2csv)
LIST = 'PNR_BUS                ', INI_PNR_BUS(12.2csv), UPD_PNR_BUS(12.2csv),  DIF_PNR_BUS(12.2csv)
LIST = 'KNR_BUS                ', INI_KNR_BUS(12.2csv), UPD_KNR_BUS(12.2csv),  DIF_KNR_BUS(12.2csv)
LIST = 'PNR_BMR                ', INI_PNR_BMR(12.2csv), UPD_PNR_BMR(12.2csv),  DIF_PNR_BMR(12.2csv)
LIST = 'KNR_BMR                ', INI_KNR_BMR(12.2csv), UPD_KNR_BMR(12.2csv),  DIF_KNR_BMR(12.2csv)
LIST = 'PNR_MR                 ', INI_PNR_MR(12.2csv),  UPD_PNR_MR(12.2csv),   DIF_PNR_MR(12.2csv)
LIST = 'KNR_MR                 ', INI_KNR_MR(12.2csv),  UPD_KNR_MR(12.2csv),   DIF_KNR_MR(12.2csv)
LIST='  '
LIST = 'TOTAL PERSON:          ', INI_Person(12.2csv),  UPD_Person(12.2csv),   DIF_Person(12.2csv)
LIST='  '
LIST = 'Metrorail              ', INI_Metro(12.2csv),   UPD_Metro(12.2csv),    DIF_Metro(12.2csv)
LIST = 'Transit:               ', INI_Transit(12.2csv), UPD_Transit(12.2csv),  DIF_Transit(12.2csv)
LIST = 'TRANSIT Control Total  ',    CONTOTAL(12.2csv), '                           <-- Based on Squeezed 3x3 Trips'
LIST = 'AutoPerson             ', INI_AutoPsn(12.2csv), UPD_AutoPsn(12.2csv),  DIF_AutoPsn(12.2csv)
LIST = 'Transit %:             ', INI_TrnPct(12.2csv),  UPD_TrnPct(12.2csv),   DIF_TrnPct(12.2csv)
LIST='  '
list = '/et       '
endif

ENDRUN
ENDLOOP
