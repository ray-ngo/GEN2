; ====================================================================
; Time-of-Day.s
; MWCOG Version 2.3 Model
; 4/3/12 - three decimals maintained for the MATO files ("dec = 3*3" added to mato statements)
;
;
;              Distribute Modeled Pump Prime Auto Driver Trips, i.e,
;              4 Purposes (HBW,HBS,HBO,NHB), 3 Modes (1,2,3+Occ Adrs)
;              among three time periods:
;
;              -  AM peak  (6:00AM   -  9:00 AM)  3 Hrs.
;              -  Midday   (9:00AM   -  3:00 PM)  6 Hrs.
;              -  PM peak  (3:00PM   -  7:00 PM)  4 Hrs.
;              -  Off-peak (All Other hrs      ) 11 Hrs.
;
;              file named: 'todcomp_2008HTS_AdjOP.dbf' is used.
;              It contains trip percentages for each time period
;              by purpose, mode, and direction.
;
;
;   Environment Variable:
;               _iter_  (Iteration indicator = 'pp','i1'-'i6'
; ====================================================================
;
;
;///////////////////////////////////////////////////////////////////
;                                                                 //
; Input/Output filenames:                                         //
;                                                                 //
TODFtrs = '..\support\todcomp_2008HTS.dbf' ; Time of Day Factor File
;                                                                 //
; I/P PP Auto Driver Trip Tables:                                 //  ; I/P PP Auto Driver Trip Tables:                                       //
 HBWADR = '%_iter_%_HBW_adr.mat' ; HBW  1,2,3+ Occ Adr Trips (t1-3)          //
 HBSADR = '%_iter_%_HBS_adr.mat' ; HBS  1,2,3+ Occ Adr Trips (t1-3)          //
 HBOADR = '%_iter_%_HBO_adr.mat' ; HBO  1,2,3+ Occ Adr Trips (t1-3)          //
 NHWADR = '%_iter_%_NHW_adr.mat' ; NHW  1,2,3+ Occ Adr Trips (t1-3)          //
 NHOADR = '%_iter_%_NHO_adr.mat' ; NHO  1,2,3+ Occ Adr Trips (t1-3)          //
;                                                                       //
; O/P Auto Dr. Pct. tables:                                             //
 ADRAM  = '%_iter_%_am_adr.mat'  ; AM     Modeled Total Auto Drivers         //
 ADRPM  = '%_iter_%_pm_adr.mat'  ; PM     Modeled Total Auto Drivers         //
 ADRMD  = '%_iter_%_md_adr.mat'  ; Midday Modeled Total Auto Drivers         //
 ADRNT  = '%_iter_%_nt_adr.mat'  ; Night  Modeled Total Auto Drivers         //
;

;; define TOD ARRAY parameters
Pur = 5  ;  1/HBW,   2/HBS,    3/HBO, 4/NHW, 5/NHO
Mod = 4  ;  1/Adr,   2/DrAlone 3/CarPoolPsn  4/Transit
Dir = 2  ;  1/H>NH,  2/NH>H
Per = 4  ;  1/AM,    2/MD,     3/PM,  4/NT


RUN PGM=MATRIX
pageheight=32767        ; Preclude header breaks
    MATI[1]=@HBWADR@    ; HBW 1,2,3+-Occ. Auto Drv. Trips(T1-3)
    MATI[2]=@HBSADR@    ; HBS 1,2,3+-Occ. Auto Drv. Trips(T1-3)
    MATI[3]=@HBOADR@    ; HBO 1,2,3+-Occ. Auto Drv. Trips(T1-3)
    MATI[4]=@NHWADR@    ; NHW 1,2,3+-Occ. Auto Drv. Trips(T1-3)
    MATI[5]=@NHOADR@    ; NHO 1,2,3+-Occ. Auto Drv. Trips(T1-3)


;  These are in P/A format and represent the Home-to-NonHome direction

    FILLMW  MW[111]  = MI.1.1,  MI.1.2,  MI.1.3 ;Work 1,2,3+ Occ Adrs P/A       t111-t113
    FILLMW  MW[121]  = MI.2.1,  MI.2.2,  MI.2.3 ;Shop 1,2,3+ Occ Adrs P/A       t121-t123
    FILLMW  MW[131]  = MI.3.1,  MI.3.2,  MI.3.3 ;Othr 1,2,3+ Occ Adrs P/A       t131-t133
    FILLMW  MW[141]  = MI.4.1,  MI.4.2,  MI.4.3 ;NHW  1,2,3+ Occ Adrs P/A       t141-t143
    FILLMW  MW[151]  = MI.5.1,  MI.5.2,  MI.5.3 ;NHO  1,2,3+ Occ Adrs P/A       t151-t153

; Put Transpose of the above
; HBW, HBS, HBO, NHW, NHO trip tables
;
MW[211]=MI.1.1.T, MW[212]=MI.1.2.T, MW[213]=MI.1.3.T; HBW 1,2,3+ Occ Adrs A/P   t211-213
MW[221]=MI.2.1.T, MW[222]=MI.2.2.T, MW[223]=MI.2.3.T; HBS 1,2,3+ Occ Adrs A/P   t221-223
MW[231]=MI.3.1.T, MW[232]=MI.3.2.T, MW[233]=MI.3.3.T; HBO 1,2,3+ Occ Adrs A/P   t231-233
MW[241]=MI.4.1.T, MW[242]=MI.4.2.T, MW[243]=MI.4.3.T; NHW 1,2,3+ Occ Adrs A/P   t241-243
MW[251]=MI.5.1.T, MW[252]=MI.5.2.T, MW[253]=MI.5.3.T; NHO 1,2,3+ Occ Adrs A/P   t251-253

;
; Now read TOD factors  file
;

Array TODFtrs  =@Pur@,@Mod@,@Dir@,@Per@

;==============================================================================================
;==============================================================================================
; Read in Time of Day factor file and populate TOD factor array

FILEI DBI[1]    ="@TODFtrs@"
LOOP K = 1,dbi.1.NUMRECORDS       ;;PURP    MODE    DIR     AM      MD      PM      OP

     x = DBIReadRecord(1,k)
           count       = dbi.1.recno
           TODFtrs[di.1.Purp][di.1.Mode][di.1.DIR][1] = di.1.AM
           TODFtrs[di.1.Purp][di.1.Mode][di.1.DIR][2] = di.1.MD
           TODFtrs[di.1.Purp][di.1.Mode][di.1.DIR][3] = di.1.PM
           TODFtrs[di.1.Purp][di.1.Mode][di.1.DIR][4] = di.1.OP
ENDLOOP
;==============================================================================================
;==============================================================================================


JLOOP

;;              Trips            p  m  d  p            Trips             p  m  d  p
;;              in               u  o  i  e            in                u  o  i  e
;;              H-NH Dir         r  d  r  r            H-NH Dir          r  d  r  r
;;              |                |  |  |  |             |                |  |  |  |
;
   mw[501] =  (MW[111] * (TODFtrs[1][2][1][1]/100.00) + MW[211]* (TODFtrs[1][2][2][1]/100.00)) / 2.0  ;   HBW / DA             *****
   mw[502] =  (MW[112] * (TODFtrs[1][3][1][1]/100.00) + MW[212]* (TODFtrs[1][3][2][1]/100.00)) / 2.0  ;   HBW / 2-occ carpool  *   *
   mw[503] =  (MW[113] * (TODFtrs[1][3][1][1]/100.00) + MW[213]* (TODFtrs[1][3][2][1]/100.00)) / 2.0  ;   HBW / 3+occ carpool  * A *
                                                                                                 ;                       * M *
   mw[504] =  (MW[121] * (TODFtrs[2][2][1][1]/100.00) + MW[221]* (TODFtrs[2][2][2][1]/100.00)) / 2.0  ;   HBS / DA             *   *
   mw[505] =  (MW[122] * (TODFtrs[2][3][1][1]/100.00) + MW[222]* (TODFtrs[2][3][2][1]/100.00)) / 2.0  ;   HBS / 2-occ carpool  * P *
   mw[506] =  (MW[123] * (TODFtrs[2][3][1][1]/100.00) + MW[223]* (TODFtrs[2][3][2][1]/100.00)) / 2.0  ;   HBS / 3+occ carpool  * E *
                                                                                                 ;                       * A *
   mw[507] =  (MW[131] * (TODFtrs[3][2][1][1]/100.00) + MW[231]* (TODFtrs[3][2][2][1]/100.00)) / 2.0  ;   HBO / DA             * K *
   mw[508] =  (MW[132] * (TODFtrs[3][3][1][1]/100.00) + MW[232]* (TODFtrs[3][3][2][1]/100.00)) / 2.0  ;   HBO / 2-occ carpool  *   *
   mw[509] =  (MW[133] * (TODFtrs[3][3][1][1]/100.00) + MW[233]* (TODFtrs[3][3][2][1]/100.00)) / 2.0  ;   HBO / 3+occ carpool  * P *
                                                                                                 ;                       * E *
   mw[510] =  (MW[141] * (TODFtrs[4][2][1][1]/100.00) + MW[241]* (TODFtrs[4][2][2][1]/100.00)) / 2.0  ;   NHW / DA             * R *
   mw[511] =  (MW[142] * (TODFtrs[4][3][1][1]/100.00) + MW[242]* (TODFtrs[4][3][2][1]/100.00)) / 2.0  ;   NHW / 2-occ carpool  * I *
   mw[512] =  (MW[143] * (TODFtrs[4][3][1][1]/100.00) + MW[243]* (TODFtrs[4][3][2][1]/100.00)) / 2.0  ;   NHW / 3+occ carpool  * O *
                                                                                                 ;                       * D *
   mw[513] =  (MW[151] * (TODFtrs[5][2][1][1]/100.00) + MW[251]* (TODFtrs[5][2][2][1]/100.00)) / 2.0  ;   NHO / DA             *   *
   mw[514] =  (MW[152] * (TODFtrs[5][3][1][1]/100.00) + MW[252]* (TODFtrs[5][3][2][1]/100.00)) / 2.0  ;   NHO / 2-occ carpool  *   *
   mw[515] =  (MW[153] * (TODFtrs[5][3][1][1]/100.00) + MW[253]* (TODFtrs[5][3][2][1]/100.00)) / 2.0  ;   NHO / 3+occ carpool  *****

;;

   mw[516] =  (MW[111] * (TODFtrs[1][2][1][2]/100.00) + MW[211]* (TODFtrs[1][2][2][2]/100.00)) / 2.0  ;   HBW / DA             *****
   mw[517] =  (MW[112] * (TODFtrs[1][3][1][2]/100.00) + MW[212]* (TODFtrs[1][3][2][2]/100.00)) / 2.0  ;   HBW / 2-occ carpool  *   *
   mw[518] =  (MW[113] * (TODFtrs[1][3][1][2]/100.00) + MW[213]* (TODFtrs[1][3][2][2]/100.00)) / 2.0  ;   HBW / 3+occ carpool  * M *
                                                                                                 ;                       * I *
   mw[519] =  (MW[121] * (TODFtrs[2][2][1][2]/100.00) + MW[221]* (TODFtrs[2][2][2][2]/100.00)) / 2.0  ;   HBS / DA             * D *
   mw[520] =  (MW[122] * (TODFtrs[2][3][1][2]/100.00) + MW[222]* (TODFtrs[2][3][2][2]/100.00)) / 2.0  ;   HBS / 2-occ carpool  * D *
   mw[521] =  (MW[123] * (TODFtrs[2][3][1][2]/100.00) + MW[223]* (TODFtrs[2][3][2][2]/100.00)) / 2.0  ;   HBS / 3+occ carpool  * A *
                                                                                                 ;                       * Y *
   mw[522] =  (MW[131] * (TODFtrs[3][2][1][2]/100.00) + MW[231]* (TODFtrs[3][2][2][2]/100.00)) / 2.0  ;   HBO / DA             *   *
   mw[523] =  (MW[132] * (TODFtrs[3][3][1][2]/100.00) + MW[232]* (TODFtrs[3][3][2][2]/100.00)) / 2.0  ;   HBO / 2-occ carpool  *   *
   mw[524] =  (MW[133] * (TODFtrs[3][3][1][2]/100.00) + MW[233]* (TODFtrs[3][3][2][2]/100.00)) / 2.0  ;   HBO / 3+occ carpool  * P *
                                                                                                 ;                       * E *
   mw[525] =  (MW[141] * (TODFtrs[4][2][1][2]/100.00) + MW[241]* (TODFtrs[4][2][2][2]/100.00)) / 2.0  ;   NHW / DA             * R *
   mw[526] =  (MW[142] * (TODFtrs[4][3][1][2]/100.00) + MW[242]* (TODFtrs[4][3][2][2]/100.00)) / 2.0  ;   NHW / 2-occ carpool  * I *
   mw[527] =  (MW[143] * (TODFtrs[4][3][1][2]/100.00) + MW[243]* (TODFtrs[4][3][2][2]/100.00)) / 2.0  ;   NHW / 3+occ carpool  * O *
                                                                                                 ;                       * D *
   mw[528] =  (MW[151] * (TODFtrs[5][2][1][2]/100.00) + MW[251]* (TODFtrs[5][2][2][2]/100.00)) / 2.0  ;   NHO / DA             *   *
   mw[529] =  (MW[152] * (TODFtrs[5][3][1][2]/100.00) + MW[252]* (TODFtrs[5][3][2][2]/100.00)) / 2.0  ;   NHO / 2-occ carpool  *   *
   mw[530] =  (MW[153] * (TODFtrs[5][3][1][2]/100.00) + MW[253]* (TODFtrs[5][3][2][2]/100.00)) / 2.0  ;   NHO / 3+occ carpool  *****

;;

   mw[531] =  (MW[111] * (TODFtrs[1][2][1][3]/100.00) + MW[211]* (TODFtrs[1][2][2][3]/100.00)) / 2.0  ;   HBW / DA             *****
   mw[532] =  (MW[112] * (TODFtrs[1][3][1][3]/100.00) + MW[212]* (TODFtrs[1][3][2][3]/100.00)) / 2.0  ;   HBW / 2-occ carpool  *   *
   mw[533] =  (MW[113] * (TODFtrs[1][3][1][3]/100.00) + MW[213]* (TODFtrs[1][3][2][3]/100.00)) / 2.0  ;   HBW / 3+occ carpool  * P *
                                                                                                 ;                       * M *
   mw[534] =  (MW[121] * (TODFtrs[2][2][1][3]/100.00) + MW[221]* (TODFtrs[2][2][2][3]/100.00)) / 2.0  ;   HBS / DA             *   *
   mw[535] =  (MW[122] * (TODFtrs[2][3][1][3]/100.00) + MW[222]* (TODFtrs[2][3][2][3]/100.00)) / 2.0  ;   HBS / 2-occ carpool  * P *
   mw[536] =  (MW[123] * (TODFtrs[2][3][1][3]/100.00) + MW[223]* (TODFtrs[2][3][2][3]/100.00)) / 2.0  ;   HBS / 3+occ carpool  * E *
                                                                                                 ;                       * A *
   mw[537] =  (MW[131] * (TODFtrs[3][2][1][3]/100.00) + MW[231]* (TODFtrs[3][2][2][3]/100.00)) / 2.0  ;   HBO / DA             * K *
   mw[538] =  (MW[132] * (TODFtrs[3][3][1][3]/100.00) + MW[232]* (TODFtrs[3][3][2][3]/100.00)) / 2.0  ;   HBO / 2-occ carpool  *   *
   mw[539] =  (MW[133] * (TODFtrs[3][3][1][3]/100.00) + MW[233]* (TODFtrs[3][3][2][3]/100.00)) / 2.0  ;   HBO / 3+occ carpool  * P *
                                                                                                 ;                       * E *
   mw[540] =  (MW[141] * (TODFtrs[4][2][1][3]/100.00) + MW[241]* (TODFtrs[4][2][2][3]/100.00)) / 2.0  ;   NHW / DA             * R *
   mw[541] =  (MW[142] * (TODFtrs[4][3][1][3]/100.00) + MW[242]* (TODFtrs[4][3][2][3]/100.00)) / 2.0  ;   NHW / 2-occ carpool  * I *
   mw[542] =  (MW[143] * (TODFtrs[4][3][1][3]/100.00) + MW[243]* (TODFtrs[4][3][2][3]/100.00)) / 2.0  ;   NHW / 3+occ carpool  * O *
                                                                                                 ;                       * D *
   mw[543] =  (MW[151] * (TODFtrs[5][2][1][3]/100.00) + MW[251]* (TODFtrs[5][2][2][3]/100.00)) / 2.0  ;   NHO / DA             *   *
   mw[544] =  (MW[152] * (TODFtrs[5][3][1][3]/100.00) + MW[252]* (TODFtrs[5][3][2][3]/100.00)) / 2.0  ;   NHO / 2-occ carpool  *   *
   mw[545] =  (MW[153] * (TODFtrs[5][3][1][3]/100.00) + MW[253]* (TODFtrs[5][3][2][3]/100.00)) / 2.0  ;   NHO / 3+occ carpool  *****

;;

   mw[546] =  (MW[111] * (TODFtrs[1][2][1][4]/100.00) + MW[211]* (TODFtrs[1][2][2][4]/100.00)) / 2.0  ;   HBW / DA             *****
   mw[547] =  (MW[112] * (TODFtrs[1][3][1][4]/100.00) + MW[212]* (TODFtrs[1][3][2][4]/100.00)) / 2.0  ;   HBW / 2-occ carpool  * O *
   mw[548] =  (MW[113] * (TODFtrs[1][3][1][4]/100.00) + MW[213]* (TODFtrs[1][3][2][4]/100.00)) / 2.0  ;   HBW / 3+occ carpool  * F *
                                                                                                 ;                       * F *
   mw[549] =  (MW[121] * (TODFtrs[2][2][1][4]/100.00) + MW[221]* (TODFtrs[2][2][2][4]/100.00)) / 2.0  ;   HBS / DA             *   *
   mw[550] =  (MW[122] * (TODFtrs[2][3][1][4]/100.00) + MW[222]* (TODFtrs[2][3][2][4]/100.00)) / 2.0  ;   HBS / 2-occ carpool  * P *
   mw[551] =  (MW[123] * (TODFtrs[2][3][1][4]/100.00) + MW[223]* (TODFtrs[2][3][2][4]/100.00)) / 2.0  ;   HBS / 3+occ carpool  * E *
                                                                                                 ;                       * A *
   mw[552] =  (MW[131] * (TODFtrs[3][2][1][4]/100.00) + MW[231]* (TODFtrs[3][2][2][4]/100.00)) / 2.0  ;   HBO / DA             * K *
   mw[553] =  (MW[132] * (TODFtrs[3][3][1][4]/100.00) + MW[232]* (TODFtrs[3][3][2][4]/100.00)) / 2.0  ;   HBO / 2-occ carpool  *   *
   mw[554] =  (MW[133] * (TODFtrs[3][3][1][4]/100.00) + MW[233]* (TODFtrs[3][3][2][4]/100.00)) / 2.0  ;   HBO / 3+occ carpool  * P *
                                                                                                 ;                       * E *
   mw[555] =  (MW[141] * (TODFtrs[4][2][1][4]/100.00) + MW[241]* (TODFtrs[4][2][2][4]/100.00)) / 2.0  ;   NHW / DA             * R *
   mw[556] =  (MW[142] * (TODFtrs[4][3][1][4]/100.00) + MW[242]* (TODFtrs[4][3][2][4]/100.00)) / 2.0  ;   NHW / 2-occ carpool  * I *
   mw[557] =  (MW[143] * (TODFtrs[4][3][1][4]/100.00) + MW[243]* (TODFtrs[4][3][2][4]/100.00)) / 2.0  ;   NHW / 3+occ carpool  * O *
                                                                                                 ;                       * D *
   mw[558] =  (MW[151] * (TODFtrs[5][2][1][4]/100.00) + MW[251]* (TODFtrs[5][2][2][4]/100.00)) / 2.0  ;   NHO / DA             *   *
   mw[559] =  (MW[152] * (TODFtrs[5][3][1][4]/100.00) + MW[252]* (TODFtrs[5][3][2][4]/100.00)) / 2.0  ;   NHO / 2-occ carpool  *   *
   mw[560] =  (MW[153] * (TODFtrs[5][3][1][4]/100.00) + MW[253]* (TODFtrs[5][3][2][4]/100.00)) / 2.0  ;   NHO / 3+occ carpool  *****

;
;-----------------------------------------------------------------------
; Summarize by purpose for checking - 601/hbw, 602/hbs, 603/hbo, 604/nhw, 605/nho
; Total HBW:
 MW[601]= MW[501]+MW[502]+MW[503] + MW[516]+MW[517]+MW[518] + MW[531]+MW[532]+MW[533] + MW[546]+MW[547]+MW[548]
; Total HBS:
 MW[602]= MW[504]+MW[505]+MW[506] + MW[519]+MW[520]+MW[521] + MW[534]+MW[535]+MW[536] + MW[549]+MW[550]+MW[551]
; Total HBO:
 MW[603]= MW[507]+MW[508]+MW[509] + MW[522]+MW[523]+MW[524] + MW[537]+MW[538]+MW[539] + MW[552]+MW[553]+MW[554]
; Total NHW:
 MW[604]= MW[510]+MW[511]+MW[512] + MW[525]+MW[526]+MW[527] + MW[540]+MW[541]+MW[542] + MW[555]+MW[556]+MW[557]
; Total NHO:
 MW[605]= MW[513]+MW[514]+MW[515] + MW[528]+MW[529]+MW[530] + MW[543]+MW[544]+MW[545] + MW[558]+MW[559]+MW[560]

;-----------------------------------------------------------------------
; Summarize by Time period, Occ Group for Assignment    611-622
;
 MW[611]= MW[501]+MW[504]+MW[507]+MW[510]+MW[513]  ; AM 1-Occ adrs
 MW[612]= MW[502]+MW[505]+MW[508]+MW[511]+MW[514]  ; AM 2-Occ adrs
 MW[613]= MW[503]+MW[506]+MW[509]+MW[512]+MW[515]  ; AM 3+Occ adrs
;
 MW[614]= MW[516]+MW[519]+MW[522]+MW[525]+MW[528]  ; MD 1-Occ adrs
 MW[615]= MW[517]+MW[520]+MW[523]+MW[526]+MW[529]  ; MD 2-Occ adrs
 MW[616]= MW[518]+MW[521]+MW[524]+MW[527]+MW[530]  ; MD 3+Occ adrs
;
 MW[617]= MW[531]+MW[534]+MW[537]+MW[540]+MW[543]  ; PM 1-Occ adrs
 MW[618]= MW[532]+MW[535]+MW[538]+MW[541]+MW[544]  ; PM 2-Occ adrs
 MW[619]= MW[533]+MW[536]+MW[539]+MW[542]+MW[545]  ; PM 3+Occ adrs
;
 MW[620]= MW[546]+MW[549]+MW[552]+MW[555]+MW[558]  ; OP 1-Occ adrs
 MW[621]= MW[547]+MW[550]+MW[553]+MW[556]+MW[559]  ; OP 2-Occ adrs
 MW[622]= MW[548]+MW[551]+MW[554]+MW[557]+MW[560]  ; OP 3+Occ adrs

; Now summarize regional totals to summarize neatly

;;AM;;
; am hbw, hbs, hbo, nhb by occupant totals:
amhbw1=amhbw1+MW[501], amhbw2=amhbw2+MW[502], amhbw3=amhbw3+MW[503]
amhbs1=amhbs1+MW[504], amhbs2=amhbs2+MW[505], amhbs3=amhbs3+MW[506]
amhbo1=amhbo1+MW[507], amhbo2=amhbo2+MW[508], amhbo3=amhbo3+MW[509]
amnhw1=amnhw1+MW[510], amnhw2=amnhw2+MW[511], amnhw3=amnhw3+MW[512]
amnho1=amnho1+MW[513], amnho2=amnho2+MW[514], amnho3=amnho3+MW[515]
; am hbw, hbs, hbo, nhb totals:
amhbw =amhbw + MW[501] + MW[502] + MW[503]
amhbs =amhbs + MW[504] + MW[505] + MW[506]
amhbo =amhbo + MW[507] + MW[508] + MW[509]
amnhw =amnhw + MW[510] + MW[511] + MW[512]
amnho =amnho + MW[513] + MW[514] + MW[515]
; am occupant level totals:
am1   =am1   +MW[611],am2   =am2   +MW[612],am3   =am3   +MW[613]
; am totals:
am    =am    +MW[611]              +MW[612]              +MW[613]


;;MD;;
; md hbw, hbs, hbo, nhb by occupant totals:
mdhbw1=mdhbw1+MW[516], mdhbw2=mdhbw2+MW[517], mdhbw3=mdhbw3+MW[518]
mdhbs1=mdhbs1+MW[519], mdhbs2=mdhbs2+MW[520], mdhbs3=mdhbs3+MW[521]
mdhbo1=mdhbo1+MW[522], mdhbo2=mdhbo2+MW[523], mdhbo3=mdhbo3+MW[524]
mdnhw1=mdnhw1+MW[525], mdnhw2=mdnhw2+MW[526], mdnhw3=mdnhw3+MW[527]
mdnho1=mdnho1+MW[528], mdnho2=mdnho2+MW[529], mdnho3=mdnho3+MW[530]
; md hbw, hbs, hbo, nhb totals:
mdhbw =mdhbw + MW[516] + MW[517] + MW[518]
mdhbs =mdhbs + MW[519] + MW[520] + MW[521]
mdhbo =mdhbo + MW[522] + MW[523] + MW[524]
mdnhw =mdnhw + MW[525] + MW[526] + MW[527]
mdnho =mdnho + MW[528] + MW[529] + MW[530]
; md occupant level totals:
md1   =md1   +MW[614],md2   =md2   +MW[615],md3   =md3   +MW[616]
; md totals:
md    =md    +MW[614]              +MW[615]              +MW[616]

;;PM;;
; pm hbw, hbs, hbo, nhb by occupant totals:
pmhbw1=pmhbw1+MW[531], pmhbw2=pmhbw2+MW[532], pmhbw3=pmhbw3+MW[533]
pmhbs1=pmhbs1+MW[534], pmhbs2=pmhbs2+MW[535], pmhbs3=pmhbs3+MW[536]
pmhbo1=pmhbo1+MW[537], pmhbo2=pmhbo2+MW[538], pmhbo3=pmhbo3+MW[539]
pmnhw1=pmnhw1+MW[540], pmnhw2=pmnhw2+MW[541], pmnhw3=pmnhw3+MW[542]
pmnho1=pmnho1+MW[543], pmnho2=pmnho2+MW[544], pmnho3=pmnho3+MW[545]
; pm hbw, hbs, hbo, nhb totals:
pmhbw =pmhbw + MW[531] + MW[532] + MW[533]
pmhbs =pmhbs + MW[534] + MW[535] + MW[536]
pmhbo =pmhbo + MW[537] + MW[538] + MW[539]
pmnhw =pmnhw + MW[540] + MW[541] + MW[542]
pmnho =pmnho + MW[543] + MW[544] + MW[545]
; pm occupant level totals:
pm1   =pm1   +MW[617],pm2   =pm2   +MW[618],pm3   =pm3   +MW[619]
; pm totals:
pm    =pm    +MW[617]              +MW[618]              +MW[619]

;;OP;;
; op hbw, hbs, hbo, nhb by occupant totals:
ophbw1=ophbw1+MW[546], ophbw2=ophbw2+MW[547], ophbw3=ophbw3+MW[548]
ophbs1=ophbs1+MW[549], ophbs2=ophbs2+MW[550], ophbs3=ophbs3+MW[551]
ophbo1=ophbo1+MW[552], ophbo2=ophbo2+MW[553], ophbo3=ophbo3+MW[554]
opnhw1=opnhw1+MW[555], opnhw2=opnhw2+MW[556], opnhw3=opnhw3+MW[557]
opnho1=opnho1+MW[558], opnho2=opnho2+MW[559], opnho3=opnho3+MW[560]
; op hbw, hbs, hbo, nhb totals:
ophbw =ophbw + MW[546] + MW[547] + MW[548]
ophbs =ophbs + MW[549] + MW[550] + MW[551]
ophbo =ophbo + MW[552] + MW[553] + MW[554]
opnhw =opnhw + MW[555] + MW[556] + MW[557]
opnho =opnho + MW[558] + MW[559] + MW[560]
; op occupant level totals:
op1   =op1   +MW[620],op2   =op2   +MW[621],op3   =op3   +MW[622]
; op totals:
op    =op    +MW[620]              +MW[621]              +MW[622]

;===============================================================================
;===============================================================================
; total output trips by purpose--output total:
 ohbw=ohbw+MW[601], ohbs=ohbs+MW[602], ohbo=ohbo+MW[603], onhw=onhw+MW[604], onho=onho+MW[605]

; total grand Total of output auto driver trips:
 adr = adr + MW[601] + MW[602] + MW[603] + MW[604] + MW[605]

; total input trips by purpose
 ihbw=ihbw + MW[111]  + MW[112]  + MW[113]
 ihbs=ihbs + MW[121]  + MW[122]  + MW[123]
 ihbo=ihbo + MW[131]  + MW[132]  + MW[133]
 inhw=inhw + MW[141]  + MW[142]  + MW[143]
 inho=inho + MW[151]  + MW[152]  + MW[153]

ENDJLOOP


; now write out the totals neatly:
if (i=zones)
; get differences by purpose (output - Input)
dfhbw = ohbw - ihbw;
dfhbs = ohbs - ihbs;
dfhbo = ohbo - ihbo;
dfnhw = onhw - inhw;
dfnho = onho - inho;

LIST = '/bt     '
LIST = ' Modeled Pump Prime Time-of-Day Results','\n'
list = 'AM Period:  1-Occ.  2-Occ.  3+Occ.      Total'
list = 'HBW       ',amhbw1(8.0),amhbw2(8.0),amhbw3(8.0),'    ',amhbw(8.0)
list = 'HBS       ',amhbs1(8.0),amhbs2(8.0),amhbs3(8.0),'    ',amhbs(8.0)
list = 'HBO       ',amhbo1(8.0),amhbo2(8.0),amhbo3(8.0),'    ',amhbo(8.0)
list = 'NHW       ',amnhw1(8.0),amnhw2(8.0),amnhw3(8.0),'    ',amnhw(8.0)
list = 'NHO       ',amnho1(8.0),amnho2(8.0),amnho3(8.0),'    ',amnho(8.0)
list = '----------------------------------------------'
list = 'Subtotal: ',am1(8.0),am2(8.0),am3(8.0),'    ',am(8.0)
list = '  '
list = '  '
list = 'Midday:     1-Occ.  2-Occ.  3+Occ.      Total'
list = 'HBW       ',mdhbw1(8.0),mdhbw2(8.0),mdhbw3(8.0),'    ',mdhbw(8.0)
list = 'HBS       ',mdhbs1(8.0),mdhbs2(8.0),mdhbs3(8.0),'    ',mdhbs(8.0)
list = 'HBO       ',mdhbo1(8.0),mdhbo2(8.0),mdhbo3(8.0),'    ',mdhbo(8.0)
list = 'NHW       ',mdnhw1(8.0),mdnhw2(8.0),mdnhw3(8.0),'    ',mdnhw(8.0)
list = 'NHO       ',mdnho1(8.0),mdnho2(8.0),mdnho3(8.0),'    ',mdnho(8.0)
list = '----------------------------------------------'
list = 'Subtotal: ',md1(8.0),md2(8.0),md3(8.0),'    ',md(8.0)
list = '  '
list = '  '
list = 'PM Period:  1-Occ.  2-Occ.  3+Occ.      Total'
list = 'HBW       ',pmhbw1(8.0),pmhbw2(8.0),pmhbw3(8.0),'    ',pmhbw(8.0)
list = 'HBS       ',pmhbs1(8.0),pmhbs2(8.0),pmhbs3(8.0),'    ',pmhbs(8.0)
list = 'HBO       ',pmhbo1(8.0),pmhbo2(8.0),pmhbo3(8.0),'    ',pmhbo(8.0)
list = 'NHW       ',pmnhw1(8.0),pmnhw2(8.0),pmnhw3(8.0),'    ',pmnhw(8.0)
list = 'NHO       ',pmnho1(8.0),pmnho2(8.0),pmnho3(8.0),'    ',pmnho(8.0)
list = '----------------------------------------------'
list = 'Subtotal: ',pm1(8.0),pm2(8.0),pm3(8.0),'    ',pm(8.0)
list = '  '
list = '  '
list = 'Night:      1-Occ.  2-Occ.  3+Occ.      Total'
list = 'HBW       ',ophbw1(8.0),ophbw2(8.0),ophbw3(8.0),'    ',ophbw(8.0)
list = 'HBS       ',ophbs1(8.0),ophbs2(8.0),ophbs3(8.0),'    ',ophbs(8.0)
list = 'HBO       ',ophbo1(8.0),ophbo2(8.0),ophbo3(8.0),'    ',ophbo(8.0)
list = 'NHW       ',opnhw1(8.0),opnhw2(8.0),opnhw3(8.0),'    ',opnhw(8.0)
list = 'NHO       ',opnho1(8.0),opnho2(8.0),opnho3(8.0),'    ',opnho(8.0)
list = '----------------------------------------------'
list = 'Subtotal: ',op1(8.0),op2(8.0),op3(8.0),'    ',op(8.0)
list = '  '
list = '  '
list = ' Input / Output Totals by Purpose:
list = '                           Diff.      '
list = '             Input    Output    (O-I)      '
list = 'HBW       ',ihbw(8.0),'  ',ohbw(8.0),'  ',dfhbw(8.0)
list = 'HBS       ',ihbs(8.0),'  ',ohbs(8.0),'  ',dfhbs(8.0)
list = 'HBO       ',ihbo(8.0),'  ',ohbo(8.0),'  ',dfhbo(8.0)
list = 'NHW       ',inhw(8.0),'  ',onhw(8.0),'  ',dfnhw(8.0)
list = 'NHO       ',inho(8.0),'  ',onho(8.0),'  ',dfnho(8.0)
list = '  '
list = 'Total Auto Drv:',adr(8.0)

list = '/et       '
endif

am1   =am1   +MW[611],am2   =am2   +MW[612],am3   =am3   +MW[613]
md1   =md1   +MW[614],md2   =md2   +MW[615],md3   =md3   +MW[616]
pm1   =pm1   +MW[617],pm2   =pm2   +MW[618],pm3   =pm3   +MW[619]
op1   =op1   +MW[620],op2   =op2   +MW[621],op3   =op3   +MW[622]

;;  Write out the auto driver files for each time period, 3 tables in each file (1-,2-, 3+occ)

   MATO[1] = @ADRAM@, MO=611-613,; AM peak period Auto Drv Trips 1,2,3+occ tabs 1-3
             name = AM_ADRs_1,AM_ADRs_2,AM_ADRs_3, dec=3*3

   MATO[2] = @ADRMD@, MO=614-616, ; Midday  period Auto Drv Trips 1,2,3+occ tabs 1-3
             name = MD_ADRs_1,MD_ADRs_2,MD_ADRs_3, dec=3*3

   MATO[3] = @ADRPM@, MO=617-619, ; PM peak period Auto Drv Trips 1,2,3+occ tabs 1-3
             name = PM_ADRs_1,PM_ADRs_2,PM_ADRs_3, dec=3*3

   MATO[4] = @ADRNT@, MO=620-622, ; Night   period Auto Drv Trips 1,2,3+occ tabs 1-3
             name = NT_ADRs_1,NT_ADRs_2,NT_ADRs_3, dec=3*3



ENDRUN
;
