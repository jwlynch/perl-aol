package Aolserver::Ns_DbHandle;

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
		croak "Your vendor has not defined Aolserver::Ns_DbHandle macro $constname";
	}
    }
    no strict 'refs';
    *$AUTOLOAD = sub () { $val };
    goto &$AUTOLOAD;
}

bootstrap Aolserver::Ns_DbHandle $VERSION;

# Preloaded methods go here.

# Autoload methods go after =cut, and are processed by the autosplit program.

1;
__END__
# Below is the stub of documentation for your module. You better edit it!

=head1 NAME

Aolserver::Ns_DbHandle - encapsulates aolserver's Ns_DbHandle

=head1 SYNOPSIS

  use Aolserver::Ns_DbHandle;
  $dbH = Aolserver::Ns_DbHandle::GetHandle($nameOfPool);

  $rowSet = $dbH->GetOneRowAtMost($sqlCommandString, $howManyRowsCameBack);

=head1 DESCRIPTION

This module encapsulates database connections and intermediate results of
queries. Picking up a handle out of a pool creates an object of this type;
returning the handle to the pool deletes it (but does not close the database
connection). Also, deleting the object returns the enclosed handle to its
pool (this would happen, i.e., when the last scalar reference went out of
scope).

With an object of this class, you can send SQL queries, and see returned
results of those queries (when a result is returned). You can do data
definition (CREATE TABLE, etc), manipulation (INSERT INTO TABLE, UPDATE
TABLE, etc) and queries that return rows of the database. Returned rows
get placed into a special Ns_Set which is handled specially by the system.

You can get exactly one row in a single statement which includes the SQL
string, or at most one row. You can also issue a Select statement which
includes SQL and then iterate over the incoming rows.

The methods:

=over 4

=item GetOneRowAtMost() (note, this calls Ns_Db0or1Row())

SYNTAX

  <scalar Lvalue> =
       <handle object> -> 
                GetOneRowAtMost( <sql string>, <scalar Lvalue nrows> );

 where <scalar Lvalue> is a perl Lvalue that can receive a scalar 
                         (which will be an Ns_Set maybe containing the row),
       <handle object> is a reference to an Aolserver::Ns_DbHandle object,
       <sql string> is the SQL command presumed to produce 
                       at most one row, and
       <scalar Lvalue nrows> is a second perl Lvalue that can receive a
                                scalar, which will be the number of rows
                                actually received.

DESCRIPTION

(Slightly paraphrased from the aolserver C API docs)

GetOneRowAtMost sends the given SQL statement to the database and 
immediately processes the results. On zero rows, a newly allocated 
Ns_Set with its keys set to the column names and values uninitialized 
is returned and nrows is set to 0. On one row, a newly allocated Ns_Set 
containing the values is returned and nrows is set to 1. You must eventually 
free this row using Ns_SetFree.

Note that an SQL select statement that does not return a row is different 
from an SQL DML statement that does not return a row but modifies the 
database. In the former case, GetOneRowAtMost still returns a newly allocated 
Ns_Set with the column names as the field key names of the rows that would 
have been returned had any of the rows in the database matched the select 
criteria. In the latter case, GetOneRowAtMost returns an error.

If the SQL statement returns more than one row or some database error occurs, 
GetOneRowAtMost returns NULL. Detailed error messages may have accumulated in 
an internal buffer in the Ns_DbHandle.

Examples

(meta: this is the orig C example; rewrite)

    Ns_Set *row;
    int nrows;
    Ns_DbHandle *handle;
    if ((handle = Ns_DbPoolGetHandle("aPoolName")) != NULL) {
        row = Ns_Db0or1Row(handle, "select aName from aTable",
                                                        &nrows);
        if (row != NULL && nrows == 1) {
                char *value;
                value = Ns_SetGet(row, "aName");
                /* use `value' here */
                Ns_SetFree(row);
        }
    } 

=back

=head1 AUTHOR

Jim Lynch, jwl@debian.org

=head1 SEE ALSO

perl(1).

=cut
