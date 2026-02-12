/// Bazi (Vier Säulen des Schicksals) Calculator
///
/// Berechnet die chinesischen astrologischen Säulen basierend auf Geburtsdatum und -zeit.
/// Bazi nutzt den chinesischen Solarkalender, NICHT den Mondkalender!
///
/// Die Vier Säulen:
/// - Jahressäule: Stem + Branch (Charakter, Kindheit)
/// - Monatssäule: Stem + Branch (Karriere, mittleres Leben)
/// - Tagessäule: Stem (Day Master) + Branch (Partnerschaft, Beziehungen)
/// - Stundensäule: Stem + Branch (Kinder, Alter) - nur mit Geburtszeit
class BaziCalculator {
  /// Die 10 Heavenly Stems (Himmelsstämme) im Zyklus
  static const List<String> _heavenlyStems = [
    'Jia',   // 甲 (Yang Wood)
    'Yi',    // 乙 (Yin Wood)
    'Bing',  // 丙 (Yang Fire)
    'Ding',  // 丁 (Yin Fire)
    'Wu',    // 戊 (Yang Earth)
    'Ji',    // 己 (Yin Earth)
    'Geng',  // 庚 (Yang Metal)
    'Xin',   // 辛 (Yin Metal)
    'Ren',   // 壬 (Yang Water)
    'Gui',   // 癸 (Yin Water)
  ];

  /// Die 12 Earthly Branches (Erdzweige) im Zyklus
  static const List<String> _earthlyBranches = [
    'Rat',    // 子 (Zi)
    'Ox',     // 丑 (Chou)
    'Tiger',  // 寅 (Yin)
    'Rabbit', // 卯 (Mao)
    'Dragon', // 辰 (Chen)
    'Snake',  // 巳 (Si)
    'Horse',  // 午 (Wu)
    'Goat',   // 未 (Wei)
    'Monkey', // 申 (Shen)
    'Rooster',// 酉 (You)
    'Dog',    // 戌 (Xu)
    'Pig',    // 亥 (Hai)
  ];

  /// Mapping Heavenly Stem → Element
  static const Map<String, String> _stemElements = {
    'Jia': 'Wood',  'Yi': 'Wood',
    'Bing': 'Fire', 'Ding': 'Fire',
    'Wu': 'Earth',  'Ji': 'Earth',
    'Geng': 'Metal', 'Xin': 'Metal',
    'Ren': 'Water', 'Gui': 'Water',
  };

  /// Mapping Earthly Branch → Element
  static const Map<String, String> _branchElements = {
    'Rat': 'Water',  'Ox': 'Earth',  'Tiger': 'Wood',
    'Rabbit': 'Wood', 'Dragon': 'Earth', 'Snake': 'Fire',
    'Horse': 'Fire',  'Goat': 'Earth',  'Monkey': 'Metal',
    'Rooster': 'Metal', 'Dog': 'Earth', 'Pig': 'Water',
  };

  /// Chinesisches Neujahr für bekannte Jahre
  /// Wichtig: Chinesisches Jahr beginnt am Lichun (立春), nicht am Mond-Neujahr!
  /// Lichun ist der Solar Term bei Sonnen-Länge 315° (~3.-5. Februar)
  static const Map<int, String> _lichunDates = {
    2020: '2020-02-04',
    2021: '2021-02-03',
    2022: '2022-02-04',
    2023: '2023-02-04',
    2024: '2024-02-04',
    2025: '2025-02-03',
    2026: '2026-02-04',
    1983: '1983-02-04',
    1984: '1984-02-04',
    1985: '1985-02-04',
  };

