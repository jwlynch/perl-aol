use Aolserver::Ns_Set;
use Aolserver::Ns_DString;
use Aolserver::Ns_Conn;
use Aolserver::Ns_Request;

$out .= "\ntesting Aolserver::Ns_Request->SkipUrl():\n";

$request = $Aolserver::Ns_Conn::theConn->Request();

$out .= "skippy 0 " . $request->SkipUrl(0) . "\n";
$out .= "skippy 1 " . $request->SkipUrl(1) . "\n";
$out .= "skippy 2 " . $request->SkipUrl(2) . "\nRuling out alterations:\n";

$out .= "skippy 0 " . $request->SkipUrl(0) . "\n";
$out .= "skippy 1 " . $request->SkipUrl(1) . "\n";
$out .= "skippy 2 " . $request->SkipUrl(2) . "\n";

$Aolserver::Ns_Conn::theConn->ReturnData(200, $out, length $out, "text/plain");

