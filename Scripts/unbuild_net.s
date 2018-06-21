*del tppl*.prn
;-------------------------------------------------------------------------------
; unbuild_net.s
;   Unbuilds a highway network (converts from TP+ binary to DBF format)
;   Output files are in the format needed for the Version 2.3 travel model
;-------------------------------------------------------------------------------
pageheight=32767  ; Set the page height to a large value to minimize page breaks


basepath  = 'I:\ateam'
inhwy     = 'zonehwy.net'
out_link  = 'Link.dbf'
out_node  = 'Node.dbf'


run pgm = hwynet

neti = @basepath@\@inhwy@

/* Write out link file */

linko= @basepath@\@out_link@,
  format=DBF,
  include=a(5),b(5),distance(7.2),spdc(7),capc(7),jur(7),Screen(5),ftype(7),toll(9),tollgroup(5),
           amlane(3),amlimit(3),pmlane(3),pmlimit(3),oplane(3),oplimit(3),edgeid(10),linkid(10),Networkyear(8),Shape_Length(7.2),
           projectid(10)

/* Write out node file */

nodeo= @basepath@\@out_node@,
  format=DBF,
  include=n(6),x(8),y(8)

endrun

*copy tppl*.prn  unbuild_net.rpt
