;-------------------------------------------------------------------
; SET_FACTORS.S   Version 2.3 Model-3722 TAZ system
; Updated 4-14-15 RJM: added step to create Station name file from 
; scenario specific station file
;-------------------------------------------------------------------

; MWCOG Version 2.3  Model
;  Set up K-factor files used in Trip Distribution
;
; Zonal K-factor Files created by this script

HBWK     = 'hbw_k.mat'    ;  zonal K-factor matrix
HBSK     = 'hbs_k.mat'    ;  zonal K-factor matrix
HBOK     = 'hbo_k.mat'    ;  zonal K-factor matrix
NHWK     = 'nhw_k.mat'    ;  zonal K-factor matrix
NHOK     = 'nho_k.mat'    ;  zonal K-factor matrix

;-------------------------------------------------------------------

;
; /////////////////////////////////////////////////////////////////////
; \\\\\\\\\    5) Begin K-Factor building, by trip purpose.          \\
; \\\\\\\\\       K-Factors values below are scaled by 1000.         \\
; \\\\\\\\\       (i.e., a value of 1000 below means K-Ftr of 1)  MW[100] = 1      \\
; \\\\\\\\\       The will be applied across income strata in trip   \\
; \\\\\\\\\       distribution.                                      \\
; /////////////////////////////////////////////////////////////////////

;; 2/27/13 All bridge-related K-factors are REMOVED

RUN PGM=MATRIX
ZONES=3722
; Now Begin the K-Factor Establishment
; Initialize K-factor matrices for each purpose:

MW[1] = 1000.0 ;  HBW       K-factor matrix
MW[2] = 1000.0 ;  HBS       K-factor matrix
MW[3] = 1000.0 ;  HBO       K-factor matrix
MW[4] = 1000.0 ;  NHW       K-factor matrix
MW[5] = 1000.0 ;  NHO       K-factor matrix

