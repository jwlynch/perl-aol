#ifdef SKIP

/*
 *----------------------------------------------------------------------
 *
 * loggit --
 *
 *	Logs a message to stderr.
 *	
 *
 * Results:
 *	none: void func.
 *
 * Side effects:
 *	appends msg to stderr.
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


#endif /*SKIP*/

#include <stdarg.h>
#include "logging.h"

#define BUFFER_SIZE 1024

char *badmess = "error message buffer could not be allocated";

/*
 *----------------------------------------------------------------------
 *
 * StringF --
 *
 *	writes a formatted string (a la printf) into a buffer
 *      which it allocates using malloc(). the address of this
 *      buffer (which contains the message: the whole idea) is 
 *      then returned.
 * 
 *      the idea is to use the LOG macro (which also logs file and line#
 *      info and frees the buffer), like this:
 *
 *      LOG(StringF("%s %s %d", "format", "string", 42));
 *
 *      so the output of StringF() here would be "format string 42"
 *      and the resulting message might look like
 *
 *      logging.h:42: format string 42
 *
 * Results:
 *	newly allocated string with message in it
 *
 * Side effects:
 *	implicitly passes responsibility for freeing the message 
 *      to the caller, which is really expected to be the macro LOG().
 *
 *      length of line limited; use of vsnprintf() should avoid buffer
 *      overrun.
 *
 */

char *StringF(char *format, ...)
{
  va_list ap;
  char *log_buffer = (char *) malloc(BUFFER_SIZE);

  if(log_buffer != 0)
    {
      va_start(ap, format);

      vsnprintf(log_buffer, BUFFER_SIZE, format, ap);

      va_end(ap);
    }
  else
    {
      log_buffer = badmess;
    }

  return log_buffer;
}
