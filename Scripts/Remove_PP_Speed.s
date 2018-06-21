;;  Remove initial 'lookup' speeds on highway links defined during hwy network building
;;  The speeds will be replaced by restrained speeds created in the 'pump prime' assignment
;;
*copy zonehwy.net zonehwy.tem
*del  zonehwy.net
RUN PGM=NETWORK
NETI = ZONEHWY.tem
NETO = zonehwy.net, exclude= PPAMSPD,PPPMSPD,PPMDSPD,PPNTSPD,PPOPSPD
ENDRUN
