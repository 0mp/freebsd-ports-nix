--- src/libstore/s3-binary-cache-store.cc.orig	2019-10-10 13:03:46 UTC
+++ src/libstore/s3-binary-cache-store.cc
@@ -54,7 +54,7 @@ class AwsLogger : public Aws::Utils::Logging::Formatte
 
     void ProcessFormattedStatement(Aws::String && statement) override
     {
-        debug("AWS: %s", chomp(statement));
+        debug("AWS: %s", chomp((const std::string &)statement));
     }
 };
 
@@ -139,8 +139,8 @@ S3Helper::DownloadResult S3Helper::getObject(
 
     auto request =
         Aws::S3::Model::GetObjectRequest()
-        .WithBucket(bucketName)
-        .WithKey(key);
+        .WithBucket(bucketName.c_str())
+        .WithKey(key.c_str());
 
     request.SetResponseStreamFactory([&]() {
         return Aws::New<std::stringstream>("STRINGSTREAM");
@@ -155,7 +155,7 @@ S3Helper::DownloadResult S3Helper::getObject(
         auto result = checkAws(fmt("AWS error fetching '%s'", key),
             client->GetObject(request));
 
-        res.data = decompress(result.GetContentEncoding(),
+        res.data = decompress(result.GetContentEncoding().c_str(),
             dynamic_cast<std::stringstream &>(result.GetBody()).str());
 
     } catch (S3Error & e) {
@@ -238,8 +238,8 @@ struct S3BinaryCacheStoreImpl : public S3BinaryCacheSt
 
         auto res = s3Helper.client->HeadObject(
             Aws::S3::Model::HeadObjectRequest()
-            .WithBucket(bucketName)
-            .WithKey(path));
+            .WithBucket(bucketName.c_str())
+            .WithKey(path.c_str()));
 
         if (!res.IsSuccess()) {
             auto & error = res.GetError();
@@ -302,7 +302,7 @@ struct S3BinaryCacheStoreImpl : public S3BinaryCacheSt
 
             std::shared_ptr<TransferHandle> transferHandle =
                 transferManager->UploadFile(
-                    stream, bucketName, path, mimeType,
+                    stream, bucketName.c_str(), path, mimeType,
                     Aws::Map<Aws::String, Aws::String>(),
                     nullptr /*, contentEncoding */);
 
@@ -320,8 +320,8 @@ struct S3BinaryCacheStoreImpl : public S3BinaryCacheSt
 
             auto request =
                 Aws::S3::Model::PutObjectRequest()
-                .WithBucket(bucketName)
-                .WithKey(path);
+                .WithBucket(bucketName.c_str())
+                .WithKey(path.c_str());
 
             request.SetContentType(mimeType);
 
@@ -393,7 +393,7 @@ struct S3BinaryCacheStoreImpl : public S3BinaryCacheSt
             auto res = checkAws(format("AWS error listing bucket '%s'") % bucketName,
                 s3Helper.client->ListObjects(
                     Aws::S3::Model::ListObjectsRequest()
-                    .WithBucket(bucketName)
+                    .WithBucket(bucketName.c_str())
                     .WithDelimiter("/")
                     .WithMarker(marker)));
 