;;; /* *********  Bridge penalty section ****************************** */
;;;
;;; ;;---------------------
;;; ;Define K-Factor production areas in mtx 100
;;; ;1/DC&Mtg&PG, 2/Suburban VA, 3/OuterMD, 4/OuterVA, 5/Extl
;;;
;;; IF  (I= 1-4,6-47,49-50,52-63,65,181-209,282-287,374-381 )  MW[100] = 1   ;  0    DC Core
;;; IF  (I= 5,48,51,64,66-180,210-281,288-373,382-393       )  MW[100] = 1   ;  0    DC Noncore
;;; IF  (I= 394-769                                         )  MW[100] = 1   ;  1    Montgomery
;;; IF  (I= 771-776,778-1404                                )  MW[100] = 1   ;  2    Prince George
;;;
;;; IF  (I=1471-1476, 1486-1489, 1495-1497                  )  MW[100] = 2   ;  3    ArlCore
;;; IF  (I=1405-1470,1477-1485,1490-1494,1498-1545          )  MW[100] = 2   ;  3    ArlNCore
;;; IF  (I=1546-1610                                        )  MW[100] = 2   ;  4    Alex
;;; IF  (I=1611-2159                                        )  MW[100] = 2   ;  5    FFx
;;; IF  (I=2160-2441                                        )  MW[100] = 2   ;  6    LDn
;;; IF  (I=2442-2554,2556-2628,2630-2819                    )  MW[100] = 2   ;  7    PW
;;;
;;; IF  (I=2820-2949                                        )  MW[100] = 3   ;  9    Frd
;;; IF  (I=3230-3265,3268-3287                              )  MW[100] = 3   ; 14    Car.
;;; IF  (I=2950-3017                                        )  MW[100] = 3   ; 10    How.
;;; IF  (I=3018-3102,3104-3116                              )  MW[100] = 3   ; 11    AnnAr
;;; IF  (I=3288-3334                                        )  MW[100] = 3   ; 15    Calv
;;; IF  (I=3335-3409                                        )  MW[100] = 3   ; 16    StM
;;; IF  (I=3117-3229                                        )  MW[100] = 3   ; 12    Chs.
;;;
;;; IF  (I=3604-3653                                        )  MW[100] = 4   ; 21    Fau
;;; IF  (I=3449-3477,3479-3481,3483-3494,3496-3541          )  MW[100] = 4   ; 19    Stf.
;;; IF  (I=3654-3662,3663-3675                              )  MW[100] = 4   ; 22/23 Clk,Jeff.
;;; IF  (I=3435-3448,3542-3543,3545-3603                    )  MW[100] = 4   ; 18/20 Fbg,Spots
;;; IF  (I=3410-3434                                        )  MW[100] = 4   ; 17    KG.
;;;
;;; IF  (I=3676-3722                                        )  MW[100] = 5   ;       Externals
;;; ;;---------------------
;;;
;;; ;;---------------------
;;; ;Define K-Factor attraction areas in mtx 200
;;; ;1/DC&Mtg&PG, 2/Suburban VA, 3/OuterMD, 4/OuterVA, 5/Extl
;;; JLOOP
;;; IF  (J= 1-4,6-47,49-50,52-63,65,181-209,282-287,374-381 )  MW[200] = 1   ;  0    DC Core
;;; IF  (J= 5,48,51,64,66-180,210-281,288-373,382-393       )  MW[200] = 1   ;  0    DC Noncore
;;; IF  (J= 394-769                                         )  MW[200] = 1   ;  1    Montgomery
;;; IF  (J= 771-776,778-1404                                )  MW[200] = 1   ;  2    Prince George
;;;
;;; IF  (J=1471-1476, 1486-1489, 1495-1497                  )  MW[200] = 2   ;  3    ArlCore
;;; IF  (J=1405-1470,1477-1485,1490-1494,1498-1545          )  MW[200] = 2   ;  3    ArlNCore
;;; IF  (J=1546-1610                                        )  MW[200] = 2   ;  4    Alex
;;; IF  (J=1611-2159                                        )  MW[200] = 2   ;  5    FFx
;;; IF  (J=2160-2441                                        )  MW[200] = 2   ;  6    LDn
;;; IF  (J=2442-2554,2556-2628,2630-2819                    )  MW[200] = 2   ;  7    PW
;;;
;;; IF  (J=2820-2949                                        )  MW[200] = 3   ;  9    Frd
;;; IF  (J=3230-3265,3268-3287                              )  MW[200] = 3   ; 14    Car.
;;; IF  (J=2950-3017                                        )  MW[200] = 3   ; 10    How.
;;; IF  (J=3018-3102,3104-3116                              )  MW[200] = 3   ; 11    AnnAr
;;; IF  (J=3288-3334                                        )  MW[200] = 3   ; 15    Calv
;;; IF  (J=3335-3409                                        )  MW[200] = 3   ; 16    StM
;;; IF  (J=3117-3229                                        )  MW[200] = 3   ; 12    Chs.
;;;
;;; IF  (J=3604-3653                                        )  MW[200] = 4   ; 21    Fau
;;; IF  (J=3449-3477,3479-3481,3483-3494,3496-3541          )  MW[200] = 4   ; 19    Stf.
;;; IF  (J=3654-3662,3663-3675                              )  MW[200] = 4   ; 22/23 Clk,Jeff.
;;; IF  (J=3435-3448,3542-3543,3545-3603                    )  MW[200] = 4   ; 18/20 Fbg,Spots
;;; IF  (J=3410-3434                                        )  MW[200] = 4   ; 17    KG.
;;;
;;; IF  (J=3676-3722                                        )  MW[200] = 5   ;       Externals
;;;
;;; ; Establish K factors    for each purpose:
;;; ;;;                                        HBWK          HBSK          HBOK          NHWK          NHOK
;;; ;;;                                       -----         -----         -----         -----         -----
;;;   IF (MW[100] = 1 && MW[200] = 1)  mw[1] = 1000  mw[2] = 1000  mw[3] = 1000  mw[4] = 1000  mw[5] = 1000 ; DC/SubMD to DC/SubMD
;;;   IF (MW[100] = 1 && MW[200] = 2)  mw[1] =  800  mw[2] =  250  mw[3] =  300  mw[4] =  600  mw[5] =  300 ; DC/SubMD to SubVA
;;;   IF (MW[100] = 1 && MW[200] = 3)  mw[1] = 1000  mw[2] = 1000  mw[3] = 1000  mw[4] = 1000  mw[5] = 1000 ; DC/SubMD to OuterMD
;;;   IF (MW[100] = 1 && MW[200] = 4)  mw[1] = 1000  mw[2] = 1000  mw[3] = 1000  mw[4] = 1000  mw[5] = 1000 ; DC/SubMD to OuterVA
;;;
;;;   IF (MW[100] = 2 && MW[200] = 1)  mw[1] =  900  mw[2] =  250  mw[3] =  700  mw[4] =  600  mw[5] =  300 ; SubVA    to DC/SubMD
;;;   IF (MW[100] = 2 && MW[200] = 2)  mw[1] = 1000  mw[2] = 1000  mw[3] = 1000  mw[4] = 1000  mw[5] = 1000 ; SubVA    to SubVA
;;;   IF (MW[100] = 2 && MW[200] = 3)  mw[1] =  500  mw[2] =  500  mw[3] =  300  mw[4] =  500  mw[5] =  500 ; SubVA    to OuterMD
;;;   IF (MW[100] = 2 && MW[200] = 4)  mw[1] = 1000  mw[2] = 1000  mw[3] = 1000  mw[4] = 1000  mw[5] = 1000 ; SubVA    to OuterVA
;;;
;;;   IF (MW[100] = 3 && MW[200] = 1)  mw[1] = 1000  mw[2] = 1000  mw[3] = 1000  mw[4] = 1000  mw[5] = 1000 ; OuterMD  to DC/SubMD
;;;   IF (MW[100] = 3 && MW[200] = 2)  mw[1] =  700  mw[2] = 1000  mw[3] = 1000  mw[4] =  500  mw[5] =  400 ; OuterMD  to SubVA
;;;   IF (MW[100] = 3 && MW[200] = 3)  mw[1] = 1000  mw[2] = 1000  mw[3] = 1000  mw[4] = 1000  mw[5] = 1000 ; OuterMD  to OuterMD
;;;   IF (MW[100] = 3 && MW[200] = 4)  mw[1] =  500  mw[2] = 1000  mw[3] = 1000  mw[4] = 1000  mw[5] = 1000 ; OuterMD  to OuterVA
;;;
;;;   IF (MW[100] = 4 && MW[200] = 1)  mw[1] =  700  mw[2] = 1000  mw[3] = 1000  mw[4] = 1000  mw[5] = 1000 ; OuterVA  to DC/SubMD
;;;   IF (MW[100] = 4 && MW[200] = 2)  mw[1] = 1000  mw[2] = 1000  mw[3] = 1000  mw[4] = 1000  mw[5] = 1000 ; OuterVA  to SubVA
;;;   IF (MW[100] = 4 && MW[200] = 3)  mw[1] =  300  mw[2] = 1000  mw[3] = 1000  mw[4] = 1000  mw[5] = 1000 ; OuterVA  to OuterMD
;;;   IF (MW[100] = 4 && MW[200] = 4)  mw[1] = 1000  mw[2] = 1000  mw[3] = 1000  mw[4] = 1000  mw[5] = 1000 ; OuterVA  to OuterVA
;;; ENDJLOOP
;;;
;;; /* *********  End Bridge penalty section ****************************** */

