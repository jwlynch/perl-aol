/*
 * The contents of this file are subject to the AOLserver Public License
 * Version 1.1 (the "License"); you may not use this file except in
 * compliance with the License. You may obtain a copy of the License at
 * http://aolserver.com/.
 *
 * Software distributed under the License is distributed on an "AS IS"
 * basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See
 * the License for the specific language governing rights and limitations
 * under the License.
 *
 * The Original Code is nsperl and related documentation
 * distributed by Jim Lynch.
 * 
 * The Initial Developer of the Original Code is Jim Lynch.
 * Portions created by AOL are Copyright (C) 1999 America Online,
 * Inc. All Rights Reserved.
 *
 * Alternatively, the contents of this file may be used under the terms
 * of the GNU General Public License (the "GPL"), in which case the
 * provisions of GPL are applicable instead of those above.  If you wish
 * to allow use of your version of this file only under the terms of the
 * GPL and not to allow others to use your version of this file under the
 * License, indicate your decision by deleting the provisions above and
 * replace them with the notice and other provisions required by the GPL.
 * If you do not delete the provisions above, a recipient may use your
 * version of this file under either the License or the GPL.
 */

/*
 * nsperl.c --
 *
 *      perl embedded for aolserver.
 *
 */

static const char *RCSID = "@(#) $Header: /home/jim/perl-aol-cvs-repo-backups/perl-aol/nsperl/nsperl.c,v 1.20 2004/06/23 08:00:19 jwl Exp $, compiled: " __DATE__ " " __TIME__;

#include "ns.h"

#include <EXTERN.h>
#include <perl.h>

// now that we have perl.h, we can now do this...

#ifdef PERL_IMPLICIT_CONTEXT
#  ifdef USE_5005THREADS
#    error "can't use 5005threads"
#  else
#    define THX_TYPE    PerlInterpreter *
#  endif
#else
#  error "this perl was not built with multiplicity, can't be used for this"
#endif

// ... which defines THX_TYPE to be the type returned by perl_alloc()

#include <perlapi.h>
#include <XSUB.h>
#include <proto.h>

#include "Ns_ConnMaps.h"
#include "logging.h"

#define NEVER 0

/*
 * The Ns_ModuleVersion variable is required.
 */
int Ns_ModuleVersion = 1;


/*
 * Private functions
 */
int
Ns_ModuleInit(char *hServer, char *hModule);



/*
 *----------------------------------------------------------------------
 *
 * NSConnIsOpen --
 *
 *	Test the Ns_Conn referred to by the pointer conn:
 *      Is the connection open? 
 *
 *      Typically, being open means that content has not
 *      been sent to the browser, or ns_write is being used
 *      and the connection is not yet closed.
 *
 * Results:
 *	0 if connection is closed, 1 otherwise.
 *
 * Side effects:
 *	none 
 *
 *----------------------------------------------------------------------
 */

int NSConnIsOpen(Ns_Conn *conn)
{
  return ((conn->flags & NS_CONN_CLOSED) == 0);
}


/*
 *----------------------------------------------------------------------
 *
 * xs_init --
 *
 *	initialize function whose address is fed to perl_parse in
 *      do_perl. the perl interpreter runs this function at some 
 *	point during its initialization.
 *
 * Results:
 *	none
 *
 * Side effects:
 *	is called by perl to do further initialization to the perl 
 *      interpreter (to allow the interp to load dynamic modules)
 *
 *----------------------------------------------------------------------
 */

void boot_DynaLoader(pTHX_ CV* cv);

void 
xs_init(pTHX)
{
  char *file = __FILE__;

  newXS("DynaLoader::boot_DynaLoader", boot_DynaLoader, file);
}


/*
 *----------------------------------------------------------------------
 *
 * send_nocontent_message --
 *
 *	tell the user that the programmer forgot to send anything
 *      to the browser
 *
 * Results:
 *	result of failing to return content (i.e., always NS_ERROR)
 *
 * Side effects:
 *	connection is completed, i.e., browser is told "document done"
 *
 *----------------------------------------------------------------------
 */

