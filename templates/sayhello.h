#ifndef __$1_sayhello_h_
#define __$1_sayhello_h_

//shared library symbols
#ifndef $1API
#  if defined(_WIN32) || defined(__CYGWIN__)
#    if defined($1_EXPORT)
#      if defined(__GNUC__)
#        define $1API __attribute__ ((dllexport)) extern
#      else
#        define $1API __declspec(dllexport) extern
#      endif
#    else
#      if defined(__GNUC__)
#        define $1API __attribute__ ((dllimport)) extern
#      else
#        define $1API __declspec(dllimport) extern
#      endif
#    endif
#  elif defined(__GNUC__) && defined($1_EXPORT)
#    define $1API __attribute__ ((visibility ("default"))) extern
#  else
#    define $1API extern
#  endif
#endif

$1API int sayHello();

#endif //__$1_sayhello_h_