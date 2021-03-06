#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include <nsthread.h>
#include <tcl.h>
#include <ns.h>
#include <nsdb.h>

#include <stdio.h>

#include "Ns_DbHandleMaps.h"
#include "../Ns_DString/Ns_DStringMaps.h"
#include "../Ns_Set/Ns_SetMaps.h"

#include "logging.h"

#include "AolserverCommon.h"

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
	    ST(0) = sv_2mortal
                      (
                        NsDbHandleOutputMap
                          (
                            RETVAL, 
                            class, 
                            perlDoesOwn
                          ) 
                      );

            LOG(StringF("Ns_DbHandle allocated"));
	}
	else
	{
	    ST(0) = &PL_sv_undef;
            LOG(StringF("Ns_DbHandle could not be allocated"));
	}


Ns_Set *
GetOneRowAtMost(handlePerlRef, sql, nrows)
	SV *	handlePerlRef
	char *		sql
	int		nrows
    PREINIT:
	Ns_DbHandle *handle = NsDbHandleInputMap
                                (
                                  handlePerlRef,
                                  "Aolserver::Ns_DbHandle",
                                  "handlePerlRef"
                                );
    CODE:
	if(NsDbHandleIsInSelectLoop(handlePerlRef))
	{
	  RETVAL = NULL;
	  Ns_DbCancel(handle);
	  NsDbHandleSetSelectLoopFlag(handlePerlRef, 0);
	}
	else
	{
	  RETVAL = Ns_Db0or1Row(handle, sql, &nrows);
	}
    OUTPUT:
	RETVAL
	nrows

Ns_Set *
GetOneRow(handlePerlRef, sql)
	SV *	handlePerlRef
	char *		sql
    PREINIT:
	Ns_DbHandle *handle = NsDbHandleInputMap
                                (
                                  handlePerlRef,
                                  "Aolserver::Ns_DbHandle",
                                  "handlePerlRef"
                                );
    CODE:
	if(NsDbHandleIsInSelectLoop(handlePerlRef))
	{
	  RETVAL = NULL;
	  Ns_DbCancel(handle);
          NsDbHandleSetSelectLoopFlag(handlePerlRef, 0);
	}
	else
	{
	  RETVAL = Ns_Db1Row(handle, sql);
	}
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
Cancel(handlePerlRef)
	SV *	handlePerlRef
    PREINIT:
	Ns_DbHandle *handle = NsDbHandleInputMap
                                (
                                  handlePerlRef,
                                  "Aolserver::Ns_DbHandle",
                                  "handlePerlRef"
                                );
    CODE:
	if(NsDbHandleIsInSelectLoop(handlePerlRef))
	{
	  RETVAL = Ns_DbCancel(handle);
	  NsDbHandleSetSelectLoopFlag(handlePerlRef, 0);
	}
	else
	{
	  RETVAL = NS_OK; // you can call Cancel as many times as you want
	}
    OUTPUT:
	RETVAL

int
ExecDML(handlePerlRef, sql)
	SV *	handlePerlRef
	char *		sql
    PREINIT:
	Ns_DbHandle *handle = NsDbHandleInputMap
                                (
                                  handlePerlRef,
                                  "Aolserver::Ns_DbHandle",
                                  "handlePerlRef"
                                );
    CODE:
	if(NsDbHandleIsInSelectLoop(handlePerlRef))
	{
	  RETVAL = NS_ERROR;
	  Ns_DbCancel(handle);
	  NsDbHandleSetSelectLoopFlag(handlePerlRef, 0);
	}
	else
	{
	  RETVAL = Ns_DbDML(handle, sql);
	}
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
Flush(handlePerlRef)
	SV *	handlePerlRef
    PREINIT:
	Ns_DbHandle *handle = NsDbHandleInputMap
                                (
                                  handlePerlRef,
                                  "Aolserver::Ns_DbHandle",
                                  "handlePerlRef"
                                );
    CODE:
	if(NsDbHandleIsInSelectLoop(handlePerlRef))
	{
	  RETVAL = Ns_DbFlush(handle);
	  NsDbHandleSetSelectLoopFlag(handlePerlRef, 0);
	}
	else
	{
	  RETVAL = NS_OK; // you can call Flush as many times as you want
                          // (however, once is enough :)
	}
    OUTPUT:
	RETVAL

int
GetRow(handlePerlRef, rowPerlRef)
	SV *	handlePerlRef
	SV *	rowPerlRef
    PREINIT:
	Ns_DbHandle *handle = NsDbHandleInputMap
                                (
                                  handlePerlRef,
                                  "Aolserver::Ns_DbHandle",
                                  "handlePerlRef"
                                );
	Ns_Set *row = 
	    NsSetInputMap
		(
		    rowPerlRef, 
		    "Aolserver::Ns_Set", 
		    "rowPerlRef"
		);
    CODE:
	RETVAL = NS_ERROR;

	if
	  (
	    NsDbHandleIsInSelectLoop(handlePerlRef) &&
	    NsDbHandleSameAsSelectRow(handlePerlRef, rowPerlRef)
	  )
	  {
	    RETVAL = Ns_DbGetRow(handle, row);

	    //   if last row already gotten OR an error occured,
	    // then the presumption is that the row is not valid,
	    //      so make perl forget about it.

	    if(RETVAL == NS_END_DATA || RETVAL == NS_ERROR)
	      NsDbHandleSetSelectLoopFlag(handlePerlRef, 0);
	  }
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

SV *
Select(handlePerlRef, sql)
	SV *	handlePerlRef
	char *	sql
    PREINIT:
	Ns_DbHandle *handle = NsDbHandleInputMap
                                (
                                  handlePerlRef,
                                  "Aolserver::Ns_DbHandle",
                                  "handlePerlRef"
                                );
    CODE:
	RETVAL = &PL_sv_undef;

	if
	  (
	    sv_isobject(handlePerlRef) && 
            sv_derived_from(handlePerlRef, "Aolserver::Ns_DbHandle")
	  )
	{
	  Ns_Set *selectRow;

	  if(! NsDbHandleIsInSelectLoop(handlePerlRef))
	    {
	      selectRow = Ns_DbSelect(handle, sql);
	      NsDbHandleStoreSelectRow(handlePerlRef, selectRow);
              NsDbHandleSetSelectLoopFlag(handlePerlRef, 1);
	      RETVAL = 
                sv_mortalcopy( NsDbHandleGetSelectRow(handlePerlRef) );
	    }
	  else
	    {
	      Ns_DbCancel(handle);
              NsDbHandleSetSelectLoopFlag(handlePerlRef, 0);
	    }
	}
    OUTPUT:
	RETVAL

void
DESTROY(handlePerlRef)
	SV *	handlePerlRef
    PREINIT:
	Ns_DbHandle *handle = NsDbHandleInputMap
                                (
                                  handlePerlRef,
                                  "Aolserver::Ns_DbHandle",
                                  "handlePerlRef"
                                );
    CODE:
        LOG(StringF("Ns_DbHandle::DESTROY:"));

	if(NsDbHandleOwnedP(handlePerlRef))
          {
            LOG(StringF("  - perl DOES own. Free handle."));

	    if(NsDbHandleIsInSelectLoop(handlePerlRef))
	    {
              LOG(StringF("    + handle was inside select loop. cancel it."));
	      Ns_DbCancel(handle);
	    }
	
	    Ns_DbPoolPutHandle(handle);
          }
        else
          {
            LOG(StringF("  - perl does NOT own. -don't- free handle."));
          }
