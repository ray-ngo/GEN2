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
; Step 2a) Read TRNBUILD line files and export links (ALLStops_PK)
;
RUN PGM=TRNBUILD

	FILEI NETI     = "input\temp_HwyNetWithTrnNodes.NET"
	FILEO LINKO    = "input\temp_LinkALLPK.DBF"

	parameters buildpaths=false
	phase1 hwytime=DISTANCE                                            ;give a link variable for path cost. This has no effect on the stop node shape file output
	support modes=200 dist=100 N=1-2                                   ;generate a dummy support link. Use a mode which is not used in your transit line file

	READ FILE      = "..\MODE1AM.TB"
	READ FILE      = "..\MODE2AM.TB"
	READ FILE      = "..\MODE3AM.TB"
	READ FILE      = "..\MODE4AM.TB"
	READ FILE      = "..\MODE5AM.TB"
	READ FILE      = "..\MODE6AM.TB"
	READ FILE      = "..\MODE7AM.TB"
	READ FILE      = "..\MODE8AM.TB"
	READ FILE      = "..\MODE9AM.TB"
	READ FILE      = "..\MODE10AM.TB"

ENDRUN

;
; Step 2b) Read TRNBUILD line files and export links (ALLStops_OP)
;
RUN PGM=TRNBUILD

	FILEI NETI     = "input\temp_HwyNetWithTrnNodes.NET"
	FILEO LINKO    = "input\temp_LinkALLOP.DBF"

	parameters buildpaths=false
	phase1 hwytime=DISTANCE                                            ;give a link variable for path cost. This has no effect on the stop node shape file output
	support modes=200 dist=100 N=1-2                                   ;generate a dummy support link. Use a mode which is not used in your transit line file

	READ FILE      = "..\MODE1OP.TB"
	READ FILE      = "..\MODE2OP.TB"
	READ FILE      = "..\MODE3OP.TB"
	READ FILE      = "..\MODE4OP.TB"
	READ FILE      = "..\MODE5OP.TB"
	READ FILE      = "..\MODE6OP.TB"
	READ FILE      = "..\MODE7OP.TB"
	READ FILE      = "..\MODE8OP.TB"
	READ FILE      = "..\MODE9OP.TB"
	READ FILE      = "..\MODE10OP.TB"

ENDRUN

;
; Step 2c) Read TRNBUILD line files and export links (MetroandLRT_AllDay)
;
RUN PGM=TRNBUILD

	FILEI NETI     = "input\temp_HwyNetWithTrnNodes.NET"
	FILEO LINKO    = "input\temp_LinkMetroLRT_PK.DBF"

	parameters buildpaths=false
	phase1 hwytime=DISTANCE                                            ;give a link variable for path cost. This has no effect on the stop node shape file output
	support modes=200 dist=100 N=1-2                                   ;generate a dummy support link. Use a mode which is not used in your transit line file
                                                                      
	READ FILE      = "..\MODE3AM.TB"                                  
	READ FILE      = "..\MODE5AM.TB"                                  
	                                                                  
ENDRUN                                                                
RUN PGM=TRNBUILD                                                      
                                                                      
	FILEI NETI     = "input\temp_HwyNetWithTrnNodes.NET"              
	FILEO LINKO    = "input\temp_LinkMetroLRT_OP.DBF"                 
                                                                      
	parameters buildpaths=false                                       
	phase1 hwytime=DISTANCE                                            ;give a link variable for path cost. This has no effect on the stop node shape file output
	support modes=200 dist=100 N=1-2                                   ;generate a dummy support link. Use a mode which is not used in your transit line file

	READ FILE      = "..\MODE3OP.TB"
	READ FILE      = "..\MODE5OP.TB"

ENDRUN

;
; Step 3a) Export nodes (ALLStops_PK)
;
RUN PGM=MATRIX

	FILEI RECI     = "input\temp_LinkALLPK.DBF"                        ;LINKO file from TRNBUILD
	FILEO RECO[1]  = "input\temp_NodeALLPK.DBF" FIELDS=N,STOP

	STOP=1
	N=RI.A
	IF (RI.MODE>0 & RI.STOP_A=1) WRITE RECO=1                          ;Select Mode
	N=RI.B
	IF (RI.MODE>0 & RI.STOP_B=1) WRITE RECO=1

ENDRUN

;
; Step 3b) Export nodes (ALLStops_OP)
;
RUN PGM=MATRIX

	FILEI RECI     = "input\temp_LinkALLOP.DBF"                        ;LINKO file from TRNBUILD
	FILEO RECO[1]  = "input\temp_NodeALLOP.DBF" FIELDS=N,STOP

	STOP=1
	N=RI.A
	IF (RI.MODE>0 & RI.STOP_A=1) WRITE RECO=1                          ;Select Mode
	N=RI.B
	IF (RI.MODE>0 & RI.STOP_B=1) WRITE RECO=1

ENDRUN

;
; Step 3c) Export nodes (MetroandLRT_AllDay)
;
RUN PGM=MATRIX

	FILEI RECI     = "input\temp_LinkMetroLRT_PK.DBF"                  ;LINKO file from TRNBUILD
	FILEO RECO[1]  = "input\temp_NodeMetroLRT_PK.DBF" FIELDS=N,STOP

	STOP=1
	N=RI.A
	IF (RI.MODE>0 & RI.STOP_A=1) WRITE RECO=1  ;Select Mode
	N=RI.B
	IF (RI.MODE>0 & RI.STOP_B=1) WRITE RECO=1  ;Select Mode
	
ENDRUN
RUN PGM=MATRIX

	FILEI RECI     = "input\temp_LinkMetroLRT_OP.DBF"                  ;LINKO file from TRNBUILD
	FILEO RECO[1]  = "input\temp_NodeMetroLRT_OP.DBF" FIELDS=N,STOP

	STOP=1
	N=RI.A
	IF (RI.MODE>0 & RI.STOP_A=1) WRITE RECO=1  ;Select Mode
	N=RI.B
	IF (RI.MODE>0 & RI.STOP_B=1) WRITE RECO=1  ;Select Mode
	
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

