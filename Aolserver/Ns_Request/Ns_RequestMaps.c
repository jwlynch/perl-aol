
// reference -> SvIV -> Ns_Request

#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include <nsthread.h>
#include <tcl.h>
#include <ns.h>

Ns_Request *NsRequestInputMap(SV *arg)
{
  dTHX;
  Ns_Request *result = 0;
  
  result = (Ns_Request *) SvIV( SvRV(arg) );
  
  return result;
}

SV *NsRequestOutputMap(Ns_Request *var, char *class)
{
  dTHX;
  SV *sviv = newSViv( (IV) var );
  SV *arg = newRV_inc( sviv );

  sv_bless(arg, gv_stashpv(class, TRUE));

  return arg;
}

