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

  hv_store
    (
      hashReferent, 
      "selectRowSet", 
      12, 
      NULL /* initially null: means NO select is current & NO rows pending */,
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

// Keep track of whether we are in a select loop. 
//
//   two possibilities:
//     - we ARE. selectRowSet is NOT zero, and actually points to a
//         statically allocated Ns_Set presumed to come from Select.
//     - we are NOT. selectRowSet is zero.
//
//   If we are in a select loop, then provide perl infrastructure (thru
//   NsSetOutputMap()) and store a properly reference counted structure.
//
//       Select() would provide an Ns_Set if no errors were encountered,
//       and this would put us in a select loop.
//
//   If we are not, store a NULL where the pointer to the perl infrastructure
//   otherwise would have been. If a row was here, make sure to break the
//   link to it from the perl infrastructure.
//
//       Having gotten the last row and calling GetRow "one more time"
//       should make this null. So should the DESTROY method as well as
//       Cancel and Flush. ALSO, calling ExecDML, GetOneRow or GetOneRowAtMost
//       on a handle which is in a select loop is an error, and causes a Flush
//       which should also make this null.

void NsDbHandleStoreSelectRow(SV *dbHandlePerlRef, Ns_Set *selectRowSet)
{
  dTHX;
  SV *selectRowSetPerlRef = NULL;

  // If incoming set ptr is not null, call Aolserver::Ns_Set's output
  // typemap to create a blessed ref to the set.........

  if(selectRowSet)
    {
      selectRowSetPerlRef = NsSetOutputMap(selectRowSet, "Aolserver::Ns_Set");
    }
  else
    {
      // break any link to existing row
      
    }

  // ....Otherwise, don't bother. The stored value will be NULL and not a set.

  hv_store
    (
      (HV*)SvRV(dbHandlePerlRef), 
      "selectRowSet", 
      12, 
      selectRowSetPerlRef,
      0
    );
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

