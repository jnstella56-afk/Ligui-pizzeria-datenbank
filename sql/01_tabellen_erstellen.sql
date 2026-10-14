-- Datenbank erstellen
DROP DATABASE IF EXISTS luigi_pizzeria;

CREATE DATABASE luigi_pizzeria
DEFAULT CHARACTER SET utf8mb4
DEFAULT COLLATE utf8mb4_unicode_ci;

USE luigi_pizzeria;


-- =====================================================
-- Tabelle: Kategorie
-- Zweck: Speichert Produktkategorien wie Pizza, Pasta, Dessert, Salat und Getränke.
-- =====================================================

CREATE TABLE Kategorie (
  Kategorie_id INT NOT NULL AUTO_INCREMENT,
  Kategorie_name VARCHAR(45) NOT NULL,

  PRIMARY KEY (Kategorie_id),

  CONSTRAINT uq_kategorie_name
    UNIQUE (Kategorie_name),

  CONSTRAINT chk_kategorie_name
    CHECK (TRIM(Kategorie_name) <> '')
) ENGINE = InnoDB;


-- =====================================================
-- Tabelle: Produkt
-- Zweck: Speichert angebotene Speisen und Getränke.
--        Die Tabelle Produkt bildet die digitale Speisekarte ab.
-- =====================================================

CREATE TABLE Produkt (
  Produkt_id INT NOT NULL AUTO_INCREMENT,
  Produktname VARCHAR(100) NOT NULL,
  Preis DECIMAL(10,2) NOT NULL,
  Beschreibung TEXT NULL,
  Aktiv BOOLEAN NOT NULL DEFAULT TRUE,
  Kategorie_id INT NOT NULL,

  PRIMARY KEY (Produkt_id),

  CONSTRAINT uq_produkt_name
    UNIQUE (Produktname),

  CONSTRAINT chk_produkt_preis
    CHECK (Preis > 0),

  CONSTRAINT chk_produkt_name_nicht_leer
    CHECK (TRIM(Produktname) <> ''),

  CONSTRAINT fk_produkt_kategorie
    FOREIGN KEY (Kategorie_id)
    REFERENCES Kategorie(Kategorie_id)
    ON UPDATE CASCADE
    ON DELETE RESTRICT
) ENGINE = InnoDB;


-- =====================================================
-- Tabelle: Kunde
-- Zweck: Speichert Kundendaten für Reservierungen und registrierte spontane Gäste.
--        Mindestens Telefonnummer oder E-Mail muss vorhanden sein.
-- =====================================================

CREATE TABLE Kunde (
  Kunde_id INT NOT NULL AUTO_INCREMENT,
  Vorname VARCHAR(100) NOT NULL,
  Nachname VARCHAR(100) NOT NULL,
  Telefonnummer VARCHAR(30) NULL,
  Email VARCHAR(100) NULL,

  PRIMARY KEY (Kunde_id),

  CONSTRAINT uq_kunde_email
    UNIQUE (Email),

  CONSTRAINT uq_kunde_telefonnummer
    UNIQUE (Telefonnummer),

  CONSTRAINT chk_kunde_vorname
    CHECK (TRIM(Vorname) <> ''),

  CONSTRAINT chk_kunde_nachname
    CHECK (TRIM(Nachname) <> ''),

  CONSTRAINT chk_kunde_kontakt
    CHECK (
      NULLIF(TRIM(Telefonnummer), '') IS NOT NULL
      OR
      NULLIF(TRIM(Email), '') IS NOT NULL
    ),

  CONSTRAINT chk_kunde_telefonnummer_nicht_leer
    CHECK (
      Telefonnummer IS NULL OR TRIM(Telefonnummer) <> ''
    ),

  CONSTRAINT chk_kunde_email_nicht_leer
    CHECK (
      Email IS NULL OR TRIM(Email) <> ''
    )
) ENGINE = InnoDB;


-- =====================================================
-- Tabelle: Tisch
-- Zweck: Speichert die Tische der Pizzeria mit ihrer Sitzplatzanzahl.
--        Die Tischnummer dient als eindeutiger Primärschlüssel.
-- =====================================================

