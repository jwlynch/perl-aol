package Aolserver::Ns_Request;

use strict;
use Carp;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK $AUTOLOAD);

require Exporter;
require DynaLoader;
require AutoLoader;

@ISA = qw(Exporter DynaLoader);
# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.
@EXPORT = qw(
	
);
$VERSION = '0.01';

sub AUTOLOAD {
    # This AUTOLOAD is used to 'autoload' constants from the constant()
    # XS function.  If a constant is not found then control is passed
    # to the AUTOLOAD in AutoLoader.

    my $constname;
    ($constname = $AUTOLOAD) =~ s/.*:://;
    croak "& not defined" if $constname eq 'constant';
    my $val = constant($constname, @_ ? $_[0] : 0);
    if ($! != 0) {
	if ($! =~ /Invalid/) {
	    $AutoLoader::AUTOLOAD = $AUTOLOAD;
	    goto &AutoLoader::AUTOLOAD;
	}
	else {
		croak "Your vendor has not defined Aolserver::Ns_Request macro $constname";
	}
    }
    no strict 'refs';
    *$AUTOLOAD = sub () { $val };
    goto &$AUTOLOAD;
}

bootstrap Aolserver::Ns_Request $VERSION;

# Preloaded methods go here.

# Autoload methods go after =cut, and are processed by the autosplit program.

1;
__END__
# Below is the stub of documentation for your module. You better edit it!

=head1 NAME

Aolserver::Ns_Request - Class encapsulating Aolserver's Ns_Request
                        (Aolserver fills out one when a browser requests
                        something)

=head1 SYNOPSIS

  use Aolserver::Ns_Request;

  $myRequest = $Aolserver::Request::newParseLine($requestLine);

  use Aolserver::Ns_Conn;

  $requestFromBrowser = $Aolserver::Ns_Conn::theConn->Request();

  $request = $requestFromBrowser;

  $request->SetUrl($urlString);

  $string = $request->SkipUrl($numberOfElementsToSkip);

Generally, there is an Ns_Request structure inside an Ns_Conn, and the
only Ns_Conn I know of is the one that comes to a perl script in the var
C<$Aolserver::Ns_Conn::theConn>, and you can use 

  $request = $Aolserver::Ns_Conn::theConn->Request();

to store a local copy of the request from the browser in $request.

=head1 DESCRIPTION

Ns_Request is Aolserver's data structure for storing details of requests
received from browsers. Normally, one comes packaged in the Ns_Conn object
handed off to the perl interpreter (and therefore your perl script) in
the variable C<$Aolserver::Ns_Conn::theConn>.

The methods:

We will use the var $conn to represent a Ns_Conn; since there
seems to only be one, I can be fairly sure that this will remain
definitive:

    $conn = $Aolserver::Ns_Conn::theConn;

Then you can get a request structure (assumed for this doc) into 
$request using the following code:

    $request = $conn->Request(); 

which is similar to the above usage.

According to http://aolserver.com/, "The Ns_Request structure breaks a 
complete HTTP request line into its many parts."

=over 4

=item newParseLine -- creates new Ns_Request object, fills in using HTTP request line

Syntax:

    $request = Aolserver::Ns_Request::newParseLine($httpReqLine);

Description:

Allocates a new Ns_Request and returns it. Parses the argument, assuming
it is an HTTP request line that came from the browser. Fills in the 
new Ns_Request with the results of the parsing. Does this using the API
call Ns_ParseRequest.

=item SetUrl -- Fill in the request structure

Syntax:

    $request->SetUrl($urlString);

Description:

Fills in the request structure, replacing elements with new ones, according to 
the given URL string, here specified by $urlString.

=item SkipUrl -- Skip past path elements in the URL of a request

Syntax:

    $moreRelativeUrlString = $request->SkipUrl($nbrOfElementsToSkip);

Description:

The SkipUrl function returns the request URL after skipping past the 
first $nbrOfElementsToSkip elements.

Example:

    # PathInfo - Request to return URL after the first 2 parts. */
    
    # META: we don't have these $context thingys yet...
    #       all they are are buffers tho

    sub PathInfo
    {
	my ($conn, $context) = @_;

	my $request = $conn->Request();

	my $info;

        /* Skip past the first two parts */
        $info = $request->SkipUrl(2);

        return $conn->ReturnNotice(200, $info, undef); # META: will undef work?
    }

=back

=head1 AUTHOR

Jim Lynch, jim@laney.edu and jwl@debian.org

=head1 SEE ALSO

perl(1)
http://www.aolserver.com/

=cut
