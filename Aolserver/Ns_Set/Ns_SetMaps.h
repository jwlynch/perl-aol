#ifndef Ns_SetMaps_h
#define Ns_SetMaps_h

#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include "/usr/local/aolserver/include/ns.h"

Ns_Set *NsSetInputMap(SV *arg, char *class);
int NsSetIsNull(SV *arg);
void NsSetMakeNull(SV *arg);
SV *NsSetOutputMap(Ns_Set *var, char *class);
void NsSetStore(SV *setPerlRef, Ns_Set *set);

#endif
