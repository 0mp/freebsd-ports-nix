--- src/libexpr/primops/fetchGit.cc.orig	1970-01-01 00:00:01 UTC
+++ src/libexpr/primops/fetchGit.cc
@@ -6,6 +6,7 @@
 #include "hash.hh"
 
 #include <sys/time.h>
+#include <sys/wait.h>
 
 #include <regex>
 
