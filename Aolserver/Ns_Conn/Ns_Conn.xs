#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include <nsthread.h>
#include <tcl.h>
#include <ns.h>

#include <stdio.h>

#include "Ns_ConnMaps.h"
#include "../Ns_DString/Ns_DStringMaps.h"
#include "../Ns_Set/Ns_SetMaps.h"

static int
not_here(char *s)
{
    croak("%s not implemented on this architecture", s);
    return -1;
}

MODULE = Aolserver::Ns_Conn		PACKAGE = Aolserver::Ns_Conn		

# NOTE that new() is presently dangerous: I don't know how to
# make new Ns_Conn thingys. So far, the only way I know to get a
# connection is to be passed it from the server (i.e., in the var
# $Aolserver::Ns_Conn::theConn.) The implementation is sufficiently
# general to make it easy to accomodate a newly arriving method for
# making new Ns_Conn objects.

Ns_Conn *
new(class)
	char *		class

    CODE:
	RETVAL = malloc(sizeof(Ns_Conn));
	if (RETVAL)
	{
	    /* initialize the space here somehow, */ 
	    /* but HOW?? so don't use new()       */

	    ST(0) = sv_newmortal();
            fprintf(stderr, "addr of newmortal is %p\n", ST(0));
            fprintf(stderr, "refcount of newmortal is %d\n", SvREFCNT(ST(0)));
	    sv_setref_pv(ST(0), class, (void*) RETVAL);
            fprintf(stderr, "addr of ST(0) is %p\n", ST(0));
            fprintf(stderr, "refcount of ST(0) is %d\n", SvREFCNT(ST(0)));
	}
	else
	{
	    ST(0) = &PL_sv_undef;
	}

SV *
newReferral(class, conn)
        char *		class
        Ns_Conn *	conn
    CODE:
	//SV* anSV;

        RETVAL = sv_newmortal();
        fprintf(stderr, "addr of newmortal is %p\n", ST(0));
        fprintf(stderr, "refcount of newmortal is %d\n", SvREFCNT(ST(0)));
        sv_setref_pv(RETVAL, class, conn);
        fprintf(stderr, "addr of ST(0) is %p\n", ST(0));
        fprintf(stderr, "refcount of ST(0) is %d\n", SvREFCNT(ST(0)));
	
	// NOTE! This is -dependent- on the internals of Ns_Conn!!
	//
	// the idea here is to create perl references to each of
	// the pieces the API would return pointers to, then each
	// API function that would otherwise return a pointer to 
	// a member of the struct, would instead return the perl
	// reference that was originally canned by this function.

	// headers
	//anSV = sv_newmortal();
    OUTPUT:
        RETVAL

# test funcs

SV *
Request(connPerlRef)
	SV *	connPerlRef
    CODE:
	RETVAL = GetRequest(connPerlRef);
    OUTPUT:
	RETVAL

# HTTP Header-Related Functions

void
CondSetHeaders(conn, field, value)
	Ns_Conn *	conn
	char *	field
	char *	value
    CODE:
	Ns_ConnCondSetHeaders(conn, field, value);

void
ConstructHeaders(conn, dsPtr)
	Ns_Conn *	conn
	Ns_DString *	dsPtr
    CODE:	
	Ns_ConnConstructHeaders(conn, dsPtr);

int
FlushHeaders(conn, status)
	Ns_Conn	*	conn
	int	status
    CODE:
	RETVAL = Ns_ConnFlushHeaders(conn, status);
    OUTPUT:
	RETVAL

# SPECIAL: OutputHeaders() now returns stored/initialized perl infrastructure
#          created especially to ensure the headers don't get destroyed
#         .if a var goes out of scope. The input is perl's idea of an Ns_Conn
#          and the output is perl's idea of an Ns_Set.

SV *
OutputHeaders(connPerlRef)
	SV *	connPerlRef
    CODE:
	RETVAL = GetOutputHeaders(connPerlRef);
    OUTPUT:
	RETVAL

#Ns_Set *
#OutputHeaders(conn)
#	Ns_Conn *	conn
#    CODE:
#	RETVAL = Ns_ConnOutputHeaders(conn);
#    OUTPUT:
#	RETVAL

# omitting Ns_ConnPrintfHeader

void
ReplaceHeaders(conn, newheaders)
	Ns_Conn *	conn
	Ns_Set *	newheaders
    CODE:
	Ns_ConnReplaceHeaders(conn, newheaders);

void
SetExpiresHeader(conn, httptime)
	Ns_Conn *	conn
	char *	httptime
    CODE:	
	Ns_ConnSetExpiresHeader(conn, httptime);
    OUTPUT:
	httptime

