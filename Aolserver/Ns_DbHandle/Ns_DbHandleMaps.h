#ifndef Ns_DbHandleMaps_h
#define Ns_DbHandleMaps_h

#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include "ns.h"

Ns_DbHandle *NsDbHandleInputMap(SV *arg);
SV *NsDbHandleOutputMap(Ns_DbHandle *var, char *class);

//SV *GetHeaders(SV *connPerlRef);
//SV *GetOutputHeaders(SV *connPerlRef);
//SV *GetRequest(SV *connPerlRef);

#endif
