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
 * The Original Code is AOLserver Code and related documentation
 * distributed by AOL.
 * 
 * The Initial Developer of the Original Code is America Online,
 * Inc. Portions created by AOL are Copyright (C) 1999 America Online,
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

static const char *RCSID = "@(#) $Header: /home/jim/perl-aol-cvs-repo-backups/perl-aol/nsperl/nsperl.c,v 1.13 2000/12/26 23:43:45 jwl Exp $, compiled: " __DATE__ " " __TIME__;

#include "ns.h"

#include <EXTERN.h>
#include <perl.h>
#include <perlapi.h>
#include <XSUB.h>
#include <proto.h>

#include <Ns_ConnMaps.h>

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
  // newXS("Aolserver::Ns_DString", boot_Ns_DString, file);
  // newXS("Aolserver::Ns_Set", boot_Ns_Set, file);
  // newXS("Aolserver::Ns_Conn", boot_Ns_Conn, file);
}


/*
 *----------------------------------------------------------------------
 *
 * loggit --
 *
 *	Logs a message to a log file.
 *	
 *
 * Results:
 *	none: void func.
 *
 * Side effects:
 *	appends msg to file.
 *
 */

#define LOGPATH "/web/nusvr324/www/perl/log"

void
p_loggit(char *file, int line, char *msg)
{
  FILE *log = fopen(LOGPATH, "a");

  if(log)
    {
      fprintf(log, "%s:%d: %s\n", file, line, msg);
      fclose(log);
    }
}

#define loggit(m) p_loggit(__FILE__, __LINE__, m)


/*
 *----------------------------------------------------------------------
 *
 * trunclog --
 *
 *	Erases log file.
 *	
 *
 * Results:
 *	none: void func.
 *
 * Side effects:
 *	none
 *
 */

void
trunclog(void)
{
  FILE *log = fopen(LOGPATH, "w");

  if(log)
    {
      fclose(log);
    }
}


/*
 *----------------------------------------------------------------------
 *
 * do_perl --
 *
 *	Handle *.perl urls by creating a new perl interpreter, feeding 
 *      the specified file to that interpreter and freeing it.
 *	
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
 *      the IV is at least 1 before it reaches perl
 *
 *----------------------------------------------------------------------
 */

#include "../Aolserver/Ns_Conn/Ns_ConnMaps.h"

void Wput(const char *it, Ns_Conn *conn)
{
  loggit(it);
}

#define NEVER 0

