#ifndef Ns_RequestMaps_h
#define Ns_RequestMaps_h

#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include "ns.h"

#include "AolserverCommon.h"

int NsRequestOwnedP(SV *requestPerlRef);

Ns_Request *NsRequestInputMap(SV *arg, char *class, char *varName);
SV *NsRequestOutputMap(Ns_Request *var, char *class, int perlOwns);

#endif
