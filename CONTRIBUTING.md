# Mitwirken an der App

In diesem Dokument werden die Richtlinien und Konventionen zur Kollaboration an diesem Repository festgelegt.
**Dieses Dokument sollte gelesen werden, bevor man an diesem Repository mitwirken möchte.**

## Änderungen an diesem Dokument
Diese CONTRIBUTING.md ist sehr ähnlich zu der von der API.
Es unterscheidet sich jedoch von dem der API, weshalb empfholen wird das Dokument erneut durchzulesen.

Wichtige Unterschiede sind:
- Wir nutzen GitMojis auf dem Master/Stable Branch
- Es muss nicht umbedingt jede PR exakt einen Commit herausbringen. Es kann sein, dass eine PR mehrere Commits auf den Master bringt (Dann in einem rebase)
- Bei einem Stable Issue muss nur eine PR erstellt werden
- Eine PR kann auch ohne ein Issue erstellt werden
- Der Stable ist ein Rolling Release und wird deswegen nicht nur bei einer neuen Version gepusht. (Web wird direkt vom Stable deployed)

## Inhaltsverzeichnis
- [In diesem Dokument erhaltene Namensgebungen](#in-diesem-dokument-erhaltene-namensgebungen)
- [Welche Standard Branches hat das Projekt und wofür werden diese genutzt?](#welche-standard-branches-hat-das-projekt-und-wofür-werden-diese-genutzt?)
- [Programmierkonventionen](#programmierkonventionen)
- [Git-Konventionen](#git-konventionen)
- [Wie frage ich ein neues Feature an?](#wie-frage-ich-ein-neues-feature-an?)
  - [Template für Feature-Issues](#template-für-feature-issues)
- [Wie implementiere ich ein neues Feature?](#wie-implementiere-ich-ein-neues-feature?)
- [Wie melde ich einen Bug?](#wie-melde-ich-einen-bug?)
  - [Template für Bug-Issues](#template-für-bug-issues)
- [Wie implementiere ich einen Bugfix?](#wie-implementiere-ich-einen-bugfix?)
- ["Präziser Commit" Definition](#"präziser-commit"-definition)

## In diesem Dokument erhaltene Namensgebungen
- **"branch"**, engl. für Zweig. Beschreibt das Abzweigen eines bestimmten Standes des Projekts. Diese Abzweigung kann dann beliebig bearbeitet werden, ohne den ursprünglichen Stand zu ändern.
- **"merge"**, engl. für verschmelzen. Beim "merge" wird ein Branch A in einen Branch B "gemerged". Danach enthält der Branch B den ursprünglichen Stand von B plus alle Änderungen die in A gemacht wurden.
- **"pull request"**, kurz "PR". Bei einem PR wird eine Anforderung gestellt, einen gewissen Branch A in einen anderen Branch B zu "mergen". Dabei muss der PR von einem sogenannten "reviewer" kontrolliert werden. Mit der Zustimmung des "rewiewers" kann dann der Branch A in den Branch B "gemerged" werden. Dabei können auch mehrere "reviewer" angegeben werden.
- **"reviewer"**, engl. für Gutachter. Ein oder mehrere "reviewer" sind Personen mit der Berechtigung, Änderungen am Code zu bewerten. Diese müssen beim Erstellen eines "PRs" immer angegeben werden. Übliche Aufgaben des "rewievers" sind auf die Funktionalität des Codes zu achten, und zu kontrollieren ob vereinbarte Regeln beim Programmieren eingehalten wurden.
- **"deployment"**, engl. für Einsatz. Beim "deployment" wird ein Code/Programm auf einem Server eingesetzt. Dabei kann sich die Umgebung des Einsatzes erstmal unterscheiden. Dazu im Folgenden mehr.
- **"production"**, engl. für Produktion (eher als "produktiv" gemeint). Wird ein Code von "staging" auf "production" "deployed", bedeutet das, dass der Code in der "staging" Umgebung alle Voraussetzungen und Tests erfüllt hat und bereit ist, produktiv eingesetzt zu werden. Code in "production" wird letztendlich von Endnutzern genutzt und darf aus diesem Grund keine Fehler ("bugs") enthalten und muss immer einsatzbereit sein.
- **"bug"**, engl. für Fliege (historisch für Fehler in Computern gemeint). Wenn man von einem "bug" spricht, dann spricht man von einem Fehler im Code. Diesen gilt es zu beheben damit die Qualität des Codes besser wird und dieser in "production" eingesetzt werden kann.


## Welche Standard Branches hat das Projekt und wofür werden diese genutzt?
Dieses Projekt hat zwei Branches. Einen "master" Branch und einen "stable" Branch.
__Momentan wird dies leider noch nicht umgesetzt, das soll aber nach dem ersten Release passieren__

Der "master" Branch spiegelt den aktuellen Entwicklungsstand des Projekts wieder. Hierraus werden "feature" und "bugfix" Branches erstellt und nach Bearbeitung wieder in den "master" "gemerged". Dazu aber in den jeweiligen Unterpunkten mehr.
Der "master" Branch wird in einer "staging"-Umgebung deployed wodurch dieser im Einsatz getestet werden kann.
Wenn die Tests erfolgreich sind und keine unfertigen Änderungen vorhanden sind wird der Master vom Maintainer auf den stable gepusht.

Der "stable" Branch erfüllt die Anforderung, immer einsatzbereit zu sein. Das bedeutet dass man das Programm aus dem "stable" Branch immer einsetzen kann und es funktionieren wird. Aus diesem Grund wird auch zunächst auf dem "master" entwickelt und getestet, bevor die erfolgreichen Änderungen in den "stable" Branch "gemerged" werden.

## Programmierkonventionen
Innerhalb des Codes werden so weit es möglich ist Klassen, Attribute, Methode, etc. englisch benannt.  In Ausnahmefällen können deutsche Begriffe verwendet werden, wenn diese zur Verständlichkeit des Codes beitragen. Auch Kommentare im Code werden auf Englisch verfasst.
Der Linter sollte vor dem Commit ausgeführt werden (`flutter analyze`) und überprüft werden, dass dieser klappt.

## Git-Konventionen
- **Sprache**: Sämtliche Titel, Beschreibungen und Kommentare von Issues und PRs erfolgen auf Deutsch. Die Commits der nach den PRs werden allerdings auf Englisch formuliert.
- **Merge**: Beim mergen versuchen wir, dass möglichst gut beschriebene Commits nach dem "Ein Feature=Ein Commit" Prinzip auf den Master zu bringen. Hierfür kann entweder ein Squash Merge verwendet werden oder die Commits manuell mit einem lokalen interaktiven rebase (`rebase -i HEAD~Anzahl Commits`) verbessert werden und dann auf den Master rebasen. Jeder Commit sollte ein Emoji/Gitmoji beinhalten. Ein normaler Merge sollten vermieden werden (bis auf sehr seltene ausnahmen).
- **Force Pushes**: Force Pushes sind auf Feature/Bug Branches zulässig. Auf dem Master und Release sollten diese nicht verwendet werden, da dies unnötige Probleme verursacht.

## Wie frage ich ein neues Feature an?
Um ein neues Feauture anzufragen wird ein Issue erstellt, dabei ist das GitHub Template für Features auszuwählen. Das Template enthält eine allgemeine Formatierung für die wichtigsten Informationen, die alle beantwortet werden müssen.

### Template für Feature-Issues
**Titel**: Kurze Zusammenfassung des Features
**Kommentar**:
- Detaillierte Beschreibung des Features
- Use-Case: Wie kann das Feature verwendet werden?
- Für wen ist das Feature und warum?
- Vorher zu erfüllende Voraussetzungen für das Feature
- Links/Referenzen

**Assignees**: Ggf. die Person die dieses Feature bearbeiten soll. Man kann sich auch selber angeben.
**Projects**: "Aufgabenübersicht" hinzufügen, GitHub sollte das Issue automatisch in die Todo  Spalte tun.
**Labels**:
- Das "feature" Label setzen
- Eine Priorität setzen, "prio 1" hat höchste Priorität und "prio 3" die niedrigste

**Milestone**: Ggf. das Feature einem Milestone hinzufügen, falls dieses Feature in einem nahen Release beinhalten sein soll

## Wie implementiere ich ein neues Feature?
Wenn du ein neues Feature implementieren willst beachte bitte folgende Schritte:

- Suche das zugehörige GitHub Issue und weise (Assignee) es dir selber zu.
- Suche die Issue Nummer heraus. Diese findest du in dem URL Bereich deines Browsers wenn du das Issue aufgerufen hast (z.B. https://github.com/kagonlineteam/sym-api/issues/43).
- Erstelle eine neue Branch ausgehend vom "master" Branch mit beginnend mit "feature-ISSUE_NUMMER". Dabei ist es egal, wo der Branch liegt (eigener Nutzer oder kagonlineteam).

In diesem neuen Branch solltst du an der Implementierung des neuen Features arbeiten:
- Die einzelnen Commits sollten eine englische Commit-Message haben.
- Die Commits sollten zudem kleinschrittig gemacht werden. (Siehe auch Git-Konventionen Mergen)

Wenn du fertig mit der Implementierung bist, erstelle mit den folgenden Schritten einen Pull Request um deine Implementierung dem "master" Branch hinzuzufügen.


Erstelle eine Pull request mit folgenden Eigenschaften:
- **Base**: "master", Compare (dein Branch)
- **Titel**: "Implementation von #ISSUE: TITLE" implementieren
- **Kommentar**: Kurze Beschreibung des Features das hinzugefügt werden soll
- **Reviewers**: Personen die deine Implementation kontrollieren sollen, bevor sie in den "master" Branch gemerged wird
- **Assignees**: Du selber, ggf. andere Personen die an dem Feature arbeiten.
- **Labels**: Entsprechende Labels die es erleichtern, die Pull Request einzuordnen.
  - Eine Priorität setzen, "prio 1" hat höchste Priorität und "prio 3" die niedrigste
- **Projects**: Aufgabenübersicht, Spalte "In Progress"
- **Milestones**: Den entsprechenden Milestone, zu dem diese Implementierung gehören soll
- **Linked Issues**: Das zugehörige Issue zum Feature

Der von dir angegebene Reviewer wird sich deinen Code nun angucken und ggf. Verbesserungsvorschläge in der Pull Request äußern (oder kleinere Dinge selber verschönern). Nachdem du die Zustimmung des Reviewers hast, kann der Hauptverantwortliche der Repository die Änderungen in einem ausführlichen, präzisen Commit mergen (für die APP: strifel). Wenn du willst kannst du deinen Branch vorher schon einmal aufräumen.


## Wie melde ich einen Bug?
Um einen Bug zu melden wird ein Issue mit dem Template für Issues erstellt. Das Template enthält eine allgemeine Formatierung für die wichtigsten Informationen, die alle beantwortet werden müssen.
Sollten der Bug klein sein und du diesen sehr schnell lösen können (< 20 Minuten) kannst auch direkt den Bug fixen und eine PR erstellen.

### Template für Bug-Issues
**Titel**: Kurze Zusammenfassung des Bugs
**Kommentar**:
- Was funktioniert nicht?
- Wie sollte es eigentlich funktionieren?
- Schritte um den Fehler zu reproduzieren
- Fehlermeldung (ggf. inkl. fehlerhaftem Code)
- Erste Lösungsvorschläge
- Was sonst noch getan werden muss um diesen Bug zu lösen (z.B. Änderungen außerhalb des Codes)

**Assignees**: Ggf. die Person die diesen Bug bearbeiten soll. Man kann sich auch selber angeben.
**Projects**: "Aufgabenübersicht" hinzufügen, GitHub sollte das Issue automatisch in der Todo Spalte hinzufügen.
**Labels**:
- Das "bug" Label setzen
- Eine Priorität setzen, "prio 1" hat höchste Priorität und "prio 3" die niedrigste
- Falls der Bug in "production" auftritt und dort auch schnellsten gelöst werden soll, bitte zusätzlich das "production" Label setzen

**Milestone**: Den Bug einem der künftigen Releases hinzufügen (sicherlich abhängig von der Größe und Wichtigkeit des Bugs)


## Wie implementiere ich einen Bugfix?
Wenn du einen Bugfix implementieren willst beachte bitte folgende Schritte:

- Suche das zugehörige GitHub Issue und weise es dir selber zu.
- Suche die Issue Nummer heraus. Diese findest du in dem URL Bereich deines Browsers wenn du das Issue aufgerufen hast (z.B. https://github.com/kagonlineteam/sym-api/issues/43)
- Neuen Branch basierend auf dem Bug erstellen
- Falls das zugehörige Issue das Label "production" in kombination mit "bug" hat, erstelle eine neue Branch ausgehend vom "stable" Branch den Namen anfangend mit "hotfix-ISSUE_NUMMER"
- Falls das zugehörige Issue das Label "production" nicht hat, erstelle eine neue Branch ausgehend vom "master" Branch den Namen anfangend mit "bugfix-ISSUE_NUMMER"

In diesem neuen Branch sollst du an der Lösung des Bugs arbeiten:

- Die einzelnen Commits sollten eine englische Commit-Message haben.
- Die Commits sollten zudem kleinschrittig gemacht werden. (Siehe auch Git-Konventionen Mergen)

Wenn du fertig mit der Implementierung bist, erstelle mit den folgenden Schritten einen Pull Request um deine Implementierung dem "master" Branch hinzuzufügen.


Erstelle eine Pull request mit folgenden Eigenschaften:
- **Base**: "master", Compare "bugfix-ISSUE_NUMMER"
  - Falls der Bug einen Production Bug behebt bitte das Production Label hinzufügen der damit Hauptverantwortliche der Repository daran denkt den Fix auch in den Stable zu mergen.
- **Titel**: "Fix bug ISSUE_NUMMER"
- **Kommentar**: Kurze Beschreibung des Lösungsansatzes der hinzugefügt werden soll.
- **Reviewers**: Personen die deine Implementation kontrollieren sollen, bevor sie in den "master" Branch gemerged wird
- **Assignees**: Du selber, ggf. andere Personen die an dem Bug arbeiten.
- **Labels**: Entsprechende Labels die es erleichtern, die Pull Request einzuordnen.
  - Eine Priorität setzen, "prio 1" hat höchste Priorität und "prio 3" die niedrigste
- **Projects**: Aufgabenübersicht, Spalte "In Progress"
- **Milestones**: Den entsprechenden Milestone, zu dem dieser Bugfix gehören soll
- **Linked Issues**: Das zugehörige Issue zum Bug


Der von dir angegebene Reviewer wird sich deinen Code nun angucken und ggf. Verbesserungsvorschläge in der Pull Request äußern (oder kleinere Dinge selber verschönern). Nachdem du die Zustimmung des Reviewers hast, kann der Hauptverantwortliche der Repository die Änderungen in einem ausführlichen, präzisen Commit mergen (für die APP: strifel). Wenn du willst kannst du deinen Branch vorher schon einmal aufräumen.

### "Präziser Commit" Definition
- Überschrift:
    - Für einen Bugfix: :bug: Was in dem Commit passiert ist
    - Für ein Feature: [Passender Gitmoji](https://gitmoji.carloscuesta.me/) Was in dem Commit passiert ist
- Ausführlicher Teil des Commits fasst zuerst die Implementation zusammen (auf Englisch) und listet Änderungen auf, die die ganze App betreffen.
- Am Ende kommen Referenzen zu Issues