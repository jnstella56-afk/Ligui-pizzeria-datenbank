
USE luigi_pizzeria;

DROP TRIGGER IF EXISTS trg_bestellposition_after_insert;
DROP TRIGGER IF EXISTS trg_bestellposition_after_update;
DROP TRIGGER IF EXISTS trg_bestellposition_after_delete;
DROP TRIGGER IF EXISTS trg_produkt_preis_vor_update;
DROP PROCEDURE IF EXISTS sp_bestellung_anlegen;
DROP EVENT IF EXISTS ev_tagesreport_erstellen;
DROP FUNCTION IF EXISTS fn_anzahl_freie_tische;
DROP FUNCTION IF EXISTS fn_anzahl_erwartete_gaeste;

DELIMITER $$

-- =====================================================
-- Trigger: trg_bestellposition_after_insert
--
-- Verwendungszweck:
-- Aktualisiert den Gesamtpreis einer Bestellung automatisch,
-- nachdem eine neue Bestellposition eingefügt wurde.
--
-- Auslöseereignis:
-- AFTER INSERT auf der Tabelle Bestellposition.

-- =====================================================
CREATE TRIGGER trg_bestellposition_after_insert
AFTER INSERT ON Bestellposition
FOR EACH ROW
BEGIN
    UPDATE Bestellung
    SET Gesamtpreis = Gesamtpreis + (NEW.Bestellmenge * NEW.Einzelpreis)
    WHERE Bestellung_id = NEW.Bestellung_id;
END$$

-- =====================================================
-- Trigger: trg_bestellposition_after_update
--
-- Verwendungszweck:
-- Passt den Gesamtpreis einer Bestellung automatisch an,
-- nachdem Menge oder Einzelpreis einer Bestellposition geändert wurden.
--
-- Auslöseereignis:
-- AFTER UPDATE auf der Tabelle Bestellposition.
-- =====================================================
CREATE TRIGGER trg_bestellposition_after_update
AFTER UPDATE ON Bestellposition
FOR EACH ROW
BEGIN
    UPDATE Bestellung
    SET Gesamtpreis = Gesamtpreis
                      - (OLD.Bestellmenge * OLD.Einzelpreis)
                      + (NEW.Bestellmenge * NEW.Einzelpreis)
    WHERE Bestellung_id = NEW.Bestellung_id;
END$$

-- =====================================================
-- Trigger: trg_bestellposition_after_delete
--
-- Verwendungszweck:
-- Verringert den Gesamtpreis einer Bestellung automatisch,
-- nachdem eine Bestellposition gelöscht wurde.
--
-- Auslöseereignis:
-- AFTER DELETE auf der Tabelle Bestellposition.

-- =====================================================
CREATE TRIGGER trg_bestellposition_after_delete
AFTER DELETE ON Bestellposition
FOR EACH ROW
BEGIN
    UPDATE Bestellung
    SET Gesamtpreis = Gesamtpreis - (OLD.Bestellmenge * OLD.Einzelpreis)
    WHERE Bestellung_id = OLD.Bestellung_id;
END$$

-- =====================================================
-- Trigger: trg_produkt_preis_vor_update
--
-- Verwendungszweck:
-- Verhindert die Änderung eines Produktpreises, solange das Produkt
-- in einer offenen oder in Bearbeitung befindlichen Bestellung vorkommt.
--
-- Auslöseereignis:
-- BEFORE UPDATE auf der Tabelle Produkt.
--
-- wird mit SIGNAL SQLSTATE '45000' eine Fehlermeldung ausgegeben.
-- =====================================================
CREATE TRIGGER trg_produkt_preis_vor_update
BEFORE UPDATE ON Produkt
FOR EACH ROW
BEGIN
    DECLARE v_offene_bestellungen INT DEFAULT 0;

    IF NEW.Preis <> OLD.Preis THEN
        SELECT COUNT(*)
        INTO v_offene_bestellungen
        FROM Bestellposition bp
        INNER JOIN Bestellung b
            ON bp.Bestellung_id = b.Bestellung_id
        WHERE bp.Produkt_id = OLD.Produkt_id
          AND b.Status IN ('offen', 'in Bearbeitung');

        IF v_offene_bestellungen > 0 THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Preisänderung nicht möglich: Dieses Produkt ist noch in einer offenen Bestellung enthalten.';
        END IF;
    END IF;
