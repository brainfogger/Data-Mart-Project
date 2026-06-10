-- ==============================================================================
-- DATENBANKSCHEMA "BookSwap"
-- ==============================================================================

-- Aktivierung der Fremdschlüssel-Prüfung in SQLite (Zwingend für referenzielle Integrität)
PRAGMA foreign_keys = ON;

-- ------------------------------------------------------------------------------
-- 1. STAMMDATEN
-- ------------------------------------------------------------------------------

-- Tabelle ORT: Ausgelagert zur Normalisierung von Adressdaten.
CREATE TABLE ORT (
    PLZ INTEGER PRIMARY KEY, -- Eindeutige Postleitzahl als Primärschlüssel
    Stadt TEXT NOT NULL
);
-- PERFORMANCE-INDEX: Beschleunigt die in der App geforderte standortbezogene/räumliche Suche extrem.
CREATE INDEX idx_ort_plz ON ORT(PLZ);

-- Tabelle GENRE: Kategorisierung von Büchern
CREATE TABLE GENRE (
    Genre_ID INTEGER PRIMARY KEY AUTOINCREMENT,
    Bezeichnung TEXT NOT NULL
);

-- Tabelle BENUTZER: Speichert die Kern-Nutzerdaten.
CREATE TABLE BENUTZER (
    User_ID INTEGER PRIMARY KEY AUTOINCREMENT,
    Name TEXT NOT NULL,
    Email TEXT UNIQUE NOT NULL, -- GESCHÄFTSREGEL: E-Mail muss UNIQUE sein, um Doppelaccounts zu verhindern.
    Passwort TEXT NOT NULL,
    Strasse TEXT,
    PLZ_FK INTEGER,
    FOREIGN KEY(PLZ_FK) REFERENCES ORT(PLZ) -- Verknüpfung zum Wohnort
);

-- Tabelle BUCH: Speichert nur das abstrakte Werk (Metadaten), NICHT das physische Exemplar im Regal.
CREATE TABLE BUCH (
    ISBN TEXT PRIMARY KEY,
    Titel TEXT NOT NULL,
    Erscheinungsjahr INTEGER,
    Sprache TEXT,
    Genre_FK INTEGER,
    FOREIGN KEY(Genre_FK) REFERENCES GENRE(Genre_ID)
);

-- Tabelle AUTOR
CREATE TABLE AUTOR (
    Autor_ID INTEGER PRIMARY KEY AUTOINCREMENT,
    Name TEXT NOT NULL
);

-- Tabelle VERLAG
CREATE TABLE VERLAG (
    Verlag_ID INTEGER PRIMARY KEY AUTOINCREMENT,
    Name TEXT NOT NULL
);

-- ------------------------------------------------------------------------------
-- 2. TRANSAKTIONSTABELLEN (Auflösung von Mehrfachbeziehungen)
-- ------------------------------------------------------------------------------

-- Tabelle PUBLIKATION: Löst die n:m:p Beziehung zwischen Buch, Autor und Verlag auf.
-- ROBUSTHEIT (Tutor-Feedback): Diese Tabellenstruktur ist zwingend notwendig, da sie es 
-- langfristig erlaubt, Sonderfälle wie mehrere Autor:innen (Co-Autorenschaft) oder 
-- mehrere Verlage pro Werk abzubilden, ohne das Schema zu verletzen.
CREATE TABLE PUBLIKATION (
    Publikation_ID INTEGER PRIMARY KEY AUTOINCREMENT,
    ISBN_FK TEXT,
    Autor_ID_FK INTEGER,
    Verlag_ID_FK INTEGER,
    FOREIGN KEY(ISBN_FK) REFERENCES BUCH(ISBN),
    FOREIGN KEY(Autor_ID_FK) REFERENCES AUTOR(Autor_ID),
    FOREIGN KEY(Verlag_ID_FK) REFERENCES VERLAG(Verlag_ID)
);

