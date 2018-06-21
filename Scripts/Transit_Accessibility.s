;---------------------------------------------------------------------------
; Transit_Accessibility.s
;
; Develop transit accessibility files needed in the demographic modeling
; - the AM transit accessibility to jobs w/in 35, 40, 45, 50 min
; - Metrorail related accessibility only (BM & MR only).
;---------------------------------------------------------------------------
;


Loop Pr_ = 1,2
     IF (PR_ =1) per ='AM'
     IF (PR_ =2) per ='OP'

     Loop Ac_=1,2
          IF (Ac_ =1) Acc  = 'WK'
          IF (Ac_ =2) Acc  = 'DR'

          Loop Pth_=1,2
            IF (Pth_=1)  Path ='BM'
            IF (Pth_=2)  Path ='MR'
         ;; IF (Pth_=3)  Path ='AB'
         ;; IF (Pth_=4)  Path ='CR'


pageheight=32767  ; Preclude header breaks
ZONESIZE = 3722
RUN PGM=MATRIX
 MATI[1] =%_iter_%_@per@_@Acc@_@Path@.ttt

 ZDATI[1] =INPUTS\ZONE.dbf

 _ACCESS = 0
 _TAZ    = i

MW[100] = Mi.1.1

JLOOP

    IF (MW[100] =0.0) MW[100] =1000000

    IF (MW[100] =1000000)
        NotConnected = NotConnected + 1
       ELSE
        Connected   = Connected + 1
    ENDIF


    IF (MW[100] < 1000000 )
     _ACCESS = _ACCESS + MW[100]
    ENDIF

ENDJLOOP

 IF (_ACCESS > 0 )
  MW[100][I] = 1
 ENDIF

 _EMP35  = 0
 _EMP40  = 0
 _EMP45  = 0
 _EMP50  = 0
 _EMPTOT = 0

JLOOP
  IF (MW[100] = 1-35)
   _EMP35 = _EMP35  + ZI.1.TOTEMP[J]     ;  jobs w/35 Min
  ENDIF

  IF (MW[100] = 1-40)
   _EMP40 = _EMP40  + ZI.1.TOTEMP[J]     ;  jobs w/40 Min
  ENDIF

  IF (MW[100] = 1-45)
   _EMP45 = _EMP45  + ZI.1.TOTEMP[J]     ;  jobs w/45 Min
  ENDIF

  IF (MW[100] = 1-50)
   _EMP50 = _EMP50  + ZI.1.TOTEMP[J]     ;  jobs w/50 Min
  ENDIF

  _EMPTOT = _EMPTOT + ZI.1.TOTEMP[J]     ;  total regional jobs

ENDJLOOP

;;; ;; Print Accessibility to jobs file

FILEO RECO[1] = "%_iter_%_@per@_@Acc@_@Path@_JobAcc.dbf",
                Fields = TAZ(5), Emp35(10), Emp40(10), Emp45(10), Emp50(10), EMPTOT(10)

                ro.TAZ    = _TAZ
                ro.emp35  = _emp35
                ro.emp40  = _emp40
                ro.emp45  = _emp45
                ro.emp50  = _emp50
                ro.emptot = _emptot

                WRITE RECO=1 ;




;; Print out text file containing best path stats
IF (I= @ZONESIZE@)
 PRINT FILE=%_iter_%_@per@_@Acc@_@Path@_JOBACC.txt, FORM=12csv, LIST= 'Accessibility_Report: ',
                                                                    '  Iteration:    ','%_iter_%',
                                                                    '  Period:       ','@per@' ,
                                                                    '  AccType:      ','@Acc@' ,
                                                                    '  PathType:     ','@Path@',
                                                                    ' #Connected IJs:    ', Connected,
                                                                    ' #Disconnected IJs: ', NotConnected
ENDIF


ENDRUN
ENDLOOP
ENDLOOP
ENDLOOP