int do_perl(void *context, Ns_Conn *conn)
{
  int result = NS_OK;
  char *hServer = Ns_ConnServer(conn);
  char *scriptPathP;
  Ns_Request *theReq = conn->request;

  trunclog();

  /*
   * if it's a file, assume it's a perl script and run it.
   * else if it's a dir, tell them they did it wrong, it's a dir
   *      else tell them they did it wrong, it doesn't exist
   */

  if(Ns_UrlIsFile(hServer, theReq->url))
    {
      // define pointer to perl interp; assign it a new perl interp
      dTHXa(perl_alloc());
      char *embedding[3] = { "", "-w" };
      Ns_DString scriptPath;
      Ns_DString sendMe;
      char *sendStr;

      if(aTHX)
	{
	  Ns_DStringInit(&scriptPath);
	  Ns_UrlToFile(&scriptPath, hServer, theReq->url);
	  embedding[2] = Ns_DStringValue(&scriptPath);
	  perl_construct(aTHX);
	  perl_parse(aTHX_ xs_init, 2, embedding, NULL);
	  /* add lines to store conn (an Ns_Conn *) in the perl interp */

#ifdef SKIP
	  {
	    SV *theConnVar = get_sv("Aolserver::Ns_Conn::theConn", TRUE);
	    SV **hashValue;
	    HV *theStash;
	    GV *theConnGlob;

	    sv_setsv
	      (
	        theConnVar,
	        NsConnOutputMap(conn, "Aolserver::Ns_Conn")
	      );

	    theStash = SvSTASH(SvRV(theConnVar));
	    hashValue = hv_fetch(theStash, "theConn", 7, FALSE);
	    theConnGlob = (GV *) *hashValue;
	    GvMULTI_on(theConnGlob);
	  }
#else
	  {
	    SV *conPerlRef = NsConnOutputMap(conn, "Aolserver::Ns_Conn");
	    SV *varPtr = get_sv("Aolserver::Ns_Conn::theConn", TRUE | GV_ADDMULTI);

NsConnPrintRefCounts(varPtr);
	    sv_setsv
	      (
	        varPtr,
	        conPerlRef
	      );
	    SvREFCNT_inc(varPtr);
NsConnPrintRefCounts(varPtr);
            SvREFCNT_dec(conPerlRef); /* done with this */
	  }
#endif

	  perl_run(aTHX);
	  perl_destruct(aTHX);
	  perl_free(aTHX);
	}
      else
	{
	  Ns_DString sendMe;
	  char *sendStr;
	  /* the perl interpreter could not be allocated */

	  Ns_DStringInit(&sendMe);
      
	  Ns_DStringAppend(&sendMe, "<html>\n");
	  Ns_DStringAppend(&sendMe, "  <head>\n");
	  Ns_DStringAppend(&sendMe, "    <title>406: can't alloc</title>\n");
	  Ns_DStringAppend(&sendMe, "  </head>\n");
	  Ns_DStringAppend(&sendMe, "  <body>\n");
	  Ns_DStringAppend(&sendMe, "    <h1>406:</h1> cannot obtain ");
	  Ns_DStringAppend(&sendMe, "perl interpreter from system.\n");
	  Ns_DStringAppend(&sendMe, "  </body>\n");
	  Ns_DStringAppend(&sendMe, "</html>\n");
	  
	  sendStr = Ns_DStringValue(&sendMe);
	  
	  Ns_ConnReturnHtml(conn, 406, sendStr, -1);
	  result = NS_ERROR;
	}
    }
  else if(Ns_UrlIsDir(hServer, theReq->url))
    {
      Ns_DString sendMe;
      char *sendStr;
      /* the file %s couldn't be opened: is a dir */

      Ns_DStringInit(&sendMe);
      
      Ns_DStringAppend(&sendMe, "<html>\n");
      Ns_DStringAppend(&sendMe, "  <head>\n");
      Ns_DStringAppend(&sendMe, "    <title>406: is dir</title>\n");
      Ns_DStringAppend(&sendMe, "  </head>\n");
      Ns_DStringAppend(&sendMe, "  <body>\n");
      Ns_DStringAppend(&sendMe, "    <h1>406:</h1> the location ");
      Ns_DStringAppend(&sendMe, theReq->url);
      Ns_DStringAppend(&sendMe, " couldn't be opened ");
      Ns_DStringAppend(&sendMe, "as a script: is a dir.\n");
      Ns_DStringAppend(&sendMe, "  </body>\n");
      Ns_DStringAppend(&sendMe, "</html>\n");

      sendStr = Ns_DStringValue(&sendMe);
      
      Ns_ConnReturnHtml(conn, 406, sendStr, -1);
      result = NS_ERROR;
    }
  else
    {
      /* not found */
      Ns_DString sendMe;
      char *sendStr;
      /* the file %s couldn't be opened: is a dir */

      Ns_DStringInit(&sendMe);
      
      Ns_DStringAppend(&sendMe, "<html>\n");
      Ns_DStringAppend(&sendMe, "  <head>\n");
      Ns_DStringAppend(&sendMe, "    <title>404: not found</title>\n");
      Ns_DStringAppend(&sendMe, "  </head>\n");
      Ns_DStringAppend(&sendMe, "  <body>\n");
      Ns_DStringAppend(&sendMe, "    <h1>404:</h1> the location ");
      Ns_DStringAppend(&sendMe, theReq->url);
      Ns_DStringAppend(&sendMe, " couldn't be opened: file not found.\n");
      Ns_DStringAppend(&sendMe, "  </body>\n");
      Ns_DStringAppend(&sendMe, "</html>\n");

      sendStr = Ns_DStringValue(&sendMe);
      
      Ns_ConnReturnHtml(conn, 404, sendStr, -1);
      result = NS_ERROR;
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

