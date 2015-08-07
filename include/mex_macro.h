/*
 * Some macro definitions inspired from
 *
 * Jeff Fessler, The University of Michigan
 *
 * $Id: mex_macro.h,v 1.3 2012/07/05 21:05:25 jmh Exp $
 */

#ifndef Defs_macro
#define Defs_macro

#ifdef __cplusplus
# include <cstdarg>
#else
# include <stdarg.h>
#endif

#ifndef Note
# ifdef _WIN32
#  define Note(msg)                                             \
    { mexPrintf("Note %s %d: %s\n", __FILE__, __LINE__, msg);}
# else
#  define Note(msg)                                                     \
    { (void)fprintf(stdout, "Note %s %d: %s\n", __FILE__, __LINE__, msg); \
        (void)fflush(stdout); }
# endif
#endif

#ifndef NoteM
# define NoteM(msg, ...)                                                \
    { char _str[1024]; (void) sprintf(_str, msg, __VA_ARGS__); Note(_str) }
#endif

#ifndef Warn
# ifdef _WIN32
#  define Warn(msg)      {                                              \
        (void)fprintf(stderr, "WARN %s %d: %s\n", __FILE__, __LINE__, msg); \
        (void)fflush(stderr); }
# else
#  define Warn(msg)      {                                              \
        (void)mexPrintf("WARN %s %d: %s\n", __FILE__, __LINE__, msg); }
# endif
#endif

#ifndef WarnM
# define WarnM(msg, ...)                                                \
    { char _str[1024]; (void) sprintf(_str, msg, __VA_ARGS__); Warn(_str) }
#endif

#ifndef Fail
# ifdef _WIN32
#  define Fail(msg)     {                                               \
        (void)mexPrintf("FAIL %s %d: %s\n", __FILE__, __LINE__, msg);   \
        return 0; }
# else
#  define Fail(msg)     {                                               \
        (void)fprintf(stderr, "FAIL %s %d: %s\n", __FILE__, __LINE__, msg); \
        (void)fflush(stderr);                                           \
        return 0; }
# endif
#endif

#ifndef FailM
# define FailM(msg, ...)                                                \
    { char _str[1024]; (void) sprintf(_str, msg, __VA_ARGS__); Fail(_str) }
#endif

#ifndef Exit
# define Exit(msg)      {                                               \
        (void)fprintf(stderr, "EXIT %s %d: %s\n", __FILE__, __LINE__, msg); \
        exit(-1); }
#endif

#ifndef Call
# define Call(fun, arg)         { if (!(fun arg)) Fail(#fun) }
# define Call1(fun, arg, str)   { if (!(fun arg)) FailM(#fun" %s", str) }
#endif

#endif /* Defs_macro */