void
SetHeaders(conn, field, value)
	Ns_Conn *	conn
	char *	field
	char *	value
    CODE:
	Ns_ConnSetHeaders(conn, field, value);

void
SetLastModifiedHeader(conn, when)
	Ns_Conn *	conn
	time_t	when
    CODE:
	Ns_ConnSetLastModifiedHeader(conn, &when);
    OUTPUT:
	when

void
SetLengthHeader(conn, len)
	Ns_Conn *	conn
	int	len
    CODE:
	Ns_ConnSetLengthHeader(conn, len);

void
SetRequiredHeaders(conn, contentType, contentLength)	
	Ns_Conn *	conn
	char *	contentType
	int	contentLength
    CODE:
	Ns_ConnSetRequiredHeaders(conn, contentType, contentLength);

void
SetTypeHeader(conn, type)
	Ns_Conn *	conn
	char *	type
    CODE:
	Ns_ConnSetTypeHeader(conn, type);

# HTTP Complete Response Functions

void
ReturnAdminNotice(conn, status, notice, html)
	Ns_Conn *	conn
	int		status
	char *		notice
	char *		html
    CODE:
	Ns_ConnReturnAdminNotice(conn, status, notice, html);

int
ReturnData(conn, status, html, len, type)
	Ns_Conn *	conn
	int		status
	char *		html
	int		len
	char *		type
    CODE:
	RETVAL = Ns_ConnReturnData(conn, status, html, len, type);
    OUTPUT:
	RETVAL

int
ReturnFile(conn, status, type, file)
	Ns_Conn *	conn
	int		status
	char *		type
	char *		file
    CODE:
	RETVAL = Ns_ConnReturnFile(conn, status, type, file);
    OUTPUT:
	RETVAL

int
ReturnHtml(conn, status, html, len)
	Ns_Conn *	conn
	int		status
	char *		html
	int		len
    CODE:
	RETVAL = Ns_ConnReturnHtml(conn, status, html, len);
    OUTPUT:
	RETVAL

int
ReturnNotice(conn, status, notice, html)
	Ns_Conn *	conn
	int		status
	char *		notice
	char *		html
    CODE:
	RETVAL = Ns_ConnReturnNotice(conn, status, notice, html);
    OUTPUT:
	RETVAL

int
ReturnOpenFd(conn, status, type, fd, len)
	Ns_Conn *	conn
	int	status
	char *	type
	int	fd
	int	len
    CODE:
	RETVAL = Ns_ConnReturnOpenFd(conn, status, type, fd, len);
    OUTPUT:
	RETVAL

int
ReturnOpenFile(conn, status, type, fp, len)
	Ns_Conn *	conn
	int	status
	char *	type
	FILE *	fp
	int	len
    CODE:
	RETVAL = Ns_ConnReturnOpenFile(conn, status, type, fp, len);
    OUTPUT:
	RETVAL

int
ReturnRedirect(conn, location)
	Ns_Conn *	conn
	char *		location
    CODE:
	RETVAL = Ns_ConnReturnRedirect(conn, location);
    OUTPUT:
	RETVAL

int
ReturnStatus(conn, status)
	Ns_Conn *	conn
	int		status
    CODE:
	RETVAL = Ns_ConnReturnStatus(conn, status);
    OUTPUT:
	RETVAL

# HTTP Simple Response Functions

int
ReturnBadRequest(conn, reason)
	Ns_Conn *	conn
	char *	reason
    CODE:
	RETVAL = Ns_ConnReturnBadRequest(conn, reason);
    OUTPUT:
	RETVAL

int
ReturnForbidden(conn)
	Ns_Conn *	conn
    CODE:
	RETVAL = Ns_ConnReturnForbidden(conn);
    OUTPUT:
	RETVAL

int
ReturnInternalError(conn)
	Ns_Conn *	conn
    CODE:
	RETVAL = Ns_ConnReturnInternalError(conn);
    OUTPUT:
	RETVAL

int
ReturnNoResponse(conn)
	Ns_Conn *	conn
    CODE:
	RETVAL = Ns_ConnReturnNoResponse(conn);
    OUTPUT:
	RETVAL

int
ReturnNotFound(conn)
	Ns_Conn *	conn
    CODE:
	RETVAL = Ns_ConnReturnNotFound(conn);
    OUTPUT:
	RETVAL

int
ReturnNotImplemented(conn)
	Ns_Conn *	conn
    CODE:
	RETVAL = Ns_ConnReturnNotImplemented(conn);
    OUTPUT:
	RETVAL

int
ReturnNotModified(conn)
	Ns_Conn *	conn
    CODE:
	RETVAL = Ns_ConnReturnNotModified(conn);
    OUTPUT:
	RETVAL

