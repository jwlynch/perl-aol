export PERL_AOL := $(shell pwd)
export PERL := perl-thread
export PERLCONFIG := $(PERL) $(PERL_AOL)/perl-config
export LIBPERL := libperl.a

export NSHOME := /usr/lib/aolserver
PERLMODULES := Ns_Conn Ns_DbHandle Ns_DString Ns_Request Ns_Set

all: stamp-nsperl stamp-perlmodules

stamp-perlmodules:
	for i in $(PERLMODULES); \
	do \
	    (cd Aolserver/$$i; \
	     $(MAKE) -f Makefile.outer Makefile; \
	     $(MAKE) ) ; \
	done
	touch stamp-perlmodules

stamp-nsperl: nsperl/nsperl.so
	touch stamp-nsperl

nsperl/nsperl.so: 
	cd nsperl; $(MAKE)


install: all
	for i in $(PERLMODULES); \
	do \
	    (cd Aolserver/$$i; \
	     $(MAKE) install) ; \
	done
	cd nsperl; $(MAKE) install
