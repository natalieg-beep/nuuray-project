/// Sternzeichen-Übersetzungen
///
/// Mapt englische Sternzeichen-Keys zu lokalisierten Namen
class ZodiacNames {
  ZodiacNames._();

  /// Deutsche Sternzeichen-Namen
  static const Map<String, String> de = {
    'aries': 'Widder',
    'taurus': 'Stier',
    'gemini': 'Zwillinge',
    'cancer': 'Krebs',
    'leo': 'Löwe',
    'virgo': 'Jungfrau',
    'libra': 'Waage',
    'scorpio': 'Skorpion',
    'sagittarius': 'Schütze',
    'capricorn': 'Steinbock',
    'aquarius': 'Wassermann',
    'pisces': 'Fische',
  };

  /// Englische Sternzeichen-Namen
  static const Map<String, String> en = {
    'aries': 'Aries',
    'taurus': 'Taurus',
    'gemini': 'Gemini',
    'cancer': 'Cancer',
    'leo': 'Leo',
    'virgo': 'Virgo',
    'libra': 'Libra',
    'scorpio': 'Scorpio',
    'sagittarius': 'Sagittarius',
    'capricorn': 'Capricorn',
    'aquarius': 'Aquarius',
    'pisces': 'Pisces',
  };

  /// Gibt lokalisierten Sternzeichen-Namen zurück
  static String getName(String sign, String locale) {
    final map = locale == 'de' ? de : en;
    return map[sign.toLowerCase()] ?? sign;
  }
}
