PERL := perl-thread
export PERLCONFIG := $(PERL) $(shell pwd)/perl-config
export LIBPERL := libperl.a

export NSHOME := /usr/lib/aolserver

stamp-nsperl: nsperl/nsperl.so
	touch stamp-nsperl

nsperl/nsperl.so: 
	cd nsperl; $(MAKE)
