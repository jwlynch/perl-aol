package Aolserver::Ns_DString;

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
		croak "Your vendor has not defined Aolserver::Ns_DString macro $constname";
	}
    }
    no strict 'refs';
    *$AUTOLOAD = sub () { $val };
    goto &$AUTOLOAD;
}

bootstrap Aolserver::Ns_DString $VERSION;

# Preloaded methods go here.

# Autoload methods go after =cut, and are processed by the autosplit program.

1;
__END__
# Below is the stub of documentation for your module. You better edit it!

=head1 NAME

Aolserver::Ns_DString - Class encapsulating Aolserver's Ns_DString 
                        (Aolserver "dynamic strings")

=head1 SYNOPSIS

 use Aolserver::Ns_DString;

 $a = new Aolserver::Ns_DString;
 $a->Append("string value");
 $a->Trunc($desiredLength);
 print $a->Value(), $a->Length();

=head1 DESCRIPTION

This is a wrapper class for the C type Ns_DString, defined in aolserver.

This is one of many essential parts of an overall project to glue perl
and aolserver together in a very efficient (but maybe too C-like) way.

If you don't know what aolserver is, this is probably useless to you.

This was created as an OOP class with methods that directly calls the
aolserver api functions that deal with Ns_DString instances.

THey are implemented as a blessed reference (usually "Aolserver::Ns_DString")
to an SvIV, and the IV within points to an Ns_DString. (Thanks to Brendan
O'Dea (bod) for the implementation of new(char*) and the typemap, -important- 
contributions because together they define how instances are allocated, and 
they allow xsubs to be written in terms of C types.)

Questions about this module to jim@laney.edu -only- after you read, think
about and experiment with this module. No questions taken without this.
(And -please- don't bother bod, he's not familiar with the whole project.)

The list of functions follows here:

=over 4

=item new()

Allocates all infrastructure (a reference and an SvIV) and storage
big enough to hold an Ns_DString, and initializes it using the call
Ns_DStringInit. Once this call is made and the infrastructure is
initialized, the Ns_DString is ready for use.

Example:

    use Aolserver::Ns_DString;

    $ds = new Aolserver::Ns_DString;
    # the new() function called the Ns_DStringInit() automatically,
    # so $ds is ready.

=item Value()

Returns the current value of the Ns_DString as a perl string. Does not 
change the Ns_DString.

Syntax/example

    print $ds->Value();
    $perlString = $ds->Value;

=item Append()

Takes a string argument and appends it to the Ns_DString. Returns the
new value of the Ns_DString as a perl string.

Syntax/example

    use Aolserver::Ns_DString;

    $ds = new Aolserver::Ns_DString;
    
    print $ds->Append("hi");
    print $ds->Append(" ");
    print $ds->Append("there");

=item NAppend()

Takes a string argument and appends the first N characters of that argument
to the Ns_DString. Returns the new value of the Ns_DString as a perl string.

Syntax/example

    use Aolserver::Ns_DString;

    $ds = new Aolserver::Ns_DString;
    
    $ds->Append("hi");
    $ds->Append(" ");
    $ds->Append("there");
    $ds->Append(" ");

    print $ds->NAppend("1234567890", 5);

=item Length()

Returns the length of the string stored in the Ns_DString.

Syntax/example

    use Aolserver::Ns_DString;

    $ds = new Aolserver::Ns_DString;
    
    $ds->Append("hi");
    $ds->Append(" ");
    $ds->Append("there");

    print $ds->Length();

=item Trunc()

Truncate an Ns_DString 

Syntax:

    $ds->Append("1234567890");
    $ds->Trunc(5);

Description:

Aolserver::Trunc truncates an Ns_DString to the given length. 
Unlike Ns_DStringFree, which truncates the Ns_DString to length 0 and frees 
any memory that may have been allocated on the heap, Ns_DStringTrunc allows
you to truncate the string to any length. It maintains any memory allocated 
on the heap. This function is useful in a loop where the Ns_DString is likely 
to overflow the static space each time through. Using Aolserver::Trunc instead 
of Ns_DStringFree will avoid having the Ns_DString call malloc to obtain the 
additional space in each iteration. 

Example:

    my $ds = new Aolserver::Ns_DString;
    my $i;
    
    for ($i=0; $i < 50; $i++) {
        $ds->Append("aBigString" . $i);
        # do something with $ds, constructed above
        $ds->Trunc(0);
    }

=head1 OBPOEM

 Blah blah blah, spam spam spam.
 Yadda yadda yadda yadda sis boom bam. 

A non-haiku 1/4th of which was written by the author of the stub, and
the remaining 3/4ths by jwl.

=head1 AUTHOR

 Jim Lynch <jwl@debian.org>, methods and design
 Brendan O'Dea <bod@debian.org> designed and wrote new().

=head1 SEE ALSO

perl(1), http://www.aolserver.com/

=cut
