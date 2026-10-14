function leseJsonAntwort(response) {
  return response.json().then(function(data) {
    if (!response.ok) {
      throw new Error(data.message || "Ein Fehler ist aufgetreten.");
    }

    return data;
  });
}

/* =========================
   Dashboard
========================= */

function ladeDashboard() {
  var datum = document.getElementById("dashboardDatum").value;

  fetch("/dashboard?datum=" + datum)
    .then(leseJsonAntwort)
    .then(function(data) {
      document.getElementById("anzahlReservierungen").innerText =
        data.anzahl_reservierungen;

      document.getElementById("anzahlBestellungen").innerText =
        data.anzahl_bestellungen;

      document.getElementById("umsatz").innerText =
        Number(data.umsatz).toFixed(2) + " €";
    })
    .catch(function(error) {
      console.error("Fehler beim Laden des Dashboards:", error);
    });
}

/* =========================
   Produkte anzeigen
========================= */

function ladeProdukte() {
  fetch("/produkte")
    .then(leseJsonAntwort)
    .then(function(data) {
      var tabelle = document.getElementById("produktTabelle");
      tabelle.innerHTML = "";

      data.forEach(function(produkt) {
        var zeile = document.createElement("tr");

        zeile.innerHTML = `
          <td>${produkt.Produkt_id}</td>
          <td>${produkt.Produktname}</td>
          <td>${Number(produkt.Preis).toFixed(2)} €</td>
          <td>${produkt.Beschreibung}</td>
          <td>${produkt.Aktiv === 1 ? "Ja" : "Nein"}</td>
          <td>${produkt.Kategorie_name}</td>
        `;

        tabelle.appendChild(zeile);
      });

      fuelleProduktAuswahlfelder(data);
    })
    .catch(function(error) {
      console.error("Fehler beim Laden der Produkte:", error);
    });
}

/* =========================
   Produkt-Dropdowns füllen
========================= */

function fuelleProduktAuswahlfelder(produkte) {
  var preisSelect = document.getElementById("preisProduktId");
  var deaktivierenSelect = document.getElementById("deaktivierenProduktId");
  var reaktivierenSelect = document.getElementById("reaktivierenProduktId");
  var loeschSelect = document.getElementById("loeschProduktId");

  preisSelect.innerHTML = "";
  deaktivierenSelect.innerHTML = "";
  reaktivierenSelect.innerHTML = "";
  loeschSelect.innerHTML = "";

  produkte.forEach(function(produkt) {
    var produktText =
      produkt.Produktname + " - " + Number(produkt.Preis).toFixed(2) + " €";

    var optionPreis = document.createElement("option");
    optionPreis.value = produkt.Produkt_id;
    optionPreis.textContent = produktText;
    preisSelect.appendChild(optionPreis);

    var optionLoeschen = document.createElement("option");
    optionLoeschen.value = produkt.Produkt_id;
    optionLoeschen.textContent = produktText;
    loeschSelect.appendChild(optionLoeschen);

    if (produkt.Aktiv === 1) {
      var optionDeaktivieren = document.createElement("option");
      optionDeaktivieren.value = produkt.Produkt_id;
      optionDeaktivieren.textContent = produktText;
      deaktivierenSelect.appendChild(optionDeaktivieren);
    } else {
      var optionReaktivieren = document.createElement("option");
      optionReaktivieren.value = produkt.Produkt_id;
      optionReaktivieren.textContent = produktText;
      reaktivierenSelect.appendChild(optionReaktivieren);
    }
  });

  if (deaktivierenSelect.options.length === 0) {
    var option = document.createElement("option");
    option.textContent = "Keine aktiven Produkte vorhanden";
    option.disabled = true;
    deaktivierenSelect.appendChild(option);
  }

  if (reaktivierenSelect.options.length === 0) {
    var optionLeer = document.createElement("option");
    optionLeer.textContent = "Keine inaktiven Produkte vorhanden";
    optionLeer.disabled = true;
    reaktivierenSelect.appendChild(optionLeer);
  }
}

/* =========================
   Bestellte Produkte anzeigen
========================= */

function ladeBestellteProdukte() {
  var datum = document.getElementById("bestellteProdukteDatum").value;

  fetch("/bestellte-produkte?datum=" + datum)
    .then(leseJsonAntwort)
    .then(function(data) {
      var tabelle = document.getElementById("bestellteProdukteTabelle");
      tabelle.innerHTML = "";

      data.forEach(function(eintrag) {
        var zeile = document.createElement("tr");

        zeile.innerHTML = `
          <td>${eintrag.Bestellung_id}</td>
          <td>${eintrag.Bestellzeitpunkt}</td>
          <td>${eintrag.Status}</td>
          <td>${eintrag.Produktname}</td>
          <td>${eintrag.Bestellmenge}</td>
          <td>${Number(eintrag.Einzelpreis).toFixed(2)} €</td>
          <td>${Number(eintrag.Positionswert).toFixed(2)} €</td>
        `;

        tabelle.appendChild(zeile);
      });
    })
    .catch(function(error) {
      console.error("Fehler beim Laden der bestellten Produkte:", error);
    });
}

