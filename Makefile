export PERL_AOL      := $(shell pwd)
export PERL          := /usr/bin/perl
export PERLCONFIG    := $(PERL) $(PERL_AOL)/perl-config
export LIBPERL       := libperl.so

export PERLMODDIR    := /home/jim/perl/perl-aol/perl-modules
export PERLMODLIBDIR := $(PERLMODDIR)/lib

export NSHOME    := /home/jim/aols-git-inst
export NSINCLUDE := $(NSHOME)/include

PERLMODULES := Ns_Conn Ns_DbHandle Ns_DString Ns_Request Ns_Set
# PERLMODULES := Ns_Conn Ns_DString Ns_Request Ns_Set

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

nsperl/nsperl.so: nsperl/nsperl.c nsperl/Makefile
	cd nsperl; $(MAKE)

pmclean:
	for i in $(PERLMODULES); \
	do \
	    (cd Aolserver/$$i; \
	     $(MAKE) -f Makefile.outer clean) ; \
	done
	rm -f stamp-perlmodules

nspclean:
	cd nsperl; $(MAKE) clean
	rm -f stamp-nsperl

clean: pmclean nspclean

install: nspinstall pminstall

nspinstall: stamp-nsperl
	cd nsperl; $(MAKE) install

pminstall: stamp-perlmodules
	for i in $(PERLMODULES); \
	do \
	    (cd Aolserver/$$i; \
	     $(MAKE) install) ; \
	done
