use Aolserver::Ns_Set;
use Aolserver::Ns_DString;
use Aolserver::Ns_Conn;


# synopsis: $string = StringifySet(set);
sub StringifySet
{
    my ($set) = @_;
    
    my $last = $set->Last();
    my $i;
    my $name;
    my $out = "";

    $out .= $set->Name() . ":\n";

    for($i = 0; $i < $last; $i++)
    {
        $out .= "   " . $set->Key($i) . "=" . $set->Value($i) . "\n";
    }

    return $out;
}

$out = "";

{
    $out .= "\n=== new(), Put(), Find(), Print() ===\n\n";

    my $set = new Aolserver::Ns_Set();

    $set->Put("a", "ayyyyy!");
    $set->Put("a", "beeee!");

    $out .= "find 'a' in the set is " . $set->Find("a") . "\n";

    $out .= StringifySet($set);
}

{
    $out .= "\n=== newNamed(), Print() shows set name ===\n\n";

    my $fooSet = Aolserver::Ns_Set->newNamed("foo");

    $fooSet->Put("a", 1);
    $fooSet->Put("b", 2);
    $fooSet->Put("c", 3);

    $out .= StringifySet($fooSet);
}

$out .= "I could write to a connection!\n";


{
    $out .= "\n=== Ns_DString::Append, Ns_DString::Value ===\n\n";
    my $a = new Aolserver::Ns_DString;
    foreach my $b (1, "tue", 33, "4our", "10/2") { $a->Append($b); }
    $out .= $a->Value() . "\n";
}

{
    $out .= "\n=== Put(), Value(), PutValue(), Get(), IGet() ===\n\n";

    my $theSet = new Aolserver::Ns_Set;

    $indexOfFieldInSet = $theSet->Put("keee", "valle you");

    $out .= 
        "the value is " . 
        $theSet->Value($indexOfFieldInSet) . 
        "\n";

    $theSet->PutValue($indexOfFieldInSet, "nu valle you");

    $out .= 
        "the new value is " . 
        $theSet->Value($indexOfFieldInSet) . 
        "\n";

    $out .= 
        "and we can also get it using Get: " .
        $theSet->Get("keee") .
        "\n";

    $out .= 
        "or using IGet: " .
        $theSet->IGet("KEEE") .
        "\n";
}

{
    $out .= "\n=== Delete(3) ===\n\n";
    my $theSet = new Aolserver::Ns_Set;

    $theSet->Put("foo", "foovalue1");
    $theSet->Put("bar", "barvalue1");
    $theSet->Put("foo", "foovalue2");
    $theSet->Put("bar", "barvalue2");
    $theSet->Put("foo", "foovalue3");
    $theSet->Put("bar", "barvalue3");

    $out .= StringifySet($theSet);

    $theSet->Delete(3);

    $out .= StringifySet($theSet);
}

{
    $out .= "=== Put(), Print(), DeleteKey() ===\n\n";
    my $theSet = new Aolserver::Ns_Set;

    $theSet->Put("foo", "foovalue1");
    $theSet->Put("bar", "barvalue1");
    $theSet->Put("foo", "foovalue2");
    $theSet->Put("bar", "barvalue2");
    $theSet->Put("foo", "foovalue3");
    $theSet->Put("bar", "barvalue3");

    $out .= StringifySet($theSet);

    $theSet->DeleteKey("bar");

    $out .= StringifySet($theSet);

    $theSet->DeleteKey("bar");

    $out .= StringifySet($theSet);

    $theSet->DeleteKey("bar");

    $out .= StringifySet($theSet);
}

{
    $out .= "=== Put(), Print(), IDeleteKey() ===\n\n";
    my $theSet = new Aolserver::Ns_Set;

    $theSet->Put("foo", "foovalue1");
    $theSet->Put("bar", "barvalue1");
    $theSet->Put("foo", "foovalue2");
    $theSet->Put("bar", "barvalue2");
    $theSet->Put("foo", "foovalue3");
    $theSet->Put("bar", "barvalue3");

    $out .= StringifySet($theSet);

    $theSet->IDeleteKey("BaR");

    $out .= StringifySet($theSet);

    $theSet->IDeleteKey("BAr");

    $out .= StringifySet($theSet);

    $theSet->IDeleteKey("bAR");

    $out .= StringifySet($theSet);
}

