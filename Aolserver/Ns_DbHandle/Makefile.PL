use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.

@theTypemaps = ("../Ns_DString/typemap", "../Ns_Set/typemap");

WriteMakefile(
    'NAME'	=> 'Aolserver::Ns_DbHandle',
    'VERSION_FROM' => 'Ns_DbHandle.pm', # finds $VERSION
    'LIBS'	=> [''],   # e.g., '-lm' 
    'DEFINE'	=> '',     # e.g., '-DHAVE_SOMETHING' 
    'INC'	=> '-I/usr/local/aolserver/include',     # e.g., '-I/usr/include/other' 
    'OBJECT'    => 'Ns_DbHandle.o Ns_DbHandleMaps.o',
    'TYPEMAPS'	=> \@theTypemaps,
);
