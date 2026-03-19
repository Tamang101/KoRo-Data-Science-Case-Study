## KoRo Data Science Case Study

Autor: Prajwal Tamang
Tools: Google BigQuery (SQL), Power BI

##  Projektübersicht

In diesem Projekt wurde das Kaufverhalten von Kunden sowie die Produktperformance eines E-Commerce-Unternehmens analysiert.
Ziel war es, Neukundenverhalten, Marketingkanäle und Produktnachfrage nach Ländern zu untersuchen.

## Datensätze

Die Analyse basiert auf folgenden Tabellen:

orders → Bestelldaten (Kunde, Datum, Produkt, Land)

product_universal → Produktkategorien

product_locale → Produktnamen

marketing_sources → Marketingkanäle (reporting_channel)

## Vorgehensweise

Die detaillierten SQL-Schritte sind direkt in den .sql-Dateien dokumentiert.

Wichtige Schritte:

Erstellung eines Order-Level-Datensatzes (Entfernung von Duplikaten)

Identifikation des ersten Kaufs pro Kunde mit ROW_NUMBER()

Berechnung von Kennzahlen zur Kundenakquise

Analyse von Produktkategorien und Bestellvolumen

Ranking von Produkten mit RANK() und ROW_NUMBER()

## Task 1 – Customer Order Activity
Ziel

Analyse des Kundenverhaltens und Identifikation von Erstkäufen.

Methoden

Verwendung von ROW_NUMBER() zur Bestimmung des ersten Kaufs

Berechnung von:

Gesamtanzahl Bestellungen

Erstbestellungen

Anteil neuer Kunden (%)

Analyse von Wiederkäufen innerhalb von:

10 Tagen

15 Tagen

20 Tagen

 ## Visualisierung 1 – Neukundenanteil über Zeit

Insight

Dieses Liniendiagramm zeigt den Anteil der täglichen Bestellungen von Neukunden.
Die Visualisierung hilft dabei, Trends in der Kundenakquise zu erkennen und Veränderungen über die Zeit zu analysieren.
Ein Liniendiagramm wurde gewählt, da es zeitliche Entwicklungen besonders gut darstellt.

 ## Bonus – Marketing Channel Analyse
Ziel

Analyse der Neukunden nach Marketingkanälen.

Join mit marketing_sources

Fehlende Werte wurden als "Unknown" klassifiziert

 Visualisierung 2 – Neukundenanteil nach Marketingkanal

Insight

Diese Heatmap zeigt den Anteil der Neukunden pro Marketingkanal über die Zeit.
Dunklere Farben stehen für einen höheren Anteil an Neukunden.
Die Heatmap ermöglicht einen schnellen Vergleich der Performance verschiedener Kanäle.

 ## Task 2 – Produktanalyse
Ziel

Analyse der Produktperformance nach Ländern.

Methoden

Join zwischen orders und Produktdaten

Aggregation nach:

Land (country_iso)

Produktkategorie (main_category)

Ranking von Produkten:

Top 5 Produkte pro Land (RANK())

Bottom 5 Produkte (ROW_NUMBER())

Visualisierung 3 – Produktkategorien nach Ländern

Insight

Dieses Balkendiagramm vergleicht das Bestellvolumen verschiedener Produktkategorien zwischen Ländern.
Es zeigt, welche Kategorien besonders gefragt sind und verdeutlicht Unterschiede im Konsumverhalten.
Das Balkendiagramm eignet sich gut, um kategorische Daten zu vergleichen.

 ## Power BI Integration

Power BI wurde direkt mit Google BigQuery verbunden:

Power BI öffnen

Get Data → Google BigQuery

Login mit Google-Konto

Dataset auswählen (koro_case)

Tabellen importieren

Die Visualisierungen wurden auf Basis der SQL-Ergebnisse erstellt.