/* =========================
   Top-Produkte anzeigen
========================= */

function ladeTopProdukte() {
  fetch("/top-produkte")
    .then(leseJsonAntwort)
    .then(function(data) {
      var tabelle = document.getElementById("topProdukteTabelle");
      var diagramm = document.getElementById("topProdukteDiagramm");

      tabelle.innerHTML = "";
      diagramm.innerHTML = "";

      var maximaleMenge = 0;

      data.forEach(function(produkt) {
        if (produkt.Verkaufte_Menge > maximaleMenge) {
          maximaleMenge = produkt.Verkaufte_Menge;
        }
      });

      data.forEach(function(produkt) {
        var zeile = document.createElement("tr");

        zeile.innerHTML = `
          <td>${produkt.Produkt_id}</td>
          <td>${produkt.Produktname}</td>
          <td>${produkt.Kategorie_name}</td>
          <td>${produkt.Verkaufte_Menge}</td>
          <td>${Number(produkt.Umsatz).toFixed(2)} €</td>
        `;

        tabelle.appendChild(zeile);

        var breite = 0;

        if (maximaleMenge > 0) {
          breite = (produkt.Verkaufte_Menge / maximaleMenge) * 100;
        }

        var balkenZeile = document.createElement("div");
        balkenZeile.className = "diagramm-zeile";

        balkenZeile.innerHTML = `
          <div class="diagramm-label">${produkt.Produktname}</div>
          <div class="diagramm-balken-hintergrund">
            <div class="diagramm-balken" style="width: ${breite}%;">
              ${produkt.Verkaufte_Menge}
            </div>
          </div>
        `;

        diagramm.appendChild(balkenZeile);
      });
    })
    .catch(function(error) {
      console.error("Fehler beim Laden der Top-Produkte:", error);
    });
}

/* =========================
   Kategorien laden
========================= */

function ladeKategorien() {
  fetch("/kategorien")
    .then(leseJsonAntwort)
    .then(function(data) {
      var select = document.getElementById("kategorieId");
      select.innerHTML = "";

      data.forEach(function(kategorie) {
        var option = document.createElement("option");
        option.value = kategorie.Kategorie_id;
        option.textContent = kategorie.Kategorie_name;
        select.appendChild(option);
      });
    })
    .catch(function(error) {
      console.error("Fehler beim Laden der Kategorien:", error);
    });
}

/* =========================
   Produkte für Bestellung laden
========================= */

function ladeProdukteFuerBestellung() {
  fetch("/produkte")
    .then(leseJsonAntwort)
    .then(function(data) {
      var select = document.getElementById("bestellungProdukt");
      select.innerHTML = "";

      data.forEach(function(produkt) {
        if (produkt.Aktiv === 1) {
          var option = document.createElement("option");
          option.value = produkt.Produktname;
          option.textContent =
            produkt.Produktname + " - " + Number(produkt.Preis).toFixed(2) + " €";
          select.appendChild(option);
        }
      });
    })
    .catch(function(error) {
      console.error("Fehler beim Laden der Produkte für Bestellung:", error);
    });
}

/* =========================
   Mitarbeiter laden
========================= */

function ladeMitarbeiter() {
  fetch("/mitarbeiter")
    .then(leseJsonAntwort)
    .then(function(data) {
      var select = document.getElementById("bestellungMitarbeiter");
      select.innerHTML = "";

      data.forEach(function(mitarbeiter) {
        var option = document.createElement("option");

        option.value = mitarbeiter.Vorname + "|" + mitarbeiter.Nachname;
        option.textContent =
          mitarbeiter.Vorname +
          " " +
          mitarbeiter.Nachname +
          " (" +
          mitarbeiter.Rolle +
          ")";

        select.appendChild(option);
      });
    })
    .catch(function(error) {
      console.error("Fehler beim Laden der Mitarbeiter:", error);
    });
}

/* =========================
   Tische laden
========================= */

function ladeTische() {
  fetch("/tische")
    .then(leseJsonAntwort)
    .then(function(data) {
      var select = document.getElementById("bestellungTisch");
      select.innerHTML = "";

      data.forEach(function(tisch) {
        var option = document.createElement("option");

        option.value = tisch.Tisch_nummer;
        option.textContent =
          "Tisch " + tisch.Tisch_nummer + " (" + tisch.Sitzplaetze + " Plätze)";

        select.appendChild(option);
      });
    })
    .catch(function(error) {
      console.error("Fehler beim Laden der Tische:", error);
    });
}

/* =========================
   Bestellung anlegen
========================= */

