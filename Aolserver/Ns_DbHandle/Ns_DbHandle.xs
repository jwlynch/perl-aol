#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include <nsthread.h>
#include <tcl.h>
#include <ns.h>

#include <stdio.h>

#include "Ns_DbHandleMaps.h"
#include "../Ns_DString/Ns_DStringMaps.h"
#include "../Ns_Set/Ns_SetMaps.h"

static int
not_here(char *s)
{
    croak("%s not implemented on this architecture", s);
    return -1;
}

MODULE = Aolserver::Ns_DbHandle		PACKAGE = Aolserver::Ns_DbHandle		

Ns_DbHandle *
new(class, pool)
	char *		class
	char *		pool
    CODE:
	RETVAL = Ns_DbPoolGetHandle(pool);
	if (RETVAL)
	{
	    ST(0) = 
		sv_mortalcopy( NsDbHandleOutputMap(RETVAL, class) );
	}
	else
	{
	    ST(0) = &PL_sv_undef;
	}


Ns_Set *
GetOneRowAtMost(handle, sql, nrows)
	Ns_DbHandle *	handle
	char *		sql
	int		nrows
    CODE:
	RETVAL = Ns_Db0or1Row(handle, sql, &nrows);
    OUTPUT:
	RETVAL
	nrows

Ns_Set *
GetOneRow(handle, sql)
	Ns_DbHandle *	handle
	char *		sql
    CODE:
	RETVAL = Ns_Db1Row(handle, sql);
    OUTPUT:
	RETVAL

Ns_Set *
BindRow(handle)
	Ns_DbHandle *	handle
    CODE:
	RETVAL = Ns_DbBindRow(handle);
    OUTPUT:
	RETVAL

int
Cancel(handle)
	Ns_DbHandle *	handle
    CODE:
	RETVAL = Ns_DbCancel(handle);
    OUTPUT:
	RETVAL

int
ExecDML(handle, sql)
	Ns_DbHandle *	handle
	char *		sql
    CODE:
	RETVAL = Ns_DbDML(handle, sql);
    OUTPUT:
	RETVAL

int
Exec(handle, sql)
	Ns_DbHandle *	handle
	char *		sql
    CODE:
	RETVAL = Ns_DbExec(handle, sql);
    OUTPUT:
	RETVAL

int
Flush(handle)
	Ns_DbHandle *	handle
    CODE:
	RETVAL = Ns_DbFlush(handle);
    OUTPUT:
	RETVAL

int
GetRow(handle, row)
	Ns_DbHandle *	handle
	Ns_Set *	row
    CODE:
	RETVAL = Ns_DbGetRow(handle, row);

	//   if last row already gotten OR an error occured,
	// then the presumption is that the row is not valid,
	//      so make perl forget about it.

	if(RETVAL == NS_END_DATA || RETVAL == NS_ERROR)
	  NsDbHandleStoreSelectRow(ST(0), NULL);
    OUTPUT:
	RETVAL

int
InterpretSqlFile(handle, filename)
	Ns_DbHandle *	handle
	char *		filename
    CODE:
	RETVAL = Ns_DbInterpretSqlFile(handle, filename);
    OUTPUT:
	RETVAL

int
InSelectLoop(handlePerlRef)
	SV *	handlePerlRef
    CODE:
	RETVAL = NsDbHandleIsInSelectLoop(handlePerlRef);
    OUTPUT:
	RETVAL

SV *
GetSelectRow(handlePerlRef)
	SV *	handlePerlRef
    CODE:
	RETVAL = sv_mortalcopy( NsDbHandleGetSelectRow(handlePerlRef) );
    OUTPUT:
	RETVAL

void SetSelectRow(handlePerlRef, value)
	SV *	handlePerlRef
	int	value
    CODE:
	NsDbHandleStoreSelectRow(handlePerlRef, value);

SV *
Select(handlePerlRef, sql)
	SV *	handlePerlRef
	char *		sql
    PREINIT:
	Ns_DbHandle *handle;
    CODE:
	RETVAL = &PL_sv_undef;

	if
	  (
	    sv_isobject(handlePerlRef) && 
            sv_derived_from(handlePerlRef, "Aolserver::Ns_DbHandle")
	  )
	{
	  handle = NsDbHandleInputMap(handlePerlRef);

	  NsDbHandleStoreSelectRow(handlePerlRef, Ns_DbSelect(handle, sql));

	  RETVAL = 
             sv_mortalcopy( NsDbHandleGetSelectRow(handlePerlRef) );
	}
    OUTPUT:
	RETVAL

void
DESTROY(self)
	Ns_DbHandle *	self
    CODE:
	fprintf(stderr, "YES the destroy method gets called\n");
	Ns_DbPoolPutHandle(self);
	// PROBLEM: this never happens. WHY?

