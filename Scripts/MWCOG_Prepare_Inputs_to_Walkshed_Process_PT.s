;
; This Voyager script creates shapefile inputs for Walkshed Process
; Outputs are:
;    1) ALLStops_PK.shp         (.dbf, .shx)
;    2) ALLStops_OP.shp         (.dbf, .shx)
;    3) MetroandLRT_AllDay.shp  (.dbf, .shx)
;
; 10/17/2013, Author: KCP with support from Citilabs
;---------------------------------------------------------------------

; Reference: V2.3.52_Users_Guide_v2_w_appA.pdf Page 113
; Mode 3= Metrorail
; Mode 4 = Commuter rail
; Mode 5 = light rail
; Mode 10= BRT, Streetcar

;
; Step 1) Create network with all nodes
;
RUN PGM=HWYNET

	FILEI NODEI[1] = "..\Node.dbf"
	FILEI NODEI[2] = "..\Met_Node.tb",
                                          VAR=N,9-14,
                                          VAR=X,18-27,
                                          VAR=Y,31-40
	FILEI NODEI[3] = "..\Com_Node.tb",
                                          VAR=N,9-14,
                                          VAR=X,18-27,
                                          VAR=Y,31-40
	FILEI NODEI[4] = "..\LRT_Node.tb",
                                          VAR=N,9-14,
                                          VAR=X,18-27,
                                          VAR=Y,31-40
	FILEI NODEI[5] = "..\NEW_Node.tb",
                                          VAR=N,9-14,
                                          VAR=X,18-27,
                                          VAR=Y,31-40

	FILEI LINKI[1] = "..\Link.dbf"
	FILEI LINKI[2] = "..\Met_Link.tb",
	                                       VAR=A,12-17,
	                                       VAR=B,19-24, REV=2
    FILEI LINKI[3] = "..\Com_Link.tb",
	                                       VAR=A,12-17,
	                                       VAR=B,19-24, REV=2
	FILEI LINKI[4] = "..\LRT_Link.tb",
	                                       VAR=A,12-17,
	                                       VAR=B,19-24, REV=2
    FILEI LINKI[5] = "..\NEW_Link.tb",
	                                       VAR=A,12-17,
	                                       VAR=B,19-24, REV=2

	ZONES          = 3722
	NETO           = "input\temp_HwyNetWithTrnNodes.NET"

ENDRUN

;
; Create a Dummy Factors File for PT
;

*DEL /Q input\Dummy_FactorFile.txt

*ECHO  ;Global Settings                                                                   >> input\Dummy_FactorFile.txt
*ECHO  BESTPATHONLY=T                                                                     >> input\Dummy_FactorFile.txt
*ECHO  MAXFERS=5                                                                          >> input\Dummy_FactorFile.txt
*ECHO  SERVICEMODEL=FREQUENCY                                                             >> input\Dummy_FactorFile.txt
*ECHO  RECOSTMAX=250.0                                                                    >> input\Dummy_FactorFile.txt
*ECHO  FREQBYMODE=T                                                                       >> input\Dummy_FactorFile.txt
*ECHO.                                                                                    >> input\Dummy_FactorFile.txt
*ECHO  ;Global Settings                                                                   >> input\Dummy_FactorFile.txt
*ECHO  DELMODE = 1                                                                        >> input\Dummy_FactorFile.txt
*ECHO.                                                                                    >> input\Dummy_FactorFile.txt
*ECHO  ;Boarding and Transfer Penalties                                                   >> input\Dummy_FactorFile.txt
*ECHO  IWAITCURVE=1,  NODES=1100-99999                                                    >> input\Dummy_FactorFile.txt
*ECHO  XWAITCURVE=1, NODES=1100-99999                                                     >> input\Dummy_FactorFile.txt
*ECHO  WAITFACTOR=2.5, n=1-99999                                                          >> input\Dummy_FactorFile.txt
*ECHO  XFERFACTOR=2.5, from=1-10, to=1-10                                                 >> input\Dummy_FactorFile.txt
*ECHO.                                                                                    >> input\Dummy_FactorFile.txt
*ECHO  XFERPEN=9999, from=12, to=16,                                                      >> input\Dummy_FactorFile.txt
*ECHO  XFERPEN=9999, from=16, to=12,                                                      >> input\Dummy_FactorFile.txt
*ECHO  XFERPEN=9999, from=16, to=16                                                       >> input\Dummy_FactorFile.txt
*ECHO.                                                                                    >> input\Dummy_FactorFile.txt
*ECHO  BRDPEN=0,0,0,0,0,0 ;                                                               >> input\Dummy_FactorFile.txt
*ECHO  XFERPEN=9999, from=1, to=3-6                                                       >> input\Dummy_FactorFile.txt
*ECHO  XFERPEN=9999, from=3-6, to=1                                                       >> input\Dummy_FactorFile.txt
*ECHO  XFERPEN=2.0, from=7, to=3                                                          >> input\Dummy_FactorFile.txt