int send_nocontent_message(Ns_Conn *conn)
{
  Ns_DString sendMe;
  /* script failed to return browser content */
  
  Ns_DStringInit(&sendMe);
  
  Ns_DStringAppend(&sendMe, "<html>\n");
  Ns_DStringAppend(&sendMe, "  <head>\n");
  
  Ns_DStringAppend
    (
     &sendMe, 
     "    <title>406: script didn't return content</title>\n"
     );
  
  Ns_DStringAppend(&sendMe, "  </head>\n");
  Ns_DStringAppend(&sendMe, "  <body>\n");
  
  Ns_DStringAppend
    (
      &sendMe, 
      "    <h1>406:</h1> script didn't return content\n"
    );
  
  Ns_DStringAppend(&sendMe, "(perhaps an error terminated\n");
  Ns_DStringAppend(&sendMe, "the script early. See the log.)\n");
  Ns_DStringAppend(&sendMe, "  </body>\n");
  Ns_DStringAppend(&sendMe, "</html>\n");
  
  Ns_ConnReturnHtml(conn, 406, Ns_DStringValue(&sendMe), -1);
  
  return NS_ERROR;
}


/*
 *----------------------------------------------------------------------
 *
 * send_cantalloc_message --
 *
 *	tell the user there was an error when trying to get a perl
 *      interpreter.
 *
 * Results:
 *	result of failing to get the interpreter (i.e., always NS_ERROR)
 *
 * Side effects:
 *	connection is completed, i.e., browser is told "document done"
 *
 *----------------------------------------------------------------------
 */

int send_cantalloc_message(Ns_Conn *conn)
{
  Ns_DString sendMe;
  /* the perl interpreter could not be allocated */
  
  Ns_DStringInit(&sendMe);
  
  Ns_DStringAppend(&sendMe, "<html>\n");
  Ns_DStringAppend(&sendMe, "  <head>\n");
  Ns_DStringAppend(&sendMe, "    <title>406: can't alloc perl ");
  Ns_DStringAppend(&sendMe, "interpreter</title>\n");
  Ns_DStringAppend(&sendMe, "  </head>\n");
  Ns_DStringAppend(&sendMe, "  <body>\n");
  Ns_DStringAppend(&sendMe, "    <h1>406:</h1> cannot obtain ");
  Ns_DStringAppend(&sendMe, "perl interpreter from system.\n");
  Ns_DStringAppend(&sendMe, "  </body>\n");
  Ns_DStringAppend(&sendMe, "</html>\n");
  
  Ns_ConnReturnHtml(conn, 406, Ns_DStringValue(&sendMe), -1);
  
  return NS_ERROR;
}


/*
 *----------------------------------------------------------------------
 *
 * send_notfound_message --
 *
 *	tell the user the requested file (url) does not exist
 *
 * Results:
 *	result of failing to find the file (i.e., always NS_ERROR)
 *
 * Side effects:
 *	connection is completed, i.e., browser is told "document done"
 *
 *----------------------------------------------------------------------
 */

int send_notfound_message(Ns_Conn *conn, char *url)
{
  /* not found */
  Ns_DString sendMe;
  /* the file %s couldn't be opened: no file or dir found by that name */
  
  Ns_DStringInit(&sendMe);
  
  Ns_DStringAppend(&sendMe, "<html>\n");
  Ns_DStringAppend(&sendMe, "  <head>\n");
  Ns_DStringAppend(&sendMe, "    <title>404: ");
  Ns_DStringAppend(&sendMe, url);
  Ns_DStringAppend(&sendMe, " not found</title>\n");
  Ns_DStringAppend(&sendMe, "  </head>\n");
  Ns_DStringAppend(&sendMe, "  <body>\n");
  Ns_DStringAppend(&sendMe, "    <h1>404:</h1> the location ");
  Ns_DStringAppend(&sendMe, url);
  Ns_DStringAppend(&sendMe, " couldn't be opened: file not found.\n");
  Ns_DStringAppend(&sendMe, "  </body>\n");
  Ns_DStringAppend(&sendMe, "</html>\n");
  
  Ns_ConnReturnHtml(conn, 404, Ns_DStringValue(&sendMe), -1);

  return NS_ERROR;
}


/*
 *----------------------------------------------------------------------
 *
 * send_isdir_message --
 *
 *	tell the user the requested location (url) is actually a directory
 *
 * Results:
 *	result of failing to find the file (i.e., always NS_ERROR)
 *
 * Side effects:
 *	connection is completed, i.e., browser is told "document done"
 *
 *----------------------------------------------------------------------
 */

