
// reference -> SvIV -> Ns_Set

#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include "Ns_SetMaps.h"

#include </usr/local/aolserver/include/nsthread.h>
#include </usr/local/aolserver/include/tcl.h>
#include </usr/local/aolserver/include/ns.h>

#include <stdio.h>

#include "Ns_SetMaps.h"

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

void NsSetMakeNull(SV *arg)
{
  dTHX;
  
  NsSetStore(arg, NULL);
}

SV *NsSetOutputMap(Ns_Set *var, char *class)
{
  dTHX;
  SV *sviv = newSViv( (IV) var );
  SV *arg = newRV_inc( sviv );

  sv_bless(arg, gv_stashpv(class, TRUE));

  return arg;
}

void NsSetStore(SV *setPerlRef, Ns_Set *set)
{
  sv_setiv(SvRV(setPerlRef), (IV) set);
}

