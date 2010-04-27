#Copyright (C) 1997-2008 ZSNES Team ( theoddone33, grinvader, Nach )
#
#http://www.zsnes.com
#http://sourceforge.net/projects/zsnes
#https://zsnes.bountysource.com
#
#This program is free software; you can redistribute it and/or
#modify it under the terms of the GNU General Public License
#version 2 as published by the Free Software Foundation.
#
#This program is distributed in the hope that it will be useful,
#but WITHOUT ANY WARRANTY; without even the implied warranty of
#MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#GNU General Public License for more details.
#
#You should have received a copy of the GNU General Public License
#along with this program; if not, write to the Free Software
#Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

dnl -- Begin zlib autoconf macro
dnl When copying, include from Begin to End zlib autoconf macro, including
dnl those tags, so others can easily copy it too. (Maybe someday this will
dnl become zlib.m4?)
dnl
dnl AM_PATH_ZLIB([MINIMUM-VERSION, [ACTION-IF-FOUND [, ACTION-IF-NOT-FOUND]]])
dnl Tests for zlib, outputs ZLIB_VERSION, ZLIB_LIBS, and ZLIB_CFLAGS
AC_DEFUN([AM_PATH_ZLIB],
[
AC_ARG_WITH(zlib-prefix,
  AC_HELP_STRING([--with-zlib-prefix=PFX],
    [Prefix where zlib is installed (optional)]),
  zlib_prefix="$withval",
  zlib_prefix="")
min_zlib_version=ifelse([$1],,1.1.0,$1)
AC_MSG_CHECKING(for zlib - version >= $min_zlib_version)

tempLIBS="$LIBS"
tempCFLAGS="$CFLAGS"
if test x$zlib_prefix != x ; then
  ZLIB_LIBS="-L$zlib_prefix"
  ZLIB_CFLAGS="-I$zlib_prefix"
fi
ZLIB_LIBS="$ZLIB_LIBS -lz"
LIBS="$LIBS $ZLIB_LIBS"
CFLAGS="$CFLAGS $ZLIB_CFLAGS"

AC_RUN_IFELSE([AC_LANG_SOURCE([[
#include <zlib.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

char* my_strdup (char *str)
{
  char *new_str;

  if (str)
  {
    new_str = (char *)malloc ((strlen (str) + 1) * sizeof(char));
    strcpy (new_str, str);
  }
  else new_str = NULL;

  return new_str;
}

int main (int argc, char *argv[])
{
  int major, minor, micro, zlib_major_version, zlib_minor_version, zlib_micro_version;
  char *zlibver, *tmp_version;

  zlibver = ZLIB_VERSION;
  FILE *fp = fopen("conf.zlibtest", "a");
  if ( fp ) {
    fprintf(fp, "%s", zlibver);
    fclose(fp);
  }

  /* HP/UX 9 (%@#!) writes to sscanf strings */
  tmp_version = my_strdup("$min_zlib_version");
  if (sscanf(tmp_version, "%d.%d.%d", &major, &minor, &micro) != 3) {
    printf("%s, bad version string for\n\tmin_zlib_version... ", "$min_zlib_version");
    exit(1);
  }
  if (sscanf(zlibver, "%d.%d.%d", &zlib_major_version, &zlib_minor_version, &zlib_micro_version) != 3) {
    printf("%s, bad version string given\n", zlibver);
    puts("\tby zlib, sometimes due to very old zlibs that didnt correctly");
    printf("\tdefine their version. Please upgrade if you are running an\n\told zlib... ");
    exit(1);
  }

  if ((zlib_major_version > major) ||
     ((zlib_major_version == major) && (zlib_minor_version > minor)) ||
     ((zlib_major_version == major) && (zlib_minor_version == minor) && (zlib_micro_version >= micro)))
  { return 0; }
  else { return 1; }
}
]])],
  with_zlib=yes,
  with_zlib=no,
  [AC_MSG_RESULT(cross-compiling)
  with_zlib=""
  AC_MSG_WARN(Assuming zlib is available)])

if test x$with_zlib != x; then
  AC_MSG_RESULT($with_zlib)
fi
if test x$with_zlib = xyes; then
  ZLIB_VERSION=$(<conf.zlibtest)
  ifelse([$2], , :, [$2])
else
  ZLIB_CFLAGS=""
  ZLIB_LIBS=""
  ZLIB_VERSION=""
  ifelse([$3], , :, [$3])
fi
LIBS="$tempLIBS"
CFLAGS="$tempCFLAGS"
rm conf.zlibtest
AC_SUBST(ZLIB_CFLAGS)
AC_SUBST(ZLIB_VERSION)
AC_SUBST(ZLIB_LIBS)
])
dnl -- End zlib autoconf macro

dnl ----

