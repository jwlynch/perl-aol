#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include "logging.h"

#include <nsthread.h>
#include <tcl.h>
#include <ns.h>

#include "Ns_DStringMaps.h"

MODULE = Aolserver::Ns_DString	PACKAGE = Aolserver::Ns_DString

Ns_DString *
new(class)
	char *		class
    CODE:
        LOG(StringF("Ns_DString new:\n");
	RETVAL = malloc(sizeof(Ns_DString));
	if (RETVAL)
	{
            LOG(StringF("  - allocated, loc is %p\n", RETVAL));
	    Ns_DStringInit(RETVAL);
            LOG(StringF("  - initialized by Ns_DStringInit\n"));

	    ST(0) = sv_newmortal();
            sv_setsv(ST(0), NsDStringOutputMap(RETVAL, class));
	}
	else
	{
            LOG(StringF("  - could not be allocated\n"));
	    ST(0) = &PL_sv_undef;
	}

char *
Value(self)
	Ns_DString *	self

    CODE:
    	RETVAL = Ns_DStringValue(self);

    OUTPUT:
    	RETVAL

char *
Append(self, str)
	Ns_DString *	self
	char *		str

    CODE:
    	RETVAL = Ns_DStringAppend(self, str);

    OUTPUT:
    	RETVAL

char *
NAppend(self, str, n)
	Ns_DString *	self
	char *		str
	int		n

    CODE:
    	RETVAL = Ns_DStringNAppend(self, str, n);

    OUTPUT:
    	RETVAL

void
Trunc(self, length)
	Ns_DString *	self
	int	length
    CODE:
	Ns_DStringTrunc(self, length);

int
Length(self)
	Ns_DString *	self
    CODE:
	RETVAL = Ns_DStringLength(self);
    OUTPUT:
	RETVAL

void
DESTROY(self)
	Ns_DString *	self

    CODE:
        LOG(StringF("Ns_DString at %p to be freed\n", self));
    	Ns_DStringFree(self);
	free(self);
        LOG(StringF("Ns_DString at %p freed\n", self));

