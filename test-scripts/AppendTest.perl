use Aolserver::Ns_DString;
use Aolserver::Ns_Conn;

$out = "I could write a file OR a connection!\n";

$a = new Aolserver::Ns_DString;
foreach $b (1, "tue", 33, "4our", "10/2") { $a->Append($b); }
$out .= $a->Value() . "\n";

$Aolserver::Ns_Conn::theConn->ReturnData(200, $out, -1, "text/plain");
