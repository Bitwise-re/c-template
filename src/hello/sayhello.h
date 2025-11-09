#ifndef __HELLO_sayhello_h_
#define __HELLO_sayhello_h_

//shared library symbols
#ifndef HELLOAPI
#  if defined(_WIN32) || defined(__CYGWIN__)
#    if defined(HELLO_EXPORT)
#      if defined(__GNUC__)
#        define HELLOAPI __attribute__ ((dllexport)) extern
#      else
#        define HELLOAPI __declspec(dllexport) extern
#      endif
#    else
#      if defined(__GNUC__)
#        define HELLOAPI __attribute__ ((dllimport)) extern
#      else
#        define HELLOAPI __declspec(dllimport) extern
#      endif
#    endif
#  elif defined(__GNUC__) && defined(HELLO_EXPORT)
#    define HELLOAPI __attribute__ ((visibility ("default"))) extern
#  else
#    define HELLOAPI extern
#  endif
#endif

HELLOAPI int sayHello();

#endif //__HELLO_sayhello_h_