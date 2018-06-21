; JoinSkims.S - Consolidate highway skims used in Mode Choice Model
;   Input skims:  ???%_iter_%@PRD@.skm
;   Changed to:   ???%_iter_%@PRD@_MC.skm
;  The revised skim reflect
;      time (min) + time (min) equivalent of any Variably Priced facility toll such as ICC/VA Hot lanes
;      distance (1/10s of mi),
;      tolls (2007 cts) of any FIXED price facility, such as Dulles toll road.
;

pageheight=32767  ; Preclude header breaks


RUN PGM=MATRIX
    MATI[1]=          %_iter_%_am_sov_MC.skm
    MATI[2]=          %_iter_%_am_hov2_MC.skm
    MATI[3]=          %_iter_%_am_hov3_MC.skm

    MATI[4]=          %_iter_%_md_sov_MC.skm
    MATI[5]=          %_iter_%_md_hov2_MC.skm
    MATI[6]=          %_iter_%_md_hov3_MC.skm


    FILLMW  MW[1]  = MI.1.1,2,3
    FILLMW  MW[4]  = MI.2.1,2,3
    FILLMW  MW[7]  = MI.3.1,2,3

    FILLMW  MW[10] = MI.4.1,2,3
    FILLMW  MW[13] = MI.5.1,2,3
    FILLMW  MW[16] = MI.6.1,2,3

   MATO[1] = %_iter_%_hwy_am.skm, MO=1-9,
                                 name=SovTime,SOVDst10,SOVToll,
                                      Hv2Time,Hv2Dst10,HV2Toll,
                                      Hv3Time,Hv3Dst10,HV3Toll

   MATO[2] = %_iter_%_hwy_op.skm, MO=10-18,
                                 name=SovTime,SOVDst10,SOVToll,
                                      Hv2Time,Hv2Dst10,HV2Toll,
                                      Hv3Time,Hv3Dst10,HV3Toll
ENDRUN

