package Aolserver::Ns_Set;

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
		croak "Your vendor has not defined Aolserver::Ns_Set macro $constname";
	}
    }
    no strict 'refs';
    *$AUTOLOAD = sub () { $val };
    goto &$AUTOLOAD;
}

bootstrap Aolserver::Ns_Set $VERSION;

# Preloaded methods go here.

# Autoload methods go after =cut, and are processed by the autosplit program.

1;
__END__

=head1 NAME

Aolserver::Ns_Set - NaviServer, err, Aolserver's associative array

=head1 SYNOPSIS

  use Aolserver::Ns_Set;
  
  $setReferenceHolder = new Aolserver::Ns_Set;
  $setReferenceHolder = Aolserver::Ns_Set->newNamed( <desired name of set> );

  $indexOfFieldInSet = $setReferenceHolder->Put($key, $value);
  $setReferenceHolder->PutValue($index, $value);

  $value = $setReferenceHolder->Get($key);
  $value = $setReferenceHolder->IGet($key);

  $setName = $setReferenceHolder->Name();

  $setReferenceHolder->Delete($indexNumber);
  $setReferenceHolder->DeleteKey($key);
  $setReferenceHolder->IDeleteKey($key);

  $indexNumber = $setReferenceHolder->Find(keyName);
  $indexNumber = $setReferenceHolder->IFind(keyName);

  $keyName = $setReferenceHolder->Key($indexNumber);

  $indexNumber = $setReferenceHolder->Last();

  $isUniqueBoolean = $setReferenceHolder->Unique($keyName);
  $isUniqueBoolean = $setReferenceHolder->IUnique($keyName);

  $size = $setReferenceHolder->Size();

  $valueString = $setReferenceHolder->Value($indexNumber);

  $setReferenceHolder->Update($keyName, $newValueString);

  $setReferenceHolder->Print();

=head1 DESCRIPTION

