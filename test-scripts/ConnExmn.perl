use Aolserver::Ns_Set;
use Aolserver::Ns_DString;
use Aolserver::Ns_Conn;

$out = "";

$out .= "The connection looks like |$Aolserver::Ns_Conn::theConn|\n";
$out .= "keys: " . join(",", keys %$Aolserver::Ns_Conn::theConn) . "\n\n";

$headers = ${$Aolserver::Ns_Conn::theConn}{"headers"};

$out .= "the headers set ";
if($headers->Size() == 0)
{
    $out .= "is empty\n";
}
else
{
    $out .= "has the following " . $headers->Size() . " entries:\n";
}

foreach $i (0 .. $headers->Last() )
{
    $out .= "$i ." . " this set{" . $headers->Key($i) . "}=";
    $out .= $headers->Value($i);
    $out .= "\n";
}

$Aolserver::Ns_Conn::theConn->ReturnData(200, $out, -1, "text/plain");

