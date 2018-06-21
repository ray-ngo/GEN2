;; 4/16/11 HWYNET modules changed to 'NETWORK'
;; 4/16/11 zones increased to 7999; 'MDLIMIT = 0' and 'NTLIMIT=0' added
pageheight=32767  ; Preclude header breaks

;; write out list of highway nodes with a-nodes, b-nodes, distance, TAZ, and Ftype
;; for the walkacc program
RUN PGM=NETWORK
NETI = '%_iter_%_hwy.net'

 IF (Ftype != 0)
     print list= a(8), b(8), distance(8.2), ftype(8),TAZ(8), File= WalkAcc_links.txt
 ENDIF
ENDRUN

RUN PGM=MATRIX
ZONES=1
FILEI  RECI = WalkAcc_links.txt,
 a=  1, b=  2, distance= 3, ftype= 4,TAZ=  5

  n=n+1

  RECO[1] ="WalkAcc_Links.dbf",
  Fields = a(8), b(8), distance(8.2), ftype(8),TAZ(8)

  WRITE RECO=1
endrun
;



;; write out network with added station centroid connectors
RUN PGM=NETWORK
NETI = '%_iter_%_hwy.net'

NETO = '%_iter_%_HWYMOD.NET'

PARAMETERS ZONES=7999

IF (A=3723-7999 || B=3723-7999)
  AMLIMIT = 0
  PMLIMIT = 0
  OPLIMIT = 0
  MDLIMIT = 0
  NTLIMIT = 0
ENDIF
ENDRUN
