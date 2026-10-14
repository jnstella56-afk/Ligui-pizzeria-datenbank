var mysql = require("mysql2");
var express = require("express");
var path = require("path");

var app = express();

app.use(express.static("public", { index: false }));
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

app.get("/", function(req, res) {
  res.sendFile(path.join(__dirname, "public", "manager.html"));
});

// Zugangsdaten werden über Umgebungsvariablen gesetzt (siehe README),
// damit keine Passwörter im Code gespeichert werden.
var con = mysql.createConnection({
  host: process.env.DB_HOST || "localhost",
  user: process.env.DB_USER || "root",
  password: process.env.DB_PASSWORD || "",
  database: process.env.DB_NAME || "luigi_pizzeria"
});

con.connect(function(err) {
  if (err) throw err;
  console.log("Connected!");
});

function sendeDatenbankFehler(res, err) {
  console.error(err);

  res.status(500).json({
    success: false,
    message: err.sqlMessage || "Datenbankfehler"
  });
}

/* =========================
   SELECT: Dashboard
========================= */

app.get("/dashboard", function(req, res) {
  var datum = req.query.datum || "2026-06-25";

  var sql = `
    SELECT
      (
        SELECT COUNT(*)
        FROM Reservierung
        WHERE Reservierungsdatum = ?
      ) AS anzahl_reservierungen,

      (
        SELECT COUNT(*)
        FROM Bestellung
        WHERE DATE(Bestellzeitpunkt) = ?
          AND Status <> 'storniert'
      ) AS anzahl_bestellungen,

      (
        SELECT IFNULL(SUM(bp.Bestellmenge * bp.Einzelpreis), 0)
        FROM Bestellung b
        INNER JOIN Bestellposition bp
          ON b.Bestellung_id = bp.Bestellung_id
        WHERE DATE(b.Bestellzeitpunkt) = ?
          AND b.Status = 'abgeschlossen'
      ) AS umsatz
  `;

  con.query(sql, [datum, datum, datum], function(err, result) {
    if (err) return sendeDatenbankFehler(res, err);
    res.json(result[0]);
  });
});

/* =========================
   SELECT: Produkte anzeigen
========================= */

app.get("/produkte", function(req, res) {
  var sql = `
    SELECT
      p.Produkt_id,
      p.Produktname,
      p.Preis,
      p.Beschreibung,
      p.Aktiv,
      p.Kategorie_id,
      k.Kategorie_name
    FROM Produkt p
    INNER JOIN Kategorie k
      ON p.Kategorie_id = k.Kategorie_id
    ORDER BY p.Produkt_id
  `;

  con.query(sql, function(err, result) {
    if (err) return sendeDatenbankFehler(res, err);
    res.json(result);
  });
});

/* =========================
   SELECT: Kategorien laden
========================= */

app.get("/kategorien", function(req, res) {
  var sql = `
    SELECT Kategorie_id, Kategorie_name
    FROM Kategorie
    ORDER BY Kategorie_id
  `;

  con.query(sql, function(err, result) {
    if (err) return sendeDatenbankFehler(res, err);
    res.json(result);
  });
});

/* =========================
   SELECT: Mitarbeiter laden
========================= */

app.get("/mitarbeiter", function(req, res) {
  var sql = `
    SELECT Mitarbeiter_id, Vorname, Nachname, Rolle
    FROM Mitarbeiter
    ORDER BY Mitarbeiter_id
  `;

  con.query(sql, function(err, result) {
    if (err) return sendeDatenbankFehler(res, err);
    res.json(result);
  });
});

/* =========================
   SELECT: Tische laden
========================= */

app.get("/tische", function(req, res) {
  var sql = `
    SELECT Tisch_nummer, Sitzplaetze
    FROM Tisch
    ORDER BY Tisch_nummer
  `;

  con.query(sql, function(err, result) {
    if (err) return sendeDatenbankFehler(res, err);
    res.json(result);
  });
});

/* =========================
   SELECT: Bestellte Produkte anzeigen
========================= */

app.get("/bestellte-produkte", function(req, res) {
  var datum = req.query.datum;

  var sql = `
    SELECT
      b.Bestellung_id,
      DATE_FORMAT(b.Bestellzeitpunkt, '%Y-%m-%d %H:%i') AS Bestellzeitpunkt,
      b.Status,
      p.Produktname,
      bp.Bestellmenge,
      bp.Einzelpreis,
      ROUND(bp.Bestellmenge * bp.Einzelpreis, 2) AS Positionswert
    FROM Bestellposition bp
    INNER JOIN Bestellung b
      ON bp.Bestellung_id = b.Bestellung_id
    INNER JOIN Produkt p
      ON bp.Produkt_id = p.Produkt_id
  `;

  var werte = [];

  if (datum) {
    sql += " WHERE DATE(b.Bestellzeitpunkt) = ? ";
    werte.push(datum);
  }

  sql += " ORDER BY b.Bestellzeitpunkt DESC, b.Bestellung_id DESC ";

  con.query(sql, werte, function(err, result) {
    if (err) return sendeDatenbankFehler(res, err);
    res.json(result);
  });
});

/* =========================
   SELECT: Top-Produkte über vorhandene View
========================= */