  /// Berechnet die Jahressäule (Year Pillar)
  ///
  /// Wichtig: Verwendet Lichun (ca. 4. Februar) als Jahreswechsel,
  /// NICHT den 1. Januar oder das Mond-Neujahr!
  static Map<String, String> calculateYearPillar(DateTime birthDate) {
    int year = birthDate.year;

    // Prüfe ob vor Lichun geboren → vorheriges chinesisches Jahr
    final lichunDate = _getLichunDate(year);
    if (birthDate.isBefore(lichunDate)) {
      year -= 1;
    }

    // Berechne Stem und Branch für das Jahr
    // Referenz: 1984 = Jiazi (Jia-Rat), Start des 60-Jahre-Zyklus
    final yearsSince1984 = year - 1984;

    final stemIndex = (yearsSince1984 % 10 + 10) % 10; // +10 für negative Jahre
    final branchIndex = (yearsSince1984 % 12 + 12) % 12;

    return {
      'stem': _heavenlyStems[stemIndex],
      'branch': _earthlyBranches[branchIndex],
      'element': _stemElements[_heavenlyStems[stemIndex]]!,
    };
  }

  /// Berechnet die Monatssäule (Month Pillar)
  ///
  /// Chinesische Monate folgen Solar Terms (Jieqi), nicht dem gregorianischen Kalender!
  /// Jeder Monat beginnt bei einem spezifischen Solar Term.
  ///
  /// Die 12 Solar Terms (Monatsbeginn):
  /// - Lichun (立春, ~4. Feb): Tiger-Monat
  /// - Jingzhe (惊蛰, ~6. Mär): Hase-Monat
  /// - Qingming (清明, ~5. Apr): Drachen-Monat
  /// - Lixia (立夏, ~6. Mai): Schlangen-Monat
  /// - Mangzhong (芒种, ~6. Jun): Pferd-Monat
  /// - Xiaoshu (小暑, ~7. Jul): Ziegen-Monat
  /// - Liqiu (立秋, ~8. Aug): Affen-Monat
  /// - Bailu (白露, ~8. Sep): Hahn-Monat
  /// - Hanlu (寒露, ~8. Okt): Hund-Monat
  /// - Lidong (立冬, ~7. Nov): Schwein-Monat
  /// - Daxue (大雪, ~7. Dez): Ratten-Monat
  /// - Xiaohan (小寒, ~6. Jan): Ochsen-Monat
  static Map<String, String> calculateMonthPillar(DateTime birthDate) {
    final month = birthDate.month;
    final day = birthDate.day;

    // Bestimme chinesischen Monat (0-11) basierend auf Solar Terms
    // Branch-Index: Rat=0, Ox=1, Tiger=2, ...
    int branchIndex;

    if (month == 1) {
      branchIndex = day < 6 ? 0 : 1; // Rat → Ox (Xiaohan ~6. Jan)
    } else if (month == 2) {
      branchIndex = day < 4 ? 1 : 2; // Ox → Tiger (Lichun ~4. Feb)
    } else if (month == 3) {
      branchIndex = day < 6 ? 2 : 3; // Tiger → Rabbit (Jingzhe ~6. Mär)
    } else if (month == 4) {
      branchIndex = day < 5 ? 3 : 4; // Rabbit → Dragon (Qingming ~5. Apr)
    } else if (month == 5) {
      branchIndex = day < 6 ? 4 : 5; // Dragon → Snake (Lixia ~6. Mai)
    } else if (month == 6) {
      branchIndex = day < 6 ? 5 : 6; // Snake → Horse (Mangzhong ~6. Jun)
    } else if (month == 7) {
      branchIndex = day < 7 ? 6 : 7; // Horse → Goat (Xiaoshu ~7. Jul)
    } else if (month == 8) {
      branchIndex = day < 8 ? 7 : 8; // Goat → Monkey (Liqiu ~8. Aug)
    } else if (month == 9) {
      branchIndex = day < 8 ? 8 : 9; // Monkey → Rooster (Bailu ~8. Sep)
    } else if (month == 10) {
      branchIndex = day < 8 ? 9 : 10; // Rooster → Dog (Hanlu ~8. Okt)
    } else if (month == 11) {
      branchIndex = day < 7 ? 10 : 11; // Dog → Pig (Lidong ~7. Nov)
    } else {
      branchIndex = day < 7 ? 11 : 0; // Pig → Rat (Daxue ~7. Dez)
    }

    // Monatssäule Stem hängt vom Jahres-Stem ab
    // Formel: (Jahr-Stem × 2 + Monats-Branch) % 10
    final year = birthDate.year;
    final lichunDate = _getLichunDate(year);
    final adjustedYear = birthDate.isBefore(lichunDate) ? year - 1 : year;
    final yearsSince1984 = adjustedYear - 1984;
    final yearStemIndex = (yearsSince1984 % 10 + 10) % 10;

    // Monatssäule Stem-Offset
    final stemIndex = (yearStemIndex * 2 + branchIndex) % 10;

    return {
      'stem': _heavenlyStems[stemIndex],
      'branch': _earthlyBranches[branchIndex],
      'element': _stemElements[_heavenlyStems[stemIndex]]!,
    };
  }