int send_isdir_message(Ns_Conn *conn, char *url)
{
  Ns_DString sendMe;
  /* the file %s couldn't be opened: is a dir */
  
  Ns_DStringInit(&sendMe);
  
  Ns_DStringAppend(&sendMe, "<html>\n");
  Ns_DStringAppend(&sendMe, "  <head>\n");
  Ns_DStringAppend(&sendMe, "    <title>406: \n");
  Ns_DStringAppend(&sendMe, url);
  Ns_DStringAppend(&sendMe, " is dir</title>\n");
  Ns_DStringAppend(&sendMe, "  </head>\n");
  Ns_DStringAppend(&sendMe, "  <body>\n");
  Ns_DStringAppend(&sendMe, "    <h1>406:</h1> the location ");
  Ns_DStringAppend(&sendMe, url);
  Ns_DStringAppend(&sendMe, " couldn't be opened ");
  Ns_DStringAppend(&sendMe, "as a script: is a dir.\n");
  Ns_DStringAppend(&sendMe, "  </body>\n");
  Ns_DStringAppend(&sendMe, "</html>\n");
  
  Ns_ConnReturnHtml(conn, 406, Ns_DStringValue(&sendMe), -1);

  return NS_ERROR;
}


/*
 * macros for the perl command line arguments
 *
 * they allow for the Aolserver:: modules to either be stored with perl
 * or else in another directory.
 *
 * if there is no definition for PERL_MOD_DIR_IS_SYSTEMWIDE, 
 * there must be a definition for PERLMODLIBDIR and its value
 * should be a quoted string with the dir where Aolserver:: 
 * modules are stored.
 */

#ifdef PERL_MOD_DIR_IS_SYSTEMWIDE
#  define EMBEDDING_NAME embedding
#  define EMBEDDING_DEFINE char *EMBEDDING_NAME[3] = { "", "-w" }
#  define EMBEDDING_MAX_INDEX 2
#  define EMBEDDING_PATH_INDEX 2
#else
#  define EMBEDDING_NAME embedding
#  define EMBEDDING_DEFINE char *EMBEDDING_NAME[4] = { "", "-w", "-Mlib qw{" PERLMODLIBDIR "}" }
#  define EMBEDDING_MAX_INDEX 3
#  define EMBEDDING_PATH_INDEX 3
#endif


/*
 *----------------------------------------------------------------------
 *
 * make_filescript_interp --
 *
 *	create a perl interpreter for running a script in the filesystem; 
 *      browser connection (an aolserver Ns_Conn wrapped in perl stuff)
 *      is published to the interpreter under the name 
 *      "$Aolserver::Ns_Conn::theConn", the needed perl modules
 *      are made available with a perl-command-line equivalent
 *      to "use lib qw{/the/module/dir}" if the modules are not
 *      installed system-wide (which would make a use lib ... unnecessary).
 *
 * Results:
 *	NS_OK if perl script ran.
 *
 * Side effects:
 *	Perl script runs, might feed stuff to the browser, might make
 *      database queries and/or changes, infinite other possibilities
 *
 *
 * IRC discussion with Branden O'Dea, about passing the Ns_Conn to perl:
 *
 *      <bod>     sv_setref_pv(get_sv("dummypackage::conn", TRUE),
 *      +"Aolserver::Ns_Conn", (void *) conn);
 *      <bod> use something like the above to `publish' the connection 
 *      +object in the interpreter
 *
 *      <bod> it is simple enough to do using refcounts
 *      <bod> in which case you *do* provide a DESTROY method, and if 
 *      +the object is constructed in perl
 *      <bod> then it gets destroyed in perl
 *      <bod> if contructed from C, you ensure that the refcount on 
 *      +the IV is at least 1 before it reaches perl
 *
 * my choice is to add a flag to the perl structures I created to represent
 * aolserver data structures. This flag is either yes or no, and indicates
 * either perl owns the C memory slab (in which case destruction
 * from perl should also destroy the slab) or perl does not own
 * the slab (so only the perl stuff should be reclaimed, not the
 * slab itself, which therefore outlives the perl stuff)
 *
 *----------------------------------------------------------------------
 */

