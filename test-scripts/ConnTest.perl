use Aolserver::Ns_Set;
use Aolserver::Ns_DString;
use Aolserver::Ns_Conn;
use Aolserver::Ns_Request;

# synopsis: $string = StringifySet(set);  or  print StringifySet(set);
sub StringifySet
{
    my ($set) = @_;
    
    my $last = $set->Last();
    my $size = $set->Size();
    my $i;
    my $name = $set->Name();
    my $out = "";

    $out .= "$name: ";

    if($size == 0)
    {
        $out .= "(empty)\n";
    }
    else
    {
	my $entries = ($size == 1) ? "entry" : "entries";
        $out .= "($size $entries)\n";
    }

    foreach $i (0 .. $last)
    {
        $out .= "   " . $set->Key($i) . "=" . $set->Value($i) . "\n";
    }

    return $out;
}

$conn = $Aolserver::Ns_Conn::theConn;

$name = $conn->Server();

$out .= "this server seems to be $name\n";

$out .= $name . "'s AuthPasswd is |" . $conn->AuthPasswd() . "|\n";

$out .= $name . "'s AuthUser is |" . $conn->AuthUser() . "|\n";

$out .= $name . "'s content length of this connection is |" . $conn->ContentLength() . "|\n";

$out .= $name . "'s ContentSent is |" . ($conn->ContentSent() ? "true" : "false") . "|\n";

$out .= $name . "'s DriverName is |" . $conn->DriverName() . "|\n";

# NOTE: GetQuery is unsafe!! (maybe not anymore...)
# alter this XSub to use Ns_SetCopy and return the copy. (done)
#
$queryDataSet = $conn->GetQuery();

$out .= $name . "'s query is:\n" . StringifySet($queryDataSet) . "\n";

$out .= $name . "'s Headers is:\n" . StringifySet($conn->Headers()) . "\n";

$out .= 
    $name . 
    "'s OutputHeaders is\n" . 
    StringifySet($conn->OutputHeaders()) .
    "\n";

$out .= $name . "'s Host is |" . $conn->Host() . "|\n";

$out .= $name . "'s Location is |" . $conn->Location() . "|\n";

$out .= $name . "'s Peer is |" . $conn->Peer() . "|\n";

$out .= $name . "'s PeerPort is |" . $conn->PeerPort() . "|\n";

$out .= $name . "'s Port is |" . $conn->Port() . "|\n";

$out .= $name . "'s ResponseLength is |" . $conn->ResponseLength() . "|\n";

$out .= $name . "'s ResponseStatus is |" . $conn->ResponseStatus() . "|\n";

# $out .= $name . "'s  is |" . $conn->() . "|\n";

# $out .= $name . "'s  is |" . $conn->() . "|\n";

# $out .= $name . "'s  is |" . $conn->() . "|\n";

# $out .= $name . "'s  is |" . $conn->() . "|\n";

# $out .= $name . "'s  is |" . $conn->() . "|\n";

# $out .= $name . "'s  is |" . $conn->() . "|\n";

# $out .= $name . "'s  is |" . $conn->() . "|\n";

# $out .= $name . "'s  is |" . $conn->() . "|\n";

# $out .= $name . "'s  is |" . $conn->() . "|\n";

# $out .= $name . "'s  is |" . $conn->() . "|\n";

# $out .= $name . "'s  is |" . $conn->() . "|\n";

# $out .= $name . "'s  is |" . $conn->() . "|\n";

# $out .= $name . "'s  is |" . $conn->() . "|\n";

# $out .= $name . "'s  is |" . $conn->() . "|\n";

# $out .= $name . "'s  is |" . $conn->() . "|\n";

# $out .= $name . "'s  is |" . $conn->() . "|\n";

# $out .= $name . "'s  is |" . $conn->() . "|\n";

# $out .= $name . "'s  is |" . $conn->() . "|\n";

# $out .= $name . "'s  is |" . $conn->() . "|\n";

# $out .= $name . "'s  is |" . $conn->() . "|\n";

# $out .= $name . "'s  is |" . $conn->() . "|\n";

# $out .= $name . "'s  is |" . $conn->() . "|\n";

# $out .= $name . "'s  is |" . $conn->() . "|\n";

# $out .= $name . "'s  is |" . $conn->() . "|\n";

# $out .= $name . "'s  is |" . $conn->() . "|\n";

# $out .= $name . "'s  is |" . $conn->() . "|\n";

# $out .= $name . "'s  is |" . $conn->() . "|\n";

# $out .= $name . "'s  is |" . $conn->() . "|\n";

# $out .= $name . "'s  is |" . $conn->() . "|\n";

# $out .= $name . "'s  is |" . $conn->() . "|\n";

# $out .= $name . "'s  is |" . $conn->() . "|\n";

# $out .= $name . "'s  is |" . $conn->() . "|\n";

# $out .= $name . "'s  is |" . $conn->() . "|\n";

# $out .= $name . "'s  is |" . $conn->() . "|\n";

# $out .= $name . "'s  is |" . $conn->() . "|\n";

# $out .= $name . "'s  is |" . $conn->() . "|\n";

# $out .= $name . "'s  is |" . $conn->() . "|\n";

# $out .= $name . "'s  is |" . $conn->() . "|\n";

# $out .= $name . "'s  is |" . $conn->() . "|\n";

# $out .= $name . "'s  is |" . $conn->() . "|\n";

# $out .= $name . "'s  is |" . $conn->() . "|\n";

# $out .= $name . "'s  is |" . $conn->() . "|\n";

# $out .= $name . "'s  is |" . $conn->() . "|\n";

# $out .= $name . "'s  is |" . $conn->() . "|\n";

# $out .= $name . "'s  is |" . $conn->() . "|\n";

# $out .= $name . "'s  is |" . $conn->() . "|\n";

# $out .= $name . "'s  is |" . $conn->() . "|\n";

# $out .= $name . "'s  is |" . $conn->() . "|\n";

# $out .= $name . "'s  is |" . $conn->() . "|\n";

# $out .= $name . "'s  is |" . $conn->() . "|\n";

# $out .= $name . "'s  is |" . $conn->() . "|\n";

$Aolserver::Ns_Conn::theConn->ReturnData(200, $out, length $out, "text/plain");

