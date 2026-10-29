/* Tiny portability shim: set an environment variable from Fortran.
   Called as  CALL NSPUTENV('NAME=value')  (gfortran hidden-length convention). */
#include <stdlib.h>
#include <string.h>

void nsputenv_(char *s, int len)
{
    char *p = (char *)malloc((size_t)len + 1);
    if (!p) return;
    memcpy(p, s, (size_t)len);
    p[len] = '\0';
    while (len > 0 && p[len - 1] == ' ') p[--len] = '\0';
    putenv(p); /* p intentionally leaked: putenv keeps the pointer */
}
