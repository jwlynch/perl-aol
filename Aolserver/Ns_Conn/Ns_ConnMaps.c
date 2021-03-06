//
// This is now an Aolserver::Ns_Conn:
// 
//     SvRV  -> hash -> {theNs_Conn}    -> SvIV -> Ns_Conn
//      |               {headers}       -> (set ref as def'd by its typemap)
//      |               {outputheaders} -> (set ref as def'd by its typemap)
//      |               {request}       -> (request ref as def'd by typemap)
//      |               {perlOwns}      -> true if perl owns the Ns_Conn
//      |                                    (-never-, afaict!)
//   blessed as
// "Aolserver::Ns_Conn"

#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include "logging.h"

#include "../Ns_Set/Ns_SetMaps.h"
#include "../Ns_Request/Ns_RequestMaps.h"

#include "Ns_ConnMaps.h"

#include "AolserverCommon.h"

#include <nsthread.h>
#include <tcl.h>
#include <ns.h>

#include <stdio.h>

void NsConnPrintRefCounts(SV *connPerlRef)
{
  HV *hashReferent = (HV*)SvRV(connPerlRef);
  SV **hv = hv_fetch( hashReferent, "theNs_Conn", 10, FALSE);
  SV *theConnIV  = hv ? *hv : 0;
  SV *headers    = NsConnGetHeaders(connPerlRef);
  SV *outHeaders = NsConnGetOutputHeaders(connPerlRef);
  SV *request    = NsConnGetRequest(connPerlRef);

  LOG
  (
    StringF
    (
      "refcounts: ref: %ld, hash: %ld, conn: %ld, hdrs: %ld, oHdrs: %ld, req: %ld",
      SvREFCNT(connPerlRef),
      SvREFCNT(hashReferent),
      theConnIV ? SvREFCNT(theConnIV) : -99L,
      SvREFCNT(headers),
      SvREFCNT(outHeaders),
      SvREFCNT(request)
    )
  );
}

Ns_Conn *NsConnInputMap(SV *arg, char *class, char *varName)
{
  dTHX;
  Ns_Conn *result = 0;

  if (sv_derived_from(arg, class)) 
    {
      SV **hashValue = hv_fetch( (HV*)SvRV(arg), "theNs_Conn", 10, FALSE);
      
      LOG(StringF("NsConnInputMap: (extracting C stuff from perl stuff)"));
      NsConnPrintRefCounts(arg);
      
      if(hashValue)
	result = (Ns_Conn *) SvIV( *hashValue );
    }
  else
    {
      char msg[200];

      snprintf(msg, 199, "%s is not of type %s", varName, class);
      croak(msg);
    }

  return result;
}

SV *NsConnOutputMap(Ns_Conn *var, char *class, int perlOwns)
{
  dTHX;
  HV *hashReferent = newHV();
  SV *arg = newRV_noinc( (SV *) hashReferent);

  LOG(StringF("NsConnOutputMap: (creating new perl stuff for the C stuff)"));
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
      "theNs_Conn", 
      10, 
      newSViv((IV) var),
      0
    );

  hv_store
    (
      hashReferent, 
      "headers", 
      7, 
      NsSetOutputMap(var->headers, "Aolserver::Ns_Set", perlDoesntOwn),
      0
    );

  hv_store
    (
      hashReferent, 
      "outputheaders", 
      13, 
      NsSetOutputMap(var->outputheaders, "Aolserver::Ns_Set", perlDoesntOwn),
      0
    );

  hv_store
    (
      hashReferent, 
      "request", 
      7, 
      NsRequestOutputMap(var->request, "Aolserver::Ns_Request", perlDoesntOwn),
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

int NsConnOwnedP(SV *connPerlRef)
{
  dTHX;
  SV **hashValue = hv_fetch( (HV*)SvRV(connPerlRef), "perlOwns", 8, FALSE);
  SV *perlOwns = ((hashValue != NULL) ? *hashValue : &PL_sv_yes);
  int result = 0;

  result = (perlOwns == &PL_sv_yes);

  return result;
}

// outputs the stored ref to the Ns_Set, takes the ref to the conn as input

SV *NsConnGetHeaders(SV *connPerlRef)
{
  dTHX;
  SV **hashValue = hv_fetch( (HV*)SvRV(connPerlRef), "headers", 7, FALSE);
  SV *result = ((hashValue != NULL) ? *hashValue : 0);
  
  LOG
    (
      StringF
        (
          "NsConnGetHeaders: hashValue = %p; result = %p", 
	  hashValue, 
	  result
        )
    );

  return result;
}

// outputs the stored ref to the Ns_Set, takes the ref to the conn as input

SV *NsConnGetOutputHeaders(SV *connPerlRef)
{
  dTHX;
  SV **hashValue = 
    hv_fetch
      ( 
        (HV*)SvRV(connPerlRef), 
        "outputheaders", 
        13, 
        FALSE
      );
  
  return hashValue ? *hashValue : 0;
}

// outputs the stored ref to the Ns_Request, takes the ref to the conn as input

SV *NsConnGetRequest(SV *connPerlRef)
{
  dTHX;
  SV **hashValue = 
    hv_fetch
      ( 
        (HV*)SvRV(connPerlRef), 
        "request", 
        7, 
        FALSE
      );
  
  return hashValue ? *hashValue : 0;
}

