//
// This is now an Aolserver::Ns_Conn:
// 
// reference -> hash -> {theNs_Conn}    -> SvIV -> Ns_Conn
//      |               {headers}       -> (set ref as def'd by its typemap)
//      |               {outputheaders} -> (set ref as def'd by its typemap)
//      |               {request}       -> (request ref as def'd by typemap)
//   blessed as
// "Aolserver::Ns_Conn"

#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include "../Ns_Set/Ns_SetMaps.h"
#include "../Ns_Request/Ns_RequestMaps.h"

#include "Ns_ConnMaps.h"

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

  fprintf
    (
      stderr, 
      "refcounts: ref: %ld, hash: %ld, conn: %ld, hdrs: %ld, oHdrs: %ld, req: %ld\n",
      SvREFCNT(connPerlRef),
      SvREFCNT(hashReferent),
      theConnIV ? SvREFCNT(theConnIV) : -99L,
      SvREFCNT(headers),
      SvREFCNT(outHeaders),
      SvREFCNT(request)
    );
}

Ns_Conn *NsConnInputMap(SV *arg, char *class, char *varName)
{
  dTHX;
  Ns_Conn *result = 0;

  if (sv_derived_from(arg, class)) 
    {
      SV **hashValue = hv_fetch( (HV*)SvRV(arg), "theNs_Conn", 10, FALSE);
      
      fprintf(stderr, "NsConnInputMap: ");
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

SV *NsConnOutputMap(Ns_Conn *var, char *class)
{
  dTHX;
  HV *hashReferent = newHV();
  SV *arg = newRV_noinc( (SV *) hashReferent);

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
      NsSetOutputMap(var->headers, "Aolserver::Ns_Set"),
      0
    );

  hv_store
    (
      hashReferent, 
      "outputheaders", 
      13, 
      NsSetOutputMap(var->outputheaders, "Aolserver::Ns_Set"),
      0
    );

  hv_store
    (
      hashReferent, 
      "request", 
      7, 
      NsRequestOutputMap(var->request, "Aolserver::Ns_Request"),
      0
    );

  sv_bless(arg, gv_stashpv(class, TRUE));

  fprintf(stderr, "NsConnOutputMap: ");
  NsConnPrintRefCounts(arg);

  return arg;
}

// outputs the stored ref to the Ns_Set, takes the ref to the conn as input

SV *NsConnGetHeaders(SV *connPerlRef)
{
  dTHX;
  SV **hashValue = hv_fetch( (HV*)SvRV(connPerlRef), "headers", 7, FALSE);
  
  return hashValue ? *hashValue : 0;
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

