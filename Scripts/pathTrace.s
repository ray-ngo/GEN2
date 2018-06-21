; pathTrace.s
;   This file will get inserted into Transit Skims Steps to perform path traces
;   for select i/j's (origins and destinations)
;
;  2010-10-08  MSM
;
; 3722   Juris
; TAZ    Code   Location                                Orig  Dest
; ------------------------------------------------------------------------------
;   37     0    Downtown DC (Farragut West)              x      x
;  283     0    Union Station, DC                               x
;  492     1    Gaithersburg, near Mont Co Airpark, MD   x
;  520     1    Shady Grove, MD                          x
;  589     1    North Silver Spring, MD                  x
;  623     1    Silver Spring, MD                        x      x
;  662     1    Bethesda, MD                             x      x
;  717     1    Rockville, MD                            x      x
;  906     2    Greenbelt, MD                            x
;  982     2    College Park, Univ. of Maryland          x
; 1003     2    New Carrollton, MD                       x
; 1342     2    Andrews Air Force Base, MD                      x
; 1472     3    Rosslyn, Arlington, VA                          x
; 1496     3    Pentagon, Arlington, VA                  x      x
; 1501     3    Crystal City, Arlington, VA              x      x
; 1599     4    Old Town Alexandria, VA                  x      x
; 1679     5    South of Dulles Airport, VA                     x
; 1768     5    Reston, VA                               x
; 1823     5    Vienna, VA                               x
; 1843     5    Tysons Corner, VA                        x      x
; 2032     5    Franconia-Springfield, VA                x
; 2112     5    Fort Belvoir, VA                                x
; 2139     5    Rolling Road VRE Station, VA             x
; 2250     6    Loudoun Co. near Brunswick MARC sta.     x
; 2270     6    Leesburg, VA                             x
; 2632     7    Manassas City, Prince William Co, VA     x
; 2751     7    Dale City, Prince William Co, VA         x
; 2807     7    Quantico VRE, VA                         x
; 2928     9    City of Frederick, Fred. Co, MD          x
; 3004    10    Jessup MARC Station, Howard Co, MD       x
; 3007    10    North Laurel, Howard Co, MD              x
; 3197    12    La Plata, Charles Co, MD                 x
; 3580    20    Spotsylvania Co, VA                      x

; ***** Comment out this section when running the model;  Keep this for building only select paths
;;************* select i =
;;************* 37, 492, 520, 589, 623, 662, 717, 906, 982, 1003, 1496, 1501,
;;************* 1599, 1768, 1823, 1843, 2032, 2139, 2250, 2270, 2632, 2751, 2807,
;;************* 2928, 3004, 3007, 3197, 3580,
;;************* j =
;;************* 37, 283, 623, 662, 717, 1342, 1472, 1496, 1501, 1599, 1679, 1843, 2112
;  ***** End of section to be commented out when running travel model

select trace = (i =
37, 492, 520, 589, 623, 662, 717, 906, 982, 1003, 1496, 1501,
1599, 1768, 1823, 1843, 2032, 2139, 2250, 2270, 2632, 2751, 2807,
2928, 3004, 3007, 3197, 3580 &&
j =
37, 283, 623, 662, 717, 1342, 1472, 1496, 1501, 1599, 1679, 1843, 2112)


