#include <ns.h>

#include "Ns_DStringMaps.h"

Ns_DString *NsDStringInputMap(SV *arg)
{
  dTHX;
  Ns_DString *var;

  var = (Ns_DString *) SvIV((SV*)SvRV(arg));

  return var;
}

SV *NsDStringOutputMap(Ns_DString *var, char *class)
{
  dTHX;
  SV *sviv = newSViv( (Ns_DString *) var );
  SV *arg = newRV_inc( sviv );

  sv_bless(arg, gv_stashpv(class, TRUE));

  return arg;
}

