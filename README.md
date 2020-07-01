# KAG App
|Typ|Stable|Develop/Master|
|---|------|-------|
|Tests/Linter|![Tests Master](https://github.com/kagonlineteam/KAG-APP/workflows/Tests/badge.svg?branch=stable)|![Tests Develop](https://github.com/kagonlineteam/KAG-APP/workflows/Tests/badge.svg?branch=master)|
|Deploy-Web|![deployWeb](https://github.com/kagonlineteam/KAG-APP/workflows/deployWeb/badge.svg?branch=stable)||
|Deploy-Stores|![deployStore](https://github.com/kagonlineteam/KAG-APP/workflows/deployStores/badge.svg?branch=stable)||

Alle Workflows sollten immer grün sein!

Die KAG App für iOS, Android und [Web](https://vplan.kag-langenfeld.de).
Geschrieben 
 - 2020: [Max](https://github.com/mindmax-dev), [Nils](https://github.com/Nils2006) und [Felix](https://github.com/strifel).
 - 2019: [Robin](https://github.com/robmroi03) und [Felix](https://github.com/strifel).

## API
Die App ist mit der neusten Version von [sym-api](https://github.com/kagonlineteam/sym-api) kompatibel.
Ältere Versionen sollten im besten Fall noch unterstützt werden, tun es jedoch meistens nicht.

## Starten

Um die App zu starten muss Flutter installiert sein.
Dann mit `flutter run` starten.

## Development
Bei der Entwicklung ist für eine einfachere Entwicklung empfholen die Web Version lokal auszuführen.
Natürlich ist es aber auch wichtig zu testen ob alles unter IOS und Android funktioniert.
Wir halten uns grundsätzlich an die [CONTRIBUTING.MD](https://github.com/kagonlineteam/KAG-APP/blob/master/CONTRIBUTING.md).
Deswegen sollte diese vorher gelesen werden.

Alle Pull Requests sollten sich im Normalfall an den Develop richten

## Deploy
Alles was sich auf dem stable Branch befindet muss stabil sein.
Der stable Branch wird bei einem Release automatisch für Android gebaut und die Datei kann daraufhin in Github Actions heruntergeladen werden als APK und in den Playstore alpha Release deployed (dort sollten dann noch Changenotes hinzugefügt werden).
IOS muss von einem MacOS Gerät aus über XCode gebaut und deployed werden. (Plan zum automatischen deployen ist [Issue #88](https://github.com/kagonlineteam/KAG-APP/issues/88))
Wie das geht steht [hier](https://flutter.dev/docs/deployment/ios#create-a-build-archive)
[Full Web](https://app.kag-langenfeld.de) und [VPlan](https://vplan.kag-langenfeld.de) wird automatisch beim push auf stable deployed.

## Aktuelle Version
### Versionierung
Die aktuelle Versionierung stimmt mit dem VersionCode von Android bzw. der Buildnummer von IOS überein. <br>
Die Version wird automatisch vom Buildscript bestimmt und stimmt mit der Anzahl der Releases überein.