{
    $out .= "=== failing Find ===\n\n";

    my $theSet = new Aolserver::Ns_Set;

    $theSet->Put("Foo", "foovalue");
    $theSet->Put("Bar", "barvalue");

    $index = $theSet->Find("fOO"); # case-sensitive search

    if($index == -1)
    {
        $out .= "set key fOO not found\n";
    }
    else
    {
        $out .= "Value for Foo is " . $theSet->Get("Foo") . "\n";
    }

    $out .= "=== succeeding Find ===\n\n";

    $index = $theSet->Find("Foo"); # case-sensitive search

    if($index == -1)
    {
        $out .= "set key Foo not found\n";
    }
    else
    {
        $out .= "Value for Foo is " . $theSet->Get("Foo") . "\n";
    }

}

{
    $out .= "=== IFind ===\n\n";

    my $theSet = new Aolserver::Ns_Set;

    $theSet->Put("Foo", "foovalue");
    $theSet->Put("Bar", "barvalue");

    $index = $theSet->IFind("fOo"); # case-insensitive search

    if($index == -1)
    {
        $out .= "set key Foo not found\n";
    }
    else
    {
        $out .= "Value for Foo is " . $theSet->Get("Foo") . "\n";
    }
}

{
    $out .= "=== Key() ===\n\n";

    my $theSet = new Aolserver::Ns_Set;

    $theSet->Put("foo", "foovalue");
    $theSet->Put("bar", "barvalue");
    $out .= "Key at index 0 is " . $theSet->Key(0) . "\n";
    $out .= "Key at index 1 is " . $theSet->Key(1) . "\n";
}

{
    $out .= "=== Last() ===\n\n";
    my $theSet = new Aolserver::Ns_Set;

    $theSet->Put("foo", "foovalue1");
    $theSet->Put("bar", "barvalue1");
    $theSet->Put("foo", "foovalue2");
    $theSet->Put("bar", "barvalue2");
    $theSet->Put("foo", "foovalue3");
    $theSet->Put("bar", "barvalue3");

    $out .= "last index is " . $theSet->Last() . "\n";
}

{
    $out .= "=== Unique() ===\n\n";
    my $theSet = new Aolserver::Ns_Set;

    $theSet->Put("foo", "foovalue1");
    $theSet->Put("foo", "foovalue2");
    $theSet->Put("bar", "barvalue1");

    $fooUnique = $theSet->Unique("foo");
    $barUnique = $theSet->Unique("bar");

    $out .= "foo is " . (($fooUnique) ? "" : "not ") . "unique\n";
    $out .= "bar is " . (($barUnique) ? "" : "not ") . "unique\n";
}

{
    $out .= "=== IUnique() ===\n\n";
    my $theSet = new Aolserver::Ns_Set;

    $theSet->Put("foo", "foovalue1");
    $theSet->Put("foo", "foovalue2");
    $theSet->Put("bar", "barvalue1");

    $fooUnique = $theSet->IUnique("FOO");
    $barUnique = $theSet->IUnique("BAR");

    $out .= "FOO is " . (($fooUnique) ? "" : "not ") . "unique\n";
    $out .= "BAR is " . (($barUnique) ? "" : "not ") . "unique\n";
}

{
    $out .= "=== Size() ===\n\n";
    my $theSet1 = new Aolserver::Ns_Set;

    $theSet1->Put("foo", "foovalue1");
    $theSet1->Put("bar", "barvalue1");
    $theSet1->Put("foo", "foovalue2");
    $theSet1->Put("bar", "barvalue2");
    $theSet1->Put("foo", "foovalue3");
    $theSet1->Put("bar", "barvalue3");

    $out .= "size is " . $theSet1->Size() . "\n";

    my $theSet2 = new Aolserver::Ns_Set;

    $theSet2->Put("foo", "foovalue1");
    $theSet2->Put("foo", "foovalue2");
    $theSet2->Put("bar", "barvalue1");

    $out .= "size is " . $theSet2->Size() . "\n";
}

{
    $out .= "=== Update() ===\n\n";
    my $theSet = new Aolserver::Ns_Set;

    $theSet->Put("foo", "foovalue1");
    $theSet->Put("foo", "foovalue2");
    $theSet->Put("bar", "barvalue1");

    $out .= "before\n";
    $out .= StringifySet($theSet);

    $theSet->Update("foo", "FU VAL YUE TU");
    $theSet->Update("bar", "BARRE VAL YUE TU");

    $out .= "after\n";
    $out .= StringifySet($theSet);
}

# $Aolserver::Ns_Conn::theConn->ReturnData(200, $out, -1, "text/plain");

open FH, "> /web/nusvr324/www/perl/aFile";
print FH $out;
close FH;