-- Tabelle ZUSTAND: Standardisierte Zustandsbeschreibungen für physische Bücher
CREATE TABLE ZUSTAND (
    Zustand_ID INTEGER PRIMARY KEY AUTOINCREMENT,
    Bezeichnung TEXT NOT NULL
);

-- Tabelle EXEMPLAR: Das physische Objekt, das tatsächlich im Regal eines Benutzers steht.
CREATE TABLE EXEMPLAR (
    Exemplar_ID INTEGER PRIMARY KEY AUTOINCREMENT,
    ISBN_FK TEXT,
    Besitzer_ID_FK INTEGER,
    Zustand_ID_FK INTEGER,
    Bemerkung TEXT,
    FOREIGN KEY(ISBN_FK) REFERENCES BUCH(ISBN),
    FOREIGN KEY(Besitzer_ID_FK) REFERENCES BENUTZER(User_ID),
    FOREIGN KEY(Zustand_ID_FK) REFERENCES ZUSTAND(Zustand_ID)
);

-- Tabelle AUSLEIHE: Zentrale Prozess-Entität (Dreifachbeziehung: Wer leiht Was Wo).
CREATE TABLE AUSLEIHE (
    Ausleihe_ID INTEGER PRIMARY KEY AUTOINCREMENT,
    Exemplar_ID_FK INTEGER,
    Ausleiher_ID_FK INTEGER,
    UebergabeOrt_PLZ_FK INTEGER,
    Startdatum DATE NOT NULL,
    Enddatum DATE NOT NULL,
    FOREIGN KEY(Exemplar_ID_FK) REFERENCES EXEMPLAR(Exemplar_ID),
    FOREIGN KEY(Ausleiher_ID_FK) REFERENCES BENUTZER(User_ID),
    FOREIGN KEY(UebergabeOrt_PLZ_FK) REFERENCES ORT(PLZ)
);
-- GESCHÄFTSREGEL: Verhindert, dass ein und dasselbe physische Exemplar am exakt gleichen Tag doppelt verliehen wird.
CREATE UNIQUE INDEX idx_nur_eine_aktive_ausleihe ON AUSLEIHE(Exemplar_ID_FK, Startdatum);

-- Tabelle BEWERTUNG: Feedback zur Transaktion.
CREATE TABLE BEWERTUNG (
    Bewertung_ID INTEGER PRIMARY KEY AUTOINCREMENT,
    Ausleihe_ID_FK INTEGER,
    Sterne INTEGER CHECK(Sterne BETWEEN 1 AND 5), -- DATENINTEGRITÄT: Lässt nur gültige Werte von 1 bis 5 zu.
    Kommentar TEXT,
    FOREIGN KEY(Ausleihe_ID_FK) REFERENCES AUSLEIHE(Ausleihe_ID)
);

-- ==============================================================================
-- DUMMY-DATEN (INSERT)
-- ==============================================================================

INSERT INTO ORT (PLZ, Stadt) VALUES 
(10115, 'Berlin'), (20095, 'Hamburg'), (80331, 'München'), (50667, 'Köln'), (60311, 'Frankfurt'),
(70173, 'Stuttgart'), (40213, 'Düsseldorf'), (04109, 'Leipzig'), (44135, 'Dortmund'), (45127, 'Essen');

INSERT INTO GENRE (Bezeichnung) VALUES 
('Krimi'), ('Fantasy'), ('Sachbuch'), ('Science Fiction'), ('Biografie'),
('Historischer Roman'), ('Ratgeber'), ('Thriller'), ('Horror'), ('Kinderbuch');

INSERT INTO AUTOR (Name) VALUES 
('J.K. Rowling'), ('Stephen King'), ('George R.R. Martin'), ('Ken Follett'), ('Sebastian Fitzek'),
('Frank Schätzing'), ('Marc-Uwe Kling'), ('J.R.R. Tolkien'), ('Dan Brown'), ('Agatha Christie');