dnl -- Begin libpng autoconf macro
dnl When copying, include from Begin to End libpng autoconf macro, including
dnl those tags, so others can easily copy it too. (Maybe someday this will
dnl become libpng.m4?)
dnl
dnl AM_PATH_LIBPNG([MINIMUM-VERSION, [ACTION-IF-FOUND [, ACTION-IF-NOT-FOUND]]])
dnl Tests for libpng, outputs LIBPNG_VERSION, LIBPNG_LIBS, and LIBPNG_CFLAGS
AC_DEFUN([AM_PATH_LIBPNG],
[
dnl Comment out this section, and the other labled parts to disable the user
dnl having a choice about being able to disable libpng or not. Recommended
dnl you use AC_MSG_ERROR(LIBPNG >= 1.0.0 is required) for the
dnl ACTION-IF-NOT-FOUND if you plan on disabling user choice.

dnl <--- disable for no user choice part #1
AC_ARG_ENABLE(libpng,
  AC_HELP_STRING([--disable-libpng],[Build without libpng support]),
  ,
  enable_libpng=yes)
dnl --->

AC_ARG_WITH(libpng-prefix,
  AC_HELP_STRING([--with-libpng-prefix=PX],
    [Prefix where libpng is installed (optional)]),
  libpng_prefix="$withval",
  libpng_prefix="")

min_libpng_version=ifelse([$1], ,1.2.0,$1)

AC_MSG_CHECKING(for libpng - version >= $min_libpng_version)

dnl <--- disable for no user choice part #2
if test x$enable_libpng != xno; then
dnl --->
  tempLIBS="$LIBS"
  tempCFLAGS="$CFLAGS"
  if test x$libpng_prefix != x ; then
    LIBPNG_LIBS="-L$libpng_prefix"
    LIBPNG_CFLAGS="-I$libpng_prefix"
  fi
  LIBPNG_LIBS="$LIBPNG_LIBS -lpng -lm"
  LIBS="$LIBS $LIBPNG_LIBS"
  CFLAGS="$CFLAGS $LIBPNG_CFLAGS"

  AC_RUN_IFELSE([AC_LANG_SOURCE([[
#include <png.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

char* my_strdup (char *str)
{
  char *new_str;

  if (str)
  {
    new_str = (char *)malloc ((strlen (str) + 1) * sizeof(char));
    strcpy (new_str, str);
  }
  else new_str = NULL;

  return new_str;
}

int main (int argc, char *argv[])
{
  int major, minor, micro, libpng_major_version, libpng_minor_version, libpng_micro_version;
  char *libpngver, *tmp_version;

  libpngver = PNG_LIBPNG_VER_STRING;

  FILE *fp = fopen("conf.libpngtest", "a");
  if ( fp ) {
    fprintf(fp, "%s", libpngver);
    fclose(fp);
  }

  /* HP/UX 9 (%@#!) writes to sscanf strings */
  tmp_version = my_strdup("$min_libpng_version");
  if (sscanf(tmp_version, "%d.%d.%d", &major, &minor, &micro) != 3) {
    printf("%s, bad version string for\n\tmin_libpng_version... ", "$min_libpng_version");
    exit(1);
  }
  if (sscanf(libpngver, "%d.%d.%d", &libpng_major_version, &libpng_minor_version, &libpng_micro_version) != 3) {
    printf("%s, bad version string given\n", libpngver);
    puts("\tby libpng, sometimes due to very old libpngs that didnt correctly");
    printf("\tdefine their version. Please upgrade if you are running an\n\told libpng... ");
    exit(1);
  }

  if ((libpng_major_version > major) ||
     ((libpng_major_version == major) && (libpng_minor_version > minor)) ||
     ((libpng_major_version == major) && (libpng_minor_version == minor) && (libpng_micro_version >= micro)))
  { return 0; }
  else { return 1; }
}
  ]])],
  with_libpng=yes,
  with_libpng=no,
  [AC_MSG_RESULT(cross-compiling)
  with_libpng=""
  AC_MSG_WARN(Assuming libpng is available)])

  if test x$with_libpng != x; then
    AC_MSG_RESULT($with_libpng)
  fi
  if test x$with_libpng = xyes; then
    LIBPNG_VERSION=$(<conf.libpngtest)
    ifelse([$2], , :, [$2])
  else
    LIBPNG_CFLAGS=""
    LIBPNG_LIBS=""
    LIBPNG_VERSION=""
    ifelse([$3], , :, [$3])
  fi
  LIBS="$tempLIBS"
  CFLAGS="$tempCFLAGS"
  rm conf.libpngtest
  AC_SUBST(LIBPNG_CFLAGS)
  AC_SUBST(LIBPNG_VERSION)
  AC_SUBST(LIBPNG_LIBS)

dnl <--- disable for no user choice part #3
else
  AC_MSG_RESULT(disabled by user)
fi
dnl --->
])
dnl -- End libpng autoconf macro

