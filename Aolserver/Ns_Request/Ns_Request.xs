#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include "logging.h"

#include <nsthread.h>
#include <tcl.h>
#include <ns.h>

#include "Ns_RequestMaps.h"

static int
not_here(char *s)
{
    croak("%s not implemented on this architecture", s);
    return -1;
}


MODULE = Aolserver::Ns_Request		PACKAGE = Aolserver::Ns_Request		

# NOTE: Class method that builds a new Request out of a http request line

SV *
newParseLine(class, requestLine)
	char *		class
        char *          requestLine
    PREINIT:
	Ns_Request *theRequest;
    CODE:
        LOG(StringF("Aolserver::Ns_Request new:"));
	theRequest = Ns_ParseRequest(requestLine);
	if (theRequest)
	{
	    RETVAL = sv_2mortal
                       ( 
	                 NsRequestOutputMap(theRequest, class, perlDoesOwn) 
                       );
	    LOG
	      (
	        StringF
                  (
                    "  - new Ns_Request %p wrapped in output mapping at %p",
                    theRequest,
                    RETVAL
                  )
              );
	}
	else
	{
	    LOG(StringF("  - new Ns_Request could not be created by nsd"));
	    RETVAL = &PL_sv_undef;
	}
    OUTPUT:	
	RETVAL

void
SetUrl(request, url)
	Ns_Request *	request
	char *	url
    CODE:
	Ns_SetRequestUrl(request, url);

char *
SkipUrl(request, nurl)
	Ns_Request *	request
	int	nurl
    CODE:	
	RETVAL = Ns_SkipUrl(request, nurl);
    OUTPUT:	
	RETVAL

void
DESTROY(reqPerlRef)
	SV *	reqPerlRef
    PREINIT:
	Ns_Request *req = NsRequestInputMap
                            (
                              reqPerlRef, 
                              "Aolserver::Ns_Request",
                              "reqPerlRef"
                            );
    CODE:
	LOG(StringF("Ns_Request:"));
	if(NsRequestOwnedP(reqPerlRef))
	{
	  LOG
            (
              StringF
                (
                  "  - freed request at perl ref %p (internal %p)", 
                  reqPerlRef, 
                  req
                )
            );
	  Ns_FreeRequest(req);
	}
	else
	{
	  LOG
            (
              StringF
                (
                  "  - request from perl ref %p not freed because null",
                  reqPerlRef
                )
            );
	}
