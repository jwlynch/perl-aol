#ifndef Ns_DStringMaps_h
#define Ns_DStringMaps_h

#include <XSUB.h>
#include <EXTERN.h>
#include <perl.h>

#include "AolserverCommon.h"

Ns_DString *NsDStringInputMap(SV *arg, char *class, char *varName);
SV *NsDStringOutputMap(Ns_DString *var, char *class, int perlOwns);
int NsDStringOwnedP(SV *dStringPerlRef);

#endif
