copy /Y ..\Main.swf
call "D:\Resource\AdobeAIRSDK 15 15.0.0.249\bin\adt" -package -target ipa-test -provisioning-profile ../../cameo_enterprise.mobileprovision -storetype pkcs12 -keystore ../../cameo_enterprise.p12 -storepass cameo Family-v2.0.1203.ipa Main-app-ios.xml -extdir "C:/github/flashCommon/ane/iOS" Main.swf Default.png Default@2x.png Default-568h@2x.png icons