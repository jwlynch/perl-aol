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
    my $h = "testing";
    $conn = $Aolserver::Ns_Conn::theConn;

    $h = new Aolserver::Ns_DbHandle("jim");

    if($h)
    {
	$out .= "selecting... here is the initial set:\n";
	$set = $h->Select("select * from a");
	if($set)
	{
	  $out .= "set looks like $set\n";
	}
	else
	{
	  $out .= "Select() returned undef\n";
	}

	$out .= "\nkeys are: " . join(", ", keys %$h) . "\n";
	$out .= "the set structure looks like |" . ${$h}{selectRowSet} . "|\n";
	$out .= "the value of that scalar is " . ${${$h}{selectRowSet}} . "\n";

	$out .= "the handle looks like |" . ${$h}{theNs_DbHandle} . "|\n";

	$out .= "\nthe conn looks like |" . $conn . "|\n";
	$out .= "keys are: " . join(", ", keys %$conn) . "\n";
	$out .= "the conn looks like |" . ${$conn}{theNs_Conn} . "|\n";

	$out .= "\ntesting the selectRow placeholder:\n";
	$out .= "the handle is ";
	$out .= "not "
	    unless( $h->InSelectLoop() );
	$out .= "in select loop.\n";
	#$out .= "the select row looks like " . $h->GetSelectRow() . "\n";
	$h->SetSelectRow(42);
	$out .= "the handle is ";
	$out .= "not "
	    unless( $h->InSelectLoop() );
	$out .= "in select loop.\n";
	$out .= "the value of that scalar is " . ${$h->GetSelectRow()} . "\n";

	$h->SetSelectRow(0);
	$out .= "the handle is ";
	$out .= "not "
	    unless( $h->InSelectLoop() );
	$out .= "in select loop.\n";
	$a = $h->GetSelectRow();
	$b = $h->GetSelectRow();
	$c = $h->GetSelectRow();
	$out .= "the rows are:\naaa $a\nbbb $b\nccc $c\n";
	$out .= "the select row looks like " . $h->GetSelectRow() . "\n";
	$out .= "the select row looks like " . $h->GetSelectRow() . "\n";
	$h->DESTROY();
    }

}

$Aolserver::Ns_Conn::theConn->ReturnData(200, $out, -1, "text/plain");

