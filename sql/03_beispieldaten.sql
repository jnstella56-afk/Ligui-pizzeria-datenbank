USE luigi_pizzeria;

-- =====================================================
-- Beispieldaten: Kategorie
-- =====================================================

INSERT INTO Kategorie (Kategorie_id, Kategorie_name)
VALUES
(1, 'Pizza'),
(2, 'Pasta'),
(3, 'Salat'),
(4, 'Dessert'),
(5, 'Getränk');


-- =====================================================
-- Beispieldaten: Produkt
-- =====================================================

INSERT INTO Produkt (Produkt_id, Produktname, Preis, Beschreibung, Aktiv, Kategorie_id)
VALUES
(1, 'Pizza Margherita', 8.50, 'Pizza mit Tomatensoße und Käse', TRUE, 1),
(2, 'Pizza Salami', 9.50, 'Pizza mit Tomatensoße, Käse und Salami', TRUE, 1),
(3, 'Pizza Funghi', 9.00, 'Pizza mit Tomatensoße, Käse und Champignons', TRUE, 1),
(4, 'Pizza Tonno', 10.50, 'Pizza mit Thunfisch und Zwiebeln', TRUE, 1),
(5, 'Pizza Vegetaria', 10.00, 'Pizza mit Gemüse und Käse', TRUE, 1),
(6, 'Pizza Hawaii', 10.00, 'Pizza mit Schinken und Ananas', FALSE, 1),

(7, 'Spaghetti Bolognese', 10.50, 'Pasta mit Bolognese-Soße', TRUE, 2),
(8, 'Penne Arrabbiata', 9.90, 'Pasta mit scharfer Tomatensoße', TRUE, 2),
(9, 'Lasagne', 11.50, 'Lasagne mit Hackfleisch und Käse', TRUE, 2),
(10, 'Tagliatelle Alfredo', 10.90, 'Bandnudeln mit Sahnesoße und Käse', TRUE, 2),

(11, 'Gemischter Salat', 6.50, 'Frischer Salat mit Dressing', TRUE, 3),
(12, 'Caesar Salat', 8.90, 'Salat mit Hähnchen, Käse und Dressing', TRUE, 3),
(13, 'Tomatensalat', 5.90, 'Salat mit Tomaten, Zwiebeln und Olivenöl', TRUE, 3),

(14, 'Tiramisu', 5.50, 'Italienisches Dessert mit Mascarpone und Kaffee', TRUE, 4),
(15, 'Panna Cotta', 5.00, 'Italienisches Sahnedessert', TRUE, 4),
(16, 'Gelato Vanille', 4.50, 'Vanilleeis', TRUE, 4),

(17, 'Cola 0,5l', 3.20, 'Erfrischungsgetränk 0,5 Liter', TRUE, 5),
(18, 'Wasser 0,5l', 2.80, 'Mineralwasser 0,5 Liter', TRUE, 5),
(19, 'Espresso', 2.50, 'Italienischer Kaffee', TRUE, 5),
(20, 'Apfelschorle 0,5l', 3.00, 'Apfelschorle 0,5 Liter', TRUE, 5);


-- =====================================================
-- Beispieldaten: Kunde
-- Mindestens Telefonnummer oder Email muss vorhanden sein.
-- =====================================================

INSERT INTO Kunde (Kunde_id, Vorname, Nachname, Telefonnummer, Email)
VALUES
(1, 'Max', 'Müller', '0176000001', 'max.mueller@mail.de'),
(2, 'Anna', 'Schmidt', '0176000002', 'anna.schmidt@mail.de'),
(3, 'Paul', 'Weber', '0176000003', NULL),
(4, 'Lisa', 'Fischer', NULL, 'lisa.fischer@mail.de'),
(5, 'Jonas', 'Klein', '0176000005', 'jonas.klein@mail.de'),
(6, 'Emma', 'Wolf', '0176000006', NULL),
(7, 'Noah', 'Becker', NULL, 'noah.becker@mail.de'),
(8, 'Mia', 'Hoffmann', '0176000008', 'mia.hoffmann@mail.de'),
(9, 'Leon', 'Schulz', '0176000009', NULL),
(10, 'Sarah', 'Koch', NULL, 'sarah.koch@mail.de'),
(11, 'Tim', 'Maier', '0176000011', 'tim.maier@mail.de'),
(12, 'Julia', 'Lang', '0176000012', NULL),
(13, 'David', 'Neumann', NULL, 'david.neumann@mail.de'),
(14, 'Laura', 'Hartmann', '0176000014', 'laura.hartmann@mail.de'),
(15, 'Ben', 'Peters', '0176000015', NULL),
(16, 'Sophie', 'Wagner', NULL, 'sophie.wagner@mail.de'),
(17, 'Felix', 'Braun', '0176000017', 'felix.braun@mail.de'),
(18, 'Lena', 'Schneider', '0176000018', NULL),
(19, 'Nico', 'Werner', NULL, 'nico.werner@mail.de'),
(20, 'Marie', 'Keller', '0176000020', 'marie.keller@mail.de');


