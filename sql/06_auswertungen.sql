USE luigi_pizzeria;

-- =====================================================
-- Q1: Wochentag mit den meisten Bestellungen
--
-- Zweck:
-- Ermittelt, an welchen Wochentagen wie viele Bestellungen
-- aufgenommen wurden.


SELECT
  DAYNAME(Bestellzeitpunkt) AS Wochentag,
  COUNT(*) AS Anzahl_Bestellungen
FROM Bestellung
GROUP BY DAYNAME(Bestellzeitpunkt)
ORDER BY Anzahl_Bestellungen DESC;


-- =====================================================
-- Q2: Mitarbeiter mit höchstem Gesamtumsatz
--
-- Zweck:
-- Ermittelt den Gesamtumsatz, der von jedem Mitarbeiter
-- über abgeschlossene Bestellungen erzielt wurde.
-- =====================================================

SELECT
  CONCAT(m.Vorname, ' ', m.Nachname) AS Mitarbeiter,
  m.Rolle,
  SUM(b.Gesamtpreis) AS Gesamtumsatz
FROM Bestellung b
JOIN Mitarbeiter m ON b.Mitarbeiter_id = m.Mitarbeiter_id
WHERE b.Status = 'abgeschlossen'
GROUP BY m.Mitarbeiter_id, Mitarbeiter, m.Rolle
ORDER BY Gesamtumsatz DESC;


-- =====================================================
-- Q3: Durchschnittlicher Bestellwert pro Kategorie
--     über dem Gesamtdurchschnitt
--
-- Zweck:
-- Ermittelt die Kategorien, deren durchschnittlicher
-- Positionswert über dem Durchschnitt aller Bestellpositionen
-- liegt.

SELECT
  k.Kategorie_name,
  ROUND(AVG(bp.Einzelpreis * bp.Bestellmenge), 2) AS Durchschnittlicher_Positionswert
FROM Bestellposition bp
JOIN Produkt p   ON bp.Produkt_id = p.Produkt_id
JOIN Kategorie k ON p.Kategorie_id = k.Kategorie_id
GROUP BY k.Kategorie_id, k.Kategorie_name
HAVING AVG(bp.Einzelpreis * bp.Bestellmenge) > (
  SELECT AVG(bp2.Einzelpreis * bp2.Bestellmenge)
  FROM Bestellposition bp2
)
ORDER BY Durchschnittlicher_Positionswert DESC;


-- =====================================================
-- Q8: Am wenigsten bestellte Produkte
--
-- Zweck:
-- Zeigt, welche Produkte bisher in der geringsten Menge
-- bestellt wurden.
SELECT
    p.Produktname,
    SUM(bp.Bestellmenge) AS Gesamtmenge
FROM Produkt p
JOIN Bestellposition bp ON p.Produkt_id = bp.Produkt_id
GROUP BY p.Produkt_id, p.Produktname
ORDER BY Gesamtmenge ASC;


-- =====================================================
-- Q_Reservierung: Kunden reserviert, aber nicht erschienen
--
-- Zweck:
-- Ermittelt Kunden, deren Reservierung bereits in der
-- Vergangenheit liegt, zu der aber keine nicht stornierte
-- Bestellung vorhanden ist.


SELECT
r.Reservierung_id,
r.Reservierungsdatum,
r.Zeitraum,
r.Tisch_nummer,
k.Kunde_id,
k.Vorname,
k.Nachname,
k.Telefonnummer,
k.Email,
r.Personenanzahl
FROM Reservierung r
INNER JOIN Kunde k ON r.Kunde_id = k.Kunde_id
WHERE r.Reservierungsdatum < CURRENT_DATE
AND NOT EXISTS (
  SELECT * FROM Bestellung b
  WHERE b.Reservierung_id = r.Reservierung_id
  AND b.Status <> 'storniert'
);


-- =====================================================
-- Q_Mitarbeiter_über_Durchschnitt:
-- Mitarbeiter mit Umsatz über dem Durchschnitt
--
-- Zweck:
-- Ermittelt die Mitarbeiter, deren Gesamtumsatz über dem
-- durchschnittlichen Gesamtumsatz aller Mitarbeiter liegt.
--


SELECT
    CONCAT(m.Vorname, ' ', m.Nachname) AS Mitarbeiter,
    m.Rolle,
    SUM(bp.Bestellmenge * bp.Einzelpreis) AS Gesamtumsatz
FROM Mitarbeiter m
JOIN Bestellung b ON m.Mitarbeiter_id = b.Mitarbeiter_id
JOIN Bestellposition bp ON b.Bestellung_id = bp.Bestellung_id
WHERE b.Status = 'abgeschlossen'
GROUP BY m.Mitarbeiter_id, m.Vorname, m.Nachname, m.Rolle
HAVING SUM(bp.Bestellmenge * bp.Einzelpreis) >
(
    SELECT AVG(Umsatz) FROM
    (
        SELECT SUM(bp2.Bestellmenge * bp2.Einzelpreis) AS Umsatz
        FROM Bestellung b2
        JOIN Bestellposition bp2 ON b2.Bestellung_id = bp2.Bestellung_id
        WHERE b2.Status = 'abgeschlossen'
        GROUP BY b2.Mitarbeiter_id
    ) AS Durchschnitt
)
ORDER BY Gesamtumsatz DESC;