  /// Berechnet die Tagessäule (Day Pillar)
  ///
  /// Der Day Master (Tages-Stem) ist die wichtigste Komponente im Bazi.
  /// Er repräsentiert das Selbst, die Identität, den Kern der Persönlichkeit.
  ///
  /// WICHTIG: Der 60-Tage-Zyklus (Jiazi-Zyklus) folgt einer festen Sequenz!
  /// Referenz empirisch kalibriert: 24. Januar 1900 = Jia-Rat (甲子)
  static Map<String, String> calculateDayPillar(DateTime birthDate) {
    // Berechne Julian Day für präzises Datum (lokale Zeit!)
    final julianDay = _calculateJulianDay(birthDate);

    // Referenz: 3. Oktober 1983 = Jiazi (Jia-Rat), Tag 0 des 60-Tage-Zyklus
    // Arbeite direkt mit bekanntem Datum statt historischer Referenz
    const referenceJD = 2445611.0; // 3. Okt 1983, 12:00 (Mittag)

    // Tage seit Referenz (ohne Fractional Part für Tag-Grenze bei Mitternacht)
    final daysSinceReference = (julianDay - referenceJD + 0.5).floor();

    // Index im 60-Tage-Zyklus (Jiazi-Zyklus)
    final cycleIndex = ((daysSinceReference % 60) + 60) % 60; // Positiver Modulo

    // Der 60-Tage-Zyklus: Stem (10) und Branch (12) laufen parallel
    // Tag 0: Jia-Rat (0,0), Tag 1: Yi-Ox (1,1), ..., Tag 58: Ren-Xu (8,10)
    final stemIndex = cycleIndex % 10;
    final branchIndex = cycleIndex % 12;

    final stem = _heavenlyStems[stemIndex];
    final branch = _earthlyBranches[branchIndex];

    return {
      'stem': stem,           // = Day Master!
      'branch': branch,
      'element': _stemElements[stem]!,
    };
  }

  /// Berechnet die Stundensäule (Hour Pillar)
  ///
  /// Benötigt genaue Geburtszeit. Ohne Geburtszeit → null
  ///
  /// Chinesische Stunden sind 2-Stunden-Blöcke:
  /// Rat: 23-01, Ox: 01-03, Tiger: 03-05, ...
  static Map<String, String>? calculateHourPillar({
    required DateTime birthDateTime,
  }) {
    // Benötigt Geburtszeit
    final hour = birthDateTime.hour;

    // Bestimme chinesische Stunde (0-11)
    // Rat = 23-01, Ox = 01-03, Tiger = 03-05, ...
    int chineseHour;

    if (hour >= 23 || hour < 1) {
      chineseHour = 0; // Rat
    } else if (hour >= 1 && hour < 3) {
      chineseHour = 1; // Ox
    } else if (hour >= 3 && hour < 5) {
      chineseHour = 2; // Tiger
    } else if (hour >= 5 && hour < 7) {
      chineseHour = 3; // Rabbit
    } else if (hour >= 7 && hour < 9) {
      chineseHour = 4; // Dragon
    } else if (hour >= 9 && hour < 11) {
      chineseHour = 5; // Snake
    } else if (hour >= 11 && hour < 13) {
      chineseHour = 6; // Horse
    } else if (hour >= 13 && hour < 15) {
      chineseHour = 7; // Goat
    } else if (hour >= 15 && hour < 17) {
      chineseHour = 8; // Monkey
    } else if (hour >= 17 && hour < 19) {
      chineseHour = 9; // Rooster
    } else if (hour >= 19 && hour < 21) {
      chineseHour = 10; // Dog
    } else {
      chineseHour = 11; // Pig
    }

    final branchIndex = chineseHour;

    // Stundensäule Stem hängt vom Tages-Stem ab
    final dayPillar = calculateDayPillar(birthDateTime);
    final dayStem = dayPillar['stem']!;
    final dayStemIndex = _heavenlyStems.indexOf(dayStem);

    // Formel für Stunden-Stem basierend auf Tages-Stem
    final hourStemOffset = (dayStemIndex * 2 + chineseHour) % 10;

    return {
      'stem': _heavenlyStems[hourStemOffset],
      'branch': _earthlyBranches[branchIndex],
      'element': _stemElements[_heavenlyStems[hourStemOffset]]!,
    };
  }

