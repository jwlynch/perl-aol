#ifndef Ns_DbHandleMaps_h
#define Ns_DbHandleMaps_h

#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include "ns.h"
#include "nsdb.h"

#include "AolserverCommon.h"

Ns_DbHandle *NsDbHandleInputMap(SV *arg, char *class, char *varName);
SV *NsDbHandleOutputMap(Ns_DbHandle *var, char *class, int perlOwns);
void NsDbHandleSetSelectLoopFlag(SV *dbHandlePerlRef, int isInSelectLoop);

SV *NsDbHandleGetSelectRow(SV *dbHandlePerlRef);
void NsDbHandleStoreSelectRow(SV *dbHandlePerlRef, Ns_Set *selectRowSet);
int NsDbHandleIsInSelectLoop(SV *dbHandlePerlRef);
int NsDbHandleSameAsSelectRow(SV *dbHandlePerlRef, SV *nsSetPerlRef);

int NsDbHandleOwnedP(SV *dbHandlePerlRef);

#endif
