#ifndef Ns_RequestMaps_h
#define Ns_RequestMaps_h

#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include "ns.h"

Ns_Request *NsRequestInputMap(SV *arg);
SV *NsRequestOutputMap(Ns_Request *var, char *class);

#endif
