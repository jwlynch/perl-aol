//
// This is now an Aolserver::Ns_DbHandle:
// 
// reference -> hash -> {theNs_DbHandle} -> SvIV -> Ns_Conn
//      |               {selectRowSet}   -> Ns_Set containing current row
//      |                                     in multirow select process
//      |               {inSelectLoopP}  -> true if select loop in progress
//      |               {perlOwns}       -> true if perl should free this
//      |                                             upon DESTROY
//   blessed as:
// "Aolserver::Ns_DbHandle"

#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#include "logging.h"

#include "../Ns_Set/Ns_SetMaps.h"
#include "../Ns_DString/Ns_DStringMaps.h"

#include "AolserverCommon.h"

#include <nsthread.h>
#include <tcl.h>
#include <ns.h>

#include <stdio.h>

Ns_DbHandle *NsDbHandleInputMap(SV *arg, char *class, char *varName)
{
  dTHX;
  Ns_DbHandle *result = 0;

  if(sv_derived_from(arg, class))
    {
      SV **hashValue = hv_fetch( (HV*)SvRV(arg), "theNs_DbHandle", 14, FALSE);

      if(hashValue)
	result = (Ns_DbHandle *) SvIV( *hashValue );
    }
  else
    {
      char msg[200];

      snprintf(msg, 199, "%s is not of type %s", varName, class);
      croak(msg);
    }

  return result;
}

SV *NsDbHandleOutputMap(Ns_DbHandle *var, char *class, int perlOwns)
{
  dTHX;
  HV *hashReferent = newHV();
  SV *arg = newRV_noinc( (SV *) hashReferent);

  hv_store
    (
      hashReferent, 
      "theNs_DbHandle", 
      14, 
      newSViv((IV) var),
      0
    );

  // create perl infrastructure for selectRowSet, 
  // make the ptr be initially a (Ns_Set*) NULL

  hv_store
    (
      hashReferent, 
      "selectRowSet", 
      12, 
      NsSetOutputMap( (Ns_Set*) NULL, "Aolserver::Ns_Set", perlDoesntOwn),
      0
    );

  // scalar flag: true if in select loop

  hv_store
    (
      hashReferent, 
      "inSelectLoopP", 
      13, 
      &PL_sv_no,
      0
    );

  // scalar flag: true if perl infrastructure owns, and should therefore
  // return handle to pool upon destruction

  hv_store
    (
      hashReferent, 
      "perlOwns", 
      8, 
      (perlOwns ? &PL_sv_yes : &PL_sv_no),
      0
    );

  sv_bless(arg, gv_stashpv(class, TRUE));

  return arg;
}

// takes a 1 (for true) or 0 (for false) and sets the select loop flag.

void NsDbHandleSetSelectLoopFlag(SV *dbHandlePerlRef, int isInSelectLoop)
{
  dTHX;
  HV *hashReferent = (HV*)SvRV(dbHandlePerlRef);

  hv_store
    (
      hashReferent, 
      "inSelectLoopP", 
      13, 
      (isInSelectLoop ? &PL_sv_yes : &PL_sv_no),
      0
    );
}

// outputs the stored ref to the Ns_Set which is output from Ns_DbSelect 
// !!or!! undef if no select active; takes the ref to the dbhandle as input

SV *NsDbHandleGetSelectRow(SV *dbHandlePerlRef)
{
  dTHX;
  SV *result = &PL_sv_undef;

  if(NsDbHandleIsInSelectLoop(dbHandlePerlRef))
    {
      SV **hashValue = 
           hv_fetch
             ( 
               (HV*)SvRV(dbHandlePerlRef), 
               "selectRowSet", 
               12, 
               FALSE
             );

      if(hashValue)
        result = *hashValue;
    }

  return result;
}

// Store an existing Ns_Set (or a NULL pointer) into the perl infrastructure
// of the selectRow Ns_Set.

void NsDbHandleStoreSelectRow(SV *dbHandlePerlRef, Ns_Set *selectRowSet)
{
  dTHX;

  hv_store
    (
      (HV*)SvRV(dbHandlePerlRef), 
      "selectRowSet", 
      12, 
      NsSetOutputMap(selectRowSet, "Aolserver::Ns_Set", perlDoesntOwn),
      0
    );
}

// Return true if we are in a select loop.
//
//   selectRowSet always points at a blessed perl Ns_Set infrastructure.
//   Within this infrastructure, is a pointer presumed to be to an Ns_Set.
//   This pointer either points at a set (and is non-zero) or at nothing
//   (and is zero). However, a separate flag has been added, and that
//   flag is now used to determine if a select loop is in progress.
//
//   two possibilities:
//     - we ARE. The pointer actually points to a statically allocated 
//         Ns_Set presumed to come from Select, and the flag is set to true.
//     - we are NOT. The flag is set to false.
//
//   Going into a select loop...
//
//       Select() would provide an Ns_Set if no errors were encountered,
//       and this would put us in a select loop. The flag is set to true.
//
//   Coming out of a select loop...
//
//       Having gotten the last row and calling GetRow "one more time" should 
//       take us out. So should the DESTROY method as well as Cancel and Flush.
//       ALSO, calling ExecDML, GetOneRow or GetOneRowAtMost on a handle which
//       is in a select loop is an error, and causes a Flush which should also
//       take us out of the (existing!) select loop. In all of these cases,
//       the flag is set to false.

int NsDbHandleIsInSelectLoop(SV *dbHandlePerlRef)
{
  int result = 0;
  SV **hashValue = 
       hv_fetch
         ( 
           (HV*)SvRV(dbHandlePerlRef), 
           "inSelectLoopP", 
           13, 
           FALSE
         );

  if(hashValue)
    result = (*hashValue == &PL_sv_yes);

  return result;
}

// returns true if the ref argument is to the 
// stored select row in the given handle

int NsDbHandleSameAsSelectRow(SV *dbHandlePerlRef, SV *nsSetPerlRef)
{
  return SvRV(nsSetPerlRef) == SvRV(NsDbHandleGetSelectRow(dbHandlePerlRef));
}

int NsDbHandleOwnedP(SV *dbHandlePerlRef)
{
  int result = 1;
  SV **hashValue = 
       hv_fetch
         ( 
           (HV*)SvRV(dbHandlePerlRef), 
           "perlOwns", 
           8, 
           FALSE
         );

  if(hashValue)
    result = (*hashValue == &PL_sv_yes);

  return result;
}