CREATE TABLE Tisch (
  Tisch_nummer INT NOT NULL,
  Sitzplaetze INT NOT NULL,

  PRIMARY KEY (Tisch_nummer),

  CONSTRAINT chk_tisch_nummer
    CHECK (Tisch_nummer > 0),

  CONSTRAINT chk_tisch_sitzplaetze
    CHECK (Sitzplaetze > 0)
) ENGINE = InnoDB;


-- =====================================================
-- Tabelle: Reservierung
-- Zweck: Speichert Tischreservierungen mit Zeitraum, Datum,
--        Personenanzahl und optionalem Allergiehinweis.
-- =====================================================

CREATE TABLE Reservierung (
  Reservierung_id INT NOT NULL AUTO_INCREMENT,
  Kunde_id INT NOT NULL,
  Tisch_nummer INT NOT NULL,

  Zeitraum ENUM(
    '12:00-14:00',
    '18:00-20:00',
    '20:00-22:00'
  ) NOT NULL,

  Reservierungsdatum DATE NOT NULL,
  Personenanzahl INT NOT NULL,
  Allergiehinweis TEXT NULL,

  PRIMARY KEY (Reservierung_id),

  CONSTRAINT chk_reservierung_personenanzahl
    CHECK (Personenanzahl > 0),

  CONSTRAINT chk_reservierung_allergiehinweis
    CHECK (
      Allergiehinweis IS NULL
      OR TRIM(Allergiehinweis) <> ''
    ),

  CONSTRAINT fk_reservierung_kunde
    FOREIGN KEY (Kunde_id)
    REFERENCES Kunde(Kunde_id)
    ON UPDATE CASCADE
    ON DELETE RESTRICT,

  CONSTRAINT fk_reservierung_tisch
    FOREIGN KEY (Tisch_nummer)
    REFERENCES Tisch(Tisch_nummer)
    ON UPDATE CASCADE
    ON DELETE RESTRICT,

  CONSTRAINT uq_tisch_datum_zeitraum
    UNIQUE (Tisch_nummer, Reservierungsdatum, Zeitraum)
) ENGINE = InnoDB;


-- =====================================================
-- Tabelle: Mitarbeiter
-- Zweck: Speichert Mitarbeiter, die Bestellungen aufnehmen oder bearbeiten.
-- =====================================================

CREATE TABLE Mitarbeiter (
  Mitarbeiter_id INT NOT NULL AUTO_INCREMENT,
  Vorname VARCHAR(45) NOT NULL,
  Nachname VARCHAR(45) NOT NULL,
  Telefonnummer VARCHAR(30) NOT NULL,

  Rolle ENUM('Manager', 'Kellner', 'Koch') NOT NULL,

  PRIMARY KEY (Mitarbeiter_id),

  CONSTRAINT uq_mitarbeiter_telefon
    UNIQUE (Telefonnummer),

  CONSTRAINT chk_mitarbeiter_vorname
    CHECK (TRIM(Vorname) <> ''),

  CONSTRAINT chk_mitarbeiter_nachname
    CHECK (TRIM(Nachname) <> ''),

  CONSTRAINT chk_mitarbeiter_telefonnummer
    CHECK (TRIM(Telefonnummer) <> '')
) ENGINE = InnoDB;


-- =====================================================
-- Tabelle: Bestellung
-- Zweck: Speichert Vor-Ort-Bestellungen.
--        Eine Bestellung wird von einem Mitarbeiter an einem Tisch aufgenommen.
--        Sie gehört entweder zu einer Reservierung oder direkt zu einem Kunden.
-- =====================================================

CREATE TABLE Bestellung (
  Bestellung_id INT NOT NULL AUTO_INCREMENT,
  Bestellzeitpunkt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

  Status ENUM('offen', 'in Bearbeitung', 'abgeschlossen', 'storniert')
    NOT NULL DEFAULT 'offen',

  Gesamtpreis DECIMAL(10,2) NOT NULL DEFAULT 0,

  Mitarbeiter_id INT NOT NULL,
  Tisch_nummer INT NOT NULL,
  Reservierung_id INT NULL,
  Kunde_id INT NULL,

  PRIMARY KEY (Bestellung_id),

  CONSTRAINT chk_bestellung_gesamtpreis
    CHECK (Gesamtpreis >= 0),

  CONSTRAINT fk_bestellung_mitarbeiter
    FOREIGN KEY (Mitarbeiter_id)
    REFERENCES Mitarbeiter(Mitarbeiter_id)
    ON UPDATE CASCADE
    ON DELETE RESTRICT,

  CONSTRAINT fk_bestellung_tisch
    FOREIGN KEY (Tisch_nummer)
    REFERENCES Tisch(Tisch_nummer)
    ON UPDATE CASCADE
    ON DELETE RESTRICT,

  CONSTRAINT fk_bestellung_reservierung
    FOREIGN KEY (Reservierung_id)
    REFERENCES Reservierung(Reservierung_id)
    ON UPDATE RESTRICT
    ON DELETE RESTRICT,

  CONSTRAINT fk_bestellung_kunde
    FOREIGN KEY (Kunde_id)
    REFERENCES Kunde(Kunde_id)
    ON UPDATE RESTRICT
    ON DELETE RESTRICT
) ENGINE = InnoDB;


