use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    'NAME'	=> 'Aolserver::Ns_DString',
    'VERSION_FROM' => 'Ns_DString.pm', # finds $VERSION
    'LIBS'	=> [''],   # e.g., '-lm' 
    'DEFINE'	=> '',     # e.g., '-DHAVE_SOMETHING' 
    'OBJECT'    => 'Ns_DString.o Ns_DStringMaps.o',
    'INC'	=> '-I/usr/local/aolserver/include',     # e.g., '-I/usr/include/other' 
);
