#ifndef Ns_SetMaps_h
#define Ns_SetMaps_h

#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include "ns.h"

Ns_Set *NsSetInputMap(SV *arg, char *class, char * varName);
int NsSetIsNull(SV *arg);
void NsSetMakeNull(SV *arg);
//SV *NsSetOutputMap(Ns_Set *var, char *class, int perlOwns);
SV *NsSetOutputMap(Ns_Set *var, char *class);
void NsSetStore(SV *setPerlRef, Ns_Set *set);

#endif
