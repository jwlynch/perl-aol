#ifndef Ns_DStringMaps_h
#define Ns_DStringMaps_h

#include <XSUB.h>
#include <EXTERN.h>
#include <perl.h>

Ns_DString *NsDStringInputMap(SV *arg);
SV *NsDStringOutputMap(Ns_DString *var, char *class);

#endif
