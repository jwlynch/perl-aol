use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.

@theTypemaps = ("../Ns_DString/typemap", "../Ns_Set/typemap");

WriteMakefile(
    'NAME'		=> 'Aolserver::Ns_Conn',
    'VERSION_FROM'	=> 'Ns_Conn.pm', # finds $VERSION
    'PREREQ_PM'		=> {}, # e.g., Module::Name => 1.1
    'LIBS'		=> [''], # e.g., '-lm'
    'DEFINE'		=> '', # e.g., '-DHAVE_SOMETHING'
    'INC'		=> '-I/usr/local/aolserver/include', # e.g., '-I/usr/include/other'
    'TYPEMAPS'		=> \@theTypemaps,
);