-- =====================================================
-- Beispieldaten: Tisch
-- =====================================================

INSERT INTO Tisch (Tisch_nummer, Sitzplaetze)
VALUES
(1, 2),
(2, 2),
(3, 4),
(4, 4),
(5, 4),
(6, 6),
(7, 6),
(8, 8),
(9, 4),
(10, 2);


-- =====================================================
-- Beispieldaten: Reservierung
-- =====================================================

INSERT INTO Reservierung (
  Reservierung_id,
  Kunde_id,
  Tisch_nummer,
  Zeitraum,
  Reservierungsdatum,
  Personenanzahl,
  Allergiehinweis
)
VALUES
(1, 1, 3, '18:00-20:00', '2026-06-21', 4, NULL),
(2, 2, 4, '20:00-22:00', '2026-06-21', 2, 'Nussallergie'),
(3, 4, 6, '12:00-14:00', '2026-06-22', 5, NULL),
(4, 5, 5, '18:00-20:00', '2026-06-22', 3, 'Glutenunverträglichkeit'),
(5, 8, 8, '20:00-22:00', '2026-06-23', 6, NULL),
(6, 10, 2, '18:00-20:00', '2026-06-23', 2, NULL),
(7, 11, 7, '20:00-22:00', '2026-06-23', 5, 'Laktoseintoleranz'),
(8, 13, 9, '12:00-14:00', '2026-06-24', 4, NULL),
(9, 14, 1, '18:00-20:00', '2026-06-24', 2, NULL),
(10, 16, 10, '20:00-22:00', '2026-06-24', 2, 'Erdnussallergie'),
(11, 17, 3, '12:00-14:00', '2026-06-25', 3, NULL),
(12, 18, 5, '18:00-20:00', '2026-06-25', 4, NULL),
(13, 19, 6, '20:00-22:00', '2026-06-25', 6, NULL),
(14, 20, 8, '18:00-20:00', '2026-06-26', 7, 'Schalentierallergie'),
(15, 3, 4, '12:00-14:00', '2026-06-26', 4, NULL);


-- =====================================================
-- Beispieldaten: Mitarbeiter
-- =====================================================

INSERT INTO Mitarbeiter (Mitarbeiter_id, Vorname, Nachname, Telefonnummer, Rolle)
VALUES
(1, 'Luigi', 'Rossi', '0661000001', 'Manager'),
(2, 'Marco', 'Bianchi', '0661000002', 'Kellner'),
(3, 'Sofia', 'Conti', '0661000003', 'Kellner'),
(4, 'Giovanni', 'Ferrari', '0661000004', 'Koch'),
(5, 'Luca', 'Romano', '0661000005', 'Koch'),
(6, 'Elena', 'Moretti', '0661000006', 'Kellner');


-- =====================================================
-- Beispieldaten: Zutat
-- =====================================================

INSERT INTO Zutat (Zutat_id, Zutatenname, Einheit)
VALUES
(1, 'Tomatensoße', 'ml'),
(2, 'Käse', 'g'),
(3, 'Salami', 'g'),
(4, 'Champignons', 'g'),
(5, 'Thunfisch', 'g'),
(6, 'Zwiebeln', 'g'),
(7, 'Paprika', 'g'),
(8, 'Oliven', 'g'),
(9, 'Schinken', 'g'),
(10, 'Ananas', 'g'),
(11, 'Spaghetti', 'g'),
(12, 'Hackfleisch', 'g'),
(13, 'Penne', 'g'),
(14, 'Chili', 'g'),
(15, 'Lasagneplatten', 'g'),
(16, 'Sahne', 'ml'),
(17, 'Salat', 'g'),
(18, 'Dressing', 'ml'),
(19, 'Hähnchen', 'g'),
(20, 'Tomaten', 'g'),
(21, 'Mascarpone', 'g'),
(22, 'Kaffee', 'ml'),
(23, 'Vanilleeis', 'g'),
(24, 'Cola', 'ml'),
(25, 'Wasser', 'ml'),
(26, 'Apfelschorle', 'ml');