-- =====================================================
-- Tabelle: Bestellposition
-- Zweck: Zwischentabelle zur N:M-Beziehung zwischen Bestellung und Produkt.
--        Speichert, welche Produkte in welcher Bestellmenge
--        zu einer Bestellung gehören.
--        Der Einzelpreis wird gespeichert, damit historische Bestellungen
--        auch bei späteren Preisänderungen korrekt bleiben.
-- =====================================================

CREATE TABLE Bestellposition (
  Bestellung_id INT NOT NULL,
  Produkt_id INT NOT NULL,
  Bestellmenge INT NOT NULL,
  Einzelpreis DECIMAL(10,2) NOT NULL,

  PRIMARY KEY (Bestellung_id, Produkt_id),

  CONSTRAINT chk_bestellposition_bestellmenge
    CHECK (Bestellmenge >= 1),

  CONSTRAINT chk_bestellposition_einzelpreis
    CHECK (Einzelpreis > 0),

  CONSTRAINT fk_bestellposition_bestellung
    FOREIGN KEY (Bestellung_id)
    REFERENCES Bestellung(Bestellung_id)
    ON UPDATE CASCADE
    ON DELETE CASCADE,

  CONSTRAINT fk_bestellposition_produkt
    FOREIGN KEY (Produkt_id)
    REFERENCES Produkt(Produkt_id)
    ON UPDATE CASCADE
    ON DELETE RESTRICT
) ENGINE = InnoDB;


-- =====================================================
-- Tabelle: Zutat
-- Zweck: Speichert alle Zutaten, die für Produkte verwendet werden.
--        Jede Zutat wird nur einmal gespeichert und kann später
--        über die Zwischentabelle Produkt_Zutat mehreren Produkten
--        zugeordnet werden.
-- =====================================================

CREATE TABLE Zutat (
  Zutat_id INT NOT NULL AUTO_INCREMENT,
  Zutatenname VARCHAR(100) NOT NULL,
  Einheit ENUM('g', 'ml', 'Stück') NOT NULL,

  PRIMARY KEY (Zutat_id),

  CONSTRAINT uq_zutat_name
    UNIQUE (Zutatenname),

  CONSTRAINT chk_zutat_name
    CHECK (TRIM(Zutatenname) <> '')
) ENGINE = InnoDB;

-- =====================================================
-- Tabelle: Produkt_Zutat
-- Zweck: Zwischentabelle zur N:M-Beziehung zwischen Produkt und Zutat.
--        Speichert, welche Zutaten in welcher Menge zu einem Produkt gehören.
-- =====================================================

CREATE TABLE Produkt_Zutat (
  Produkt_id INT NOT NULL,
  Zutat_id INT NOT NULL,
  Zutatenmenge DECIMAL(10,2) NOT NULL,

  PRIMARY KEY (Produkt_id, Zutat_id),

  CONSTRAINT chk_produkt_zutat_menge
    CHECK (Zutatenmenge > 0),

  CONSTRAINT fk_produkt_zutat_produkt
    FOREIGN KEY (Produkt_id)
    REFERENCES Produkt(Produkt_id)
    ON UPDATE CASCADE
    ON DELETE CASCADE,

  CONSTRAINT fk_produkt_zutat_zutat
    FOREIGN KEY (Zutat_id)
    REFERENCES Zutat(Zutat_id)
    ON UPDATE CASCADE
    ON DELETE RESTRICT
) ENGINE = InnoDB;