This module is an encapsulation into a perl class, of the associative array 
type Ns_Set which is exposed by the API of aolserver. (If you don't know 
what aolserver is, you -definitely- don't need this module, and it won't 
work since you probably don't have aolserver.)

NOTE that this module does NO type conversion. That will be added later, 
and will be done -outside- this module.

NOTE also that you need a specially-built perl -and- my nsperl module
for aolserver to make any use of this module. This is -one piece- of a
whole. If you don't know what aolserver is, PLEASE just use a perl
hash; it will work much better and faster. OTOH, if you would like to
explore it, two places to start are http://www.aolserver.com/ and
http://philip.greenspun.com/teaching/.

Each is implemented as a blessed reference (usually "Aolserver::Ns_Set")
to an SvIV, and the IV within points to an Ns_Set. 

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

=over 4

=item new()

Syntax:

  $setReferenceHolder = new Aolserver::Ns_Set;

Allocates all infrastructure (a reference and an SvIV) and calls
Ns_SetCreate() to get a pointer to a newly initialized Ns_Set.
Once this call is made and the infrastructure is
initialized, the Ns_Set is ready for use. 

If the allocation succeeded, new() returns the Ns_Set; otherwise undef
is returned.

Example:

    use Aolserver::Ns_Set;

    $theSet = new Aolserver::Ns_Set;
    # the new() function did everything necessary to 
    # allocate and prepare the set, so $theSet is ready.

(the docs below assume that either new Aolserver::Ns_Set or 
Aolserver::Ns_Set->newNamed produced a value for $theSet.)

=item newNamed()

Syntax:

  $setReferenceHolder = Aolserver::Ns_Set->newNamed( <desired name of set> );

Does everything new() does, and adds the ability to pass a name for the
set, to be stored in the Ns_Set structure. However, I'm pretty sure the 
syntax 

  $s = newNamed Aolserver::Ns_Set("fooper")

is -not- allowed; see example below for working syntax.

Example:

    use Aolserver::Ns_Set;

    # NOTE the syntax of newNamed is different from new!

    $theSet = Aolserver::Ns_Set->newNamed("name of this set");
    # the newNamed() function did everything necessary to 
    # allocate and prepare the set, so $theSet is ready.

(the docs below assume that new Aolserver::Ns_Set or 
Aolserver::Ns_Set->newNamed produced a value for $theSet.)

=item Put()

Syntax/example

  $indexOfFieldInSet = $theSet->Put($key, $value);

Description

Aolserver::Ns_Set::Put adds a new field to a set whose key name is the 
given key and value is the given value. The value of the new field may 
be NULL. 

The index of the new field is returned. 

Internally, Aolserver::Ns_Set::Put calls the aolserver API function
Ns_SetPut, which uses strcpy() to copy the value and uses realloc()
to adjust the size of the fields to accommodate.

=item PutValue()

Syntax/example

  $theSet->PutValue($index, $value);

Description

Aolserver::Ns_Set::PutValue sets the value of the field in $theSet at 
the given index to the new value. Any existing value of the affected 
field overwritten.

If the specified index is greater than the number of fields in the set, 
this function does nothing.

There is no return value as the API function is void.

Internally, Aolserver::Ns_Set::PutValue calls the aolserver API function
Ns_SetPutValue.

=item Get()

Returns the value for a field

Syntax/example

  $value = $theSet->Get($key);

Description

Aolserver::Ns_Set::Get() returns the value of the first field whose key name
matches $key. Ns_SetGet returns NULL if no field is found. If more than
one field in the set has the same key name, Aolserver::Ns_Set::Get returns 
just the first field.

Aolserver::Ns_Set::IGet is this function's case-insensitive counterpart.

=item IGet()

Returns the value for a field ignoring upper/lower case of the key

Syntax/example

  $value = $theSet->IGet($key);

Other than the the fact this method ignores the case of the key, it
is otherwise identical to Aolserver::Ns_Set::Get().

=item Name()

Returns the name of a set 

Syntax/example

  $setName = $theSet->Name();

Aolserver::Ns_Set::Name() returns the name of the set, which may be NULL.

=item Delete()

Removes a field from a set by field index 

Syntax/example:

  $theSet->Delete($indexNumber);

Description:

Aolserver::Ns_Set::Delete() removes the field of the given index from the 
set. Any fields that follow the deleted field are moved up to keep the set 
contiguous.

=item DeleteKey()

Remove a field from a set by key name

Syntax/example:

  $theSet->DeleteKey($key);

Aolserver::Ns_Set::DeleteKey() removes the field whose key name matches the
given key. Any fields that follow the deleted field are moved up to keep the 
set contiguous. If more than one field in the set has the same key name,
Ns_Set-DeleteKey deletes just the first field.

The Ns_SetIDeleteKey function is this function's case-insensitive counterpart.

=item IDeleteKey()

Remove a field from a set by key name, ignoring the upper/lower case of the key

Syntax/example:

  $theSet->IDeleteKey($key);

Other than the the fact this method ignores the case of the key, it
is otherwise identical to Aolserver::Ns_Set::DeleteKey().

=item Find()

Syntax:

  $indexNumber = $theSet->Find(keyName);

Locate the index of a field within an Ns_Set

Aolserver::Ns_Set::Find() returns the index of the first field 
whose key name matches the given key. The index is in C array order, 
i.e., 0 is the index of the first field. If no fields are found, 
Aolserver::Ns_Set::Find() returns -1. If more than one field in the set 
has the same key name, Aolserver::Ns_Set::Find returns just the first 
field index.

Example

    $theSet->Put("Foo", "foovalue");
    $theSet->Put("Bar", "barvalue");

    $index = $theSet->Find("fOO"); # case-sensitive search

    if($index == -1)
    {
	print STDERR "set key Foo not found";
    }
    else
    {
	print STDERR "Value for Foo is " . $theSet->Get("Foo");
    }

=item IFind()

Locate the index of a field within an Ns_Set, ignoring the upper/lower 
case of the key

Syntax

  $indexNumber = $theSet->IFind(keyName);

Description

Aolserver::Ns_Set::IFind() is the case-insensitive counterpart of 
Aolserver::Ns_Set::Find(). It returns the index of the first field 
whose key name matches the given key case-insensitively. The index 
is in C array order, i.e., 0 is the index of the first field. If no 
fields are found, Aolserver::Ns_Set::IFind() returns -1. If more 
than one field in the set has the same key name, Aolserver::Ns_Set::IFind() 
returns just the first field index.

Example

    $theSet->Put("Foo", "foovalue");
    $theSet->Put("Bar", "barvalue");

    $index = $theSet->IFind("Foo"); # case-insensitive search

    if($index == -1)
    {
	print STDERR "set key Foo not found";
    }
    else
    {
	print STDERR "Value for Foo is " . $theSet->Get("Foo");
    }

Other than the the fact this method ignores the case of the key, it
is otherwise identical to Aolserver::Ns_Set::Find().

=item Key()

Return the key name of a field 

Syntax

  $keyName = $theSet->Key($indexNumber);

Description

Aolserver::Ns_Set::Key() returns the field key name of the field at the 
given index.

Example

    $theSet->Put("foo", "foovalue");
    $theSet->Put("bar", "barvalue");
    print STDERR "Key at index 0 is " . $theSet->Key(0) . "\n"; 

=item Last()

Return the index of the last element of a set 

Syntax

  $indexNumber = $theSet->Last();

Description

Aolserver::Ns_Set::Last() returns the index of the last element of the set.

Example

    $theSet->Put("foo", "foovalue");
    $theSet->Put("bar", "barvalue");

    print STDERR "last key is at index " . $theSet->Last() . "\n";

=item Unique()

Check if a key in an Ns_Set is unique (case sensitive) 

Syntax

  $isUniqueBoolean = $theSet->Unique($keyName);

Description

Aolserver::Ns_Set::Unique returns 1 if the specified key is unique in 
the specified set and 0 if it is not. The test for uniqueness is 
performed case-sensitively. 

Example

    $theSet->Put("foo", "foovalue1");
    $theSet->Put("bar", "barvalue1");
    $theSet->Put("foo", "foovalue2");
    $theSet->Put("bar", "barvalue2");
    $theSet->Put("foo", "foovalue3");
    $theSet->Put("bar", "barvalue3");

    print STDERR "the foo key is ";
    print STDERR "not "
        if(! $theSet->Unique("foo"));
    print STDERR "unique.\n";

=item IUnique()

Check if a key in an Ns_Set is unique (case insensitive) 

Other than the the fact this method ignores the case of the key, it
is otherwise identical to Aolserver::Ns_Set::Unique().

Syntax

  $isUniqueBoolean = $theSet->IUnique($keyName);

Description

Aolserver::Ns_Set::IUnique returns 1 if the specified key is unique in 
the specified set and 0 if it is not, -ignoring- upper/lower case of the
key.

Example

    $theSet->Put("foo", "foovalue1");
    $theSet->Put("bar", "barvalue1");
    $theSet->Put("foo", "foovalue2");
    $theSet->Put("bar", "barvalue2");
    $theSet->Put("foo", "foovalue3");
    $theSet->Put("bar", "barvalue3");

    print STDERR "the FOO key (entered as foo) is ";
    print STDERR "not "
        if(! $theSet->IUnique("FOO"));
    print STDERR "unique.\n";

=item Size()

Return the current size of a set 

Syntax:

  $size = $theSet->Size();

Description

Size() returns the current number of fields in a set.

Example

    $theSet->Put("foo", "foovalue1");
    $theSet->Put("bar", "barvalue1");
    $theSet->Put("foo", "foovalue2");
    $theSet->Put("bar", "barvalue2");
    $theSet->Put("foo", "foovalue3");
    $theSet->Put("bar", "barvalue3");

    print STDERR "the set has " . $theSet->Size() . " fields.\n";

=item Value()

Return the value of a field

Syntax:

  $valueString = $theSet->Value($indexNumber);

Description

Value() returns the value of the field at the given index.

Example

    $theSet->Put("foo", "foovalue1");
    $theSet->Put("bar", "barvalue1");
    $theSet->Put("foo", "foovalue2");
    $theSet->Put("bar", "barvalue2");
    $theSet->Put("foo", "foovalue3");
    $theSet->Put("bar", "barvalue3");

    print STDERR "the fourth value is " . $theSet->Value(3) . ".\n";

=item Update()

  $theSet->Update($keyName, $newValueString);

Description

Remove an item from the Ns_Set whose key = key, if one exists, and then re-add
the item with the new value.

Example

    $theSet->Put("foo", "foovalue1");
    $theSet->Put("bar", "barvalue1");
    $theSet->Put("foo", "foovalue2");
    $theSet->Put("bar", "barvalue2");
    $theSet->Put("foo", "foovalue3");
    $theSet->Put("bar", "barvalue3");

    $barIndex = $theSet->Find("bar");

    print STDERR "the first 'bar' field is numbered $barIndex...\n";
    print STDERR 
        "its current value is " . 
        $theSet->Value($barIndex) . 
        "...\n";

    print STDERR "now we replace that value with BARVALUETUE:\n";

    $theSet->Update("bar", "BARVALUETUE");

    print STDERR 
        "and the new value is " . 
        $theSet->Value($barIndex) . 
        "\n";

=item Print()

Prints the contents of the set to the aolserver error log.

Syntax:

  $theSet->Print();

Description

Aolserver::Ns_Set::Print() prints all fields in a set to the AOLserver error 
log file (or the terminal if the AOLserver is running in foreground mode). 
It is useful for debugging.

Example

    $theSet->Put("foo", "foovalue");
    $theSet->Put("bar", "barvalue");

    $theSet->Print();;

=back

=head1 AUTHOR

 Jim Lynch, jwl@debian.org

=head1 CONTRIBUTORS

 Brendan O'Dea <bod@debian.org>

=head1 SEE ALSO

 L<http://www.aolserver.com/>
 perl(1).

=cut
