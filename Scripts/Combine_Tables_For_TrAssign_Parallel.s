; COMBINE TRIPS FOR ALL PURPOSES INTO ONE FOR EACH SUB TRANSIT MODE
distribute intrastep=%useIdp% multistep=%useMdp%

RUN PGM=MATRIX
distributeIntrastep processId='MWCOG', ProcessList=%subnode%
MATI[1] = '%_iter_%_HBW_NL_MC.MTT' ;AECOM HBW Mode Choice file           (Input)
MATI[2] = '%_iter_%_HBS_NL_MC.MTT' ;AECOM HBS Mode Choice file           (Input)
MATI[3] = '%_iter_%_HBO_NL_MC.MTT' ;AECOM HBO Mode Choice file           (Input)
MATI[4] = '%_iter_%_NHW_NL_MC.MTT' ;AECOM NHW Mode Choice file           (Input)
MATI[5] = '%_iter_%_NHO_NL_MC.MTT' ;AECOM NHO Mode Choice file           (Input)

; Note: There are 11 tables on the *.TRP files, not 12, since, for CR, KNR and PNR are combined
MATO[1]='%_iter_%_AMMS.TRP',MO=04-14,
  NAME = WK_CR, WK_BUS, WK_BUS_MR, WK_MR, PNR_KNR_CR, PNR_BUS, KNR_BUS, PNR_BUS_MR, KNR_BUS_MR, PNR_MR, KNR_MR
MATO[2]='%_iter_%_OPMS.TRP',MO=24-34,
  NAME = WK_CR, WK_BUS, WK_BUS_MR, WK_MR, PNR_KNR_CR, PNR_BUS, KNR_BUS, PNR_BUS_MR, KNR_BUS_MR, PNR_MR, KNR_MR

;PK TRIP MATRICES
MW[1]=MI.1.1                          ; AM DR ALONE
MW[2]=MI.1.2                          ; AM SR2
MW[3]=MI.1.3                          ; AM SR3+
MW[4]=MI.1.4                          ; AM WK-CR
MW[5]=MI.1.5                          ; AM WK-BUS
MW[6]=MI.1.6                          ; AM WK-BU/MR
MW[7]=MI.1.7                          ; AM WK-MR
MW[8]=MI.1.8                          ; AM PNR-CR, KNR-CR
MW[9]=MI.1.9                          ; AM PNR-BUS
MW[10]=MI.1.10                        ; AM KNR-BUS
MW[11]=MI.1.11                        ; AM PNR-BU/MR
MW[12]=MI.1.12                        ; AM KNR-BU/MR
MW[13]=MI.1.13                        ; AM PNR-MR
MW[14]=MI.1.14                        ; AM KNR-MR

;OP TRIP MATRICES
MW[21]=MI.2.1+MI.3.1+MI.4.1+MI.5.1          ; OP DR ALONE
MW[22]=MI.2.2+MI.3.2+MI.4.2+MI.5.2          ; OP SR2
MW[23]=MI.2.3+MI.3.3+MI.4.3+MI.5.3          ; OP SR3+
MW[24]=MI.2.4+MI.3.4+MI.4.4+MI.5.4          ; OP WK-CR
MW[25]=MI.2.5+MI.3.5+MI.4.5+MI.5.5          ; OP WK-BUS
MW[26]=MI.2.6+MI.3.6+MI.4.6+MI.5.6          ; OP WK-BU/MR
MW[27]=MI.2.7+MI.3.7+MI.4.7+MI.5.7          ; OP WK-MR
MW[28]=MI.2.8+MI.3.8+MI.4.8+MI.5.8          ; OP PNR-CR, KNR-CR
MW[29]=MI.2.9+MI.3.9+MI.4.9+MI.5.9          ; OP PNR-BUS
MW[30]=MI.2.10+MI.3.10+MI.4.10+MI.5.10      ; OP KNR-BUS
MW[31]=MI.2.11+MI.3.11+MI.4.11+MI.5.11      ; OP PNR-BU/MR
MW[32]=MI.2.12+MI.3.12+MI.4.12+MI.5.12      ; OP KNR-BU/MR
MW[33]=MI.2.13+MI.3.13+MI.4.13+MI.5.13      ; OP PNR-MR
MW[34]=MI.2.14+MI.3.14+MI.4.14+MI.5.14      ; OP KNR-MR

ENDRUN
