PERL = perl-thread
PERLCONFIG = $(PERL) $(shell pwd)/perl-config

NSHOME = /usr/lib/aolserver

stamp-nsperl: nsperl/nsperl.so
	rm -f stamp-nsperl
	cd nsperl; $(MAKE)
	touch stamp-nsperl

