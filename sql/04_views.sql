USE luigi_pizzeria;

DROP VIEW IF EXISTS view_umsatz_nach_zeitraum;

-- =====================================================
-- View: Umsatz nach Zeitraum
-- Zweck: Zeigt den Umsatz pro Reservierungszeitraum.
--        Es werden nur abgeschlossene Bestellungen berücksichtigt.
-- =====================================================

CREATE VIEW view_umsatz_nach_zeitraum AS
SELECT
    r.Reservierungsdatum,
    r.Zeitraum,
    COUNT(b.Bestellung_id) AS Anzahl_Bestellungen,
    SUM(b.Gesamtpreis) AS Umsatz
FROM Reservierung r
INNER JOIN Bestellung b
    ON r.Reservierung_id = b.Reservierung_id
WHERE b.Status = 'abgeschlossen'
GROUP BY
    r.Reservierungsdatum,
    r.Zeitraum;
-- zum anzeigen
SELECT *
FROM view_umsatz_nach_zeitraum
ORDER BY Reservierungsdatum, Zeitraum;

DROP VIEW IF EXISTS view_treue_kunden;

-- =====================================================
-- View: Treue Kunden
-- Zweck: Zeigt Kunden, die mindestens zweimal reserviert haben.
--        Dadurch können Stammkunden erkannt werden.
-- =====================================================

CREATE VIEW view_treue_kunden AS
SELECT
    k.Kunde_id,
    k.Vorname,
    k.Nachname,
    k.Telefonnummer,
    k.Email,
    COUNT(r.Reservierung_id) AS Anzahl_Reservierungen,
    SUM(r.Personenanzahl) AS Gesamtpersonenanzahl,
    MAX(r.Reservierungsdatum) AS Letzte_Reservierung
FROM Kunde k
INNER JOIN Reservierung r
    ON k.Kunde_id = r.Kunde_id
GROUP BY
    k.Kunde_id,
    k.Vorname,
    k.Nachname,
    k.Telefonnummer,
    k.Email
HAVING COUNT(r.Reservierung_id) >= 2;

-- zum Anzeigen 
SELECT *
FROM view_treue_kunden
ORDER BY Anzahl_Reservierungen DESC, Letzte_Reservierung DESC;


DROP VIEW IF EXISTS view_top_produkte;

-- =====================================================
-- View: Top-Produkte
-- Zweck: Zeigt, welche Produkte am meisten verkauft wurden.
--        Berücksichtigt werden nur abgeschlossene Bestellungen.
-- =====================================================

CREATE VIEW view_top_produkte AS
SELECT
    p.Produkt_id,
    p.Produktname,
    k.Kategorie_name,
    SUM(bp.Bestellmenge) AS Verkaufte_Menge,
    SUM(bp.Bestellmenge * bp.Einzelpreis) AS Umsatz
FROM Bestellung b
INNER JOIN Bestellposition bp
    ON b.Bestellung_id = bp.Bestellung_id
INNER JOIN Produkt p
    ON bp.Produkt_id = p.Produkt_id
INNER JOIN Kategorie k
    ON p.Kategorie_id = k.Kategorie_id
WHERE b.Status = 'abgeschlossen'
GROUP BY
    p.Produkt_id,
    p.Produktname,
    k.Kategorie_name;
    
    -- Zum Anzeigen 
    SELECT *
FROM view_top_produkte
ORDER BY Verkaufte_Menge DESC
LIMIT 5;


DROP VIEW IF EXISTS view_offene_bestellungen;

-- =====================================================
-- View: Offene Bestellungen
-- Zeigt alle Bestellungen, die noch nicht abgeschlossen
-- oder storniert wurden.
-- =====================================================

CREATE VIEW view_offene_bestellungen AS
SELECT
    Bestellung_id,
    Bestellzeitpunkt,
    Status,
    Gesamtpreis,
    Mitarbeiter_id,
    Tisch_nummer,
    Reservierung_id,
    Kunde_id
FROM Bestellung
WHERE Status = 'offen'
WITH CHECK OPTION;


-- =====================================================
-- SELECT zum Anzeigen der offenen Bestellungen
-- =====================================================

SELECT *
FROM view_offene_bestellungen
ORDER BY Bestellzeitpunkt;