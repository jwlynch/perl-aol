//
// This is now an Aolserver::Ns_Conn:
// 
// reference    -> hash -> {theNs_Conn}    -> SvIV -> Ns_Conn
//      |                  {headers}       -> (set ref as def'd by its typemap)
// blessed as              {outputheaders} -> (set ref as def'd by its typemap)
// "Aolserver::Ns_Conn"    {request}       -> (request ref as def'd by typemap)

#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include "../../Aolserver/Ns_Set/Ns_SetMaps.h"
#include "../../Aolserver/Ns_DString/Ns_DStringMaps.h"

#include <nsthread.h>
#include <tcl.h>
#include <ns.h>

#include <stdio.h>

Ns_DbHandle *NsDbHandleInputMap(SV *arg)
{
  dTHX;
  Ns_DbHandle *result = 0;
  SV **hashValue = hv_fetch( (HV*)SvRV(arg), "theNs_DbHandle", 14, FALSE);

  if(hashValue)
    result = (Ns_DbHandle *) SvIV( *hashValue );
 
  return result;
}

int NsDbHandleIsNull(SV *arg)
{
  return NsDbHandleInputMap(arg) == NULL;
}

void MakeNsDbHandleNull(SV *arg)
{
  dTHX;
  
  //sv_setiv(SvRV(arg), 0);
}

SV *NsDbHandleOutputMap(Ns_DbHandle *var, char *class)
{
  dTHX;
  HV *hashReferent = newHV();
  SV *arg = newRV_inc( (SV *) hashReferent);

  hv_store
    (
      hashReferent, 
      "theNs_DbHandle", 
      14, 
      newSViv((IV) var),
      0
    );

  //hv_store
  //  (
  //    hashReferent, 
  //    "headers", 
  //    7, 
  //    NsSetOutputMap(var->headers, "Aolserver::Ns_Set"),
  //    0
  //  );

  //hv_store
  //  (
  //    hashReferent, 
  //    "outputheaders", 
  //    13, 
  //    NsSetOutputMap(var->outputheaders, "Aolserver::Ns_Set"),
  //    0
  //  );

  //hv_store
  //  (
  //    hashReferent, 
  //    "request", 
  //    7, 
  //    NsRequestOutputMap(var->request, "Aolserver::Ns_Request"),
  //    0
  //  );

  sv_bless(arg, gv_stashpv(class, TRUE));

  return arg;
}

// outputs the stored ref to the Ns_Set, takes the ref to the conn as input

//SV *GetHeaders(SV *connPerlRef);
//SV *GetHeaders(SV *connPerlRef)
//{
//  dTHX;
//  SV **hashValue = hv_fetch( (HV*)SvRV(connPerlRef), "headers", 7, FALSE);
//  
//  return *hashValue;
//}


// outputs the stored ref to the Ns_Set, takes the ref to the conn as input

//SV *GetOutputHeaders(SV *connPerlRef);
//SV *GetOutputHeaders(SV *connPerlRef)
//{
//  dTHX;
//  SV **hashValue = 
//    hv_fetch
//      ( 
//        (HV*)SvRV(connPerlRef), 
//        "outputheaders", 
//        13, 
//        FALSE
//      );
//  
//  return *hashValue;
//}

// outputs the stored ref to the Ns_Request, takes the ref to the conn as input

//SV *GetRequest(SV *connPerlRef);
//SV *GetRequest(SV *connPerlRef)
//{
//  dTHX;
//  SV **hashValue = 
//    hv_fetch
//      ( 
//        (HV*)SvRV(connPerlRef), 
//        "request", 
//        7, 
//        FALSE
//      );
//  
//  return *hashValue;
//}

