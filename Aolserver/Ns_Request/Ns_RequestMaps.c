
// This is an Aolserver::Ns_Request:
//
// reference -> SvIV -> ram slab which is Ns_Request
//     |
//   blessed as
// "Aolserver::Ns_Request"

#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include "logging.h"

#include <nsthread.h>
#include <tcl.h>
#include <ns.h>

Ns_Request *NsRequestInputMap(SV *arg, char *class, char *varName)
{
  dTHX;
  Ns_Request *result = 0;

  if (sv_derived_from(arg, class)) 
    {
      SV **hashValue = hv_fetch( (HV*)SvRV(arg), "theNs_Request", 13, FALSE);
      
      LOG(StringF("NsRequestInputMap: (extracting C stuff from perl stuff)"));
      
      if(hashValue)
	result = (Ns_Request *) SvIV( *hashValue );
    }
  else
    {
      char msg[200];

      snprintf(msg, 199, "%s is not of type %s", varName, class);
      croak(msg);
    }

  return result;
}

SV *NsRequestOutputMap(Ns_Request *var, char *class, int perlOwns)
{
  dTHX;
  HV *hashReferent = newHV();
  SV *arg = newRV_noinc( (SV *) hashReferent);

  LOG(StringF("NsRequestOutputMap: (creating perl stuff for the C stuff)"));
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
      "theNs_Request", 
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

int NsRequestOwnedP(SV *requestPerlRef)
{
  dTHX;
  SV **hashValue = hv_fetch( (HV*)SvRV(requestPerlRef), "perlOwns", 8, FALSE);
  SV *perlOwns = ((hashValue != NULL) ? *hashValue : &PL_sv_yes);
  int result = 0;

  result = (perlOwns == &PL_sv_yes);

  return result;
}

