#ifndef Ns_SetMaps_h
#define Ns_SetMaps_h

#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include "/usr/local/aolserver/include/ns.h"

Ns_Set *NsSetInputMap(SV *arg);
int NsSetIsNull(SV *arg);
void MakeNsSetNull(SV *arg);
SV *NsSetOutputMap(Ns_Set *var, char *class);

#endif