document.getElementById("bestellungForm").addEventListener("submit", function(event) {
  event.preventDefault();

  var mitarbeiterWert = document.getElementById("bestellungMitarbeiter").value;
  var teile = mitarbeiterWert.split("|");

  var daten = {
    tischNummer: document.getElementById("bestellungTisch").value,
    mitarbeiterVorname: teile[0],
    mitarbeiterNachname: teile[1],
    produktname: document.getElementById("bestellungProdukt").value,
    bestellmenge: document.getElementById("bestellmenge").value
  };

  fetch("/bestellung-anlegen", {
    method: "POST",
    headers: {
      "Content-Type": "application/json"
    },
    body: JSON.stringify(daten)
  })
    .then(leseJsonAntwort)
    .then(function(data) {
      document.getElementById("bestellungMeldung").innerText = data.message;

      document.getElementById("bestellungForm").reset();

      ladeDashboard();
      ladeBestellteProdukte();
      ladeTopProdukte();
    })
    .catch(function(error) {
      document.getElementById("bestellungMeldung").innerText = error.message;
    });
});

/* =========================
   Produkt hinzufügen
========================= */

document.getElementById("produktForm").addEventListener("submit", function(event) {
  event.preventDefault();

  var produkt = {
    produktname: document.getElementById("produktname").value,
    preis: document.getElementById("preis").value,
    beschreibung: document.getElementById("beschreibung").value,
    kategorieId: document.getElementById("kategorieId").value
  };

  fetch("/produkt", {
    method: "POST",
    headers: {
      "Content-Type": "application/json"
    },
    body: JSON.stringify(produkt)
  })
    .then(leseJsonAntwort)
    .then(function(data) {
      document.getElementById("produktMeldung").innerText = data.message;

      document.getElementById("produktForm").reset();

      ladeProdukte();
      ladeProdukteFuerBestellung();
    })
    .catch(function(error) {
      document.getElementById("produktMeldung").innerText = error.message;
    });
});

/* =========================
   Produktpreis ändern
========================= */

document.getElementById("preisForm").addEventListener("submit", function(event) {
  event.preventDefault();

  var daten = {
    produktId: document.getElementById("preisProduktId").value,
    neuerPreis: document.getElementById("neuerPreis").value
  };

  fetch("/produkt-preis", {
    method: "PUT",
    headers: {
      "Content-Type": "application/json"
    },
    body: JSON.stringify(daten)
  })
    .then(leseJsonAntwort)
    .then(function(data) {
      document.getElementById("preisMeldung").innerText = data.message;

      ladeProdukte();
      ladeProdukteFuerBestellung();
    })
    .catch(function(error) {
      document.getElementById("preisMeldung").innerText = error.message;
    });
});

/* =========================
   Produkt deaktivieren
========================= */

document.getElementById("deaktivierenForm").addEventListener("submit", function(event) {
  event.preventDefault();

  var daten = {
    produktId: document.getElementById("deaktivierenProduktId").value
  };

  fetch("/produkt-deaktivieren", {
    method: "PUT",
    headers: {
      "Content-Type": "application/json"
    },
    body: JSON.stringify(daten)
  })
    .then(leseJsonAntwort)
    .then(function(data) {
      document.getElementById("deaktivierenMeldung").innerText = data.message;

      ladeProdukte();
      ladeProdukteFuerBestellung();
    })
    .catch(function(error) {
      document.getElementById("deaktivierenMeldung").innerText = error.message;
    });
});

/* =========================
   Produkt reaktivieren
========================= */

document.getElementById("reaktivierenForm").addEventListener("submit", function(event) {
  event.preventDefault();

  var daten = {
    produktId: document.getElementById("reaktivierenProduktId").value
  };

  fetch("/produkt-reaktivieren", {
    method: "PUT",
    headers: {
      "Content-Type": "application/json"
    },
    body: JSON.stringify(daten)
  })
    .then(leseJsonAntwort)
    .then(function(data) {
      document.getElementById("reaktivierenMeldung").innerText = data.message;

      ladeProdukte();
      ladeProdukteFuerBestellung();
    })
    .catch(function(error) {
      document.getElementById("reaktivierenMeldung").innerText = error.message;
    });
});

/* =========================
   Produkt löschen
========================= */

document.getElementById("loeschForm").addEventListener("submit", function(event) {
  event.preventDefault();

  var produktId = document.getElementById("loeschProduktId").value;

  fetch("/produkt/" + produktId, {
    method: "DELETE"
  })
    .then(leseJsonAntwort)
    .then(function(data) {
      document.getElementById("loeschMeldung").innerText = data.message;

      ladeProdukte();
      ladeProdukteFuerBestellung();
    })
    .catch(function(error) {
      document.getElementById("loeschMeldung").innerText = error.message;
    });
});

/* =========================
   Beim Laden der Seite automatisch Daten laden
========================= */

ladeDashboard();
ladeProdukte();
ladeKategorien();
ladeProdukteFuerBestellung();
ladeMitarbeiter();
ladeTische();
ladeTopProdukte();