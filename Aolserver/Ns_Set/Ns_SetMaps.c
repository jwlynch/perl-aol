//
// This is (NOT YET) now an Aolserver::Ns_Set:
// 
//     SvRV  -> hash -> {theNs_Set}     -> SvIV -> ram slab which is Ns_Set
//      |               {perlOwns}      -> true or false value (if false,
//   blessed as                              do not free theNs_Set)
// "Aolserver::Ns_Set"


// This is (the original and current definition of) an Aolserver::Ns_Set:
//
//    SvRV    -> SvIV -> ram slab which is Ns_Set
//     |
//   blessed as
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

#ifdef SKIP

Ns_Conn *NsSetInputMap(SV *arg, char *class, char *varName)
{
  dTHX;
  Ns_Set *result = 0;

  if (sv_derived_from(arg, class)) 
    {
      SV **hashValue = hv_fetch( (HV*)SvRV(arg), "theNs_Set", 9, FALSE);
      
      LOG(StringF("NsSetInputMap: (extracting C stuff from perl stuff)\n"));
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

#endif

Ns_Set *NsSetInputMap(SV *arg, char *class, char *varName)
{
  dTHX;
  Ns_Set *result = 0;

  if (sv_derived_from(arg, class))
    {
      result = (Ns_Set *) SvIV( SvRV(arg) );
    }
  else
    {
      char errString[200];
      
      snprintf(errString, 200, "%s is not of type %s", varName, class);
      croak(errString);
    }
 
  return result;
}

int NsSetIsNull(SV *arg)
{
  return NsSetInputMap(arg, "Aolserver::Ns_Set", "arg") == NULL;
}

void NsSetMakeNull(SV *arg)
{
  NsSetStore(arg, NULL);
}

// SV *NsSetOutputmap(NsSet *var, char *class) {
//  SV *r = newSV(); sv_setref_pv(r, class, var); return r; }

SV *NsSetOutputMap(Ns_Set *var, char *class)
{
  dTHX;

  SV *sviv = newSViv( (IV) var );
  SV *arg = newRV_noinc( sviv );

  sv_bless(arg, gv_stashpv(class, TRUE));
  LOG(StringF("set p=%p wrapped as %s, sviv at %p\n", var, class, sviv));

  return arg;
}

#ifdef SKIP

SV *NsSetOutputMap(Ns_Conn *var, char *class, int perlOwns)
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
      (perlOwns ? (&pl_sv_yes) : (&pl_sv_no)),
      0
    );

  sv_bless(arg, gv_stashpv(class, TRUE));

  return arg;
}

#endif

void NsSetStore(SV *setPerlRef, Ns_Set *theSet)
{
  SV *theSvIV;
  IV theIV;
  dTHX;

  if(setPerlRef != 0 && setPerlRef != &PL_sv_undef)
    {
      theSvIV = SvRV(setPerlRef);
      theIV = SvIV(theSvIV);

      LOG
	(
	  StringF
	    (
	      "NsSetStore: ref @ %p, SvIV at %p, old value %p, new value %p\n",
	      setPerlRef, 
	      theSvIV, 
	      theIV,
	      theSet
            )
        );

      sv_setiv(theSvIV, (IV) theSet);
    }
  else
    {
      LOG(StringF("NsSetStore: perl ref to set was zero\n"));
    }

}

