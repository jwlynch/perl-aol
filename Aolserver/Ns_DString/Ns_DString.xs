#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include <nsthread.h>
#include <tcl.h>
#include <ns.h>

#include "Ns_DStringMaps.h"

MODULE = Aolserver::Ns_DString	PACKAGE = Aolserver::Ns_DString

Ns_DString *
new(class)
	char *		class
    CODE:
	RETVAL = malloc(sizeof(Ns_DString));
	if (RETVAL)
	{
	    Ns_DStringInit(RETVAL);

	    ST(0) = sv_newmortal();
            sv_setsv(ST(0), NsDStringOutputMap(RETVAL, class));
	}
	else
	{
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
    	Ns_DStringFree(self);
	free(self);