int
ReturnOk(conn)
	Ns_Conn *	conn
    CODE:
	RETVAL = Ns_ConnReturnOk(conn);
    OUTPUT:
	RETVAL

int
ReturnUnauthorized(conn)
	Ns_Conn *	conn
    CODE:
	RETVAL = Ns_ConnReturnUnauthorized(conn);
    OUTPUT:
	RETVAL

int
RunRequest(conn)
	Ns_Conn *	conn
    CODE:
	RETVAL = Ns_ConnRunRequest(conn);
    OUTPUT:
	RETVAL

# HTTP Low-Level Connection Functions

char *
AuthPasswd(conn)
	Ns_Conn *	conn
    CODE:
	RETVAL = Ns_ConnAuthPasswd(conn);
    OUTPUT:
	RETVAL

char *
AuthUser(conn)
	Ns_Conn *	conn
    CODE:
	RETVAL = Ns_ConnAuthUser(conn);
    OUTPUT:
	RETVAL

int
Close(conn)
	Ns_Conn *	conn
    CODE:
	RETVAL = Ns_ConnClose(conn);
    OUTPUT:
	RETVAL

int
ContentLength(conn)
	Ns_Conn *	conn
    CODE:
	RETVAL = Ns_ConnContentLength(conn);
    OUTPUT:
	RETVAL

int
ContentSent(conn)
	Ns_Conn *	conn
    CODE:
	RETVAL = Ns_ConnContentSent(conn);
    OUTPUT:
	RETVAL

#int
#CopyToChannel(conn, iToCopy, chan)
#	Ns_Conn *	conn
#	size_t	iToCopy
#	Tcl_Channel	chan
#    CODE:
#	RETVAL = Ns_ConnCopyToChannel(conn, iToCopy, chan);
#    OUTPUT:
#	RETVAL

int
CopyToDString(conn, iToCopy, pds)
	Ns_Conn *	conn
	size_t	iToCopy
	Ns_DString *	pds
    CODE:
	RETVAL = Ns_ConnCopyToDString(conn, iToCopy, pds);
    OUTPUT:
	RETVAL

int
CopyToFd(conn, iToCopy, fd)
	Ns_Conn *	conn
	size_t	iToCopy
	int	fd
    CODE:
	RETVAL = Ns_ConnCopyToFd(conn, iToCopy, fd);
    OUTPUT:
	RETVAL

int
CopyToFile(conn, iToCopy, fp)
	Ns_Conn *	conn
	size_t	iToCopy
	FILE *	fp
    CODE:
	RETVAL = Ns_ConnCopyToFile(conn, iToCopy, fp);
    OUTPUT:
	RETVAL

void *
DriverContext(conn)
	Ns_Conn *	conn
    CODE:
	RETVAL = Ns_ConnDriverContext(conn);
    OUTPUT:
	RETVAL

char *
DriverName(conn)
	Ns_Conn *	conn
    CODE:
	RETVAL = Ns_ConnDriverName(conn);
    OUTPUT:
	RETVAL

int
FlushContent(conn)
	Ns_Conn *	conn
    CODE:
	RETVAL = Ns_ConnFlushContent(conn);
    OUTPUT:
	RETVAL

Ns_Set *
GetQuery(conn)
	Ns_Conn *	conn
    CODE:
	RETVAL = Ns_ConnGetQuery(conn);
    OUTPUT:
	RETVAL

# NOTE!! Function parameters modified here to accomodate OOP idiom!
# called as: $connection->Gets($buf, $size) 
# (so the connection must be the first arg)
#
# One point: the perl programmer considering the use of Gets must worry
# about how to allocate a buffer, because the buffer must be of the
# specified size.

char *
Gets(conn, buf, sz)
	Ns_Conn *	conn
	char *	buf
	size_t	sz
    CODE:
	RETVAL = Ns_ConnGets(buf, sz, conn);
    OUTPUT:
	RETVAL

# SPECIAL: Headers() now returns stored/initialized perl infrastructure
#          created especially to ensure the headers don't get destroyed
#         .if a var goes out of scope.

SV *
Headers(connPerlRef)
	SV *	connPerlRef
    CODE:
	RETVAL = GetHeaders(connPerlRef);
    OUTPUT:
	RETVAL

# Ns_Set *
# Headers(conn)
#	Ns_Conn *	conn
#    CODE:
#	RETVAL = Ns_ConnHeaders(conn);
#    OUTPUT:
#	RETVAL

char *
Host(conn)
	Ns_Conn *	conn
    CODE:
	RETVAL = Ns_ConnHost(conn);
    OUTPUT:
	RETVAL