app.get("/top-produkte", function(req, res) {
  var sql = `
    SELECT
      Produkt_id,
      Produktname,
      Kategorie_name,
      Verkaufte_Menge,
      Umsatz
    FROM view_top_produkte
    ORDER BY Verkaufte_Menge DESC
    LIMIT 5
  `;

  con.query(sql, function(err, result) {
    if (err) return sendeDatenbankFehler(res, err);
    res.json(result);
  });
});

/* =========================
   INSERT: Produkt hinzufügen
========================= */

app.post("/produkt", function(req, res) {
  var produktname = req.body.produktname;
  var preis = req.body.preis;
  var beschreibung = req.body.beschreibung;
  var kategorieId = req.body.kategorieId;

  var sql = `
    INSERT INTO Produkt
      (Produktname, Preis, Beschreibung, Aktiv, Kategorie_id)
    VALUES
      (?, ?, ?, TRUE, ?)
  `;

  con.query(sql, [produktname, preis, beschreibung, kategorieId], function(err, result) {
    if (err) return sendeDatenbankFehler(res, err);

    res.json({
      success: true,
      message: "Produkt wurde erfolgreich hinzugefügt.",
      neueProduktId: result.insertId
    });
  });
});

/* =========================
   INSERT über vorhandene Stored Procedure:
   Bestellung anlegen
========================= */

app.post("/bestellung-anlegen", function(req, res) {
  var tischNummer = req.body.tischNummer;
  var mitarbeiterVorname = req.body.mitarbeiterVorname;
  var mitarbeiterNachname = req.body.mitarbeiterNachname;
  var produktname = req.body.produktname;
  var bestellmenge = req.body.bestellmenge;

  var sql = "CALL sp_bestellung_anlegen(?, ?, ?, ?, ?)";

  con.query(
    sql,
    [tischNummer, mitarbeiterVorname, mitarbeiterNachname, produktname, bestellmenge],
    function(err, result) {
      if (err) return sendeDatenbankFehler(res, err);

      res.json({
        success: true,
        message: "Bestellung wurde erfolgreich über die Stored Procedure angelegt."
      });
    }
  );
});

/* =========================
   UPDATE: Produktpreis ändern
========================= */

app.put("/produkt-preis", function(req, res) {
  var produktId = req.body.produktId;
  var neuerPreis = req.body.neuerPreis;

  var sql = `
    UPDATE Produkt
    SET Preis = ?
    WHERE Produkt_id = ?
  `;

  con.query(sql, [neuerPreis, produktId], function(err, result) {
    if (err) return sendeDatenbankFehler(res, err);

    if (result.affectedRows === 0) {
      return res.status(404).json({
        success: false,
        message: "Es wurde kein Produkt mit dieser ID gefunden."
      });
    }

    res.json({
      success: true,
      message: "Produktpreis wurde aktualisiert.",
      geaenderteDatensaetze: result.affectedRows
    });
  });
});

/* =========================
   UPDATE: Produkt deaktivieren
========================= */

app.put("/produkt-deaktivieren", function(req, res) {
  var produktId = req.body.produktId;

  var sql = `
    UPDATE Produkt
    SET Aktiv = FALSE
    WHERE Produkt_id = ?
  `;

  con.query(sql, [produktId], function(err, result) {
    if (err) return sendeDatenbankFehler(res, err);

    if (result.affectedRows === 0) {
      return res.status(404).json({
        success: false,
        message: "Es wurde kein Produkt mit dieser ID gefunden."
      });
    }

    res.json({
      success: true,
      message: "Produkt wurde deaktiviert und bleibt für alte Bestellungen erhalten."
    });
  });
});

/* =========================
   UPDATE: Produkt reaktivieren
========================= */

app.put("/produkt-reaktivieren", function(req, res) {
  var produktId = req.body.produktId;

  var sql = `
    UPDATE Produkt
    SET Aktiv = TRUE
    WHERE Produkt_id = ?
  `;

  con.query(sql, [produktId], function(err, result) {
    if (err) return sendeDatenbankFehler(res, err);

    if (result.affectedRows === 0) {
      return res.status(404).json({
        success: false,
        message: "Es wurde kein Produkt mit dieser ID gefunden."
      });
    }

    res.json({
      success: true,
      message: "Produkt wurde erfolgreich reaktiviert."
    });
  });
});

/* =========================
   DELETE: Produkt löschen
========================= */

app.delete("/produkt/:id", function(req, res) {
  var produktId = req.params.id;

  var sql = `
    DELETE FROM Produkt
    WHERE Produkt_id = ?
  `;

  con.query(sql, [produktId], function(err, result) {
    if (err) {
      if (err.errno === 1451) {
        return res.status(400).json({
          success: false,
          message: "Dieses Produkt kann nicht gelöscht werden, weil es bereits in Bestellungen verwendet wurde. Bitte deaktivieren Sie das Produkt stattdessen."
        });
      }

      return sendeDatenbankFehler(res, err);
    }

    if (result.affectedRows === 0) {
      return res.status(404).json({
        success: false,
        message: "Es wurde kein Produkt mit dieser ID gefunden."
      });
    }

    res.json({
      success: true,
      message: "Produkt wurde erfolgreich gelöscht.",
      geloeschteDatensaetze: result.affectedRows
    });
  });
});

app.listen(8080, function() {
  console.log("Server läuft auf http://localhost:8080");
});