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
includes SQL and then iterate over the matching rows.

The methods:

=over 4

=item new()

Overview

Creates a new object which encapsulates Aolserver's Ns_DbHandle data structure.
It gets the Ns_DbHandle from a pool of existing handles.

SYNTAX

  <scalar Lvalue> = new Aolserver::Ns_DbHandle ( <pool name string> );

 where <scalar Lvalue> is a perl Lvalue that can receive a scalar
                         (which will be the new handle object), and
       <pool name string> is a string containing the name of the desired
                          pool. Said pool must exist.

DESCRIPTION

The new() method allocates and constructs a perl object to hold a database
connection handle. The handle returned can then be used to query and modify
the database. The actual connection object is pulled from a pool of existing
live connections to the database; when destroyed, it returns the connection
to the pool.

Upon success, you get a handle; if it fails, new() returns undef.

It's constructed in such a way that when it goes out of scope, it's
deallocated.

=item BindRow()

Overview

Return an Ns_Set structure of column names to be returned by 
the previously-executed (i.e., using Exec) SQL command 

SYNTAX

  <scalar Lvalue> =
       <handle object> -> 
                BindRow();

 where <scalar Lvalue> is a perl Lvalue that can receive a scalar
                         (which will be an Ns_Set maybe containing the row),
       <handle object> is a reference to an Aolserver::Ns_DbHandle object.

DESCRIPTION

The BindRow method returns an Ns_Set structure whose key names are the 
column names of rows to be returned by the SQL command previously-executed 
by Exec. If the SQL command does not return rows (i.e., the Exec method 
did not return NS_ROWS), NS_ERROR is returned.

=item Cancel()

Overview

Cancel an active SQL select statement (which would have been initiated
by the Select() method)

SYNTAX

  <scalar Lvalue> =
       <handle object> -> 
                Cancel();

 where <scalar Lvalue> is a perl Lvalue that can receive a scalar 
                         (which will be an error/success code),
       <handle object> is a reference to an Aolserver::Ns_DbHandle object, and

DESCRIPTION

The Cancel method is similar to the Ns_DbFlush function, but instead of 
allowing the select statement to complete and send all selected rows, 
Cancel sends a cancels message to the database. This can result in 
faster interruption of a long-running query. Cancel returns NS_OK 
on success and NS_ERROR on error.

=item Exec()

Overview

Execute any arbitrary SQL command 

SYNTAX

  <scalar LValue> = 
       <handle object> -> 
                Exec( <sql string> );

Description

The Exec method executes the specified SQL command on the specified 
database connection. Exec returns one of the following status codes: 

 NS_ERROR  if the SQL command fails
 NS_DML    if the SQL command is DML (Data Manipulation Language) 
              or DDL (Data Definition Language) 
 NS_ROWS   if the SQL command will return rows (such as a SELECT command)

This function allows you to write a true ad hoc query tool and process SQL 
statements without knowing ahead of time if they return rows or are DDL or 
DML statements.

=item ExecDML() (note, calls Ns_DbDML())

Overview

Execute an SQL DML statement 

Syntax

  <scalar Lvalue> = <handle object> -> ExecDML( <sql string> );

 where <scalar Lvalue> is a perl Lvalue that can receive a scalar 
                         (which will be an error/success code),
       <handle object> is a reference to an Aolserver::Ns_DbHandle object, and

Description

The ExecDML function executes SQL that should be a data manipulation 
language statement such as an insert or update, or data definition 
language such as a create table. If the statement was executed 
successfully, ExecDML returns NS_OK. If the statement results in rows 
being returned or a database error, ExecDML returns NS_ERROR. 

Detailed error messages may have accumulated in an internal buffer in 
the Ns_DbHandle.

Examples

[META: convert to perl]

    my $handle = new Aolserver::Ns_DbHandle("aPoolName");
    my $status;

    if ($handle) 
    {
        $status = $handle->ExecDML
                ("insert into aTable (colName1,colName2) values (1,2)");

        if ($status != NS_OK) 
        {
                # handle error condition
        }

        $handle->DESTROY(); # this should not be necessary... for now it is tho
    }

=item Flush()

Overview

Flush any waiting rows 


Syntax

    int Ns_DbFlush(
    Ns_DbHandle *handle
    );

Description

The Flush method fetches and dumps any waiting rows after a call of the 
Select() method. This function is useful when you have already fetched 
all the rows you intend to process. Flush returns NS_OK after successfully 
flushing the database or NS_ERROR on error.

Flush is called automatically when Ns_DbHandle's are returned to their 
pools with Aolserver::NsDbHandle's DESTROY method, which calls the
Ns_DbPutHandle() function to make sure the handle is ready the next time 
it is used.

Some database drivers will also cancel any active transactions when 
Flush() is called.

=item GetRow

Overview

Fetch the next waiting row after a Select() call has been made.

SYNTAX

    <scalar Lvalue> = <handle object> -> GetRow( <scalar containing row> );

 where <scalar Lvalue> is a perl Lvalue that can receive a scalar 
                         (which will be an error/success code),
       <handle object> is a reference to an Aolserver::Ns_DbHandle object, and
       <scalar containing row> contains the row object that was output from
                                 the Select() method

Description

The GetRow method fetches the next row waiting to be retrieved after 
a Select(). The row Ns_Set must be the result of a previous Select. 
GetRow frees any existing values of the set and sets the values to 
the next row fetched from the database. Possible return values are: 

 NS_OK       A row has been fetched and more rows may be waiting.
 NS_END_DATA No row has been fetched and there are no more rows waiting.
 NS_ERROR    A database error occurred, or the function has already 
             returned NS_END_DATA but has been called again anyway.

