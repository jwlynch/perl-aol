//
// This is now an Aolserver::Ns_Set:
// 
//     SvRV  -> hash -> {theNs_Set}     -> SvIV -> ram slab which is Ns_Set
//      |               {perlOwns}      -> true or false value (if false,
//   blessed as                              do not free theNs_Set)
// "Aolserver::Ns_Set"

#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include "Ns_SetMaps.h"

#include "logging.h"

#include <nsthread.h>
#include <tcl.h>
#include <ns.h>

#include <stdio.h>

#include "Ns_SetMaps.h"

Ns_Set *NsSetInputMap(SV *arg, char *class, char *varName)
{
  dTHX;
  Ns_Set *result = 0;

  if (sv_derived_from(arg, class)) 
    {
      SV **hashValue = hv_fetch( (HV*)SvRV(arg), "theNs_Set", 9, FALSE);
      
      LOG(StringF("NsSetInputMap: (extracting C stuff from perl stuff)"));
      //NsConnPrintRefCounts(arg);
      
      if(hashValue)
	result = (Ns_Set *) SvIV( *hashValue );
    }
  else
    {
      char msg[200];

      snprintf(msg, 199, "%s is not of type %s", varName, class);
      croak(msg);
    }

  return result;
}

SV *NsSetOutputMap(Ns_Set *var, char *class, int perlOwns)
{
  dTHX;
  HV *hashReferent = newHV();
  SV *arg = newRV_noinc( (SV *) hashReferent);

  LOG(StringF("NsSetOutputMap: (creating new perl stuff for the C stuff)\n"));
  LOG
    (
      StringF
        (
          "  - overall ref at %p and its refcnt is %ld\n", 
	  arg, 
	  SvREFCNT(arg)
	)
    );
  LOG
    (
      StringF
        (
          "  - hash at %p and its refcnt is %ld\n", 
	  hashReferent, 
	  SvREFCNT(hashReferent)
	)
    );

  hv_store
    (
      hashReferent, 
      "theNs_Set", 
      9, 
      newSViv((IV) var),
      0
    );

  hv_store
    (
      hashReferent, 
      "perlOwns", 
      8, 
      (perlOwns ? (&PL_sv_yes) : (&PL_sv_no)),
      0
    );

  sv_bless(arg, gv_stashpv(class, TRUE));

  return arg;
}

int NsSetOwnedP(SV *connPerlRef)
{
  dTHX;
  SV **hashValue = hv_fetch( (HV*)SvRV(connPerlRef), "perlOwns", 8, FALSE);
  SV *perlOwns = ((hashValue != NULL) ? *hashValue : &PL_sv_yes);
  int result = 0;

  if(perlOwns == &PL_sv_yes)
    result = 1;
  else 
    result = 0;

  return result;
}