-- =====================================================
-- Beispieldaten: Produkt_Zutat
-- Zweck: Welche Zutaten gehören in welcher Menge zu welchem Produkt?
-- =====================================================

INSERT INTO Produkt_Zutat (Produkt_id, Zutat_id, Zutatenmenge)
VALUES
-- Pizza Margherita
(1, 1, 80.00),
(1, 2, 100.00),

-- Pizza Salami
(2, 1, 80.00),
(2, 2, 100.00),
(2, 3, 60.00),

-- Pizza Funghi
(3, 1, 80.00),
(3, 2, 100.00),
(3, 4, 70.00),

-- Pizza Tonno
(4, 1, 80.00),
(4, 2, 100.00),
(4, 5, 80.00),
(4, 6, 30.00),

-- Pizza Vegetaria
(5, 1, 80.00),
(5, 2, 100.00),
(5, 4, 50.00),
(5, 7, 50.00),
(5, 8, 30.00),

-- Pizza Hawaii
(6, 1, 80.00),
(6, 2, 100.00),
(6, 9, 60.00),
(6, 10, 50.00),

-- Spaghetti Bolognese
(7, 11, 120.00),
(7, 12, 100.00),
(7, 1, 80.00),

-- Penne Arrabbiata
(8, 13, 120.00),
(8, 1, 90.00),
(8, 14, 10.00),

-- Lasagne
(9, 15, 150.00),
(9, 12, 120.00),
(9, 2, 80.00),
(9, 1, 90.00),

-- Tagliatelle Alfredo
(10, 16, 120.00),
(10, 2, 60.00),

-- Gemischter Salat
(11, 17, 150.00),
(11, 18, 30.00),
(11, 20, 50.00),

-- Caesar Salat
(12, 17, 150.00),
(12, 18, 30.00),
(12, 19, 100.00),
(12, 2, 30.00),

-- Tomatensalat
(13, 20, 180.00),
(13, 6, 30.00),
(13, 8, 20.00),

-- Tiramisu
(14, 21, 80.00),
(14, 22, 20.00),

-- Panna Cotta
(15, 16, 100.00),

-- Gelato Vanille
(16, 23, 120.00),

-- Getränke
(17, 24, 500.00),
(18, 25, 500.00),
(19, 22, 30.00),
(20, 26, 500.00);


-- =====================================================
-- Beispieldaten: Bestellung
-- Wichtig:
-- Eine Bestellung hat entweder Reservierung_id ODER Kunde_id.
-- Nicht beides gleichzeitig.
-- =====================================================

INSERT INTO Bestellung (
  Bestellung_id,
  Bestellzeitpunkt,
  Status,
  Mitarbeiter_id,
  Tisch_nummer,
  Reservierung_id,
  Kunde_id
)
VALUES
-- Reservierte Gäste
(1, '2026-06-21 18:15:00', 'abgeschlossen', 2, 3, 1, NULL),
(2, '2026-06-21 20:10:00', 'abgeschlossen', 3, 4, 2, NULL),
(3, '2026-06-22 12:20:00', 'abgeschlossen', 2, 6, 3, NULL),
(4, '2026-06-22 18:35:00', 'abgeschlossen', 6, 5, 4, NULL),
(5, '2026-06-23 20:15:00', 'abgeschlossen', 3, 8, 5, NULL),
(6, '2026-06-23 18:30:00', 'abgeschlossen', 2, 2, 6, NULL),
(7, '2026-06-23 20:40:00', 'abgeschlossen', 6, 7, 7, NULL),
(8, '2026-06-24 12:30:00', 'abgeschlossen', 3, 9, 8, NULL),
(9, '2026-06-24 18:20:00', 'abgeschlossen', 2, 1, 9, NULL),
(10, '2026-06-24 20:30:00', 'abgeschlossen', 6, 10, 10, NULL),
(11, '2026-06-25 12:15:00', 'abgeschlossen', 2, 3, 11, NULL),
(12, '2026-06-25 18:10:00', 'in Bearbeitung', 3, 5, 12, NULL),
(13, '2026-06-25 20:25:00', 'offen', 6, 6, 13, NULL),
(14, '2026-06-26 18:45:00', 'abgeschlossen', 2, 8, 14, NULL),
(15, '2026-06-26 12:10:00', 'storniert', 3, 4, 15, NULL),

