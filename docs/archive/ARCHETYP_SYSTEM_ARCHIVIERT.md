# ⚠️ ARCHIVIERT: Archetyp-System (Alte Konzeption)

> **Status:** 🗄️ **ARCHIVIERT am 2026-02-12**
> **Grund:** Dieses Dokument beschreibt ein **veraltetes hardcodiertes 12-Archetypen-System**
> **Aktuelle Implementierung:** Individuell generierte Archetyp-Titel via Claude API

---

## 📌 Was war das alte Konzept?

Das ursprüngliche Archetyp-System sah vor:
- **12 hardcodierte Archetyp-Namen** (Die Pionierin, Die Diplomatin, Die Kreative, etc.)
- **10 hardcodierte Bazi-Adjektive** (die standfeste, die anpassungsfähige, die strahlende, etc.)
- **Kombination:** Western Archetyp + Bazi Adjektiv = "Die standfeste Pionierin"
- **12 separate Detail-Screens** für jeden Archetyp

---

## ✅ Was ist die aktuelle Implementierung?

**Archetyp-Signatur = Individuell generiert via Claude API**

### Wie es funktioniert:
1. User gibt Geburtsdaten ein
2. System berechnet BirthChart (Western + Bazi + Numerologie)
3. **Claude API generiert INDIVIDUELLEN Titel + Synthese-Text**
   - Beispiel: "Die großzügige Perfektionistin"
   - NICHT aus 12 vordefinierten Namen!
4. Text wird in `profiles.signature_text` gespeichert
5. Erscheint auf Home Screen (goldene Hero-Card)

### Technische Details:
- **Prompt-File:** `apps/glow/lib/src/core/services/prompts/archetype_signature_prompt.dart`
- **Service:** `ArchetypeSignatureService`
- **DB-Feld:** `profiles.signature_text` (TEXT, nullable)
- **UI-Widget:** `ArchetypeHeader` (Home Screen)
- **Kosten:** ~$0.001 pro User (einmalig)

---

## 📚 Aktuelle Dokumentation

Für die **aktuelle** Archetyp-Implementierung siehe:
- **`docs/CLAUDE_BRIEFING_CONTENT_STRATEGY.md`** — Archetyp vs. Content Library (klare Aufstellung)
- **`docs/daily-logs/2026-02-12_archetyp-konzept-klarstellung.md`** — Konzept-Änderung erklärt
- **`docs/daily-logs/2026-02-12_content-strategy-klarstellung.md`** — Session-Log der Klarstellung

---

## 🗂️ Archivierte Original-Dokumentation

Die ursprüngliche Konzeption ist verfügbar in:
- **`docs/archive/ARCHETYP_SYSTEM_OLD.md`** — Original-Dokument (historisch)

---

**Archiviert:** 2026-02-12
**Grund:** Implementierung weicht fundamental vom ursprünglichen Konzept ab
**Status:** Nur noch für historische Referenz relevant