;
; Create a Dummy System File for PT
;

*DEL /Q input\Dummy_SystemFile.txt

*ECHO  ;;<<PT>><<SYSTEM>>;;                                                               >> input\Dummy_SystemFile.txt
*ECHO.                                                                                    >> input\Dummy_SystemFile.txt
*ECHO  ; Wait curve definitions                                                           >> input\Dummy_SystemFile.txt
*ECHO  WAITCRVDEF NUMBER=1 LONGNAME="Initial and Transfer Wait" NAME=InitXferWait ,       >> input\Dummy_SystemFile.txt
*ECHO             CURVE=0-0,1-0.25,4-1,60-15,120-30                                       >> input\Dummy_SystemFile.txt

;
; Copy All PT Line Files into One
;   This is done so as to have the option to have an empty line file
;
*COPY ..\MODE*AM.Lin  input\Combined_MODEsAM.Lin

;
; Step 2a) Read TRNBUILD line files and export links (ALLStops_PK)
;
RUN PGM=PUBLIC TRANSPORT

	FILEI NETI     = "input\temp_HwyNetWithTrnNodes.NET"
	FILEO LINKO    = "input\temp_LinkALLPK.DBF", ONOFFS=Y

	FILEI FACTORI[1] = "input\Dummy_FactorFile.txt"
	FILEI SYSTEMI    = "input\Dummy_SystemFile.txt"

	;Globals
     PARAMETERS USERCLASSES=1,FARE=N, HDWAYPERIOD=1,NOROUTEERRS=99999999,
           NOROUTEMSGS=99999999,TRANTIME=100, SKIPBADLINES=Y

	FILEI LINEI         = "input\Combined_MODEsAM.Lin"

	; FILEI LINEI[1]      = "..\MODE1AM.Lin"
	; FILEI LINEI[2]      = "..\MODE2AM.Lin"
	; FILEI LINEI[3]      = "..\MODE3AM.Lin"
	; FILEI LINEI[4]      = "..\MODE4AM.Lin"
	; FILEI LINEI[5]      = "..\MODE5AM.Lin"
	; FILEI LINEI[6]      = "..\MODE6AM.Lin"
	; FILEI LINEI[7]      = "..\MODE7AM.Lin"
	; FILEI LINEI[8]      = "..\MODE8AM.Lin"
	; FILEI LINEI[9]      = "..\MODE9AM.Lin"
	; FILEI LINEI[10]     = "..\MODE10AM.Lin"

	PHASE=DATAPREP
	ENDPHASE

	PHASE=SKIMIJ
	ENDPROCESS

ENDRUN

;
; Copy All PT Line Files into One
;   This is done so as to have the option to have an empty line file
;
*COPY ..\MODE*OP.Lin  input\Combined_MODEsOP.Lin

;
; Step 2b) Read TRNBUILD line files and export links (ALLStops_OP)
;
RUN PGM=PUBLIC TRANSPORT

	FILEI NETI     = "input\temp_HwyNetWithTrnNodes.NET"
	FILEO LINKO    = "input\temp_LinkALLOP.DBF", ONOFFS=Y

	FILEI FACTORI[1] = "input\Dummy_FactorFile.txt"
	FILEI SYSTEMI    = "input\Dummy_SystemFile.txt"

	;Globals
     PARAMETERS USERCLASSES=1,FARE=N, HDWAYPERIOD=1,NOROUTEERRS=99999999,
           NOROUTEMSGS=99999999,TRANTIME=100, SKIPBADLINES=Y

	FILEI LINEI         = "input\Combined_MODEsOP.Lin"

	; FILEI LINEI[1]      = "..\MODE1OP.Lin"
	; FILEI LINEI[2]      = "..\MODE2OP.Lin"
	; FILEI LINEI[3]      = "..\MODE3OP.Lin"
	; FILEI LINEI[4]      = "..\MODE4OP.Lin"
	; FILEI LINEI[5]      = "..\MODE5OP.Lin"
	; FILEI LINEI[6]      = "..\MODE6OP.Lin"
	; FILEI LINEI[7]      = "..\MODE7OP.Lin"
	; FILEI LINEI[8]      = "..\MODE8OP.Lin"
	; FILEI LINEI[9]      = "..\MODE9OP.Lin"
	; FILEI LINEI[10]     = "..\MODE10OP.Lin"

	PHASE=DATAPREP
	ENDPHASE

	PHASE=SKIMIJ
	ENDPROCESS

