//
// This is now an Aolserver::Ns_DString:
// 
//     SvRV  -> hash -> {theNs_DString} -> SvIV -> ram slab which is Ns_DString
//      |               {perlOwns}      -> true or false value (if false,
//   blessed as                              do not free theNs_Set)
// "Aolserver::Ns_DString"

#include <ns.h>

#include "logging.h"
#include "Ns_DStringMaps.h"

Ns_DString *NsDStringInputMap(SV *arg, char *class, char *varName)
{
  dTHX;
  Ns_DString *result = 0;

  if (sv_derived_from(arg, class)) 
    {
      SV **hashValue = hv_fetch( (HV*)SvRV(arg), "theNs_DString", 13, FALSE);
      
      LOG(StringF("NsDStringInputMap: (extracting C stuff from perl stuff)"));
      
      if(hashValue)
	result = (Ns_DString *) SvIV( *hashValue );
    }
  else
    {
      char msg[200];

      snprintf(msg, 199, "%s is not of type %s", varName, class);
      croak(msg);
    }

  return result;
}

SV *NsDStringOutputMap(Ns_DString *var, char *class, int perlOwns)
{
  dTHX;
  HV *hashReferent = newHV();
  SV *arg = newRV_noinc( (SV *) hashReferent);

  LOG(StringF("NsDStringOutputMap: (creating new perl stuff for C stuff)"));
  LOG
    (
      StringF
        (
          "  - overall ref at %p and its refcnt is %ld", 
	  arg, 
	  SvREFCNT(arg)
	)
    );
  LOG
    (
      StringF
        (
          "  - hash at %p and its refcnt is %ld", 
	  hashReferent, 
	  SvREFCNT(hashReferent)
	)
    );

  hv_store
    (
      hashReferent, 
      "theNs_DString", 
      13, 
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

// checks if perl should free this (which it should if it owns it)
int NsDStringOwnedP(SV *dStringPerlRef)
{
  dTHX;
  SV **hashValue = hv_fetch( (HV*)SvRV(dStringPerlRef), "perlOwns", 8, FALSE);
  SV *perlOwns = ((hashValue != NULL) ? *hashValue : &PL_sv_yes);
  int result = 0;

  result = (perlOwns == &PL_sv_yes);

  return result;
}