;;---------------------------------------
;Define K-Factor production areas

;  HBW: Same as those used in the Ver. 2.2 model, but dropped
;          * pw-dc core
;          * frd-frd

if     (i =    5,48,51,64,66-180,210-281,288-373,382-393)
   mw[1] = 2000, include= 1-4,6-47,49-50,52-63,65,181-209,282-287,374-381  ; DC non-core to DC core
elseif (i =  394-769)
   mw[1] = 2000, include=  1-4,6-47,49-50,52-63,65,181-209,282-287,374-381 ; Mont to DC core
elseif (i =  394- 769)
   mw[1] = 2500, include=  394- 769                                     ; Mont to Mont
elseif (i = 771-776,778-1404)
   mw[1] = 1500, include=771-776,778-1404                               ; PG to PG
elseif     (i =    471-1476, 1486-1489, 1495-1497)
   mw[1] = 2500, include=  1-4,6-47,49-50,52-63,65,181-209,282-287,374-381 ; Arl cr to DC cr
elseif     (i =    1405-1470,1477-1485,1490-1494,1498-1545)
   mw[1] = 1700, include=  1-4,6-47,49-50,52-63,65,181-209,282-287,374-381 ; Arl non-cr to DC cr
elseif     (i =    1546-1610)
   mw[1] = 2000, include=  1-4,6-47,49-50,52-63,65,181-209,282-287,374-381 ; Alx to DC cr