ENDRUN

;
; Copy Metro & LRT PT Line Files into One
;   This is done so as to have the option to have an empty line file
;
*COPY ..\MODE3AM.Lin  +  ..\MODE5AM.Lin  input\Combined_MetroLRTAM.Lin

;
; Step 2c) Read TRNBUILD line files and export links (MetroandLRT_AllDay)
;
RUN PGM=PUBLIC TRANSPORT

	FILEI NETI     = "input\temp_HwyNetWithTrnNodes.NET"
	FILEO LINKO    = "input\temp_LinkMetroLRT_PK.DBF", ONOFFS=Y

	FILEI FACTORI[1] = "input\Dummy_FactorFile.txt"
	FILEI SYSTEMI    = "input\Dummy_SystemFile.txt"

	;Globals
     PARAMETERS USERCLASSES=1,FARE=N, HDWAYPERIOD=1,NOROUTEERRS=99999999,
           NOROUTEMSGS=99999999,TRANTIME=100, SKIPBADLINES=Y

	FILEI LINEI         = "input\Combined_MetroLRTAM.Lin"

	; FILEI LINEI[3]      = "..\MODE3OP.Lin"
	; FILEI LINEI[5]      = "..\MODE5OP.Lin"

	PHASE=DATAPREP
	ENDPHASE

	PHASE=SKIMIJ
	ENDPROCESS

ENDRUN

;
; Copy Metro & LRT PT Line Files into One
;   This is done so as to have the option to have an empty line file
;
*COPY ..\MODE3OP.Lin  +  ..\MODE5OP.Lin  input\Combined_MetroLRTOP.Lin


RUN PGM=PUBLIC TRANSPORT

	FILEI NETI     = "input\temp_HwyNetWithTrnNodes.NET"
	FILEO LINKO    = "input\temp_LinkMetroLRT_OP.DBF", ONOFFS=Y

	FILEI FACTORI[1] = "input\Dummy_FactorFile.txt"
	FILEI SYSTEMI    = "input\Dummy_SystemFile.txt"

	;Globals
     PARAMETERS USERCLASSES=1,FARE=N, HDWAYPERIOD=1,NOROUTEERRS=99999999,
           NOROUTEMSGS=99999999,TRANTIME=100, SKIPBADLINES=Y

	FILEI LINEI         = "input\Combined_MetroLRTOP.Lin"

	; FILEI LINEI[3]      = "..\MODE3OP.Lin"
	; FILEI LINEI[5]      = "..\MODE5OP.Lin"

	PHASE=DATAPREP
	ENDPHASE

	PHASE=SKIMIJ
	ENDPROCESS

ENDRUN

;
; Step 3a) Export nodes (ALLStops_PK)
;
RUN PGM=MATRIX

	FILEI RECI     = "input\temp_LinkALLPK.DBF"                        ;LINKO file from TRNBUILD
	FILEO RECO[1]  = "input\temp_NodeALLPK.DBF" FIELDS=N,STOP

	STOP=1
	N=RI.A
	IF (RI.MODE>0 & RI.STOPA=1) WRITE RECO=1                          ;Select Mode
	N=RI.B
	IF (RI.MODE>0 & RI.STOPB=1) WRITE RECO=1

ENDRUN

;
; Step 3b) Export nodes (ALLStops_OP)
;
RUN PGM=MATRIX

	FILEI RECI     = "input\temp_LinkALLOP.DBF"                        ;LINKO file from TRNBUILD
	FILEO RECO[1]  = "input\temp_NodeALLOP.DBF" FIELDS=N,STOP

	STOP=1
	N=RI.A
	IF (RI.MODE>0 & RI.STOPA=1) WRITE RECO=1                          ;Select Mode
	N=RI.B
	IF (RI.MODE>0 & RI.STOPB=1) WRITE RECO=1

