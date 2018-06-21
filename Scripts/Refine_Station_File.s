*del voya*.prn
;; Refine_Station_File.s - program to read standard V2.3 station file with odd formats, column widths
;;                         and writes the SAME data with a neater appearance

Station_Input  = 'Station_2040_FromMary_4_13_11.DBF'       ;   input  file of this script
Station_Output = 'Station_2040_Final_4_13_13.DBF'          ;   output file of this script

RUN PGM=MATRIX
ZONES=1

FILEI DBI[1]  = "@Station_Input@"

RECO[1]       = "@Station_Output@", form=10.0,
             Fields = SEQNO, MM(C8), NCT, STAPARK, STAUSE, SNAME(c27),  STAC, STAZ, STAT, STAP,
             STAN1, STAN2, STAN3, STAN4, STAPCAP, STAX, STAY,
             STAPKCost(13), STAOPCost(13), STAPKShad(13), STAOPShad(13), FirstYr, STa_CenD

 cnt = 0

; All Station Nodes:
 LOOP L= 1,dbi.1.NUMRECORDS
         x=DBIReadRecord(1,L)
            cnt=cnt+1
            ro.seqno       =di.1.seqno
            RO.MM          =di.1.MM
            RO.NCT         =di.1.NCT
            RO.stapark     =di.1.STAPARK
            RO.stause      =di.1.stause
            RO.Sname       =di.1.Sname
            RO.STAC        =di.1.STAC
            RO.STAZ        =di.1.STAZ
            RO.STAT        =di.1.STAT
            RO.STAP        =di.1.STAP
            RO.STAN1       =di.1.STAN1
            RO.STAN2       =di.1.STAN2
            RO.STAN3       =di.1.STAN3
            RO.STAN4       =di.1.STAN4
            RO.STAPCAP     =di.1.STAPCAP
            RO.STAX        =di.1.STAX
            RO.STAY        =di.1.STAY
            RO.STAPKCost   =di.1.STAPKCost
            RO.STAOPCost   =di.1.STAOPCost
            RO.STAPKShad   =di.1.STAPKShad
            RO.STAOPShad   =di.1.STAOPShad
            RO.FirstYr     =di.1.FirstYr
            RO.STA_CenD    =di.1.Sta_CenD

            write reco=1
 ENDLOOP


ENDRUN


