use Aolserver::Ns_Set;
use Aolserver::Ns_DString;
use Aolserver::Ns_Conn;
use Aolserver::Ns_DbHandle;


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

$out = "";

{
    my $set;
    my $h = "testing";
    $conn = $Aolserver::Ns_Conn::theConn;

    $h = new Aolserver::Ns_DbHandle("main");

    if($h)
    {
	$out .= "selecting... here is the initial set:\n";
	$set = $h->Select("select * from a");

	$h->GetRow($set);
	
	$out .= StringifySet($set);

	$h->DESTROY();
    }

}

$Aolserver::Ns_Conn::theConn->ReturnData(200, $out, -1, "text/plain");

