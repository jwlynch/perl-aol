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
Ns_DbHandle *
new(class, pool)
	char *		class
	char *		pool
    CODE:
	RETVAL = Ns_DbPoolGetHandle(pool);
	if (RETVAL)
	{
	    ST(0) = sv_newmortal();
	    sv_setsv(ST(0), NsDbHandleOutputMap(RETVAL, class));
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
	RETVAL, nrows

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
    OUTPUT:
	RETVAL

int
InterpretSqlFile
	Ns_DbHandle *	handle
	char *		filename
    CODE:
	RETVAL = Ns_DbInterpretSqlFile(handle, filename);
    OUTPUT:
	RETVAL

Ns_Set *
Select(handle, sql)
	Ns_DbHandle *	handle
	char *		sql
    CODE:
	RETVAL = Ns_DbSelect(handle, sql);
    OUTPUT:
	RETVAL

void
DESTROY(self)
	Ns_DbHandle *	self
    CODE:
	if(! NsDbHandleIsNull(self))
	  Ns_DbPoolPutHandle(self);