INSERT INTO VERLAG (Name) VALUES 
('Carlsen'), ('Heyne'), ('Bastei Lübbe'), ('Rowohlt'), ('Suhrkamp'),
('Klett-Cotta'), ('dtv'), ('Ullstein'), ('Droemer Knaur'), ('Goldmann');

INSERT INTO ZUSTAND (Bezeichnung) VALUES 
('Neu'), ('Wie neu'), ('Sehr gut'), ('Gut'), ('Akzeptabel'),
('Leichte Gebrauchsspuren'), ('Deutliche Gebrauchsspuren'), ('Mängelexemplar'), ('Beschädigt'), ('Antiquarisch');

INSERT INTO BENUTZER (Name, Email, Passwort, Strasse, PLZ_FK) VALUES 
('Max Müller', 'max@mail.de', 'pw123', 'Hauptstr. 1', 10115),
('Anna Schmidt', 'anna@mail.de', 'pw123', 'Nebenstr. 2', 20095),
('Tom Meier', 'tom@mail.de', 'pw123', 'Dorfweg 3', 80331),
('Lisa Wagner', 'lisa@mail.de', 'pw123', 'Ringstr. 4', 50667),
('Jan Becker', 'jan@mail.de', 'pw123', 'Marktplatz 5', 60311),
('Mia Hoffmann', 'mia@mail.de', 'pw123', 'Waldweg 6', 70173),
('Leo Koch', 'leo@mail.de', 'pw123', 'Bergstr. 7', 40213),
('Sara Richter', 'sara@mail.de', 'pw123', 'Talstr. 8', 04109),
('Tim Klein', 'tim@mail.de', 'pw123', 'Uferstr. 9', 44135),
('Lea Wolf', 'lea@mail.de', 'pw123', 'Gasse 10', 45127);

INSERT INTO BUCH (ISBN, Titel, Erscheinungsjahr, Sprache, Genre_FK) VALUES 
('978-3-551-55167-2', 'Harry Potter 1', 1998, 'Deutsch', 2),
('978-3-453-43382-7', 'Es', 1986, 'Deutsch', 9),
('978-3-442-26774-3', 'Game of Thrones 1', 1996, 'Deutsch', 2),
('978-3-404-14216-3', 'Die Säulen der Erde', 1989, 'Deutsch', 6),
('978-3-426-19926-8', 'Der Seelenbrecher', 2008, 'Deutsch', 8),
('978-3-462-03372-0', 'Der Schwarm', 2004, 'Deutsch', 8),
('978-3-548-37257-0', 'Die Känguru-Chroniken', 2009, 'Deutsch', 7),
('978-3-608-93666-8', 'Der Herr der Ringe', 1954, 'Deutsch', 2),
('978-3-404-15411-1', 'Sakrileg', 2003, 'Deutsch', 8),
('978-3-502-51980-5', 'Mord im Orientexpress', 1934, 'Deutsch', 1);

INSERT INTO PUBLIKATION (ISBN_FK, Autor_ID_FK, Verlag_ID_FK) VALUES 
('978-3-551-55167-2', 1, 1), ('978-3-453-43382-7', 2, 2), ('978-3-442-26774-3', 3, 3),
('978-3-404-14216-3', 4, 3), ('978-3-426-19926-8', 5, 9), ('978-3-462-03372-0', 6, 4),
('978-3-548-37257-0', 7, 8), ('978-3-608-93666-8', 8, 6), ('978-3-404-15411-1', 9, 3),
('978-3-502-51980-5', 10, 10);

INSERT INTO EXEMPLAR (ISBN_FK, Besitzer_ID_FK, Zustand_ID_FK, Bemerkung) VALUES 
('978-3-551-55167-2', 1, 3, 'Keine Mängel'), ('978-3-453-43382-7', 2, 4, 'Eselsohren'),
('978-3-442-26774-3', 3, 1, 'Ungelesen'), ('978-3-404-14216-3', 4, 6, 'Wasserschaden Seite 1'),
('978-3-426-19926-8', 5, 2, 'Top Zustand'), ('978-3-462-03372-0', 6, 5, 'Rücken geknickt'),
('978-3-548-37257-0', 7, 3, ''), ('978-3-608-93666-8', 8, 8, 'Stempel unten'),
('978-3-404-15411-1', 9, 4, ''), ('978-3-502-51980-5', 10, 10, 'Sehr altes Cover');

