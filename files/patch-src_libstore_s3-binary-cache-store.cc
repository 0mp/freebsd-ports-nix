--- src/libstore/s3-binary-cache-store.cc.orig	2019-11-25 18:48:38 UTC
+++ src/libstore/s3-binary-cache-store.cc
@@ -54,7 +54,7 @@ class AwsLogger : public Aws::Utils::Logging::Formatte
 
     void ProcessFormattedStatement(Aws::String && statement) override
     {
-        debug("AWS: %s", chomp(statement));
+        debug("AWS: %s", chomp((const std::string &)statement));
     }
 };
 
