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

Ns_Request *
newParseLine(requestLine)
        char *          requestLine
    CODE:
        RETVAL = Ns_ParseRequest(requestLine);
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
	Ns_Request *req = NsRequestInputMap(reqPerlRef);
    CODE:
	LOG(StringF("Ns_Request:\n"));
	if(! NsRequestIsNull(reqPerlRef))
	{
	  LOG
            (
              StringF
                (
                  "  - freed request at perl ref %p (internal %p)\n", 
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
                  "  - request from perl ref %p not freed because null\n",
                  reqPerlRef
                )
            );
	}