elseif     (i =    1611-2159)
   mw[1] = 1500, include=  1-4,6-47,49-50,52-63,65,181-209,282-287,374-381 ; Ffx to DC cr
elseif     (i =    1611-2159)
   mw[1] = 1000, include=  5,48,51,64,66-180,210-281,288-373,382-393 ; Ffx to DC non-cr
elseif     (i =    1611-2159)
   mw[1] = 1200, include=  1611-2159                                ; Ffx to Ffx
elseif     (i =    2442-2554,2556-2628,2630-2819)
   mw[1] = 2000, include=  1611-2159                                ; PW to Ffx
endif


;  HBS  = 1.5 for most intra-jurisdiction movements
;         Exceptions: DC; Mont; PG; Ffx; Staf all = 2.0

if     (i = 5,48,51,64,66-180,210-281,288-373,382-393)
   mw[2] = 2500, include=5,48,51,64,66-180,210-281,288-373,382-393       ; DC non-core to DC non-core
elseif (i =  394- 769)
   mw[2] = 2000, include=  394- 769       ; Mont to Mont
elseif (i = 771-776,778-1404)
   mw[2] = 2500, include=771-776,778-1404 ; PG to PG
elseif (i = 1405-1470,1477-1485,1490-1494,1498-1545)
   mw[2] = 2000, include=  1405-1470,1477-1485,1490-1494,1498-1545       ; Arl non-core to Arl non-core
elseif (i =  1546-1610)
   mw[2] = 2000, include= 1546-1610       ; Alx to Alx
elseif (i = 1611-2159)
   mw[2] = 2500, include= 1611-2159       ; Ffx to Ffx
elseif (i = 2160-2441)
   mw[2] = 1500, include= 2160-2441       ; Ldn to Ldn
elseif (i = 2442-2554,2556-2628,2630-2819)
   mw[2] = 1750, include= 2442-2554,2556-2628,2630-2819       ; PW to PW
elseif (i = 2820-2949)
   mw[2] = 1500, include= 2820-2949       ; Frd to Frd
elseif (i = 3230-3265,3268-3287)
   mw[2] = 1500, include= 3230-3265,3268-3287       ; Car to Car
elseif (i = 2950-3017)
   mw[2] = 1500, include= 2950-3017       ; How to How
elseif (i = 3018-3102,3104-3116)
   mw[2] = 1500, include= 3018-3102,3104-3116       ; Ann to Ann
elseif (i = 3288-3334)
   mw[2] = 1500, include= 3288-3334       ; Calv to Calv
elseif (i = 3335-3409)
   mw[2] = 1500, include= 3335-3409       ; StM to StM
elseif (i = 3117-3229)
   mw[2] = 1500, include= 3117-3229       ; Chs to Chs