INSERT INTO AUSLEIHE (Exemplar_ID_FK, Ausleiher_ID_FK, UebergabeOrt_PLZ_FK, Startdatum, Enddatum) VALUES 
(1, 2, 10115, '2026-02-01', '2026-02-15'), (2, 3, 20095, '2026-02-02', '2026-02-16'),
(3, 4, 80331, '2026-02-03', '2026-02-17'), (4, 5, 50667, '2026-02-04', '2026-02-18'),
(5, 6, 60311, '2026-02-05', '2026-02-19'), (6, 7, 70173, '2026-02-06', '2026-02-20'),
(7, 8, 40213, '2026-02-07', '2026-02-21'), (8, 9, 04109, '2026-02-08', '2026-02-22'),
(9, 10, 44135, '2026-02-09', '2026-02-23'), (10, 1, 45127, '2026-02-10', '2026-02-24');

INSERT INTO BEWERTUNG (Ausleihe_ID_FK, Sterne, Kommentar) VALUES 
(1, 5, 'Super gelaufen!'), (2, 4, 'Buch etwas zerknickt, sonst gut.'),
(3, 5, 'Spannendes Buch.'), (4, 3, 'Übergabe hat sich verzögert.'),
(5, 5, 'Gerne wieder.'), (6, 4, 'Alles ok.'),
(7, 5, 'Sehr netter Kontakt.'), (8, 2, 'Buch roch nach Rauch.'),
(9, 5, 'Perfekt.'), (10, 5, 'Klassiker!');

-- ==============================================================================
-- TESTFÄLLE (SELECT)
-- ==============================================================================

SELECT 
    BUCH.Titel, 
    GENRE.Bezeichnung AS Genre,
    BENUTZER.Name AS Besitzer, 
    ORT.Stadt, 
    ORT.PLZ
FROM EXEMPLAR
JOIN BUCH ON EXEMPLAR.ISBN_FK = BUCH.ISBN
JOIN GENRE ON BUCH.Genre_FK = GENRE.Genre_ID
JOIN BENUTZER ON EXEMPLAR.Besitzer_ID_FK = BENUTZER.User_ID
JOIN ORT ON BENUTZER.PLZ_FK = ORT.PLZ
WHERE ORT.Stadt = 'Berlin';

SELECT 
    BENUTZER.Name AS Ausleiher, 
    BUCH.Titel AS Ausgeliehenes_Buch, 
    AUSLEIHE.Startdatum, 
    AUSLEIHE.Enddatum,
    ORT.Stadt AS Uebergabeort
FROM AUSLEIHE
JOIN BENUTZER ON AUSLEIHE.Ausleiher_ID_FK = BENUTZER.User_ID
JOIN EXEMPLAR ON AUSLEIHE.Exemplar_ID_FK = EXEMPLAR.Exemplar_ID
JOIN BUCH ON EXEMPLAR.ISBN_FK = BUCH.ISBN
JOIN ORT ON AUSLEIHE.UebergabeOrt_PLZ_FK = ORT.PLZ;

SELECT 
    BUCH.Titel, 
    AUTOR.Name AS Autor, 
    VERLAG.Name AS Verlag, 
    BUCH.Erscheinungsjahr
FROM PUBLIKATION
JOIN BUCH ON PUBLIKATION.ISBN_FK = BUCH.ISBN
JOIN AUTOR ON PUBLIKATION.Autor_ID_FK = AUTOR.Autor_ID
JOIN VERLAG ON PUBLIKATION.Verlag_ID_FK = VERLAG.Verlag_ID;