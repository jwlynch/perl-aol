package Aolserver::Ns_Conn;

require 5.005_62;
use strict;
use warnings;
use Carp;

require Exporter;
require DynaLoader;
use AutoLoader;

our @ISA = qw(Exporter DynaLoader);

# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.

# This allows declaration	use Aolserver::Ns_Conn ':all';
# If you do not need this, moving things directly into @EXPORT or @EXPORT_OK
# will save memory.
our %EXPORT_TAGS = ( 'all' => [ qw(
	
) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw(
	
);
our $VERSION = '0.01';

sub AUTOLOAD {
    # This AUTOLOAD is used to 'autoload' constants from the constant()
    # XS function.  If a constant is not found then control is passed
    # to the AUTOLOAD in AutoLoader.

    my $constname;
    our $AUTOLOAD;
    ($constname = $AUTOLOAD) =~ s/.*:://;
    croak "& not defined" if $constname eq 'constant';
    my $val = constant($constname, @_ ? $_[0] : 0);
    if ($! != 0) {
	if ($! =~ /Invalid/ || $!{EINVAL}) {
	    $AutoLoader::AUTOLOAD = $AUTOLOAD;
	    goto &AutoLoader::AUTOLOAD;
	}
	else {
	    croak "Your vendor has not defined Aolserver::Ns_Conn macro $constname";
	}
    }
    {
	no strict 'refs';
	# Fixed between 5.005_53 and 5.005_61
	if ($] >= 5.00561) {
	    *$AUTOLOAD = sub () { $val };
	}
	else {
	    *$AUTOLOAD = sub { $val };
	}
    }
    goto &$AUTOLOAD;
}

bootstrap Aolserver::Ns_Conn $VERSION;

# Preloaded methods go here.

# Autoload methods go after =cut, and are processed by the autosplit program.

1;
__END__
# Below is stub documentation for your module. You better edit it!

=head1 NAME

Aolserver::Ns_Conn - NaviServer, err, Aolserver's browser connection structure

All functions that handle connection requests, which we refer to as
AOLserver operations, take as an argument a pointer to an Ns_Conn
structure. This structure contains all information and state about the
active connection. The public members that you may find useful
include:


=head1 SYNOPSIS

    use Aolserver::Ns_DString;
    $dstring = new Aolserver::Ns_DString;

    use Aolserver::Ns_Conn;

    $string = $conn->AuthPasswd();
    $string = $conn->AuthUser();
    $integer = $conn->Close();
    $conn->CondSetHeaders($fieldString, $valueString);
    $length = $conn->ContentLength();
    $trueOrFalse = $conn->ContentSent();
    $errStatus = $conn->CopyToChannel($howManyBytes, $tclChannel); (how $tclChannel?)
    (but CopyToChannel is not implemented yet)
    $errStatus = $conn->CopyToDString($howManyBytes, $dstring);
    $errStatus = $conn->CopyToFd($howManyBytes, $fdInt); (how $fdInt?)
    $errStatus = $conn->CopyToFile($howManyBytes, $fileFILEPtr); (how $fileFILEPtr?)
    $contextPtr = $conn->DriverContext(); (how $context?)
    $nameString = $conn->DriverName();
    $errStatus = $conn->FlushContent();
    $errStatus = $conn->FlushHeaders($statusInt);
    $queryDataSet = $conn->GetQuery();
    $string = $conn->Gets($storage, $size); (how $storage?)
    $set = $conn->Headers();
    $string = $conn->Host();
    $someInt = $conn->Init();
    $locationString = $conn->Location();
    $trueOrFalse = $conn->ModifiedSince($anMtimeTime_T);
    $outHeadersSet = $conn->OutputHeaders();
    $peerString = $conn->Peer();
    $portInt = $conn->PeerPort();
    $portInt = $conn->Port();
    $someInt = $conn->PrintfHeader($formatString, ...); (how ...?)
    $errStatus = $conn->Puts($string);
    $errStatusOrCharCount = $conn->Read($buffer, $bufferSize); (how $buffer?)
    $headersSet = new Aolserver::Ns_Set;
    $someInt = $conn->ReadHeaders($headersSet, $howManyRead);
    $lineDString = new Aolserver::Ns_DString;
    $errStatus = $conn->ReadLine($lineDString, $howManyRead);
    $someInt = $conn->Redirect($urlString);
    $conn->ReplaceHeaders($newHeadersSet);
    $responseLength = $conn->ResponseLength();
    $responseStatus = $conn->ResponseStatus();
    $conn->ReturnAdminNotice($statusInt, $noticeString, $htmlString);
    $someInt = $conn->ReturnBadRequest($reasonString);
    $errStatus = $conn->ReturnData
                        (
                           $statusInt, 
                           $htmlString, 
                           $sizeInt, 
                           $typeString
                        );
    $errStatus = $conn->ReturnFile($statusInt, $typeString, $filenameString);
    $someInt = $conn->ReturnForbidden(); 
    $errStatus = $conn->ReturnHtml($statusInt, $htmlString, $lengthInt);
    $someInt = ReturnInternalError();
    $someInt = $conn->ReturnNoResponse();
    $someInt = $conn->ReturnNotFound();
    $someInt = $conn->ReturnNotImplemented();
    $someInt = $conn->ReturnNotModified();
    $errStatus = $conn->ReturnNotice($statusInt, $noticeString, $htmlString);
    $someInt = $conn->ReturnOK();
    $someInt = $conn->ReturnOpenChannel
                      (
                          $statusInt, 
                          $typeString, 
                          $tclChan, (how?)
                          $lengthInt
                      );
    $errStatus = $conn->ReturnOpenFile
                        (
                            $statusInt, 
                            $typeString, 
                            $fdInt, (how?)
                            $lengthInt
                        ); 
    $errStatus = $conn->ReturnOpenFile
                        (
                            $statusInt, 
                            $typeString, 
                            $filestreamFile, (how?)
                            $lengthInt
                        ); 
    $errStatus = $conn->ReturnRedirect($locationString); 
    $errStatus = $conn->ReturnStatus($statusInt); 
    $someInt = $conn->ReturnUnauthorized();
    $requestErrStatus = $conn->RunRequest();
    $someInt = $conn->SendChannel($tclChan, $lengthInt); (how $tclChan?)
    $someInt = $conn->SendDString($dstringToSend);
    $errStatus = $conn->SendFd($filedescriptorInt, $lengthInt);
                                  (how?)
    $errStatus = $conn->SendFp($filestreamFile, $lengthInt); 
                                  (how?)
    $servernameString = $conn->Server();
    $conn->SetExpiresHeader($httptimeString);
    $conn->SetHeaders($fieldString, $valueString);
    $conn->SetLastModifiedHeader($whenTime_T); (how $whenTime_T?)
    $conn->SetLengthHeader($lengthInt);
    $conn->SetRequiredHeaders($typeString, $contentlengthInt);
    $conn->SetTypeHeader($typeString);
    $numwrittenOrMinusOne = $conn->Write($storage, $lengthInt); (how $storage?)
    $numwrittenOrMinusOne = $conn->WriteConn($storage, $lengthInt); (ditto?)


=head1 DESCRIPTION

This module is an encapsulation into a perl class, of the Aolserver
data structure Ns_Conn, which is used to store information about a
requesting web browser's connection to the server. You'd send content
thru that object.  The structure and some functions that manipulate
and/or use it are exposed by the API of aolserver. (If you don't know
what aolserver is, you -definitely- don't need this module, and it
won't work since you probably don't have aolserver.)

NOTE that this module does NO type conversion. That will be added later, 
and will be done -outside- this module.

NOTE also that you need a specially-built perl -and- my nsperl module
for aolserver to make any use of this module. This is -one piece- of
a whole. If you don't know what aolserver is, this module has no meaning
for you. OTOH, if you would like to explore it, two places to start are
http://www.aolserver.com/ and http://philip.greenspun.com/teaching/.

Each is implemented as a blessed reference (usually
"Aolserver::Ns_Conn") to an SvIV, and the IV within points to a
struct Ns_Conn. 

(Thanks to Brendan O'Dea <bod@debian.org> for the implementation of
new(char*) and the typemaps.  This contribution is -very- important
because it lets everything else happen correctly.  THANKS, Brendan!
I, in turn, took those typemaps and factored the conversion code into
C functions so they could be used (1) outside of perl entirely, and
(2) by other perl modules.  Questions about this module to
jim@laney.edu ONLY AFTER you have read, thought about and -tried- this
doc. Please have a properly built perl (right now, it's perl 5.6 w/
multiplicity and Ithreads), aolserver 3.1, nsperl (the module for
aolserver that runs a perl script on the linked libperl),
postgresql-7.0.2 (optional but interesting :) and the perl modules
Aolserver::*.  If you don't have these things working, please don't
bother. They'll be released when they're done. The list above is not
as definitive as it could be because I'm designing the inner API glue
as I go, not everything is done yet and things could change.)

The methods:

We will use the var $conn to represent a Ns_Conn; since there
seems to only be one, I can be fairly sure that this will remain
definitive:

    $conn = $Aolserver::Ns_Conn::theConn;

From the Aolserver C API docs:

All functions that handle connection requests, which we refer to as
AOLserver operations, take as an argument a pointer to an Ns_Conn
structure. This structure contains all information and state about the
active connection. The public members that you may find useful
include:

=over 4

=item AuthPasswd -- Return password

Syntax:

    $string = $conn->AuthPasswd();

Description:

The AuthPasswd function returns the decoded password from the header
information associated with the connection. 

Example:

# PassTrace - A server trace to log users and passwords.

sub PassTrace
{
    my ($ctx, $conn) = @_;
    my ($user, $pass);

    $user = $conn->AuthUser();
    $pass = $conn->AuthPasswd();

    if ( ($user ne "") && ($pass ne "") ) 
    {
	# this isn't perl yet... and won't be for datastruct release
	Ns_Log(Notice, "User: %s Password: %s", user, pass);
    }
}

=item AuthUser -- Return user name

Syntax:

    $string = $conn->AuthUser();

Description:

The AuthUser function
returns the decoded user name from
the header information associated
with the connection. 

Example:

See the example for
Ns_ConnAuthPasswd. 

=item Close -- Close a connection

Syntax:

    $integer = $conn->Close();

Description:

The Close function closes a
connection. The semantics of this
call are specific to the driver
associated with the connection. In
the case of a socket driver (the
nssock module), this function will
cause the socket associated with
the connection to be closed.
Close returns a status of
NS_OK or NS_ERROR. 

This function is called by
AOLserver before running any
registered traces. You do not
normally need to call it. 

=item CondSetHeaders -- Set the value for a header field conditionally

Syntax:

    $conn->CondSetHeaders($fieldString, $valueString);

Description:

The CondSetHeaders function
sets the value of a field if and
only if the field/value pair does
not already exist. The search for
an existing field is not case
sensitive. 

Example:

=item ConstructHeaders -- Put HTTP header into DString

Syntax:

    use Aolserver::Ns_DString;
    $dstring = new Aolserver::Ns_DString;

    $conn->ConstructHeaders($dstring);

Description:

Put the header of an HTTP response
into the DString. Content-Length
and Connection-Keepalive headers
will be added if possible. 

Example:

=item ContentLength -- Return content length

Syntax:

    $length = $conn->ContentLength();

Description:

The ContentLength function
returns the number of bytes in the
content associated with the
connection. 

Example:

    # Copy the content from the browser to a DString.

    use Aolserver::Ns_DString;
    $dsring = new Aolserver::Ns_DString;
    $len = $conn->ContentLength();

    $conn->CopyToDString($len, $dstring);

=item ContentSent -- Check if browser sent content

Syntax:

    $trueOrFalse = $conn->ContentSent();

Description:

Returns TRUE if the browser sent
any content, such as in a PUT
request. Returns FALSE otherwise. 

=item CopyToChannel -- Copy content to Tcl channel (not yet)

Syntax:

    $errStatus = $conn->CopyToChannel($howManyBytes, $tclChannel);

Description:

Copy content, such as in a PUT
request, from the connection into
an open Tcl channel. $howManyBytes bytes
will be copied. 

=item CopyToDString -- Copy data from connection to dynamic string

Syntax:

    use Aolserver::Ns_DString;
    $dstring = new Aolserver::Ns_DString;

    $errStatus = $conn->CopyToDString($howManyBytes, $dstring);

Description:

The CopyToDString function
copies $howManyBytes bytes of data from
the connection to the Ns_DString
in $dstring.
CopyToDString returns a
status of NS_OK or NS_ERROR. 

Example:

See the example for
ContentLength. 

=item CopyToFd -- Copy content to file descriptor

Syntax:

(assuming the descriptor integer of a file opened with write
permissions is in $fd...)

    $errStatus = $conn->CopyToFd($howManyBytes, $fdInt);

Description:

Copy content, such as in a PUT
request, from the connection into
an open file descriptor. iToCopy
bytes will be copied.

=item CopyToFile -- Copy data from connection to a file

Syntax:

(assuming $file has some ref to a FILE structure representing
a file that can be written to...)

    $errStatus = $conn->CopyToFile($howManyBytes, $fileFILEPtr);

Description:

The CopyToFile function
copies $howManyBytes bytes of data from
the connection to the file pointed
to by fp. CopyToFile returns
a status of NS_OK or NS_ERROR
(seen here assigned to $errStatus). 

Example:

    # Copy the content from the browser to a file.

    FILE *fp; # how translate this?? (assume $fp)

    fp = fopen("content.out", "w"); # and this?? (assume $fp)

    $len = $conn->ContentLength();
    $errStatus = $conn->CopyToFile($len, $fp);

    fclose(fp); # and this??

=item DriverContext -- Return driver context

Syntax:

    $contextPtr = $conn->DriverContext();

Description:

The DriverContext function
returns a pointer to the
communications driver context
associated with the connection.
This context is set in the
Ns_QueueConn function. This
function exists primarily for
AOLserver communications driver
developers. 

=item DriverName

Syntax:

    $nameString = $conn->DriverName();

Description:

The Ns_ConnDriverName function
returns the communications driver
name associated with the
connection. 

=item FlushContent -- Flush remaining content

Syntax:
    
    $errStatus = $conn->FlushContent();

Description:

Read all remaining content sent by
the browser, for example in a PUT
request, and throw it away. 

=item FlushHeaders -- Mark the end of the headers

Syntax:

    $errStatus = $conn->FlushHeaders($statusInt);

Description:

The FlushHeaders functions
returns a single blank line that
signifies the end of the headers.
It also sets the state of the
connection from header buffering
mode to immediate sending of data
to the client. Before this function
is called, any headers are not
actually sent to the client but
instead are buffered in the Ns_Conn
structure to avoid the cost of
sending the headers in individual
network packets. 

The status is a standard error code
such as 403 for access denied or
200 for OK. Returns NS_OK or
NS_ERROR. 

This function is normally required
just before sending content to the
client. 

Example:

# A simple Hello request function. */

sub MyHello(Ns_Conn *conn, void *ctx)
{
    my ($conn, $context) = @_;

    $hello = "hello";
    $len = length($hello);
    $conn->SetRequiredHeaders("text/plain", $len);
    $conn->FlushHeaders(200);

    return $conn->Write($hello, $len);
}

=item GetQuery -- Construct Ns_Set representing query data

Syntax:

    $queryDataSet = $conn->GetQuery();

Description:

The GetQuery function
constructs and returns an Ns_Set
structure representing the query
data associated with the
connection. It reads the POST
content or the query string. The
POST content takes precedence over
the query string. 

Note that you must not call
Ns_SetFree (or in perl, $queryDataSet->Free()) on the result of this
function. 

META: maybe make the set be a copy of the output; then it's safe

Example:

    # Get the value from an <INPUT NAME="mydata"> form tag.

    $set = $conn->GetQuery();

    if ($set != NULL) # META: alter Ns_Set or GetQuery()
                      # somehow to make this work 
    {
	$value = $set->GetValue("mydata");
    }

=item Gets-- Read content into a buffer

Syntax:

(assuming $storage is some ref to an allocated buffer...)

    $string = $conn->Gets($storage, $size); 

(if the assumption is wrong, this func isn't useful. Use another way.)

Description:

The Gets function reads $size
bytes of a single line (until
newline/cr) from the connection
into the buffer specified by $storage.
Gets returns $storage or, in the
case of a read error, NULL. (or undef? META: what to do??) 

=item Headers -- Return headers

Syntax:

    $set = $conn->Headers();

Description:

The Headers function
returns, as an Ns_Set, the headers
associated with the connection. 

Example:

    # Log the Referer header.

    $headers = $conn->Headers();

    if (headers != NULL) # META: alter Headers or Ns_Set for this
    {
        $refer = $headers->Get("Referer");

        if (refer != NULL) # META: something else to deal w/...
        {
            # THis won't work yet; first release is certain data structs only
            # syntax will be different as well
            Ns_Log(Notice, "Referer: %s", refer);
        }
    }

=item Host -- Return host

Syntax:

    $string = $conn->Host();

Description:

The Host function returns
the server hostname associated with
the connection.

=item Init -- Run socket init procedure

Syntax:

    $someInt = $conn->Init();

Description:

Run a socket driver's init
procedure. This function is usually
only called internally. 

=item Location -- Return location

Syntax:

    $locationString = $conn->Location();

Description:

The Ns_ConnLocation function
returns the HTTP location
associated with the connection. For
example: http://www.avalon.com:81. 

Multiple communications drivers can
be loaded into a single server.
This means a server may have more
than one location. For example, if
the nsssl module is loaded and
bound to port 8000 and the nssock
module is loaded and bound to port
9000, the server would have the
following two locations: 

 http://www.avalon.com:9000
 https://www.avalon.com:8000

For this reason it is important to
use the Ns_ConnLocation function to
determine the driver location at
run time.

=item ModifiedSince -- Determine if content modified since a specified date

Syntax:

(assuming $anMtime is a time_t...)

    $trueOrFalse = $conn->ModifiedSince($anMtimeTime_T);

Description:

The ModifiedSince function
returns 1 if the content associated
with the connection has been
modified since mtime. It uses the
HTTP header variable
"If-Modified-Since".

=item OutputHeaders -- Get Ns_Set of headers to send to client

Syntax:

    $outHeadersSet = $conn->OutputHeaders();

Description:

Get a writeable Ns_Set containing
headers to send back to the client.

=item Peer

Syntax:

    $peerString = $conn->Peer();

Description:

The Peer function returns
the name of the peer associated
with the connection. 

The peer address is determined by
the communications driver in use by
the connection. Typically it is a
dotted IP address, for example,
199.221.53.205, but this is not
guaranteed.

=item PeerPort -- Return peer port

Syntax:

    $portInt = $conn->PeerPort();

Description:

Returns the port from which the
peer is connected. 

=item Port -- Return port

Syntax:

    $portInt = $conn->Port();

Description:

The Port function returns
the server port number associated
with the connection.

=item PrintfHeader -- Return a formatted header (not yet)

Syntax:

    $someInt = $conn->PrintfHeader($formatString, ...);

Description:

The PrintfHeader function
constructs a formatted string using
the given format specification and
any optional arguments. It then
appends the necessary line feed and
carriage return characters and
sends the header to the client.

=item Puts -- Send a string to a client

Syntax:

    $errStatus = $conn->Puts($string);

Description:

The Puts function sends the
given string to the client. It
returns NS_OK on success and
NS_ERROR on failure.

=item Read -- Read content into buffer

Syntax:

    $errStatusOrCharCount = $conn->Read($buffer, bufferSize);

    # META: $buffer is another dyn allocated thingy... deal :)

Description:

The Read function (tries to) read
$bufferSize bytes from the connection
into $buffer. Read returns the
status NS_ERROR or the number of
bytes read from the connection. 

Example:

    # Read content from the browser into buf.
    char buf[1024]; # META: how deal?

    $errStatusOrCharCount = $conn->Read(buf, sizeof(buf));

=item ReadHeaders -- Read headers into Ns_Set

Syntax:

    use Aolserver::Ns_Set;

    $headersSet = new Aolserver::Ns_Set;
    $someInt = $conn->ReadHeaders($headersSet, $howManyRead);

Description:

Read headers from the conn and put
them into the passed-in set. 

=item ReadLine

Syntax:

    use Aolserver::Ns_DString;

    $lineDString = new Aolserver::Ns_DString;
    $errStatus = $conn->ReadLine($lineDString, $howManyRead);

Description:

The ReadLine function reads
an \n or \r terminated line from
the connection into the Ns_DString
referred to by $lineDString. The $howManyRead
argument will contain the number of
bytes read. ReadLine returns
a status of NS_OK or NS_ERROR. 

=item Redirect -- Perform internal redirect

Syntax:

    $someInt = $conn->Redirect($urlString);

Description:

Perform an internal redirect, i.e.,
make it appear that the user
requested a different URL and then
run that request. This doesn't
require an additional thread. 

=item ReplaceHeaders -- Replace output headers for connection

Syntax:

    use Aolserver::Ns_Set;

    $newHeadersSet = new Aolserver::Ns_Set;

      (... put stuff in $newHeadersSet ...)

    $conn->ReplaceHeaders($newHeadersSet);

Description:

The ReplaceHeaders function
sets the current output headers for
the connection to the $newHeadersSet.
It copies the $newHeadersSet
and frees memory associated with
the old output headers in the
connection. 

=item ResponseLength -- Return response length

Syntax:

    $responseLength = $conn->ResponseLength();

Description:

The ResponseStatus function
returns the response length
associated with the connection.
This value is only meaningful after
a response has been returned to the
client. This function will normally
be used in trace functions. See
Ns_RegisterTrace for more
information about traces.

=item ResponseStatus -- Return response status

Syntax:

    $responseStatus = $conn->ResponseStatus();

Description:

The ResponseStatus function
returns the response status
associated with the connection.
This value is only meaningful after
a response has been returned to the
client. This function will normally
be used in trace functions. See
Ns_RegisterTrace for more
information about traces.

=item ReturnAdminNotice -- Return a short notice to a client to contact system administrator

Syntax:

    $conn->ReturnAdminNotice($statusInt, $noticeString, $htmlString);

Description:

The ReturnAdminNotice
function returns to a client a
simple HTML page with the given
$noticeString as the title of the page. It
also appends a message directing
users to contact the system
administrator or web master if
specified in the configuration
file. The page includes the
/NS/Asset/notice.gif image at the
top of the page. If the html
parameter is not NULL, it is added
to the page after the notice. The
HTML source can be arbitrarily long
and should not contain the <HTML>
or <BODY> begin or end tags; these
tags will be added by
ReturnAdminNotice.
ReturnAdminNotice returns a
status of NS_OK or NS_ERROR. (META: does it?? it's a void func...)

=item ReturnBadRequest -- Return an "invalid request" HTTP status line.

Syntax:

    $someInt = $conn->ReturnBadRequest($reasonString);

Description:

Calls Ns_ConnReturnStatus or
Ns_ConnReturnNotice with a status
code of 400 to indicate that the
request was invalid.

=item ReturnData -- Return an HTML string to a client

Syntax:

    $errStatus = $conn->ReturnData
                        (
                           $statusInt, 
                           $htmlString, 
                           $sizeInt, 
                           $typeString
                        );

Description:

The ReturnData function
calls the RequiredHeaders
function with the given $statusInt
followed by the given $htmlString.
The length is used to generate the
Content-Length header. If the
$sizeInt is -1, the function
calculates the Content-Length from
the string. The $typeString is used to
generate the Content-Type header.
ReturnData returns a status
of NS_OK or NS_ERROR.

=item ReturnFile -- Return a file to a client

Syntax:

    $errStatus = $conn->ReturnFile($statusInt, $typeString, $filenameString);

Description:

The ReturnFile function
returns the entire contents of the
file named by $filenameString to the client. In
addition to setting the HTTP status
response line header (from $statusInt) and Content-Type
header (from $typeString),
ReturnFile also uses the
stat system call to generate the
appropriate Last-Modified and
Content-Length headers.
ReturnFile returns a status
of NS_OK or NS_ERROR.

=item ReturnForbidden -- Return a "request forbidden" HTTP status line.

Syntax:

    $someInt = $conn->ReturnForbidden(); 

Description:

Calls ReturnStatus or
ReturnNotice with a status
code of 403 to indicate that the
request is forbidden. There is no
Authorization header that will
authorize access from this IP
address.

=item ReturnHtml -- Return an HTML string to a client

Syntax:

    $errStatus = $conn->ReturnHtml($statusInt, $htmlString, $lengthInt);

Description:

The ReturnHtml function
calls the SetRequiredHeaders
function with $statusInt
followed by the given HTML string.
$lengthInt is used to generate the
Content-Length header. If
$lengthInt is -1, the function
calculates the Content-Length from
the string. ReturnHtml
returns a status of NS_OK or
NS_ERROR.

=item ReturnInternalError -- Return an "internal error" HTTP status line.

Syntax:

    $someInt = ReturnInternalError();

Description:

Calls ReturnStatus or
ReturnNotice with a status
code of 500 to indicate that an
internal error occurred. 

=item ReturnNoResponse -- Return a "no response" HTTP status line.

Syntax:

    $someInt = $conn->ReturnNoResponse();

Description:

Calls ReturnStatus or
ReturnNotice with a status
code of 204 to indicate that the
request requires no response. 

=item ReturnNotFound -- Return a "not found" HTTP status line.

Syntax:

    $someInt = $conn->ReturnNotFound();

Description:

Calls ReturnStatus or
ReturnNotice with a status
code of 404 to indicate that the
requested URL was not found on the
server.

=item ReturnNotImplemented -- Return a "not implemented" HTTP status line.

Syntax:

    $someInt = $conn->ReturnNotImplemented();

Description:

Calls ReturnStatus or
ReturnNotice with a status
code of 500 to indicate that the
request has not been implemented by
the server.

=item ReturnNotModified -- Return a "not modified" HTTP status line.

Syntax:

    $someInt = $conn->ReturnNotModified();

Description:

Calls ReturnStatus or
ReturnNotice with a status
code of 304 to indicate that the
requested data have not been
modified since the time specified
by the If-Modified-Since header
sent by the client.

=item ReturnNotice -- Return a
short notice to a client

Syntax:

    $errStatus = $conn->ReturnNotice($statusInt, $noticeString, $htmlString);

Description:

The ReturnNotice function
returns to a client a simple HTML
page with the given $noticeString as the
title of the page. The page
includes the /NS/Asset/notice.gif
image at the top of the page. If
the $htmlString parameter is not NULL, it
is added to the page after the
notice. The HTML source can be
arbitrarily long and should not
contain the <HTML> or <BODY> begin
or end tags; these tags will be
added by ReturnNotice.
AOLserver uses ReturnNotice
extensively, to achieve a
consistent look on the pages it
automatically generates.
ReturnNotice returns a
status of NS_OK or NS_ERROR.

=item ReturnOk -- Return an "OK" HTTP status line.

Syntax:

    $someInt = $conn->ReturnOK();

Description:

Calls ReturnStatus or
ReturnNotice with a status
code of 200 to indicate that the
request was successful. 

=item ReturnOpenChannel -- Write channel content to conn (not yet)

Syntax:

    $someInt = $conn->ReturnOpenChannel
                      (
                          $statusInt, 
                          $typeString, 
                          $tclChan, 
                          $lengthInt
                      );

Description:

Write $lengthInt bytes of an open Tcl
channel $tclChan out to the $conn. Return
HTTP status in $statusInt and
Content-type in $typeString. 

=item ReturnOpenFd -- Return a file to a client

Syntax:

    $errStatus = $conn->ReturnOpenFile
                        (
                            $statusInt, 
                            $typeString, 
                            $fdInt, 
                            $lengthInt
                        ); 

Description:

The ReturnOpenFd function is
the same as ReturnFile
except that it takes an $fdInt argument
instead of a $filenameString, and it
requires an additional $lengthInt
argument. It returns the entire
contents of the given file to the
client. Ns_ConnReturnOpenFd returns
a status of NS_OK or NS_ERROR. 

=item ReturnOpenFile -- Return a file to a client

Syntax:

int Ns_ConnReturnOpenFile ($statusInt, char *type, FILE *fp, int len); 

    $errStatus = $conn->ReturnOpenFile
                        (
                            $statusInt, 
                            $typeString, 
                            $filestreamFile, 
                            $lengthInt
                        ); 

Description:

The ReturnOpenFile function
is the same as ReturnFile
except that it takes a $filestreamFile (a C FILE *)
argument instead of a $filenameString,
and it requires an additional $lengthInt
argument. It returns the
entire contents of the given file
to the client.
ReturnOpenFile returns a
status of NS_OK or NS_ERROR. 

=item ReturnRedirect -- Return an HTTP redirect response to a client

Syntax:

    $errStatus = $conn->ReturnRedirect($locationString); 

Description:

The ReturnRedirect function
returns a properly formatted HTTP
redirect message for the given
$locationString. This causes the browser
to seamlessly open the new location
on behalf of the user.
ReturnRedirect returns NS_OK
or NS_ERROR. 

=item ReturnStatus -- Return a status message to a client

Syntax:

    $errStatus = $conn->ReturnStatus($statusInt); 

Description:

The ReturnStatus function
calls SetRequiredHeaders
with the given $statusInt and reason
and then immediately calls
FlushHeaders. It can be used
when only the status of the request
must be returned to the client. 

The $statusInt is a standard error code
such as 403 for access denied or
200 for OK. Returns NS_OK or
NS_ERROR. 

=item ReturnUnauthorized -- Return an "unauthorized" HTTP status line.

Syntax:
    
    $someInt = $conn->ReturnUnauthorized();

Description:

Calls ReturnStatus or
ReturnNotice with a status
code of 401 to indicate that the
request did not include a valid
Authorization header or the header
did not specify an authorized user.
The user will usually be prompted
for a username/password after this
status is returned. 

=item RunRequest

Syntax:

    $requestErrStatus = $conn->RunRequest();

Description:

Locate and execute the procedure
for the given method and URL
pattern (in the $conn->request).
Returns a standard request
procedure result, normally NS_OK. 

=item SendChannel -- Send Tcl channel content to conn (not yet)

Syntax:

    $someInt = $conn->SendChannel($tclChan, $lengthInt); 

Description:

Read $lengthInt bytes from an open Tcl
channel $tclChan and write it out to the
conn until EOF. 

=item SendDString -- Write a DString to the conn (not yet, but soon)

Syntax:

int Ns_ConnSendDString (Ns_Conn *conn, Ns_DString *dsPtr); 

    use Aolserver::Ns_DString;

    $dstringToSend = new Aolserver::Ns_Set;

      (... put stuff in $dstringToSend ...)

    $someInt = $conn->SendDString($dstringToSend);

Description:

Write out a DString to the conn.

=item SendFd -- Write file to
connection content

Syntax:

    $errStatus = $conn->SendFd($filedescriptorInt, $lengthInt);

Description:

The SendFd function writes to the connection
$lengthInt bytes from the file referred to
by $filedescriptorInt.
Ns_ConnSendFd returns the status
NS_ERROR or NS_OK. 

=item SendFp -- Write file to connection content

Syntax:

    $errStatus = $conn->SendFp($filestreamFile, $lengthInt); 

Description:

The SendFp function writes to the connection
$lengthInt bytes from the file referred to
by $filestreamFile.
Ns_ConnSendFp returns the status
NS_ERROR or NS_OK. 

=item Server -- Return name of server

Syntax:

    $servernameString = $conn->Server();

Description:

The Server function returns
the name of the server associated
with the connection. 

=item SetExpiresHeader -- Return an "expires" header for the given time

Syntax:

    $conn->SetExpiresHeader($httptimeString);

Description:

The SetExpiresHeader formats
and sends a header that will
expire, using the time specified by
$httptimeString. You can use
the Ns_HttpTime function to
generate $httptimeString. 

=item SetHeaders -- Set the value for a header field

Syntax:

    $conn->SetHeaders($fieldString, $valueString);

Description:

The SetHeaders function sets
the value of $fieldString to $valueString in the output
headers, replacing an existing
field/value pair. 

=item SetLastModifiedHeader -- Return a last modified header using the given time

Syntax:

    $conn->SetLastModifiedHeader($whenTime_T);

Description:

The SetLastModifiedHeader
function formats and sends a
Last-Modified header based on $whenTime_T. 
This $whenTime_T time parameter is
most often generated with the stat
system call on an existing file. 

=item SetLengthHeader -- Return a Content-Length header

Syntax:

    $conn->SetLengthHeader($lengthInt);

Description:

The SetLengthHeader function
formats and sends a Content-Length
header for the given $lengthInt.

=item SetRequiredHeaders -- Return the required HTTP headers

Syntax:

    $conn->SetRequiredHeaders($typeString, $contentlengthInt);

Description:

The SetRequiredHeaders
function writes the required
headers of the HTTP response. If
$typeString is NULL, it defaults to
'text/html'. If $contentlengthInt is 0,
no contentLength header will be
written out. 

The ReturnStatus function
can be used to return a status-only
response to the client. 

=item SetTypeHeader -- Return a Content-Type header

Syntax:

    $conn->SetTypeHeader($typeString);

Description:

The SetTypeHeader function
formats and sends a Content-Type
header for the given $typeString. You can
use the Ns_GuessMimeType() function
to look up a Content-Type string
for filename.

=item Write -- Send data to a client

Syntax:

    $numwrittenOrMinusOne = $conn->Write($storage, $lengthInt);

Description:

The Write function attempts
to write out the specified $lengthInt
of data from $storage to
the client. It returns the number
of bytes sent or -1 if there is an
error. This function may write
fewer than len bytes. 

Example:
 
    # Write length($storage) bytes from $storage.

    # assume $storage is a plain, nonempty perl string

    my $towrite = length($storage);

    while ($towrite > 0) 
    {
        my $nwrote;

        $nwrote = $conn->Write($storage, $towrite);

        if ($nwrote == -1) 
        {
            /* ... handle error ... */
        }

        substr($storage, 0, $nwrote) = "";

        $towrite -= $nwrote;
    }

=item WriteConn -- Send a specified length of data to the client

Syntax:

    $numwrittenOrMinusOne = $conn->WriteConn($storage, $lengthInt);

Description:

The WriteConn function performs
the same function as Write,
except that WriteConn guarantees
to write as many bytes as are
specified in $lengthInt. It writes the
specified length of data from the
buffer to the client. 

=back

=head1 AUTHOR

 Jim Lynch, jwl@debian.org

=head1 CONTRIBUTORS

 Brendan O'Dea <bod@debian.org>

=head1 SEE ALSO

 L<http://www.aolserver.com/>
 perl(1).

=cut
