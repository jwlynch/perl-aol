#ifndef Ns_ConnMaps_h
#define Ns_ConnMaps_h

#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include "ns.h"

Ns_Conn *NsConnInputMap(SV *arg, char *class, char *varName);
SV *NsConnOutputMap(Ns_Conn *var, char *class);

void NsConnPrintRefCounts(SV *connPerlRef);

SV *NsConnGetHeaders(SV *connPerlRef);
SV *NsConnGetOutputHeaders(SV *connPerlRef);
SV *NsConnGetRequest(SV *connPerlRef);

void NsConnMakeNull(SV *connPerlRef);

#endif
