#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

static int
not_here(char *s)
{
    croak("%s not implemented on this architecture", s);
    return -1;
}

MODULE = Aolserver::Ns_DbHandle		PACKAGE = Aolserver::Ns_DbHandle		

Ns_Set *
GetOneRowAtMost(handle, sql, nrows)
	Ns_DbHandle *	handle
	char *		sql
	int		nrows
    CODE:
	RETVAL = Ns_Db0or1Row(handle, sql, &nrows);
    OUTPUT:
	RETVAL, nrows