ENDRUN

;
; Step 3c) Export nodes (MetroandLRT_AllDay)
;
RUN PGM=MATRIX

	FILEI RECI     = "input\temp_LinkMetroLRT_PK.DBF"                  ;LINKO file from TRNBUILD
	FILEO RECO[1]  = "input\temp_NodeMetroLRT_PK.DBF" FIELDS=N,STOP

	STOP=1
	N=RI.A
	IF (RI.MODE>0 & RI.STOPA=1) WRITE RECO=1  ;Select Mode
	N=RI.B
	IF (RI.MODE>0 & RI.STOPB=1) WRITE RECO=1  ;Select Mode

ENDRUN
RUN PGM=MATRIX

	FILEI RECI     = "input\temp_LinkMetroLRT_OP.DBF"                  ;LINKO file from TRNBUILD
	FILEO RECO[1]  = "input\temp_NodeMetroLRT_OP.DBF" FIELDS=N,STOP

	STOP=1
	N=RI.A
	IF (RI.MODE>0 & RI.STOPA=1) WRITE RECO=1  ;Select Mode
	N=RI.B
	IF (RI.MODE>0 & RI.STOPB=1) WRITE RECO=1  ;Select Mode

ENDRUN

;
; Step 4a) Use nodes and network to export stop-shapefile (ALLStops_PK)
;
RUN PGM=NETWORK

	FILEI LINKI[1] = "input\temp_HwyNetWithTrnNodes.NET"               ;Input highway netwerk
	FILEI NODEI[2] = "input\temp_NodeALLPK.DBF"  COMBINE=T             ;Stop node file from previous MATRIX step
	FILEO NODEO    = "input\ALLStops_PK.shp" FORMAT=SHP                ;stop nodes shape file.

	MERGE RECORD=T

	PHASE=NODEMERGE
	  IF (ni.2.stop=0) delete
	ENDPHASE

ENDRUN

;
; Cube does not create a projection (.prj) file, so copy from template
;
*COPY ..\..\..\Scripts\Maryland1900Ft_ShapefileProjection_TEMPLATE.prj    input\ALL_Stops_PK.prj

;
; Step 4b) Use nodes and network to export stop-shapefile (ALLStops_OP)
;
RUN PGM=NETWORK

	FILEI LINKI[1] = "input\temp_HwyNetWithTrnNodes.NET"               ;Input highway netwerk
	FILEI NODEI[2] = "input\temp_NodeALLOP.DBF"  COMBINE=T             ;Stop node file from previous MATRIX step
	FILEO NODEO    = "input\ALLStops_OP.shp" FORMAT=SHP                ;stop nodes shape file.

	MERGE RECORD=T

	PHASE=NODEMERGE
	  IF (ni.2.stop=0) delete
	ENDPHASE

ENDRUN

;
; Cube does not create a projection (.prj) file, so copy from template
;
*COPY ..\..\..\Scripts\Maryland1900Ft_ShapefileProjection_TEMPLATE.prj    input\ALLStops_OP.prj


;
; Step 4c) Use nodes and network to export stop-shapefile (MetroandLRT_AllDay)
;
RUN PGM=NETWORK

	FILEI LINKI[1] = "input\temp_HwyNetWithTrnNodes.NET"               ;Input highway netwerk
	FILEI NODEI[2] = "input\temp_NodeMetroLRT_PK.DBF"  COMBINE=T       ;Stop node file from previous MATRIX step
	FILEI NODEI[3] = "input\temp_NodeMetroLRT_OP.DBF"  COMBINE=T       ;Stop node file from previous MATRIX step
	FILEO NODEO    = "input\MetroandLRT_AllDay.shp" FORMAT=SHP         ;stop nodes shape file.

	MERGE RECORD=T

	PHASE=NODEMERGE
	  IF (ni.2.stop=0) delete
	  IF (ni.3.stop=0) delete
	ENDPHASE

ENDRUN

;
; Cube does not create a projection (.prj) file, so copy from template
;
*COPY ..\..\..\Scripts\Maryland1900Ft_ShapefileProjection_TEMPLATE.prj    input\MetroandLRT_AllDay.prj