You cannot call ExecDML, GetOneRow, or GetOneRowAtMost with the same 
database handle while fetching rows from the database in a GetRow 
loop. Doing so Cancel()s any waiting rows and a subsequent call to GetRow 
will fail. You -can- do so, however, if you use separate database handles.

Note, if the handle is not presently in "select/getrow loop mode" (i.e.,
if InSelectLoop() returns false), this is an error and the API function
is not called. NS_ERROR is returned.

If the row set presented to GetRow() is not the one returned by Select(), 
this is also an error; again, NS_ERROR is returned, and the call to the 
API function Ns_DbHandleGetRow() is prevented.

Examples

        my $handle;
        my $row;
        my $status;

        $handle = new Aolserver::Ns_DbHandle("mypool");

        $row = $handle->Select("select * from mytable");
        if (! $handle->InSelectLoop()) 
        {
                # ... handle select error ...
        }

        while ( ($status = $handle->GetRow($row)) == NS_OK) 
        {
                # ... process the row fetched from the database ...
        }

        if ($status != NS_END_DATA) 
        {
                # ... handle get row error ...
        }

=item GetOneRow() (note, this calls Ns_Db1Row())

Overview

Execute an SQL statement that must return one row 

SYNTAX

  <scalar Lvalue> =
       <handle object> -> 
                GetOneRow( <sql string> );

 where <scalar Lvalue> is a perl Lvalue that can receive a scalar 
                         (which will be an Ns_Set maybe containing the row),
       <handle object> is a reference to an Aolserver::Ns_DbHandle object, and
       <sql string> is the SQL command presumed to produce 
                       exactly one row.

DESCRIPTION

The GetOneRow method calls the Ns_Db0or1Row function with the given SQL 
statement. If Ns_Db0or1Row returns 1 row, GetOneRow returns the newly 
allocated Ns_Set for the row. Under normal conditions, the row set will
be freed for you automatically. If NsDb0or1Row returns zero rows, GetOneRow 
returns undef.

If the SQL statement returns zero rows or a database error has occurred, 
GetOneRow returns undef. Detailed error messages may have accumulated in 
an internal buffer in the Ns_DbHandle.

Examples

    my $row;
    my $handle = new Aolserver::Ns_DbHandle("aPoolName");
    
    if ($handle) 
    {
        $row = $handle->GetOneRow( "select aName from aTable" );

        if ($row) 
        {
            my $value = $row->Get("aName");
            # (use $value here)
        }

        $handle->DESTROY(); # this should not be necessary... for now it is tho
    } 
    
=item GetOneRowAtMost() (note, this calls Ns_Db0or1Row())

Overview

Execute an SQL statement that must return at most 1 row 

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

    my $row;
    my $nrows;
    my $handle = new Aolserver::Ns_DbHandle("main");
    if ($handle)
    {
     	$row =
            $handle->GetOneRowAtMost("select aValue from aTable", $nrows);

	if ($row && $nrows == 1)
	{
            my $value;
            $value = $row->Get("aValue");

            # (use $value somehow here)
            
            # note, set in $row will be freed when $row goes out of scope
	}

        $handle->DESTROY(); # this should not be necessary... for now it is tho
    }

=item GetSelectRow

Overview

Returns the stored perl infrastructure which (might) wrap around a database
row represented as an Ns_Set structure.

SYNTAX

  <scalar Lvalue> = <handle object> -> GetSelectRow();

 where <scalar Lvalue> is a perl Lvalue that can receive a scalar (which 
                         will be an Ns_Set maybe containing the row), and
       <handle object> is a reference to an Aolserver::Ns_DbHandle object.

DESCRIPTION

This function returns a pointer to the stored perl infrastructure of the
database row, whose lifespan is the same as the database handle wrapping.

Some details:

The perl wrapping of aolserver's Ns_DbHandle was designed to hold the row
being iterated upon by Select() and GetRow(). The reason for the special
handling, is that the docs said that the row structure is statically
allocated, and no attempt should be made to alter or free it; normally,
the Ns_Set perl wrapping would free it, so that had to be prevented.

=item InterpretSqlFile

=item InSelectLoop

Overview

Returns a true value, if Select() has been successfully been called on the
handle, and there may be more rows available which match the select
criteria. Returns false if it's not possible to get more rows with GetRow().

SYNTAX

  <scalar Lvalue> = 
       <handle object> -> InSelectLoop();

 where <scalar Lvalue> is a perl Lvalue that can receive a scalar 
                         (which will be a true/false value), and
       <handle object> is a reference to an Aolserver::Ns_DbHandle object.

=item Select

Overview

Stores a pointer to an un-wrapped C structure Ns_Set into the stored perl
infrastructure representing the select row to perl. Not normally used 
other than by developers of perl-aol.

SYNTAX

       <handle object> -> SetSelectRow( <Ns_Set pointer> );

 where <handle object> is a reference to an Aolserver::Ns_DbHandle object, and
       <Ns_Set pointer> is a pointer to the C Ns_Set structure.

=item DESTROY

=back

=head1 BUGS

None presently known; the handle leak bug has been solved.

=head1 AUTHOR

Jim Lynch, jwl@debian.org

=head1 SEE ALSO

perl(1).

=cut
