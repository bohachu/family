copy /Y ..\Main.swf
call "D:\Resource\AdobeAIRSDK 3.7\bin\adt" -package -target apk-captive-runtime -storetype pkcs12 -keystore ../../androidFlash.p12 -storepass 123456 Family-v1.5.0502.apk Main-app-android.xml -extdir "C:/github/flashCommon/ane/Android" Main.swf icons Resource