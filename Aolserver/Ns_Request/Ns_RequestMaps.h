#ifndef Ns_RequestMaps_h
#define Ns_RequestMaps_h

#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include "ns.h"

Ns_Request *NsRequestInputMap(SV *arg);
SV *NsRequestOutputMap(Ns_Request *var, char *class);

int NsRequestIsNull(SV *arg);
void NsRequestMakeNull(SV *arg);
void NsRequestStore(SV *requestPerlRef, Ns_Request *request);

#endif
