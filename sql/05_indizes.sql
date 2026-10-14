USE luigi_pizzeria;

-- =====================================================
-- Index-Skript für Luigi's Pizzeria
-- Zweck: Legt die Indizes an, die für die Trigger, Prozeduren,
-- Events und Functions dieses Projekts benötigt werden.
-- Hinweis: idx_produkt_name wird NICHT angelegt, da Produktname
-- bereits durch die UNIQUE-Constraint uq_produkt_name automatisch
-- indiziert ist (redundant).
-- =====================================================

-- Zustand vorher prüfen (optional, zur Kontrolle)

SHOW INDEX FROM Mitarbeiter;
SHOW INDEX FROM Kunde;
SHOW INDEX FROM Reservierung;
SHOW INDEX FROM Bestellung;


-- =====================================================
-- Index 1: Mitarbeitersuche über Namen
-- Zweck: sp_bestellung_anlegen sucht bei jedem Aufruf
-- Mitarbeiter über Vorname + Nachname (kein Index vorhanden,
-- da keine UNIQUE-Constraint auf diese Kombination existiert)
-- =====================================================
CREATE INDEX idx_mitarbeiter_name
ON Mitarbeiter(Nachname, Vorname);


-- =====================================================
-- Index 2: Kundensuche über Namen
-- Zweck: Vorbereitung für zukünftige Prozeduren mit
-- Kundenzuordnung (aktuell in sp_bestellung_anlegen noch
-- nicht verwendet, aber Kunde.Nachname/Vorname sind nicht
-- UNIQUE, daher kein automatischer Index vorhanden)
-- =====================================================
CREATE INDEX idx_kunde_name
ON Kunde(Nachname, Vorname);


-- =====================================================
-- Index 3: Reservierungsdatum
-- Zweck: fn_anzahl_freie_tische und fn_anzahl_erwartete_gaeste
-- filtern nach Reservierungsdatum + Zeitraum. Der bestehende
-- UNIQUE-Index (Tisch_nummer, Reservierungsdatum, Zeitraum)
-- deckt eine Suche nach Reservierungsdatum ALLEIN nicht ab
-- (Linksregel bei zusammengesetzten Indizes)
-- =====================================================
CREATE INDEX idx_reservierung_datum
ON Reservierung(Reservierungsdatum);


-- =====================================================
-- Index 4: Bestellzeitpunkt
-- Zweck: ev_tagesreport_erstellen filtert nach Bestellzeitpunkt.
-- WICHTIG: Der Event-Code muss dafür DATE(Bestellzeitpunkt)
-- durch einen Bereichsvergleich (>=/<) ersetzen, sonst bleibt
-- dieser Index wirkungslos (Funktion im Prädikat verhindert
-- Indexnutzung)
-- =====================================================
CREATE INDEX idx_bestellung_zeitpunkt
ON Bestellung(Bestellzeitpunkt);


-- =====================================================
-- Index 5: Bestellposition nach Produkt
-- Zweck: trg_produkt_preis_vor_update UND
-- ev_tagesreport_erstellen suchen nach Produkt_id allein.
-- Der zusammengesetzte Primärschlüssel (Bestellung_id,
-- Produkt_id) deckt das wegen der Linksregel nicht ab.
-- =====================================================
CREATE INDEX idx_bestellposition_produkt
ON Bestellposition(Produkt_id);


-- =====================================================
-- Kontrolle: Neue Indizes anzeigen
-- =====================================================
SHOW INDEX FROM Mitarbeiter;
SHOW INDEX FROM Kunde;
SHOW INDEX FROM Reservierung;
SHOW INDEX FROM Bestellung;
 

 