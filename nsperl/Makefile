#
# $Header: /home/jim/perl-aol-cvs-repo-backups/perl-aol/nsperl/Makefile,v 1.10 2004/06/23 08:00:19 jwl Exp $
#
# nsexample --
#
#      Example AOLserver module Makefile.
#

#
# perl-aol project dir location
#
PERL_AOL = ..

#
# AOLserver's location
#
#  Since your module probably doesn't live inside the "aolserver"
#  directory, you can tell make where to find aolserver.
#
#NSHOME   =  /home/user/cvs/aolserver
#NSHOME   =  ../aolserver
#NSHOME   =  $(PERL_AOL)/aolsvr-src/aolserver3_1
#NSHOME   =  /usr/local/aolserver

#
# libs and include locations and other parameters for perl
#
#  Usually, you have to build a somewhat specially configured perl
#  and therefore install it in a place that is usually not searched
#  by general users. The $PERLCONFIG var comes from the top level
#  makefile, and uses the perl whose location is also specified
#  therein.
#

PLIBS   = $(LIBS) -L$(shell $(PERLCONFIG) --libs)
PINCLUDES = -I$(shell $(PERLCONFIG) --includes)

CFLAGS += -I$(PERL_AOL)/include
CFLAGS += $(shell $(PERLCONFIG) --cflags)
CFLAGS += -I$(PERL_AOL)/Aolserver/Ns_Set
CFLAGS += -I$(PERL_AOL)/Aolserver/Ns_DString
CFLAGS += -I$(PERL_AOL)/Aolserver/Ns_Conn
CFLAGS += -I$(PERL_AOL)/Aolserver/Ns_Request
CFLAGS += -I$(PERL_AOL)/Aolserver/Ns_Db

# location of installed perl modules (def'd in top level makefile)
CFLAGS += -DPERLMODLIBDIR=\"$(PERLMODLIBDIR)\"

#
# Module name
#
MOD      =  nsperl.so

#
# Objects to build
#
OBJS     =  nsperl.o Ns_ConnMaps.o Ns_SetMaps.o Ns_RequestMaps.o $(PERL_AOL)/logging/logging.o

#
# Header files
#
HDRS     =  

#
# Extra libraries
#
MODLIBS  =  $(shell $(PERLCONFIG) --libs) -lcrypt

#
# Compiler flags
#
#CFLAGS   =  
#(def'd above)

include  $(NSHOME)/include/Makefile.module

Ns_ConnMaps.o: $(PERL_AOL)/Aolserver/Ns_Conn/Ns_ConnMaps.c
	gcc $(CFLAGS) -c -o Ns_ConnMaps.o $(PERL_AOL)/Aolserver/Ns_Conn/Ns_ConnMaps.c

Ns_SetMaps.o: $(PERL_AOL)/Aolserver/Ns_Set/Ns_SetMaps.c
	gcc $(CFLAGS) -c -o Ns_SetMaps.o $(PERL_AOL)/Aolserver/Ns_Set/Ns_SetMaps.c

Ns_RequestMaps.o: $(PERL_AOL)/Aolserver/Ns_Request/Ns_RequestMaps.c
	gcc $(CFLAGS) -c -o Ns_RequestMaps.o $(PERL_AOL)/Aolserver/Ns_Request/Ns_RequestMaps.c

$(PERL_AOL)/logging/logging.o:
	cd $(PERL_AOL)/logging/ && $(MAKE)