elseif (i = 3604-3653)
   mw[2] = 1500, include= 3604-3653       ; Fau to Fau
elseif (i = 3449-3477,3479-3481,3483-3494,3496-3541)
   mw[2] = 1500, include= 3449-3477,3479-3481,3483-3494,3496-3541       ; Staf to Staf
elseif (i = 3654-3662)
   mw[2] = 1500, include= 3654-3662       ; Clrk to Clrk
elseif (i = 3663-3675)
   mw[2] = 1500, include= 3663-3675       ; Jef to Jef
elseif (i = 3435-3448)
   mw[2] = 1500, include= 3435-3448       ; Frbrg to Frbrg
elseif (i = 3542-3543,3545-3603)
   mw[2] = 1500, include= 3542-3543,3545-3603       ; Spots to Spots
elseif (i = 3410-3434)
   mw[2] = 1500, include= 3410-3434       ; KingG to KingG
endif

;  HBO  = 1.5 for some  intra-jurisdiction movements
;       = 2.0 for other intra-jurisdiction movements

if     (i =    5,48,51,64,66-180,210-281,288-373,382-393)
   mw[3] = 2200, include=    5,48,51,64,66-180,210-281,288-373,382-393       ; DC non-core to DC non-core
elseif (i =  394- 769)
   mw[3] = 2200, include=  394- 769       ; Mont to Mont
elseif (i = 771-776,778-1404)
   mw[3] = 2500, include=771-776,778-1404 ; PG to PG
elseif (i = 1405-1470,1477-1485,1490-1494,1498-1545)
   mw[3] = 2200, include= 1405-1470,1477-1485,1490-1494,1498-1545      ; Arl non-core to Arl non-core
elseif (i = 1546-1610)
   mw[3] = 2200, include= 1546-1610       ; Alx to Alx
elseif (i = 1611-2159)
   mw[3] = 2500, include= 1611-2159       ; Ffx to Ffx
elseif (i = 2160-2441)
   mw[3] = 2200, include= 2160-2441       ; Ldn to Ldn
elseif (i = 2442-2554,2556-2628,2630-2819)
   mw[3] = 2200, include= 2442-2554,2556-2628,2630-2819       ; PW to PW
elseif (i = 2820-2949)
   mw[3] = 2200, include= 2820-2949       ; Frd to Frd
elseif (i = 3230-3265,3268-3287)
   mw[3] = 2200, include= 3230-3265,3268-3287       ; Car to Car
elseif (i = 2950-3017)
   mw[3] = 2200, include= 2950-3017       ; How to How
elseif (i = 3018-3102,3104-3116)
   mw[3] = 2200, include= 3018-3102,3104-3116       ; Ann to Ann
elseif (i = 3288-3334)
   mw[3] = 1500, include= 3288-3334       ; Calv to Calv
elseif (i = 3335-3409)
   mw[3] = 1500, include= 3335-3409       ; StM to StM
elseif (i = 3117-3229)
   mw[3] = 1500, include= 3117-3229       ; Chs to Chs
elseif (i = 3604-3653)
   mw[3] = 1500, include= 3604-3653       ; Fau to Fau
elseif (i = 3449-3477,3479-3481,3483-3494,3496-3541)
   mw[3] = 1000, include= 3449-3477,3479-3481,3483-3494,3496-3541       ; Staf to Staf
elseif (i = 3654-3662)
   mw[3] = 1500, include= 3654-3662       ; Clrk to Clrk
elseif (i = 3663-3675)
   mw[3] = 1500, include= 3663-3675       ; Jef to Jef
elseif (i = 3435-3448)
   mw[3] = 1000, include= 3435-3448       ; Frbrg to Frbrg
elseif (i = 3542-3543,3545-3603)
   mw[3] = 1000, include= 3542-3543,3545-3603       ; Spots to Spots
elseif (i = 3410-3434)
   mw[3] = 1500, include= 3410-3434       ; KingG to KingG
endif


