
// reference -> SvIV -> Ns_Set

#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include "Ns_SetMaps.h"

#include </usr/local/aolserver/include/nsthread.h>
#include </usr/local/aolserver/include/tcl.h>
#include </usr/local/aolserver/include/ns.h>

#include <stdio.h>

Ns_Set *NsSetInputMap(SV *arg)
{
  dTHX;
  Ns_Set *result = 0;

  result = (Ns_Set *) SvIV( SvRV(arg) );
 
  return result;
}

int NsSetIsNull(SV *arg)
{
  return NsSetInputMap(arg) == NULL;
}

void MakeNsSetNull(SV *arg)
{
  dTHX;
  
  sv_setiv(SvRV(arg), 0);
}

SV *NsSetOutputMap(Ns_Set *var, char *class)
{
  dTHX;
  SV *sviv = newSViv( (IV) var );
  SV *arg = newRV_inc( sviv );

  sv_bless(arg, gv_stashpv(class, TRUE));

  return arg;
}


