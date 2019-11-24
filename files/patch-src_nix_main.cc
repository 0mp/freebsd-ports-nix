--- src/nix/main.cc.orig	2019-10-10 13:03:46 UTC
+++ src/nix/main.cc
@@ -15,6 +15,7 @@
 #include <sys/socket.h>
 #include <ifaddrs.h>
 #include <netdb.h>
+#include <netinet/in.h>
 
 extern std::string chrootHelperName;
 