THX_TYPE make_filescript_interp(void *context, Ns_Conn *conn, char *path)
{
  THX_TYPE result = 0;

  dTHXa(perl_alloc());
  EMBEDDING_DEFINE;
  
  if(aTHX)
    {
      SV *connPerlRef;
      
      EMBEDDING_NAME[EMBEDDING_PATH_INDEX] = path;
      perl_construct(aTHX);
      perl_parse(aTHX_ xs_init, EMBEDDING_MAX_INDEX, EMBEDDING_NAME, NULL);

      /* store conn (an Ns_Conn *) in the perl interp */
      
      {
	SV *varPtr = get_sv("Aolserver::Ns_Conn::theConn", TRUE | GV_ADDMULTI);
	
	connPerlRef = NsConnOutputMap
	  (
	    conn, 
	    "Aolserver::Ns_Conn", 
	    perlDoesntOwn
	  );

	sv_setsv
	  (
	    varPtr,
	    connPerlRef
	  );

#ifdef SKIP
	LOG(StringF("varPtr => %ld (expect 1)", SvREFCNT(varPtr)));
	LOG(StringF("connPerlRef => %ld (expect 1)", SvREFCNT(connPerlRef)));
	LOG(StringF("%%{varPtr} => %ld (expect 2)", SvREFCNT(SvRV(varPtr))));
	LOG(StringF("(So, we decrement that refcount so it's one)"));
#endif

	SvREFCNT_dec(SvRV(varPtr));

#ifdef SKIP
	LOG(StringF("%%{varPtr} => %ld (expect 1)", SvREFCNT(SvRV(varPtr))));
	LOG(StringF("connPerlRef => %ld (hope 1)", SvREFCNT(connPerlRef)));
#endif

	result = aTHX;
      }

    }

  return result;
}

void reclaim_perl(THX_TYPE interp)
{
  dTHXa(interp);
  
  perl_destruct(aTHX);
  
#ifdef SKIP
  LOG(StringF("after destroying perl interp"));
#endif
      
  perl_free(aTHX);
      
#ifdef SKIP
  LOG(StringF("after freeing perl interp"));
#endif
}



/*
 *----------------------------------------------------------------------
 *
 * do_perl --
 *
 *	Handle *.perl urls by creating a new perl interpreter, feeding 
 *      the specified file to that interpreter and freeing it.
 *	
 *      NOTE that do_perl is a callback whose 
 *      prototype must match that of aolserver's Ns_OpProc.
 *
 * Results:
 *	NS_OK if perl script ran.
 *
 * Side effects:
 *	Perl script runs, might feed stuff to the browser, might make
 *      database queries and/or changes, infinite other possibilities
 *
 *----------------------------------------------------------------------
 */

int do_perl(void *context, Ns_Conn *conn)
{
  int result = NS_OK;
  Ns_DString scriptPath;
  Ns_Request *theReq = conn->request;
  char *hServer = Ns_ConnServer(conn);
  char *scriptPathP = 0;

  Ns_DStringInit(&scriptPath);
  Ns_UrlToFile(&scriptPath, hServer, theReq->url);
  scriptPathP = Ns_DStringValue(&scriptPath);

  /*
   * if it's a file, assume it's a perl script and run it.
   * else if it's a dir, tell them they did it wrong, it's a dir
   *      else tell them they did it wrong, it doesn't exist
   */

  if(Ns_UrlIsFile(hServer, theReq->url))
    {
      dTHXa(make_filescript_interp(context, conn, scriptPathP));

      if(aTHX)
	{
	  perl_run(aTHX);
	  reclaim_perl(aTHX);
      
	  if(Ns_ConnContentSent(conn))
	    result = NS_OK;
	  else
	    {
	      result = send_nocontent_message(conn);
	    }
	}
      else
	{
	  result = send_cantalloc_message(conn);
	}
    }
  else if(Ns_UrlIsDir(hServer, theReq->url))
    {
      result = send_isdir_message(conn, theReq->url);
    }
  else
    {
      result = send_notfound_message(conn, theReq->url);
    }

  return result;
}



/*
 *----------------------------------------------------------------------
 *
 * Ns_ModuleInit --
 *
 *      This is the nsexample module's entry point.  AOLserver runs
 *      this function right after the module is loaded.  It is used to
 *      read configuration data, initialize data structures, kick off
 *      the Tcl initialization function (if any), and do other things
 *      at startup.
 *
 * Results:
 *	NS_OK or NS_ERROR
 *
 * Side effects:
 *	Module loads and initializes itself.
 *
 *----------------------------------------------------------------------
 */

#ifdef SKIP
  typedef void *Ns_OpContext;
  typedef int (Ns_OpProc) (void *context, Ns_Conn *conn);
  typedef void (Ns_OpDeleteProc) (void *context);

  void Ns_RegisterRequest
  (
    char *hServer,
    char *method,
    char *URL,
    Ns_OpProc *proc,
    Ns_OpDeleteProc *deleteProc,
    Ns_OpContext context,
    int flags
  );

#endif

int
Ns_ModuleInit(char *hServer, char *hModule)
{
  Ns_RegisterRequest(hServer, "GET", "/perl", do_perl, NULL, NULL, 0);
  
  return NS_OK;
}