int
Init(connPtr)
	Ns_Conn *	connPtr
    CODE:
	RETVAL = Ns_ConnInit(connPtr);
    OUTPUT:
	RETVAL

char *
Location(conn)
	Ns_Conn *	conn
    CODE:
	RETVAL = Ns_ConnLocation(conn);
    OUTPUT:
	RETVAL

int
ModifiedSince(conn, mtime)
	Ns_Conn *	conn
	time_t	mtime
    CODE:
	RETVAL = Ns_ConnModifiedSince(conn, mtime);
    OUTPUT:
	RETVAL

char *
Peer(conn)
	Ns_Conn *	conn
    CODE:
	RETVAL = Ns_ConnPeer(conn);
    OUTPUT:
	RETVAL

int
PeerPort(conn)
	Ns_Conn *	conn
    CODE:
	RETVAL = Ns_ConnPeerPort(conn);
    OUTPUT:
	RETVAL

int
Port(conn)
	Ns_Conn *	conn
    CODE:
	RETVAL = Ns_ConnPort(conn);
    OUTPUT:
	RETVAL

int
Puts(conn, string)
	Ns_Conn *	conn
	char *	string
    CODE:
	RETVAL = Ns_ConnPuts(conn, string);
    OUTPUT:
	RETVAL

int
Read(conn, pvBuf, iToRead)
	Ns_Conn *	conn
	char *	pvBuf	
	int	iToRead
    CODE:
	RETVAL = Ns_ConnRead(conn, pvBuf, iToRead);
    OUTPUT:
	RETVAL

int
ReadHeaders(conn, psetHeaders, iRead)
	Ns_Conn *	conn
	Ns_Set *	psetHeaders
	int	iRead
    CODE:
	RETVAL = Ns_ConnReadHeaders(conn, psetHeaders, &iRead);
    OUTPUT:
	RETVAL
	iRead

int
ReadLine(conn, pdsLine, iRead)
	Ns_Conn *	conn
	Ns_DString *	pdsLine
	int	iRead
    CODE:
	RETVAL = Ns_ConnReadLine(conn, pdsLine, &iRead);
    OUTPUT:
	RETVAL
	iRead

int
Redirect(conn, url)
	Ns_Conn *	conn
	char *	url
    CODE:
	RETVAL = Ns_ConnRedirect(conn, url);
    OUTPUT:
	RETVAL

int
ResponseLength(conn)
	Ns_Conn *	conn
    CODE:
	RETVAL = Ns_ConnResponseLength(conn);
    OUTPUT:
	RETVAL

int
ResponseStatus(conn)
	Ns_Conn *	conn
    CODE:
	RETVAL = Ns_ConnResponseStatus(conn);
    OUTPUT:
	RETVAL

#int
#ReturnOpenChannel(conn, status, type, chan, len)
#	Ns_Conn *	conn
#	int	status
#	char *	type
#	Tcl_Channel	chan
#	int	len
#    CODE:
#	RETVAL = Ns_ConnReturnOpenChannel(conn, status, type, chan, len);
#    OUTPUT:
#	RETVAL

#int
#SendChannel(conn, chan, len)
#	Ns_Conn *	conn
#	Tcl_Channel	chan
#	int	len
#    CODE:
#	RETVAL = Ns_ConnSendChannel(conn, chan, len);
#    OUTPUT:
#	RETVAL

#SendDString

int
SendFd(conn, fd, len)
	Ns_Conn *	conn
	int	fd
	int	len
    CODE:
	RETVAL = Ns_ConnSendFd(conn, fd, len);
    OUTPUT:
	RETVAL

int
SendFp(conn, fp, len)
	Ns_Conn *	conn
	FILE *	fp
	int	len
    CODE:
	RETVAL = Ns_ConnSendFp(conn, fp, len);
    OUTPUT:
	RETVAL

char *
Server(conn)
	Ns_Conn *	conn
    CODE:
	RETVAL = Ns_ConnServer(conn);
    OUTPUT:
	RETVAL

int
Write(conn, buf, len)
	Ns_Conn *	conn 
	char *		buf 
	int 		len
    CODE:
	RETVAL = Ns_ConnWrite(conn, buf, len);
    OUTPUT:
	RETVAL

int
WriteConn(conn, buf, len)
	Ns_Conn *	conn 
	char *		buf 
	int 		len
    CODE:
	RETVAL = Ns_WriteConn(conn, buf, len);
    OUTPUT:
	RETVAL

# void
# DESTROY(conn)
#	Ns_Conn *	conn
#    CODE:
#	/* when a way to create connections is discovered ( and */
#        /* put into new() ), undo here.                          */
#	free(conn);
