#ifndef Ns_SetMaps_h
#define Ns_SetMaps_h

#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include "ns.h"

#include "AolserverCommon.h"

Ns_Set *NsSetInputMap(SV *arg, char *class, char * varName);
int NsSetOwnedP(SV *connPerlRef);
SV *NsSetOutputMap(Ns_Set *var, char *class, int perlOwns);

#endif
