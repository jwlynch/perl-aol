//
// This is now an Aolserver::Ns_DbHandle:
// 
// reference -> hash -> {theNs_DbHandle} -> SvIV -> Ns_Conn
//      |               {selectRowSet}   -> (statically alloc'd set !or! NULL)
//      |               {}               -> ()
// blessed as           {}               -> ()
// "Aolserver::Ns_DbHandle"

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

void NsDbHandleMakeNull(SV *arg)
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

  // create perl infrastructure for selectRowSet, make the ptr be initially 0
  hv_store
    (
      hashReferent, 
      "selectRowSet", 
      12, 
      NsSetOutputMap(NULL, "Aolserver::Ns_Set"),
      0
    );

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

// outputs the stored ref to the Ns_Set which is output from Ns_DbSelect 
// !!or!! NULL if no select active; takes the ref to the dbhandle as input

SV *NsDbHandleGetSelectRow(SV *dbHandlePerlRef)
{
  dTHX;
  SV **hashValue = 
       hv_fetch
         ( 
            (HV*)SvRV(dbHandlePerlRef), 
            "selectRowSet", 7, 
            FALSE
         );
  
  return *hashValue;
}

// Store an existing Ns_Set (or a NULL pointer) into the perl infrastructure
// of the selectRow Ns_Set.

void NsDbHandleStoreSelectRow(SV *dbHandlePerlRef, Ns_Set *selectRowSet)
{
  dTHX;
  SV *selectRowSetPerlRef = NsDbHandleGetSelectRow(dbHandlePerlRef);

  NsSetStore(selectRowSetPerlRef, selectRowSet);
}

// Return true if we are in a select loop.
//
//   selectRowSet always points at a blessed perl Ns_Set infrastructure.
//   Within this infrastructure, is a pointer presumed to be to an Ns_Set.
//   This pointer either points at a set (and is non-zero) or at nothing
//   (and is zero).
//
//   two possibilities:
//     - we ARE. The pointer is NOT zero, and actually points to a
//         statically allocated Ns_Set presumed to come from Select.
//     - we are NOT. The pointer is zero.
//
//   Going into a select loop...
//
//       Select() would provide an Ns_Set if no errors were encountered,
//       and this would put us in a select loop.
//
//   Coming out of a select loop...
//
//       Having gotten the last row and calling GetRow "one more time"
//       should take us out. So should the DESTROY method as well as
//       Cancel and Flush. ALSO, calling ExecDML, GetOneRow or GetOneRowAtMost
//       on a handle which is in a select loop is an error, and causes a Flush
//       which should also take us out of the (existing!) select loop.

int NsDbHandleIsInSelectLoop(SV *dbHandlePerlRef)
{
  return ! NsSetIsNull(NsDbHandleGetSelectRow(dbHandlePerlRef));
}


//// outputs the stored ref to the Ns_Set, takes the ref to the conn as input
//
//SV *NsDbHandleGetOutputHeaders(SV *connPerlRef);
//SV *NsDbHandleGetOutputHeaders(SV *connPerlRef)
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

//// outputs the stored ref to the Ns_Request, takes the ref to the conn as input
//
//SV *NsDbHandleGetRequest(SV *connPerlRef);
//SV *NsDbHandleGetRequest(SV *connPerlRef)
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