-- Spontane registrierte Gäste
(16, '2026-06-22 19:00:00', 'abgeschlossen', 3, 2, NULL, 6),
(17, '2026-06-22 19:30:00', 'abgeschlossen', 2, 1, NULL, 7),
(18, '2026-06-23 13:10:00', 'abgeschlossen', 6, 10, NULL, 9),
(19, '2026-06-24 19:15:00', 'in Bearbeitung', 3, 7, NULL, 12),
(20, '2026-06-25 21:00:00', 'offen', 2, 2, NULL, 15);


-- =====================================================
-- Beispieldaten: Bestellposition
-- Der Gesamtpreis in Bestellung wird durch Trigger automatisch berechnet.
-- =====================================================

INSERT INTO Bestellposition (Bestellung_id, Produkt_id, Bestellmenge, Einzelpreis)
VALUES
-- Bestellung 1
(1, 2, 2, 9.50),
(1, 17, 2, 3.20),
(1, 14, 1, 5.50),

-- Bestellung 2
(2, 1, 1, 8.50),
(2, 7, 1, 10.50),
(2, 18, 2, 2.80),
(2, 19, 1, 2.50),

-- Bestellung 3
(3, 8, 3, 9.90),
(3, 11, 2, 6.50),
(3, 19, 2, 2.50),

-- Bestellung 4
(4, 5, 2, 10.00),
(4, 12, 1, 8.90),
(4, 20, 3, 3.00),

-- Bestellung 5
(5, 2, 3, 9.50),
(5, 7, 2, 10.50),
(5, 15, 3, 5.00),
(5, 17, 4, 3.20),

-- Bestellung 6
(6, 4, 1, 10.50),
(6, 13, 1, 5.90),
(6, 18, 2, 2.80),

-- Bestellung 7
(7, 9, 2, 11.50),
(7, 2, 2, 9.50),
(7, 14, 2, 5.50),
(7, 20, 4, 3.00),

-- Bestellung 8
(8, 10, 2, 10.90),
(8, 11, 2, 6.50),
(8, 19, 3, 2.50),

-- Bestellung 9
(9, 3, 1, 9.00),
(9, 17, 1, 3.20),

-- Bestellung 10
(10, 1, 2, 8.50),
(10, 16, 2, 4.50),
(10, 18, 2, 2.80),

-- Bestellung 11
(11, 7, 1, 10.50),
(11, 8, 1, 9.90),
(11, 12, 1, 8.90),
(11, 19, 2, 2.50),

-- Bestellung 12
(12, 2, 2, 9.50),
(12, 4, 1, 10.50),
(12, 17, 2, 3.20),

-- Bestellung 13
(13, 5, 3, 10.00),
(13, 14, 2, 5.50),
(13, 20, 2, 3.00),

-- Bestellung 14
(14, 9, 3, 11.50),
(14, 11, 2, 6.50),
(14, 15, 2, 5.00),
(14, 18, 4, 2.80),

-- Bestellung 15, storniert
(15, 6, 1, 10.00),
(15, 17, 1, 3.20),

-- Bestellung 16
(16, 3, 1, 9.00),
(16, 17, 1, 3.20),
(16, 14, 1, 5.50),

-- Bestellung 17
(17, 1, 1, 8.50),
(17, 18, 1, 2.80),

-- Bestellung 18
(18, 13, 2, 5.90),
(18, 19, 2, 2.50),

-- Bestellung 19
(19, 4, 2, 10.50),
(19, 12, 2, 8.90),
(19, 20, 2, 3.00),

-- Bestellung 20
(20, 2, 1, 9.50),
(20, 8, 1, 9.90),
(20, 18, 1, 2.80);


-- =====================================================
-- Kontrolle: Bestellungen mit Gesamtpreis anzeigen
-- =====================================================

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
ORDER BY Bestellung_id;