;  NHW  = 1.5 for most intra-jurisdiction movements
;       = 2.0 for some intra-jurisdiction movements

if     (i =    5,48,51,64,66-180,210-281,288-373,382-393)
   mw[4] = 1500, include=    5,48,51,64,66-180,210-281,288-373,382-393       ; DC non-core to DC non-core
elseif (i =  394- 769)
   mw[4] = 2200, include=  394- 769       ; Mont to Mont
elseif (i = 771-776,778-1404)
   mw[4] = 1500, include=771-776,778-1404 ; PG to PG
elseif (i = 1405-1470,1477-1485,1490-1494,1498-1545)
   mw[4] = 1700, include= 1405-1470,1477-1485,1490-1494,1498-1545      ; Arl non-core to Arl non-core
elseif (i = 1546-1610)
   mw[4] = 1700, include= 1546-1610       ; Alx to Alx
elseif (i = 1611-2159)
   mw[4] = 2000, include= 1611-2159       ; Ffx to Ffx
elseif (i = 2160-2441)
   mw[4] = 1700, include= 2160-2441       ; Ldn to Ldn
elseif (i = 2442-2554,2556-2628,2630-2819)
   mw[4] = 1500, include= 2442-2554,2556-2628,2630-2819       ; PW to PW
elseif (i = 2820-2949)
   mw[4] = 1500, include= 2820-2949       ; Frd to Frd
elseif (i = 3230-3265,3268-3287)
   mw[4] = 1500, include= 3230-3265,3268-3287       ; Car to Car
elseif (i = 2950-3017)
   mw[4] = 1700, include= 2950-3017       ; How to How
elseif (i = 3018-3102,3104-3116)
   mw[4] = 1500, include= 3018-3102,3104-3116       ; Ann to Ann
elseif (i = 3288-3334)
   mw[4] = 1500, include= 3288-3334       ; Calv to Calv
elseif (i = 3335-3409)
   mw[4] = 1500, include= 3335-3409       ; StM to StM
elseif (i = 3117-3229)
   mw[4] = 1500, include= 3117-3229       ; Chs to Chs
elseif (i = 3604-3653)
   mw[4] = 1500, include= 3604-3653       ; Fau to Fau
elseif (i = 3449-3477,3479-3481,3483-3494,3496-3541)
   mw[4] = 1500, include= 3449-3477,3479-3481,3483-3494,3496-3541       ; Staf to Staf
elseif (i = 3654-3662)
   mw[4] = 1500, include= 3654-3662       ; Clrk to Clrk
elseif (i = 3663-3675)
   mw[4] = 1500, include= 3663-3675       ; Jef to Jef
elseif (i = 3435-3448)
   mw[4] = 1500, include= 3435-3448       ; Frbrg to Frbrg
elseif (i = 3542-3543,3545-3603)
   mw[4] = 1500, include= 3542-3543,3545-3603       ; Spots to Spots
elseif (i = 3410-3434)
   mw[4] = 1500, include= 3410-3434       ; KingG to KingG
endif


;  NHO  = 1.5 for most intra-jurisdiction movements
;       = 2.0 for some intra-jurisdiction movements

if     (i =    5,48,51,64,66-180,210-281,288-373,382-393)
   mw[5] = 2500, include=    5,48,51,64,66-180,210-281,288-373,382-393       ; DC non-core to DC non-core
elseif (i =  394- 769)
   mw[5] = 1500, include=  394- 769       ; Mont to Mont
elseif (i = 771-776,778-1404)
   mw[5] = 1700, include=771-776,778-1404 ; PG to PG
elseif (i = 1405-1470,1477-1485,1490-1494,1498-1545)
   mw[5] = 1700, include= 1405-1470,1477-1485,1490-1494,1498-1545       ; Arl non-core to Arl non-core
elseif (i = 1546-1610)
   mw[5] = 1700, include= 1546-1610       ; Alx to Alx
elseif (i = 1611-2159)
   mw[5] = 2100, include= 1611-2159       ; Ffx to Ffx
