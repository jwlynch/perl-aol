PERL = perl-thread
PERLCONFIG = $(PERL) $(shell pwd)/perl-config

NSHOME = /usr/lib/aolserver

stamp-nsperl: nsperl/nsperl.so
	touch stamp-nsperl

nsperl/nsperl.so: 
	cd nsperl; $(MAKE)