END$$

-- =====================================================
-- Stored Procedure: sp_bestellung_anlegen
--
-- Verwendungszweck:
-- Legt eine neue Bestellung mit einer ersten Bestellposition an.
-- Bestellung und Bestellposition werden innerhalb einer Transaktion
-- als zusammengehörige Einheit gespeichert.
--
-- Funktionalität:
-- 1. Prüft die Bestellmenge.
-- 2. Prüft, ob Tisch, Mitarbeiter und Produkt existieren.
-- 3. Prüft, ob das Produkt aktiv ist.
-- 4. Startet eine Transaktion.
-- 5. Liest Produkt-ID und Preis mit FOR UPDATE.
-- 6. Legt Bestellung und erste Bestellposition an.
-- 7. Führt bei Erfolg COMMIT aus.
-- 8. Führt bei einem SQL-Fehler ROLLBACK aus.
--
-- Eingabeparameter:
-- p_tisch_nummer: Nummer des Tisches.
-- p_mitarbeiter_vorname: Vorname des Mitarbeiters.
-- p_mitarbeiter_nachname: Nachname des Mitarbeiters.
-- p_produktname: Name des ersten bestellten Produkts.
-- p_bestellmenge: Bestellte Menge; muss mindestens 1 sein.
--
-- Ausgabeparameter:
-- Keine formalen OUT-Parameter. Bei Erfolg wird die neue
--
-- Fehlerbehandlung:
-- Ein EXIT HANDLER setzt bei jedem SQL-Fehler die gesamte
-- Transaktion zurück und gibt den ursprünglichen Fehler weiter.
-- =====================================================
CREATE PROCEDURE sp_bestellung_anlegen (
    IN p_tisch_nummer INT,
    IN p_mitarbeiter_vorname VARCHAR(45),
    IN p_mitarbeiter_nachname VARCHAR(45),
    IN p_produktname VARCHAR(100),
    IN p_bestellmenge INT
)
BEGIN
    DECLARE v_bestellung_id INT;
    DECLARE v_mitarbeiter_id INT;
    DECLARE v_produkt_id INT;
    DECLARE v_produkt_preis DECIMAL(10,2);
    DECLARE v_anzahl_tisch INT DEFAULT 0;
    DECLARE v_anzahl_mitarbeiter INT DEFAULT 0;
    DECLARE v_anzahl_produkt INT DEFAULT 0;
    DECLARE v_anzahl_aktives_produkt INT DEFAULT 0;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    IF p_bestellmenge < 1 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Die Bestellmenge muss mindestens 1 sein.';
    END IF;

    SELECT COUNT(*)
    INTO v_anzahl_tisch
    FROM Tisch
    WHERE Tisch_nummer = p_tisch_nummer;

    IF v_anzahl_tisch = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Die angegebene Tischnummer existiert nicht.';
    END IF;

    SELECT COUNT(*)
    INTO v_anzahl_mitarbeiter
    FROM Mitarbeiter
    WHERE Vorname = p_mitarbeiter_vorname
      AND Nachname = p_mitarbeiter_nachname;

    IF v_anzahl_mitarbeiter = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Der angegebene Mitarbeiter existiert nicht.';
    END IF;

    IF v_anzahl_mitarbeiter > 1 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Mehrere Mitarbeiter mit diesem Vor- und Nachnamen gefunden.';
    END IF;

    SELECT Mitarbeiter_id
    INTO v_mitarbeiter_id
    FROM Mitarbeiter
    WHERE Vorname = p_mitarbeiter_vorname
      AND Nachname = p_mitarbeiter_nachname;

    SELECT COUNT(*)
    INTO v_anzahl_produkt
    FROM Produkt
    WHERE Produktname = p_produktname;

    IF v_anzahl_produkt = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Das angegebene Produkt existiert nicht.';
    END IF;

    SELECT COUNT(*)
    INTO v_anzahl_aktives_produkt
    FROM Produkt
    WHERE Produktname = p_produktname
      AND Aktiv = TRUE;

    IF v_anzahl_aktives_produkt = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Das angegebene Produkt ist aktuell nicht verfügbar.';
    END IF;

    START TRANSACTION;

    SELECT Produkt_id, Preis
    INTO v_produkt_id, v_produkt_preis
    FROM Produkt
    WHERE Produktname = p_produktname
      AND Aktiv = TRUE
    FOR UPDATE;

    INSERT INTO Bestellung (
        Mitarbeiter_id,
        Tisch_nummer,
        Status,
        Gesamtpreis
    )
    VALUES (
        v_mitarbeiter_id,
        p_tisch_nummer,
        'offen',
        0
    );

    SET v_bestellung_id = LAST_INSERT_ID();

    INSERT INTO Bestellposition (
        Bestellung_id,
        Produkt_id,
        Bestellmenge,
        Einzelpreis
    )
    VALUES (
        v_bestellung_id,
        v_produkt_id,
        p_bestellmenge,
        v_produkt_preis
    );

    COMMIT;

    SELECT
        v_bestellung_id AS Bestellung_id,
        'Die Bestellung wurde erfolgreich angelegt.' AS Meldung;
