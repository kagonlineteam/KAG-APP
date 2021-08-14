# KAG App
This repository does contain the app of a german school.

Dieses Repository beinhaltet die App des Konrad-Adenauer-Gymnasium Langenfelds.
Der Code wird unter der GNU GPLv3 (siehe LICENSE Datei) bereitgestellt.
Die App wurde von Schülern des K-A-Gs entwickelt und wird von diesen betreut.
Pull Requests sind willkommen.


|Typ|Stable|Develop/Master|
|---|------|-------|
|Tests/Linter|![Tests Master](https://github.com/kagonlineteam/KAG-APP/workflows/Tests/badge.svg?branch=stable)|![Tests Develop](https://github.com/kagonlineteam/KAG-APP/workflows/Tests/badge.svg?branch=master)|
|Deploy-Web|![deployWeb](https://github.com/kagonlineteam/KAG-APP/workflows/deployWeb/badge.svg?branch=stable)||
|Deploy-Stores|![deployStore](https://github.com/kagonlineteam/KAG-APP/workflows/deployStores/badge.svg?branch=stable)||


Die KAG App für iOS, Android, MacOS und [Web](https://vplan.kag-langenfeld.de).
Geschrieben 
 - 2020 & 2021: [Max](https://github.com/mindmax-dev), [Nils](https://github.com/Nils2006) und [Felix](https://github.com/strifel).
 - 2019: [Robin](https://github.com/robmroi03) und [Felix](https://github.com/strifel).

## API
Die API und deren Source Code ist nicht öffentlich.
Die App ist mit der neusten Version der API kompatibel.

## Starten

Um die App zu starten muss Flutter installiert sein.
Dann mit `flutter run` starten.

## Development
Bei der Entwicklung ist empfholen die Web Version lokal auszuführen.
Wir halten uns grundsätzlich an die [CONTRIBUTING.MD](https://github.com/kagonlineteam/KAG-APP/blob/master/CONTRIBUTING.md).
Deswegen sollte diese vorher gelesen werden.

Alle Pull Requests sollten sich im Normalfall an den master richten

## Forking
Gerne kann das Repository unter den Bedingungen der Lizenz geforked werden.
Änderungen für den Eigengebrauch müssen vermutlich hauptsächlich in den [API Dateien](https://github.com/kagonlineteam/KAG-APP/tree/master/lib/api) vorgenommen werden.
Die Farben des Designes können in der [main.dart](https://github.com/kagonlineteam/KAG-APP/blob/master/lib/main.dart) angepasst werden.

## Deploy
Alles was sich auf dem stable Branch befindet muss stabil sein.
Der stable Branch wird bei einem Release automatisch für Android gebaut in den Playstore alpha Release deployed (dort sollten dann noch Changenotes hinzugefügt werden).
IOS muss von einem MacOS Gerät aus über XCode gebaut und deployed werden. (Plan zum automatischen deployen ist [Issue #88](https://github.com/kagonlineteam/KAG-APP/issues/88))
Wie das geht steht [hier](https://flutter.dev/docs/deployment/ios#create-a-build-archive)
[Full Web](https://app.kag-langenfeld.de) und [VPlan](https://vplan.kag-langenfeld.de) wird automatisch beim push auf stable deployed.
Die App ist mit MacOS kompatibel, jedoch muss diese noch selber gebaut werden.

## Aktuelle Version
### Versionierung
Die aktuelle Versionierung stimmt mit dem VersionCode von Android bzw. der Buildnummer von IOS überein. <br>
Die Version wird automatisch vom Buildscript bestimmt und stimmt mit der Anzahl der Releases überein.