dnl ----

dnl -- Begin Qt autoconf macro
AC_DEFUN([AM_CHECK_QT],
[
AC_MSG_CHECKING(for Qt4 libraries >= 4.1.1)
AC_ARG_WITH(qt-path,
  AC_HELP_STRING([--with-qt-path=PATH],[Path to Qt4 libraries]),
  qtpath+="-L$withval",
  qtpath="`pkg-config --silence-errors --libs-only-L 'QtCore QtGui >= 4.1.1'`")
case x$qtpath in
  x)
    AC_MSG_ERROR(You need Qt libraries >= 4.1.1)
    ;;
  x-L)
    AC_MSG_ERROR(You need Qt libraries >= 4.1.1)
    ;;
  *)
    AC_MSG_RESULT(found)
    ;;
esac

QT_CFLAGS="`pkg-config --silence-errors --cflags QtCore QtGui`"
QT_LDFLAGS="$qtpath `pkg-config --silence-errors --libs-only-l QtCore QtGui`"

AC_MSG_CHECKING(for functionnal Qt setup)

cat > myqt.h << EOF
#include <QObject>
class Test : public QObject
{
Q_OBJECT
public:
  Test() {}
  ~Test() {}
public slots:
  void receive() {}
signals:
  void send();
};
EOF

cat > myqt.cpp << EOF
#include "myqt.h"
#include <QApplication>
int main( int argc, char **argv )
{
  QApplication app( argc, argv );
  Test t;
  QObject::connect( &t, SIGNAL(send()), &t, SLOT(receive()) );
}
EOF

bnv_try="moc myqt.h -o moc_myqt.cpp"
AC_TRY_EVAL(bnv_try)
if test x$ac_status != x0; then
  rm -f myqt.cpp myqt.h
  AC_MSG_RESULT(nope)
  AC_MSG_ERROR(moc doesn't work)
fi
bnv_try="$CXX -c $QT_CFLAGS -o moc_myqt.o moc_myqt.cpp"
AC_TRY_EVAL(bnv_try)
if test x$ac_status != x0; then
  rm -f moc_myqt.cpp myqt.cpp myqt.h
  AC_MSG_RESULT(nope)
  AC_MSG_ERROR(Couldn't compile moc output)
fi
bnv_try="$CXX -c $QT_CFLAGS -o myqt.o myqt.cpp"
AC_TRY_EVAL(bnv_try)
if test x$ac_status != x0; then
  rm -f moc_myqt.cpp moc_myqt.o myqt.cpp myqt.h
  AC_MSG_RESULT(nope)
  AC_MSG_ERROR(Couldn't compile test source)
fi
bnv_try="$CXX $QT_CFLAGS $QT_LDFLAGS -o myqt myqt.o moc_myqt.o"
AC_TRY_EVAL(bnv_try)
if test x$ac_status != x0; then
  rm -f moc_myqt.cpp moc_myqt.o myqt.cpp myqt.h myqt.o
  AC_MSG_RESULT(nope)
  AC_MSG_ERROR(Couldn't link against Qt)
fi
AC_MSG_RESULT(all fine)
rm -f moc_myqt.cpp moc_myqt.o myqt.cpp myqt.h myqt.o myqt
AC_SUBST(QT_CFLAGS)
AC_SUBST(QT_LDFLAGS)
])
dnl -- End Qt autoconf macro

dnl ----

dnl -- Begin custom tools use
dnl
AC_DEFUN([AM_ARCH_DETECT],
[
AC_MSG_CHECKING(for cpu info)
AC_ARG_ENABLE(cpucheck,
  AC_HELP_STRING([--disable-cpucheck],
    [Do not try to autodetect cpu architecture]),
  ,
  enable_cpucheck=yes)

if test x$enable_cpucheck != xno; then
  AC_RUN_IFELSE([AC_LANG_SOURCE([[
#include <stdlib.h>

int main()
{
  int check;
  system("$CC -O3 -o tools/archopt tools/archopt.c");
  check = system("tools/archopt > conf.archchk");
  return((!!check));
}
  ]])],
  cpu_test=found,
  cpu_test=failed,
  [AC_MSG_RESULT(cross-compiling)
  cpu_test=""
  AC_MSG_WARN(You should use --host=HOST)])

  if test x$cpu_test != x; then
    AC_MSG_RESULT($cpu_test)
  fi
  if test x$cpu_test = xfound; then
    ARCH_INFO=$(<conf.archchk)
  fi
  rm -f conf.archchk tools/archopt
  AC_SUBST(ARCH_INFO)
else
  AC_MSG_RESULT(disabled by user)
fi
])
dnl -- End custom tools use
