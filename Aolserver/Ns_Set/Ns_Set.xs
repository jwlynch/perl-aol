#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include <nsthread.h>
#include <tcl.h>
#include <ns.h>

#include "Ns_SetMaps.h"

static int
not_here(char *s)
{
    croak("%s not implemented on this architecture", s);
    return -1;
}


MODULE = Aolserver::Ns_Set		PACKAGE = Aolserver::Ns_Set		

# perl module encapsulating Aolserver's Ns_Set


Ns_Set *
new(class)
	char *		class
    CODE:
	RETVAL = Ns_SetCreate("");
	if (RETVAL)
	{
	    ST(0) = sv_newmortal();
	    sv_setsv(ST(0), NsSetOutputMap(RETVAL, class));
	}
	else
	{
	    ST(0) = &PL_sv_undef;
	}

Ns_Set *
newNamed(class, name)
	char *		class
	char *		name
    CODE:
	RETVAL = Ns_SetCreate(name);
	if (RETVAL)
	{
	    ST(0) = sv_newmortal();
	    sv_setref_pv(ST(0), class, (void*) RETVAL);
	}
	else
	{
	    ST(0) = &PL_sv_undef;
	}

int
Put(self, key, value)
	Ns_Set *	self
	char *	key
	char *	value
    CODE:
	RETVAL = Ns_SetPut(self, key, value);

    OUTPUT:
    	RETVAL
	
void
PutValue(self, keyIndex, value)
	Ns_Set *	self
	int	keyIndex
	char *	value
    CODE:
	Ns_SetPutValue(self, keyIndex, value);
	
char *
Get(self, key)
	Ns_Set *	self
	char *	key

    CODE:
	RETVAL = Ns_SetGet(self, key);

    OUTPUT:
    	RETVAL
	
char *
IGet(self, key)
	Ns_Set *	self
	char *	key

    CODE:
	RETVAL = Ns_SetIGet(self, key);

    OUTPUT:
    	RETVAL
	
char *
Name(self)
	Ns_Set *	self
    CODE:
	RETVAL = Ns_SetName(self);

    OUTPUT:
    	RETVAL

void
Delete(self, index)
	Ns_Set *	self
	int	index
    CODE:
	Ns_SetDelete(self, index);

void
DeleteKey(self, key)
	Ns_Set *	self
	char *	key
    CODE:
	Ns_SetDeleteKey(self, key);

void
IDeleteKey(self, key)
	Ns_Set *	self
	char *	key
    CODE:
	Ns_SetIDeleteKey(self, key);

int
Find(self, key)
	Ns_Set *	self
	char *	key
    CODE:
	RETVAL = Ns_SetFind(self, key);
    OUTPUT:
    	RETVAL

int
IFind(self, key)
	Ns_Set *	self
	char *	key
    CODE:
	RETVAL = Ns_SetIFind(self, key);
    OUTPUT:
    	RETVAL

char *
Key(self, index)
	Ns_Set *	self
	int	index
    CODE:
	RETVAL = Ns_SetKey(self, index);
    OUTPUT:
    	RETVAL

void
Print(self)
	Ns_Set *	self
    CODE:
	Ns_SetPrint(self);

int	
Last(self)
	Ns_Set *	self
    CODE:
	RETVAL = Ns_SetLast(self);
    OUTPUT:
    	RETVAL

int
Unique(self, key)
	Ns_Set *	self
	char *	key
    CODE:
	RETVAL = Ns_SetUnique(self, key);
    OUTPUT:
    	RETVAL

int
IUnique(self, key)
	Ns_Set *	self
	char *	key
    CODE:
	RETVAL = Ns_SetIUnique(self, key);
    OUTPUT:
    	RETVAL

int
Size(self)
	Ns_Set *	self
    CODE:
	RETVAL = Ns_SetSize(self);
    OUTPUT:
    	RETVAL

char *
Value(self, index)
	Ns_Set *	self
	int	index
    CODE:
	RETVAL = Ns_SetValue(self, index);
    OUTPUT:
    	RETVAL

void
Update(self, key, value)
	Ns_Set *	self
	char *	key
	char *	value
    CODE:
	Ns_SetUpdate(self, key, value);

void
DESTROY(self)
	Ns_Set *	self
    CODE:
	if(! NsSetIsNull(self))
    	  Ns_SetFree(self);


