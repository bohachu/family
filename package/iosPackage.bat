copy /Y ..\Main.swf
call "D:\Resource\AdobeAIRSDK 4.0 Beta\bin\adt" -package -target ipa-test -provisioning-profile ../../pan_asia2.mobileprovision -storetype pkcs12 -keystore ../../pan_asia.p12 -storepass cameo Family-v1.5.0502.ipa Main-app-ios.xml -extdir "C:/github/flashCommon/ane/iOS" Main.swf Default.png Default@2x.png Default-568h@2x.png icons Resource