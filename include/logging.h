#ifndef logmacro_H
#define logmacro_H

#include <stdio.h>


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

char *StringF(char *format, ...);



/*
 *----------------------------------------------------------------------
 *
 * --MACRO-- LOG(s) 
 *
 *	writes a log message s, which (WARNING) must be a malloc-ed buffer.
 *      Also logs line number and file name information, and flushes
 *      the log device.
 *
 *      the macro named STREAM contains a FILE* (stderr is suggested,
 *      or you could open a file; -or- the implementation could be
 *      changed so that every call to LOG opens the file for append,
 *      writes the message to the file and then closes it, implying
 *      that the macro STREAM would not be needed)
 * 
 *      the idea is to use StringF, which formats a log message into
 *      a newly allocated char array, like this:
 *
 *      LOG(StringF("%s %s %d", "format", "string", 42));
 *
 *      and the resulting message might look like
 *
 *      logging.h:42: format string 42
 *
 * Parameters:
 *      s -- address of an array of char that must have been allocated
 *           with malloc()
 *
 * Results:
 *	none
 *
 * Side effects:
 *      takes responsibility for freeing the message s (by doing so, of course)
 *
 */

#define STREAM stderr

#define LOG(s)                                              \
if(1)                                                       \
{                                                           \
  fprintf(STREAM, "%s:%d: %s\n", __FILE__, __LINE__, (s));  \
  free(s);                                                  \
  fflush(STREAM);                                           \
}                                                           \
else

// (See Holub's "The C Companion", chapter on preprocessor, for why the if)

#endif


