# KAG App
Tests Develop: ![Tests Develop](https://github.com/kagonlineteam/KAG-APP/workflows/Tests/badge.svg?branch=develop)<br>
Tests Master: ![Tests Develop](https://github.com/kagonlineteam/KAG-APP/workflows/Tests/badge.svg?branch=master)<br>
Deploy Master: ![main](https://github.com/kagonlineteam/KAG-APP/workflows/main/badge.svg?branch=master)

Die KAG App für iOS, Android und [Web](https://app.kag-langenfeld.de).
Geschrieben 
 - 2019: Robin Jipps und Felix Strick.
 - 2020: ...

## API
Die App ist mit der neusten Version von [sym-api](https://github.com/kagonlineteam/sym-api) kompatibel.
Ältere Versionen werden meistens nicht unterstützt

## Starten

Um die App zu starten muss Flutter installiert sein.
Dann mit flutter run --release starten.

## Deploy
Der Master Branch dient als Stable Branch. Alles was sich auf dem Master befindet muss stabil sein.
Der Master Branch wird automatisch für Android gebaut und die Datei kann daraufhin in Github Actions heruntergeladen werden als APK und AAB. 
Die AAB muss hochgeladen werden in die Google Play Console.
Die APK soll zu dem Release auf Github hinzugefügt werden.
IOS muss von einem MacOS Gerät aus über XCode gebaut und deployed werden.
Wie das geht steht [hier](https://flutter.dev/docs/deployment/ios#create-a-build-archive)
[Web](https://app.kag-langenfeld.de) wird automatisch deployed.

## Aktuelle Version
VC-8
### Versionierung
Die aktuelle Versionierung stimmt mit dem VersionCode von Android bzw. der Buildnummer von IOS überein. 

