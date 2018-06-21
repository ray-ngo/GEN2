*del voya*.prn
;=================================================================
;	CheckStationAccess.s
;	Purpose: To check whether transit stations are accessible
	
; RM, RN
; Date:      2018-03-30
;
;=================================================================


RUN PGM=MATRIX

ZONES=8000
FILEI LOOKUPI[1] = 'inputs\node.dbf'
FILEI MATI[1] = '%_iter_%_am_sov_mod.skm'

LOOKUP LOOKUPI = 1, NAME = NODES, LOOKUP[1] = N, RESULT = N, INTERPOLATE = N, FAIL = 0,0,0, LIST = Y

MW[1] = MI.1.1
TIMESUM = ROWSUM(1)
IF (I = 5000 - 8000)
	NODEVAL = NODES(1, I)
	IF (NODEVAL>0 && TIMESUM = 0)          
    PRINT LIST = 'STATION NUMBER ', NODEVAL(5), ' HAS NO SKIM BUILT TO IT'  
		ABORT MSG = STATION CENTROIDS WITHOUT SKIMS. PLEASE CHECK THE NETWORK.
	ENDIF      	
ENDIF

ENDRUN
