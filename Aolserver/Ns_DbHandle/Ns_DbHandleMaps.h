#ifndef Ns_DbHandleMaps_h
#define Ns_DbHandleMaps_h

#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include "ns.h"

Ns_DbHandle *NsDbHandleInputMap(SV *arg);
int NsDbHandleIsNull(SV *arg);
void NsDbHandleMakeNull(SV *arg);
SV *NsDbHandleOutputMap(Ns_DbHandle *var, char *class);
SV *NsDbHandleGetSelectRow(SV *dbHandlePerlRef);
void NsDbHandleStoreSelectRow(SV *dbHandlePerlRef, Ns_Set *selectRowSet);
int NsDbHandleIsInSelectLoop(SV *dbHandlePerlRef);

//SV *GetHeaders(SV *connPerlRef);
//SV *GetOutputHeaders(SV *connPerlRef);
//SV *GetRequest(SV *connPerlRef);

#endif
