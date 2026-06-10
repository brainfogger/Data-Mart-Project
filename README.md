# BookSwap - Datenbank-Implementierung

Dieses Repository enthält das vollständige relationale Datenbankschema sowie die Testdaten für die Buchtausch-App "BookSwap". Das Projekt wurde im Rahmen des Kurses DLBDSPBDM01_D (Data-Mart-Erstellung in SQL) an der IU Internationale Hochschule entwickelt.

## Projektbeschreibung
BookSwap ist das Konzept für eine lokale Sharing-Economy-Plattform, auf der Nutzer:innen physische Bücher zum temporären Tausch anbieten und ausleihen können. 

Die Datenbank wurde entwickelt, um ein dynamisches Rollenkonzept abzubilden, bei dem Benutzer fließend als Anbieter und Ausleiher agieren. Ein besonderer Fokus bei der Modellierung lag auf der Auflösung komplexer Dreifachbeziehungen (z. B. bei Publikationen oder der räumlichen Zuordnung von Ausleihvorgängen) sowie der Sicherstellung von Datenintegrität durch entsprechende Constraints und Indizes.

### Technische Details
* **DBMS:** SQLite
* **Struktur:** 11 normalisierte Tabellen (3. Normalform)
* **Testdaten:** 110 Dummy-Datensätze (10 pro Tabelle) zur Validierung der Geschäftslogik.

## Dateien in diesem Repository
* `BookSwap.db`: Die lauffähige, vorkonfigurierte SQLite-Datenbankdatei inklusive aller Tabellen und Dummy-Datensätze.
* `Benz-Niklas_10249383_DLBDSPBDM01_D_Erarbeitungsphase_SQL.sql`: Das vollständige SQL-Skript (DDL & DML). Es enthält die Tabellenerstellung (inkl. Kommentare zur technischen Logik), das Einfügen der Datensätze und komplexe `JOIN`-Testabfragen (z. B. für eine standortbezogene Suche).

## Installationsanleitung & Nutzung
Um die Datenbank lokal auszuführen und die Abfragen zu testen, gehe wie folgt vor:

1. Lade dir die kostenlose Open-Source-Software [DB Browser for SQLite](https://sqlitebrowser.org/) herunter und installiere sie.
2. Lade die Datei `BookSwap.db` aus diesem Repository herunter oder klone das gesamte Repository auf deinen Rechner.
3. Öffne den *DB Browser for SQLite* und klicke oben auf **"Datenbank öffnen"**.
4. Wähle die heruntergeladene `BookSwap.db` Datei aus.
5. Im Reiter **"Daten durchsuchen"** kannst du dir die befüllten Tabellen ansehen. Im Reiter **"SQL ausführen"** können eigene Queries und Testabfragen gegen die Datenbank gefahren werden.