END$$

DELIMITER ;


-- CALL sp_bestellung_anlegen(1, 'Luigi', 'Rossi', 'Pizza Salami', 2);

-- =====================================================
-- Tabelle: Tagesreport
--
-- Verwendungszweck:
-- Speichert verkaufte Produkte, Mengen, Umsätze sowie erwartete
-- und tatsächlich erschienene Gäste für einen Auswertungstag.
-- =====================================================
CREATE TABLE IF NOT EXISTS Tagesreport (
    Report_id INT NOT NULL AUTO_INCREMENT,
    Reportdatum DATE NOT NULL,
    Produkt_id INT NOT NULL,
    Produktname VARCHAR(100) NOT NULL,
    Verkaufte_Menge INT NOT NULL,
    Umsatz DECIMAL(10,2) NOT NULL,
    Erwartete_Kunden INT NOT NULL DEFAULT 0,
    Tatsaechliche_Kunden INT NOT NULL DEFAULT 0,
    Erstellt_am DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (Report_id),
    CONSTRAINT uq_tagesreport_datum_produkt
        UNIQUE (Reportdatum, Produkt_id)
) ENGINE = InnoDB;

SET GLOBAL event_scheduler = ON;

DELIMITER $$

-- =====================================================
-- Event: ev_tagesreport_erstellen
--
-- Verwendungszweck:
-- Erstellt automatisch einen Tagesreport über Verkäufe, Umsätze,
-- erwartete Gäste und tatsächlich erschienene Gäste.
--
-- Ausführungszeitpunkt:
-- Einmalig eine Minute nach Erstellung des Events.
--
-- Eingabeparameter:
-- Keine. Das auszuwertende Datum wird intern fest auf
-- den 24.06.2026 gesetzt, damit vorhandene Beispieldaten
-- ausgewertet werden können.
--
-- Ausgabeparameter:
-- Keine direkten Ausgabeparameter.
--
-- Funktionalität:
-- 1. Ermittelt die erwarteten Gäste.
-- 2. Ermittelt die tatsächlich erschienenen Gäste.
-- 3. Löscht vorhandene Reportdaten für denselben Tag.
-- 4. Berechnet Verkaufsmenge und Umsatz je Produkt.
-- 5. Speichert die Ergebnisse in Tagesreport.
-- =====================================================
CREATE EVENT ev_tagesreport_erstellen
ON SCHEDULE AT CURRENT_TIMESTAMP + INTERVAL 1 MINUTE
DO
BEGIN
    DECLARE v_reportdatum DATE;
    DECLARE v_erwartete_kunden INT DEFAULT 0;
    DECLARE v_tatsaechliche_kunden INT DEFAULT 0;

    -- Festes Testdatum, da dafür Beispieldaten vorhanden sind.
    SET v_reportdatum = '2026-06-24';

    SELECT
        CASE
            WHEN COUNT(*) = 0 THEN 0
            ELSE SUM(Personenanzahl)
        END
    INTO v_erwartete_kunden
    FROM Reservierung
    WHERE Reservierungsdatum = v_reportdatum;

    SELECT
        CASE
            WHEN COUNT(*) = 0 THEN 0
            ELSE SUM(Personenanzahl)
        END
    INTO v_tatsaechliche_kunden
    FROM Reservierung
    WHERE Reservierungsdatum = v_reportdatum
      AND Reservierung_id IN (
          SELECT Reservierung_id
          FROM Bestellung
          WHERE Reservierung_id IS NOT NULL
            AND Status <> 'storniert'
      );

    DELETE FROM Tagesreport
    WHERE Reportdatum = v_reportdatum;

    INSERT INTO Tagesreport (
        Reportdatum,
        Produkt_id,
        Produktname,
        Verkaufte_Menge,
        Umsatz,
        Erwartete_Kunden,
        Tatsaechliche_Kunden
    )
    SELECT
        v_reportdatum,
        p.Produkt_id,
        p.Produktname,
        SUM(bp.Bestellmenge),
        SUM(bp.Bestellmenge * bp.Einzelpreis),
        v_erwartete_kunden,
        v_tatsaechliche_kunden
    FROM Bestellung b
    INNER JOIN Bestellposition bp
        ON b.Bestellung_id = bp.Bestellung_id
    INNER JOIN Produkt p
        ON bp.Produkt_id = p.Produkt_id
    WHERE DATE(b.Bestellzeitpunkt) = v_reportdatum
      AND b.Status = 'abgeschlossen'
    GROUP BY p.Produkt_id, p.Produktname;