elseif (i = 2160-2441)
   mw[5] = 1500, include= 2160-2441       ; Ldn to Ldn
elseif (i = 2442-2554,2556-2628,2630-2819)
   mw[5] = 1500, include= 2442-2554,2556-2628,2630-2819       ; PW to PW
elseif (i = 2820-2949)
   mw[5] = 1500, include= 2820-2949       ; Frd to Frd
elseif (i = 3230-3265,3268-3287)
   mw[5] = 1500, include= 3230-3265,3268-3287       ; Car to Car
elseif (i = 2950-3017)
   mw[5] = 1700, include= 2950-3017       ; How to How
elseif (i = 3018-3102,3104-3116)
   mw[5] = 1700, include= 3018-3102,3104-3116       ; Ann to Ann
elseif (i = 3288-3334)
   mw[5] = 1700, include= 3288-3334       ; Calv to Calv
elseif (i = 3335-3409)
   mw[5] = 1700, include= 3335-3409       ; StM to StM
elseif (i = 3117-3229)
   mw[5] = 1700, include= 3117-3229       ; Chs to Chs
elseif (i = 3604-3653)
   mw[5] = 1700, include= 3604-3653       ; Fau to Fau
elseif (i = 3449-3477,3479-3481,3483-3494,3496-3541)
   mw[5] = 1700, include= 3449-3477,3479-3481,3483-3494,3496-3541       ; Staf to Staf
elseif (i = 3654-3662)
   mw[5] = 1300, include= 3654-3662       ; Clrk to Clrk
elseif (i = 3663-3675)
   mw[5] = 1300, include= 3663-3675       ; Jef to Jef
elseif (i = 3435-3448)
   mw[5] = 1700, include= 3435-3448       ; Frbrg to Frbrg
elseif (i = 3542-3543,3545-3603)
   mw[5] = 1700, include= 3542-3543,3545-3603       ; Spots to Spots
elseif (i = 3410-3434)
   mw[5] = 1500, include= 3410-3434       ; KingG to KingG
endif


MATO[1] =@HBWK@ ,MO=1
MATO[2] =@HBSK@ ,MO=2
MATO[3] =@HBOK@ ,MO=3
MATO[4] =@NHWK@ ,MO=4
MATO[5] =@NHOK@ ,MO=5



; |\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\|
; |//////   End of K-Factor Specifications for All Purposes  /////|
; |\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\|

endrun

; |\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\|
; |///  Added step to create station name file for the Linesum \\\| 
; |///  program directly from scenario specific station file   \\\| 
; |\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\|


;Program step to write a station names file (used by the LINSESUM program) directly from
;the "Station.dbf" file.  The O/P file will be sent to the inputs subdirectory; make sure
;that this is reflected in the LINESUM_MR_Access.ctl file

;Input file:
    Sta_File    =  'inputs\Station.dbf'  ; Std. Station file


; Output File:
    Sta_Names   =  'inputs\station_names.dbf' ;
 
 
RUN PGM=MATRIX
Zones=1
FILEI DBI[1]    ="@Sta_File@"
FILEO RECO[1]   ="@Sta_Names@", Fields= ID(12.0),Station(c35)
;
LOOP  K = 1,dbi.1.NUMRECORDS
      x = DBIReadRecord(1,k)
          idx         = dbi.1.recno  ;
          STAT        = di.1.STAT    ; Station no.
          STAN1       = di.1.STAN1   ; First Bus Node no.
          MM          = di.1.MM      ; Mode Code (M,C,L,B,N)
          SNAME       = di.1.SNAME   ; Mode Code (M,C,L,B,N)
          ;
          ; Index = STAT unless mode = "B"- in that case the Station will equal STAN1
                        RO.ID       = STAT
          IF (MM = 'B') RO.ID       = STAN1
                        RO.STATION  = SNAME
          WRITE  RECO = 1
ENDLOOP

ENDRUN