  /// Berechnet das dominante Element aus allen vier Säulen
  ///
  /// Zählt die Element-Vorkommen in allen Stems und Branches,
  /// gibt das häufigste Element zurück.
  static String calculateDominantElement({
    required Map<String, String> yearPillar,
    required Map<String, String> monthPillar,
    required Map<String, String> dayPillar,
    Map<String, String>? hourPillar,
  }) {
    final elementCounts = <String, int>{
      'Wood': 0,
      'Fire': 0,
      'Earth': 0,
      'Metal': 0,
      'Water': 0,
    };

    // Zähle Elemente aus allen Säulen
    void countPillar(Map<String, String> pillar) {
      final stemElement = _stemElements[pillar['stem']]!;
      final branchElement = _branchElements[pillar['branch']]!;

      elementCounts[stemElement] = (elementCounts[stemElement] ?? 0) + 1;
      elementCounts[branchElement] = (elementCounts[branchElement] ?? 0) + 1;
    }

    countPillar(yearPillar);
    countPillar(monthPillar);
    countPillar(dayPillar);
    if (hourPillar != null) countPillar(hourPillar);

    // Finde häufigstes Element
    String dominantElement = 'Wood';
    int maxCount = 0;

    elementCounts.forEach((element, count) {
      if (count > maxCount) {
        maxCount = count;
        dominantElement = element;
      }
    });

    return dominantElement;
  }

  // ============================================================
  // HELPER METHODS
  // ============================================================

  /// Gibt das Lichun-Datum (Frühlingsbeginn) für ein Jahr zurück
  ///
  /// Lichun ist der Solar Term bei Sonnen-Länge 315° (~3.-5. Februar)
  /// und markiert den Beginn des chinesischen Solarjahres.
  static DateTime _getLichunDate(int year) {
    if (_lichunDates.containsKey(year)) {
      return DateTime.parse(_lichunDates[year]!);
    }

    // Fallback: 4. Februar als Annäherung
    return DateTime(year, 2, 4);
  }

  /// Berechnet die Julian Day Number (JD) für präzise Tagesberechnung
  ///
  /// WICHTIG: Nutzt LOKALE Zeit, nicht UTC!
  /// Bazi basiert auf Solar Time am Geburtsort, nicht auf UTC.
  static double _calculateJulianDay(DateTime dateTime) {
    // NICHT zu UTC konvertieren - lokale Zeit verwenden!
    int year = dateTime.year;
    int month = dateTime.month;
    final day = dateTime.day;
    final hour = dateTime.hour;
    final minute = dateTime.minute;
    final second = dateTime.second;

    if (month <= 2) {
      year -= 1;
      month += 12;
    }

    final A = (year / 100).floor();
    final B = 2 - A + (A / 4).floor();

    final JD = (365.25 * (year + 4716)).floor() +
        (30.6001 * (month + 1)).floor() +
        day +
        (hour + minute / 60.0 + second / 3600.0) / 24.0 +
        B -
        1524.5;

    return JD;
  }
}