END$$

-- =====================================================
-- Function: fn_anzahl_freie_tische
--
-- Verwendungszweck:
-- Ermittelt die Anzahl freier Tische für ein Datum und einen Zeitraum.
--
-- Eingabeparameter:
-- p_reservierungsdatum: Zu prüfendes Reservierungsdatum.
-- p_zeitraum: Zu prüfender Zeitraum, z. B. '18:00-20:00'.
--
-- Rückgabewert:
-- INT mit der Anzahl der verfügbaren Tische.
-- =====================================================
CREATE FUNCTION fn_anzahl_freie_tische (
    p_reservierungsdatum DATE,
    p_zeitraum VARCHAR(20)
)
RETURNS INT
READS SQL DATA
BEGIN
    DECLARE v_anzahl_freie_tische INT DEFAULT 0;

    SELECT COUNT(*)
    INTO v_anzahl_freie_tische
    FROM Tisch
    WHERE Tisch_nummer NOT IN (
        SELECT Tisch_nummer
        FROM Reservierung
        WHERE Reservierungsdatum = p_reservierungsdatum
          AND Zeitraum = p_zeitraum
    );

    RETURN v_anzahl_freie_tische;
END$$

-- =====================================================
-- Function: fn_anzahl_erwartete_gaeste
--
-- Verwendungszweck:
-- Ermittelt die erwartete Gästezahl für ein Datum und einen Zeitraum.
--
-- Eingabeparameter:
-- p_reservierungsdatum: Auszuwertendes Reservierungsdatum.
-- p_zeitraum: Auszuwertender Zeitraum, z. B. '18:00-20:00'.
--
-- Rückgabewert:
-- INT mit der Summe der reservierten Personen.
-- =====================================================
CREATE FUNCTION fn_anzahl_erwartete_gaeste (
    p_reservierungsdatum DATE,
    p_zeitraum VARCHAR(20)
)
RETURNS INT
READS SQL DATA
BEGIN
    DECLARE v_anzahl_erwartete_gaeste INT DEFAULT 0;

    SELECT
        CASE
            WHEN COUNT(*) = 0 THEN 0
            ELSE SUM(Personenanzahl)
        END
    INTO v_anzahl_erwartete_gaeste
    FROM Reservierung
    WHERE Reservierungsdatum = p_reservierungsdatum
      AND Zeitraum = p_zeitraum;

    RETURN v_anzahl_erwartete_gaeste;
END$$

DELIMITER ;


-- SELECT fn_anzahl_freie_tische('2026-06-28', '18:00-20:00') AS Freie_Tische;
-- SELECT fn_anzahl_erwartete_gaeste('2026-06-28', '18:00-20:00') AS Erwartete_Gaeste;
-- SELECT * FROM Tagesreport ORDER BY Reportdatum, Produkt_id;